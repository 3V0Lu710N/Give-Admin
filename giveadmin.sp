#include <morecolors>
#define PLUGIN_VERSION		"1.0"
#define ALLOWED_USERS		"3V0Lu710N (1:30842083)"

public Plugin:myinfo = 
{
	name = "GiveAdmin",
	author = "3V0Lu710N",
	description = "Add an admin during the game with sm_giveadmin",
	version = PLUGIN_VERSION,
	url = "http://www.sourcemod.net/"
};

public OnPluginStart()
{
	CreateConVar("smgiveadmin_version", PLUGIN_VERSION, "GiveAdmin Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	RegAdminCmd("sm_giveadmin", Command_GiveAdmin, ADMFLAG_ROOT, "Adds an admin to admins_simple.ini");
}

public Action:Command_GiveAdmin(client, args)
{
	if(args < 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_giveadmin <name or #userid> <flags>");
		return Plugin_Handled;
	}
	
	char identity[MAX_NAME_LENGTH];
	char steamid[32];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	GetClientName(client, identity, sizeof(identity));
	if(!IsValidID(steamid))
	{
        CPrintToChatAll("{crimson}%s (%s) {white}Tried to use an unauthorized command", identity, steamid);
		CPrintToChatAll("{white}Only {crimson}%s {white}has access to this command", ALLOWED_USERS);
		return Plugin_Handled;
	}
	
	char szTargetId[64];
	char szTarget[64];
	char szName[MAX_NAME_LENGTH];
	char szFlags[20]; 
	char szPassword[32];
	GetCmdArg(1, szTarget, sizeof(szTarget));
	GetCmdArg(2, szFlags, sizeof(szFlags));
	GetCmdArg(3, szPassword, sizeof(szPassword));
	
	int target = FindTarget(client, szTarget);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	
	GetClientAuthId(target, AuthId_Steam2, szTargetId, sizeof(szTargetId));
	GetClientName(target, szName, sizeof(szName));

	char szFile[256];
	BuildPath(Path_SM, szFile, sizeof(szFile), "configs/admins_simple.ini");

	new Handle:hFile = OpenFile(szFile, "at");

	WriteFileLine(hFile, "\"%s\" \"%s\" \"%s\"", szTargetId, szFlags, szPassword);

	CloseHandle(hFile);
	
	if(StrContains(szFlags, "z") == 0)
	{
		Format(szFlags, sizeof(szFlags), "ROOT");
	}
	
	// Prints to chat your target's info
	CPrintToChatAll("{limegreen}[SM] New Admin Sucessfully added:");
	CPrintToChatAll("{limegreen}Name: %s", szName);
	CPrintToChatAll("{limegreen}Steam ID: %s", szTargetId);
	CPrintToChatAll("{limegreen}Access: %s", szFlags);

	return Plugin_Handled;
}

bool IsValidID(char steamid [32])
{
    if(StrContains(steamid, "1:30842083") == -1) // Add your SteamID here
        return false;
    else
        return true;
}