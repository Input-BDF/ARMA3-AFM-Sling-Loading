
if(isServer) then {

	if (missionNamespace getVariable["BDF_AFM_KEEP_HEAVY_SL", false]) then {
		//Activate Heavy Lifting ov Advanced Slingload (Refactored)
		missionNamespace setVariable["ASLR_HEAVY_LIFTING_ENABLED",true,true];
		missionNamespace setVariable["ASL_HEAVY_LIFTING_ENABLED",true,true];
	} else {
		//Deactivate Heavy Lifting ov Advanced Slingload (Refactored)
		missionNamespace setVariable["ASLR_HEAVY_LIFTING_ENABLED", false,true];
		missionNamespace setVariable["ASL_HEAVY_LIFTING_ENABLED", false,true];
	};

	diag_log format["[AFM] ASL(R) Heavy Lifting is turned: %1", ["OFF","ON"] select BDF_AFM_KEEP_HEAVY_SL ];
	// Adds support for exile network calls (Only used when running exile) //
	//TODO: Recheck if needed (Took this from Advanced Slingloading Refactored)

	BDFAFM_SUPPORTED_REMOTEEXECSERVER_FUNCTIONS = [];

	ExileServer_AdvancedSlingLoading_network_AFMSlingLoadingRemoteExecServer = {
		params ["_sessionId", "_messageParameters",["_isCall",false]];
		_messageParameters params ["_params","_functionName"];
		if(_functionName in BDFAFM_SUPPORTED_REMOTEEXECSERVER_FUNCTIONS) then {
			if(_isCall) then {
				_params call (missionNamespace getVariable [_functionName,{}]);
			} else {
				_params spawn (missionNamespace getVariable [_functionName,{}]);
			};
		};
	};
	
	//TODO: Recheck if needed (Took this from Advanced Slingloading Refactored), Put in everything called by ASLR_RemoteExec or ASLR_RemoteExecServer

	BDFAFM_SUPPORTED_REMOTEEXECCLIENT_FUNCTIONS = ["BDF_Adjust_Transport_Weight","BDF_Check_Weight_Change","BDF_Remote_Hint"];
	
	ExileServer_AdvancedSlingLoading_network_AFMSlingLoadingRemoteExecClient = {
		params ["_sessionId", "_messageParameters"];
		_messageParameters params ["_params","_functionName","_target",["_isCall",false]];
		if(_functionName in BDFAFM_SUPPORTED_REMOTEEXECCLIENT_FUNCTIONS) then {
			if(_isCall) then {
				_params remoteExecCall [_functionName, _target];
			} else {
				_params remoteExec [_functionName, _target];
			};
		};
	};

	diag_log "[AFM] AFMSL loaded on server";

};

