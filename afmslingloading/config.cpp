class CfgPatches
{
	class BDF_AFMSlingLoading
	{
		name="AFM Sling Loading";
		author = "Input [BDF]";
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = 
		{
			"CBA_Extended_EventHandlers",
			"CBA_MAIN"
		};
	};
};

class CfgFunctions
{
	class BDF
	{
		class Functions
		{
			class initAFMSLClient { file = "x\BDF_addons_afmslingloading\functions\afmsl_client_init.sqf"; };
      class initAFMSLServer  { file = "x\BDF_addons_afmslingloading\functions\afmsl_server_init.sqf"; };
      class initAFMSLSettings { file = "x\BDF_addons_afmslingloading\functions\afmsl_client_settings_init.sqf"; };
		};
	};
};

/*
Allowed targets:
  0 - can target all machines (default)
  1 - can only target clients, execution on the server is denied
  2 - can only target the server, execution on clients is denied
  Any other value will be treated as 0.
*/
class CfgRemoteExec
{
  class Functions
  {
    mode = 1;
	  // Set allowed remote exec funtions //see e.g.: https://github.com/ryantownshend/advanced_sling_loading_refactored?tab=readme-ov-file#multiplayer-refactor-notes
    class BDF_Adjust_Transport_Weight   	{ allowedTargets=0; };
    class BDF_Check_Weight_Change       	{ allowedTargets=0; };
    class BDF_fnc_initAFMSLClient         { allowedTargets=1; };
    class BDF_Remote_Hint                	{ allowedTargets=1; };
  };
};

class Extended_PreInit_EventHandlers {
  class ADDON {
    init = "[] call BDF_fnc_initAFMSLSettings";
  };
  class AFMSlingLoading {
    //execute only on server
    serverinit = "[] spawn BDF_fnc_initAFMSLServer";
    //execute only on client
    clientInit = "if (hasInterface) then { [] spawn { waitUntil {!isNull player}; [] remoteExec ['BDF_fnc_initAFMSLClient', player] }; };";
  };
};