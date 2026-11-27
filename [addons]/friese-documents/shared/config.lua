Documents = {}
Documents.Config = {
    Command = 'documenten',
    ShowCommand = 'toondocument',
    Distance = 3.0,
    Types = {
        id = { label = 'Identiteitskaart', fields = {'name','birthdate','gender','citizenid'} },
        driver = { label = 'Rijbewijs', fields = {'name','citizenid','status','issued'} },
        weapon = { label = 'Wapenvergunning', fields = {'name','citizenid','status','issued'} }
    }
}
