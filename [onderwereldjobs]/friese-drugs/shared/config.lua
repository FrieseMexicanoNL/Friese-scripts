Config={ProcessDistance=4.0,BuyerDistance=4.0,PoliceJobs={police=true},MinPolice=0,SaleCooldown=3,SecretLocations={
 {label='Achteraf locatie Noord',coords=vector3(1391.0,3605.0,38.9),radius=3.0},
 {label='Industriegebied',coords=vector3( -110.0, -2660.0, 6.0),radius=3.0}
},Buyers={
 {coords=vector3( -1172.0,-1572.0,4.6),radius=3.0,priceMultiplier=1.0},
 {coords=vector3(  1692.0,3761.0,34.7),radius=3.0,priceMultiplier=1.1}
},Drugs={
 weed={label='Cannabis',stages={{input='cannabis_leaf',count=5,output='cannabis_dried',out=2,label='Drogen'},{input='cannabis_dried',count=2,output='cannabis_bag',out=2,label='Verpakken'}},price=180,harvest='cannabis_seed',harvestOut='cannabis_leaf'},
 cocaine={label='Cocaïne',stages={{input='coca_leaf',count=6,output='coca_paste',out=2,label='Verwerken'},{input='coca_paste',count=2,output='cocaine_powder',out=2,label='Drogen'},{input='cocaine_powder',count=2,output='cocaine_bag',out=2,label='Verpakken'}},price=420,harvest='coca_seed',harvestOut='coca_leaf'},
 meth={label='Methamfetamine',stages={{input='chemical_mix',count=4,output='meth_crystal',out=2,label='Kristalliseren'},{input='meth_crystal',count=2,output='meth_bag',out=2,label='Verpakken'}},price=520,harvest='chemical_kit',harvestOut='chemical_mix'},
 heroin={label='Heroïne',stages={{input='poppy_flower',count=5,output='opium_raw',out=2,label='Verwerken'},{input='opium_raw',count=2,output='heroin_bag',out=2,label='Verpakken'}},price=500,harvest='poppy_seed',harvestOut='poppy_flower'},
}
}
