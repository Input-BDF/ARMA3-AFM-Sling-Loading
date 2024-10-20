/*
Sticky note for filepatching
call compile preProcessFileLineNumbers "\x\BDF\addons\afmslingloading\functions\afmsl_client_init.sqf";
*/


BDF_RemoteExec = {
	/* RemoteExec from Advanced Slingloading Refactored */
	params ["_params","_functionName","_target",["_isCall",false]];
	if(!isNil "ExileClient_system_network_send") then {
		["AFMSlingLoadingRemoteExecClient",[_params,_functionName,_target,_isCall]] call ExileClient_system_network_send;
	} else {
		if(_isCall) then {
			_params remoteExecCall [_functionName, _target];
		} else {
			_params remoteExec [_functionName, _target];
		};
	};
};

BDF_RemoteExecServer = {
	/* RemoteExecServer From Advanced Slingloading Refactored */
	params ["_params","_functionName",["_isCall",false]];
	if(!isNil "ExileClient_system_network_send") then {
		["AFMSlingLoadingRemoteExecServer",[_params,_functionName,_isCall]] call ExileClient_system_network_send;
	} else {
		if(_isCall) then {
			_params remoteExecCall [_functionName, 2];
		} else {
			_params remoteExec [_functionName, 2];
		};
	};
};

BDF_Remote_Hint = {
	/*Hint function from advance slingloading refactored*/
    params ["_msg",["_isSuccess",true]];
    if(!isNil "ExileClient_gui_notification_event_addNotification") then {
		if(_isSuccess) then {
			["Success", [_msg]] call ExileClient_gui_notification_event_addNotification; 
		} else {
			["Whoops", [_msg]] call ExileClient_gui_notification_event_addNotification; 
		};
    } else {
        hint _msg;
    };
};

BDF_Adjust_Transport_Weight = {
	/*
	* Adjust Cargo an heli weight by given values
		_helo: Helicopter - object
		_cargo: Cargo - object
		_CargoMass: Mass cargo should have - int
		_CargoRTDMass: Mass cargo is represented for RTD weight - int
		_reset: Reset to original masses - bool
	*/
	params ["_helo", "_cargo", "_CargoMass", "_CargoRTDMass", "_reset"];

	_curRTDWeight = ( weightRTD _helo ) select 3;
	_newRTDWeight = _curRTDWeight + ( _CargoRTDMass * ( [1,-1] select _reset ) );
	_cargo setMass[ _CargoMass , 0.5];
	_helo setCustomWeightRTD ( [ 0, _newRTDWeight ] select ( _newRTDWeight >= 0 ) ); //only set if not new weight is not negative; set to 0 if something went wrong
	_cargo setVariable ["BDFAFM_Cargo_Override", [true, false] select _reset ];

	[ 
		[
			format["AFM vehicle weight %1\n
			Helo: %2\n
			Cargo weight: %3",
			["overridden","resetted"] select _reset,
			[ [weightRTD _helo] call BDF_Get_Total] call BDF_Conv_Weight_To_Str ,
			[_CargoMass] call BDF_Conv_Weight_To_Str],
			false
		],
		"BDF_Remote_Hint",
		driver _helo
	] call BDF_RemoteExec;
};

BDF_Conv_Weight_To_Str = {
	/* form string from weight in Kg return as Tons */
	params ["_weigth"];
	_str = format["%1t", ( round( _weigth /100) ) / 10 ];
	_str;
};

BDF_Get_Total = {
	params ["_weights"];
	_total = 0;
	{_total = _total + _x} forEach _weights;
	_total;
};

BDF_Get_Weights = {
	params ["_cargo"];
	_origCargoMass = getMass _cargo;
	_newCargoMass = round (_origCargoMass / BDF_AFM_CARGO_FACTOR); //round to prevent ugly numbers. Nobody gares about some grams
	_newCargoRTDMass = 0;
	if( BDF_AFM_RTDCARGO_FACTOR > 0) then {
		_newCargoRTDMass = round ( _origCargoMass / BDF_AFM_RTDCARGO_FACTOR ); //round prevent ugly numbers. Nobody gares about some grams
	};
	[_origCargoMass, _newCargoMass, _newCargoRTDMass];
};

BDF_Check_Weight_Change = {
	/*
	* Loop function constantly checking cargo for weight adjustment
	* 	_helo: Helicopter - object
	*	_cargo: Cargo - object
	*/
	params ["_helo", "_cargo"];

	_newWeights = _cargo call BDF_Get_Weights;
	_origCargoMass = _newWeights select 0; 
	_newCargoMass = _newWeights select 1;
	_newCargoRTD = _newWeights select 2;

	[[format["This weights %1.", [_origCargoMass] call BDF_Conv_Weight_To_Str ], false],"BDF_Remote_Hint", clientOwner] call BDF_RemoteExec;

	while { _cargo in (ropeAttachedObjects _helo) } do {
		if ( ( difficultyEnabledRTD ) && ( ( position _helo ) select 2 ) > 1 ) then {
			_cargoOverride = _cargo getVariable ["BDFAFM_Cargo_Override", false];
			_ropes = ropes _helo;
			_firstrope = _ropes select 0;
			_cargo_ropes = _cargo getVariable ["BDFAFM_CARGO_Ropes", []] arrayIntersect ropes _helo;
			//Get rope with most distant mount point. Looks ugly but...
			_sortedRopes = [_cargo_ropes, [], { ( ropeEndPosition (_x) select 0 ) distance ( ropeEndPosition (_x) select 0 ) }, "DESCEND"] call BIS_fnc_sortBy;
			_distantRope = _sortedRopes select 0;
			_ropeEnds = ropeEndPosition _distantRope;
			_distance = ( _ropeEnds select 0 ) distance (_ropeEnds select 1);
			_length = ( ropeLength _distantRope ) - BDF_AFM_ROPE_TOLERANCE;
			if ( ( _distance >= _length ) && !( _cargoOverride ) ) then {
				// Rope is tight but transports have original weight
				[[_helo, _cargo, _newCargoMass, _newCargoRTD, false], "BDF_Adjust_Transport_Weight", _helo , true] call BDF_RemoteExec;
			};
			if ( ( _distance < _length ) && ( _cargoOverride ) ) then {
				// Rope is not tight and transports should have original weight (again)
				[[_helo, _cargo, _origCargoMass, _newCargoRTD, true], "BDF_Adjust_Transport_Weight", _helo , true] call BDF_RemoteExec;
			};
		};
		//TODO implement amplification based on container height 0.5 + x*int(Cargo[ZPOS])
		sleep 0.5;
	};

	//if( !( _cargo in (ropeAttachedObjects _helo) ) && ( _cargo getVariable ["BDFAFM_Cargo_Override", false] ) ) then {
	if!( _cargo in (ropeAttachedObjects _helo) ) then {
		//In Case cargo was lost without landing or rope was to tight on release
		[[_helo, _cargo, _origCargoMass, _newCargoRTD, true], "BDF_Adjust_Transport_Weight", _helo , true] spawn BDF_RemoteExec;
		_cargo setVariable ["BDFAFM_Rope_Attached", false]; //reset knowlede ropes attached (may be redundant due to BDFAFM_CARGO_Ropes)
		_cargo setVariable ["BDFAFM_CARGO_Ropes", []]; //empty known ropes array
		[["Cargo released.", true],"BDF_Remote_Hint", driver _helo] call BDF_RemoteExec;
	};
};

BDF_react_on_attach_EH = {
	/*
	* react on ropes attached to heli Eventhandler
    *		_helo: 	Object - object to which the event handler is assigned. (Helicopter in this case)
    *		_rope: 		Object - the rope being attached between object 1 and object 2.
    *		_cargo: 	Object - the object that is being attached to object 1 via rope.	
	*/
	params ["_helo", "_rope", "_cargo"];

	if( !isNull _helo && !isNull _cargo  && isObjectRTD _helo && !( _cargo isKindOf "Land_Can_V2_F" ) ) then {
		//	Vehicle has RTD capability
		//	Vehicle is not Adv. Sling Load Helper Object
		_ropes = ( _cargo getVariable ["BDFAFM_CARGO_Ropes", []] );
		_ropes pushBack _rope;
		_cargo setVariable ["BDFAFM_CARGO_Ropes", _ropes ];

		if!( _cargo getVariable ["BDFAFM_Rope_Attached",false] ) then {
			_cargo setVariable ["BDFAFM_Rope_Attached",true];
			//Excecute everything on the position the client is connectet
			[[_helo, _cargo],"BDF_Check_Weight_Change", _helo, false] spawn BDF_RemoteExec //must be unscheduled as it contains sleep
		};
	};
};

BDF_react_on_getin_EH = {
	/*
	*	React on players get into vehicle
	* 	EventHandler delivers:
    *	unit: 		Object - unit the event handler is assigned to
    *	role: 		String - can be either "driver", "gunner" or "cargo"
    *	vehicle: 	Object - vehicle the unit entered
    *	turret: 	Array - turret path
	*/
	params ["_unit", "_role", "_vehicle", "_turret"];
	if( (_vehicle isKindOf "Helicopter") && !( _vehicle getVariable ["BDFAFM_EH_active",false] ) ) then {
		//TODO: maybe consider BIS_fnc_helicopterType
		[_vehicle] call BDF_Helo_Add_Event_Handler;
		_vehicle setVariable ["BDFAFM_EH_active",true];
		diag_log format["Got in, Owner: %1", clientOwner];
		[["Vehicle weight handled by AFM SL.", false],"BDF_Remote_Hint", _unit] call BDF_RemoteExec;
		diag_log format["Got in, Owner: %1", clientOwner];
	};

	//TODO: Also check here Cargo and Call BDF_react_on_attach_EH for each in case cargo was not initialized. Is somehow tricky cause I dont know which rope belongs to the cargo
};

BDF_Helo_Add_Event_Handler = {
	/* 
	* Attach EH to helicopter
	* _helo:	vehicle EH is targeted
	*/
	params["_helo"];
	_helo addEventHandler ["RopeAttach", {[(_this select 0),(_this select 1),(_this select 2)] spawn BDF_react_on_attach_EH;}];
	/*
	//Reset EH knowledge on respawn
	*/
	_helo addMPEventHandler ["MPKilled", {
		_newHelo = _this select 0;
		_newHelo setVariable ["BDFAFM_EH_active",false];
	}];
	[["Vehicle weight handled by AFM SL.", false],"BDF_Remote_Hint", driver _helo] call BDF_RemoteExec;
};

BDF_Player_Add_Event_Handler = {
	/*
	* Add GetInMan EH to player 
	* "short" way to somewhen init helicopter to reacht on it's own EH
	* direct rope interaction is handled via _helper in Adv Slingload, so you won't know if player has a rope
	*/
	player addEventHandler ["GetInMan", {[(_this select 0),(_this select 1),(_this select 2),(_this select 4)] spawn BDF_react_on_getin_EH;}];
	/*
	* TODO: consider
	* ControlsShifted params ["_vehicle", "_activeCoPilot", "_oldController"];
	* SeatSwitched params ["_vehicle", "_unit1", "_unit2"];
	* SeatSwitchedMan params ["_unit1", "_unit2", "_vehicle"];
	*/
	//Reset EH knowledge on respawn
	player addEventHandler ["Respawn", {
		player setVariable ["BDFAFM_EH_active",false];
	}];
};

diag_log '[AFM] AFMSL loading on client';

// runloop for the sling loading change behavior
[] spawn {
	while {true} do {
		if(!isNull player && isPlayer player) then {
			if!( player getVariable ["BDFAFM_EH_active",false] ) then {
				[] call BDF_Player_Add_Event_Handler;
				player setVariable ["BDFAFM_EH_active",true];
			};
		};
		//can wait a long time since this won't happen often
		sleep 30;
	};
};

diag_log '[AFM] AFMSL loaded on client';