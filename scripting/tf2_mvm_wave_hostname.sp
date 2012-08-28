#pragma semicolon 1

#include <sourcemod>
#include <string>

#define PLUGIN_VERSION "1.0.0"

new Handle:g_hHostname = INVALID_HANDLE;
new Handle:g_hDynamicHostname = INVALID_HANDLE;
new currentWave = 0;
new currentMaxWave = 0;

public Plugin:myinfo =  
{
	name = "TF2 MvM Wave Hostname",
	author = "kimoto",
	description = "auto change hostname by current/max wave number",
	version = PLUGIN_VERSION,
	url = "http://kymt.me/"
};

public OnPluginStart()
{
  // hostnameに設定されたテンプレート文字を変換する
  // ex: %wave %max_waves
  g_hHostname = FindConVar("hostname");
  g_hDynamicHostname = CreateConVar("sm_tf2_mvm_wave_hostname", ".", "..", FCVAR_PLUGIN);
  LogMessage("start mvm waver!!");
  HookEvent("mvm_begin_wave", Event_BeginWave, EventHookMode_Pre);
}

public UpdateHostname(wave, maxWaves)
{
  decl String:sWave[32];
  decl String:sMaxWaves[32];
  decl String:buffer[128];
  decl String:hostname[128];

  GetConVarString(g_hDynamicHostname, hostname, sizeof(hostname));
  strcopy(buffer, sizeof(buffer), hostname);

  IntToString(wave, sWave, sizeof(sWave));
  ReplaceString(buffer, sizeof(buffer), "%wave", sWave);

  IntToString(maxWaves, sMaxWaves, sizeof(sMaxWaves));
  ReplaceString(buffer, sizeof(buffer), "%max_wave", sMaxWaves);

  DebugPrint("%s", buffer);
  SetConVarString(g_hHostname, buffer);
}

public Action:Event_BeginWave(Handle:event, const String:name[], bool:dontBroadcast)
{
  new waveIndex = GetEventInt(event, "wave_index");
  new maxWaves = GetEventInt(event, "max_waves");
  DebugPrint("wave: %d, max: %d", waveIndex, maxWaves);

  currentWave = waveIndex + 1;
  currentMaxWave = maxWaves;
  UpdateHostname(currentWave, currentMaxWave);

  return Plugin_Continue;
}

public DebugPrint(const String:Message[], any:...)
{
  decl String:DebugBuff[256];
  VFormat(DebugBuff, sizeof(DebugBuff), Message, 2);
  LogMessage(DebugBuff);
}

