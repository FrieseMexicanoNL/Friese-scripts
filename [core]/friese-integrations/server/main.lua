local RESOURCE = GetCurrentResourceName()
local function debug(message)
    if FrieseIntegrations.Debug then print(('[%s] %s'):format(RESOURCE, message)) end
end

local function getPlayer(src)
    if GetResourceState('friese-core') ~= 'started' then return nil end
    local ok, result = pcall(function() return exports['friese-core']:GetPlayer(tonumber(src)) end)
    return ok and result or nil
end

local function identity(src)
    local p = getPlayer(src)
    local d = p and p.PlayerData or {}
    local c = d.charinfo or {}
    return {
        source = tonumber(src), citizenid = d.citizenid,
        name = (('%s %s'):format(c.firstname or '', c.lastname or '')):gsub('^%s*(.-)%s*$', '%1'),
        job = d.job and d.job.name or 'unemployed'
    }
end

local function log(category, actor, message, metadata)
    if GetResourceState(FrieseIntegrations.LogsResource) == 'started' then
        pcall(function() exports[FrieseIntegrations.LogsResource]:Write(category, actor, message, metadata or {}) end)
    end
    TriggerEvent('friese-integrations:server:logged', category, actor, message, metadata or {})
end

local function notify(src, message, kind, title)
    if not tonumber(src) or not GetPlayerName(tonumber(src)) then return false end
    TriggerClientEvent(FrieseIntegrations.NotifyEvent, tonumber(src), {
        title = title or 'Friese-Core', description = tostring(message), type = kind or 'info'
    })
    TriggerEvent('friese-integrations:server:notification', tonumber(src), message, kind or 'info', title or 'Friese-Core')
    return true
end

-- Public cross-resource API. All money changes go through Friese-Core's server exports.
local function chargePlayer(src, amount, reason, account)
    src, amount, account = tonumber(src), math.floor(tonumber(amount) or 0), account or FrieseIntegrations.InvoiceAccount
    if not src or amount < 1 or amount > FrieseIntegrations.MaxInvoice or not getPlayer(src) then return false, 'invalid_player_or_amount' end
    local ok, result = pcall(function() return exports['friese-core']:RemoveMoney(src, account, amount, reason or 'Friese-Core betaling') end)
    if not ok or not result then return false, 'payment_failed' end
    pcall(function() exports['friese-core']:SavePlayer(src) end)
    return true
end

local function createInvoice(issuer, target, amount, description, category)
    issuer, target = tonumber(issuer), tonumber(target)
    amount = math.floor(tonumber(amount) or 0)
    description = tostring(description or 'Factuur'):gsub('[%c]', ' '):sub(1, 180)
    category = tostring(category or 'general'):sub(1, 40)
    local from, to = issuer and identity(issuer), target and identity(target)
    if not from or not to or amount < 1 or amount > FrieseIntegrations.MaxInvoice then return false, 'invalid_invoice' end
    local id = MySQL.insert.await([[INSERT INTO friese_invoices
        (issuer_citizenid, target_citizenid, amount, description, category, status, due_at)
        VALUES (?, ?, ?, ?, ?, 'unpaid', DATE_ADD(NOW(), INTERVAL ? DAY))]],
        { from.citizenid, to.citizenid, amount, description, category, FrieseIntegrations.InvoiceDueDays })
    log('invoice', from.citizenid, ('Factuur #%s aangemaakt voor %s (€%s)'):format(id, to.citizenid or 'onbekend', amount), {invoiceId=id, target=to.citizenid, category=category})
    notify(target, ('Je hebt een factuur ontvangen van €%s: %s'):format(amount, description), 'info', 'Nieuwe factuur')
    TriggerEvent('friese-integrations:server:invoiceCreated', id, from, to, amount, description, category)
    return true, id
end

local function payInvoice(src, invoiceId)
    src, invoiceId = tonumber(src), tonumber(invoiceId)
    local p = getPlayer(src)
    if not p or not invoiceId then return false, 'invalid_request' end
    local row = MySQL.single.await('SELECT * FROM friese_invoices WHERE id = ? AND target_citizenid = ? AND status = \'unpaid\' LIMIT 1', { invoiceId, p.PlayerData.citizenid })
    if not row then return false, 'invoice_not_found' end
    local ok, err = chargePlayer(src, row.amount, ('Factuur #%s'):format(invoiceId), FrieseIntegrations.InvoiceAccount)
    if not ok then return false, err end
    local changed = MySQL.update.await("UPDATE friese_invoices SET status='paid', paid_at=NOW() WHERE id=? AND status='unpaid'", { invoiceId })
    if changed ~= 1 then
        -- Defensive refund if another payment raced this invoice.
        exports['friese-core']:AddMoney(src, FrieseIntegrations.InvoiceAccount, row.amount, 'Factuur terugbetaling')
        exports['friese-core']:SavePlayer(src)
        return false, 'invoice_already_paid'
    end
    log('invoice', p.PlayerData.citizenid, ('Factuur #%s betaald (€%s)'):format(invoiceId, row.amount), {invoiceId=invoiceId})
    TriggerEvent('friese-integrations:server:invoicePaid', invoiceId, src, row)
    return true
end

exports('GetIdentity', identity)
exports('Notify', notify)
exports('Log', log)
exports('ChargePlayer', chargePlayer)
exports('CreateInvoice', createInvoice)
exports('PayInvoice', payInvoice)
exports('GetInvoices', function(src)
    local p = getPlayer(src); if not p then return {} end
    return MySQL.query.await('SELECT id, issuer_citizenid, amount, description, category, status, created_at, due_at, paid_at FROM friese_invoices WHERE target_citizenid = ? ORDER BY id DESC LIMIT 100', { p.PlayerData.citizenid }) or {}
end)

-- Unified event hooks: other resources can publish domain events without hard dependencies.
AddEventHandler('friese-core:server:playerLoaded', function(src, data)
    log('session', data and data.citizenid or 'unknown', 'Personage geladen', {source=src})
    TriggerEvent('friese-integrations:server:playerReady', src, data)
end)
AddEventHandler('friese-core:server:playerUnloaded', function(src, data)
    log('session', data and data.citizenid or 'unknown', 'Personage uitgelogd', {source=src})
end)
AddEventHandler('friese-core:server:moneyChanged', function(src, account, amount, action, reason)
    local who = identity(src)
    TriggerEvent('friese-integrations:server:moneyChanged', who, account, amount, action, reason)
end)
AddEventHandler('friese-core:server:jobUpdated', function(src, job)
    local who = identity(src)
    log('job', who.citizenid or 'unknown', ('Functie gewijzigd naar %s'):format(job and job.name or 'onbekend'), {source=src, job=job})
    TriggerEvent('friese-integrations:server:jobChanged', who, job)
end)
AddEventHandler('friese-dispatch:server:callCreated', function(call)
    log('dispatch', call and call.caller or 'unknown', 'Nieuwe noodmelding', {callId=call and call.id, category=call and call.category, message=call and call.message})
end)
AddEventHandler('friese-dispatch:server:callAccepted', function(call, src)
    local who = identity(src)
    log('dispatch', who.citizenid or who.name, 'Noodmelding aangenomen', {callId=call and call.id})
end)
AddEventHandler('friese-dispatch:server:callClosed', function(call, src)
    local who = identity(src)
    log('dispatch', who.citizenid or who.name, 'Noodmelding afgesloten', {callId=call and call.id})
end)

-- Domain event subscribers keep separate resources connected through one audit stream.
AddEventHandler('friese-police:server:fineRecorded', function(fineId, officer, target, amount, reason)
    local a, b = identity(officer), identity(target)
    log('police_fine', a.citizenid or 'unknown', ('Boete #%s voor %s (€%s)'):format(fineId or '?', b.citizenid or 'unknown', amount), {fineId=fineId, target=b.citizenid, amount=amount, reason=reason})
end)
AddEventHandler('friese-dealership:server:vehiclePurchased', function(src, citizenid, model, plate, price)
    log('vehicle', citizenid or 'unknown', ('Voertuig %s gekocht (%s) voor €%s'):format(model, plate, price), {source=src, model=model, plate=plate, price=price})
end)
AddEventHandler('friese-mechanic:server:serviceCompleted', function(src, citizenid, plate, service, cost)
    log('vehicle_service', citizenid or 'unknown', ('%s uitgevoerd aan %s (€%s)'):format(service, plate, cost), {source=src, plate=plate, service=service, cost=cost})
end)
AddEventHandler('friese-ambulance:server:treatmentCompleted', function(medicSrc, patientSrc, medicCid, patientCid, treatment)
    log('medical', medicCid or 'unknown', ('Behandeling %s uitgevoerd bij %s'):format(treatment, patientCid or 'unknown'), {medicSource=medicSrc, patientSource=patientSrc, patientCitizenId=patientCid, treatment=treatment})
end)
AddEventHandler('friese-impound:server:vehicleImpounded', function(src, plate, ownerCid, reason, fee)
    log('impound', ownerCid or 'unknown', ('Voertuig %s in beslag genomen'):format(plate), {officerSource=src, reason=reason, fee=fee})
end)

RegisterCommand('facturen', function(src)
    if src == 0 then return end
    local p = getPlayer(src); if not p then return end
    local rows = exports[RESOURCE]:GetInvoices(src)
    notify(src, ('Je hebt %s factuur/facturen. Gebruik /betaalfactuur [id].'):format(#rows), 'info', 'Friese Banking')
    for _, row in ipairs(rows) do
        TriggerClientEvent('chat:addMessage', src, {args={'Factuur #' .. row.id, ('€%s | %s | %s'):format(row.amount, row.description, row.status)}})
    end
end, false)
RegisterCommand('betaalfactuur', function(src, args)
    if src == 0 then return end
    local ok, err = payInvoice(src, args[1])
    notify(src, ok and 'Factuur betaald.' or ('Factuur niet betaald: %s'):format(err or 'onbekend'), ok and 'success' or 'error', 'Friese Banking')
end, false)

-- Cross-system invoice command for citizens; UI can call the same server export.
RegisterNetEvent('friese-integrations:server:payInvoice', function(invoiceId)
    local src = source
    local ok, err = payInvoice(src, invoiceId)
    notify(src, ok and 'Factuur succesvol betaald.' or ('Betaling mislukt: %s'):format(err or 'onbekend'), ok and 'success' or 'error', 'Facturen')
end)

-- Small server-side health report for administrators and diagnostics.
exports('HealthCheck', function()
    local resources = { 'friese-core','friese-logs','friese-banking','friese-police','friese-meos','friese-dispatch','friese-phone','friese-garage','friese-dealership','friese-impound','friese-ambulance','friese-hospital' }
    local status = {}
    for _, name in ipairs(resources) do status[name] = GetResourceState(name) end
    return { resource = RESOURCE, dependencies = status, database = GetResourceState('oxmysql') }
end)

CreateThread(function()
    Wait(1000)
    print('^4[Friese-Core]^7 Integratielaag gestart. Cross-resource API beschikbaar.')
    debug('Integration API ready')
end)
