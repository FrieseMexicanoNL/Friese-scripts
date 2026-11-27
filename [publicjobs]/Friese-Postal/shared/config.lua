Config = {
    JobId = 'postal', Label = 'Postbezorging', Action = 'Pakket bezorgen',
    MinPay = 130, MaxPay = 240, PayoutAccount = 'cash',
    InteractionDistance = 3.0, StopCooldown = 8, MaxDistance = 8.0,
    ItemReward = { name = 'parcel', min = 1, max = 2 },
    Route = {
    { x=-32.00, y=-151.00, z=57.00 },
    { x=115.00, y=-1462.00, z=29.00 },
    { x=250.00, y=-1730.00, z=29.00 },
    { x=430.00, y=-800.00, z=29.00 }
    }
}
