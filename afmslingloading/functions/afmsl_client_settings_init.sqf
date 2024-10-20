diag_log "[AFM] Registering settings.";
//Settings
/*
BDF_AFM_CARGO_FACTOR = 4;
BDF_AFM_RTDCARGO_FACTOR = 4;
BDF_AFM_ROPE_TOLERANCE = 3;

***Assumption:***
CH-67 weights ingame with fuel etc. ~12t. It. Provides lift till ~15t. More than 15-16t --> cant lift.
From the Specs of CH-47D (Wikipedia): 
Weight empty: 10.185kg
Trainload: 12.700kg

Weight total: 22.885kg (this should nearly not move upwards)

weightRTD heli eg. shows: [10000, 100, 1088,0,30]

I assume, that maximumLoad = 6000; value somehow made it's way into the RTD calculations instead of slingLoadMaxCargoMass = 12000; where the helo does not provide lift anymore
*/

//Settings using CBA
[
	"BDF_AFM_CARGO_FACTOR",
	"LIST",
	["Cargo Weight Factor", "Factor cargo weight is adjusted (devided) on sling"],
	"BDF - AFM Sling Loading",
	[[10,5,4,3,2,1], ["1/10","1/5", "1/4", "1/3", "1/2", "1:1"], 2],
	true, //global
	nil,
	true // needs restart
] call CBA_fnc_addSetting;
//] call cba_settings_fnc_init;

[
	"BDF_AFM_RTDCARGO_FACTOR",
	"LIST",
	["RTD Weight Factor", "Factor Cargos weight is added to RTDs custom weight on sling.\n e.g.: Factor = 1/2 Cargo = 7.5t RTD weight = 3.75t"],
	"BDF - AFM Sling Loading",
	[[10,5,4,3,2,1,0], ["1/10","1/5", "1/4", "1/3", "1/2", "1:1","Deactivate"], 2],
	true, //global
	nil,
	true // needs restart
] call CBA_fnc_addSetting;
//] call cba_settings_fnc_init;

[
	"BDF_AFM_ROPE_TOLERANCE",
	"LIST",
	["Rope Tolerance", "Distance before rope is tight (aka Weight switch)"],
	"BDF - AFM Sling Loading",
	[[5,4,3,2,1], ["5m", "4m", "3m", "2m", "1m"], 2],
	true, //global
	nil,
	true // needs restart
] call CBA_fnc_addSetting;

[
	"BDF_AFM_KEEP_HEAVY_SL",
	"CHECKBOX",
	["Allow Adv. Sling Loading Heavy Lift", "Adv. Sling Loading can allow heavy lift and overwrites all heavy weight with 5000kg.\n Keeping this active sabotages AFM Sling Load usage"],
	"BDF - AFM Sling Loading",
	false,
	true, //global
	{ BDF_AFM_KEEP_HEAVY_SL = _this; },
	true // needs restart
] call CBA_fnc_addSetting;