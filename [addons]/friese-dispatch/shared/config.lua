Config = {}
Config.Command = '112'
Config.DispatchCommand = 'meldkamer'
Config.CooldownSeconds = 45
Config.MaxMessageLength = 240
Config.DispatchJobs = { police = true, ambulance = true }
Config.JobLabels = { police = 'Politie', ambulance = 'Ambulance' }
Config.Blip = { sprite = 280, colour = 3, scale = 1.0, duration = 120 }
Config.Text = {
  noMessage = 'Vermeld kort waarvoor je hulp nodig hebt.',
  cooldown = 'Je kunt over %s seconden opnieuw een melding maken.',
  sent = 'Je 112-melding is verzonden.',
  noPermission = 'Je hebt geen toegang tot de meldkamer.',
  accepted = 'Je hebt de melding aangenomen.',
  taken = 'Deze melding is al aangenomen door een collega.'
}
