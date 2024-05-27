program GameServer;

{$APPTYPE CONSOLE}

{$R *.res}

//{$INLINE AUTO}

uses
  System.SysUtils,
  Generics.Collections,
  ClientConnection in 'Connection\ClientConnection.pas',
  ServerSocket in 'Connection\ServerSocket.pas',
  GlobalDefs in 'Data\GlobalDefs.pas',
  MiscData in 'Data\MiscData.pas',
  Packets in 'Data\Packets.pas',
  PlayerData in 'Data\PlayerData.pas',
  Funcoes in 'Functions\Funcoes.pas',
  Functions in 'Functions\Functions.pas',
  ItemFunctions in 'Functions\ItemFunctions.pas',
  Load in 'Functions\Load.pas',
  Log in 'Functions\Log.pas',
  BaseMob in 'Mob\BaseMob.pas',
  NPC in 'Mob\NPC.pas',
  Player in 'Mob\Player.pas',
  NpcFunctions in 'PacketHandlers\NPCs\NpcFunctions.pas',
  NPCHandlers in 'PacketHandlers\NPCs\NPCHandlers.pas',
  CombatHandlers in 'PacketHandlers\Combat\CombatHandlers.pas',
  Commands in 'PacketHandlers\Commands.pas',
  PacketHandlers in 'PacketHandlers\PacketHandlers.pas',
  Volatiles in 'PacketHandlers\Volatiles.pas',
  BMBuffs in 'PacketHandlers\Combat\Skills\BeastMaster\BMBuffs.pas',
  FMBuffs in 'PacketHandlers\Combat\Skills\Foema\FMBuffs.pas',
  HTBuffs in 'PacketHandlers\Combat\Skills\Huntress\HTBuffs.pas',
  TKBuffs in 'PacketHandlers\Combat\Skills\TransKnight\TKBuffs.pas',
  Util in 'Functions\Util.pas',
  BuffsData in 'Data\BuffsData.pas',
  GuildFunctions in 'Functions\GuildFunctions.pas',
  BackgroundThread in 'Threads\BackgroundThread.pas',
  FiniteStateMachine in 'Mob\AI\FiniteStateMachine.pas',
  VisibleListBackgroundThread in 'Threads\VisibleListBackgroundThread.pas',
  AIBackgroundThread in 'Threads\AIBackgroundThread.pas',
  State in 'Mob\AI\State.pas',
  QuestsBackgroundThread in 'Threads\QuestsBackgroundThread.pas',
  VisibleDropListBackgroundThread in 'Threads\VisibleDropListBackgroundThread.pas',
  LoginDisconnectBackgroundThread in 'Threads\LoginDisconnectBackgroundThread.pas',
  SaveAccountsBackgroundThread in 'Threads\SaveAccountsBackgroundThread.pas',
  UpdateHpMpBackgroundThread in 'Threads\UpdateHpMpBackgroundThread.pas',
  WeatherChangeBackgroundThread in 'Threads\WeatherChangeBackgroundThread.pas',
  PositionUpdateBackgroundThread in 'Threads\PositionUpdateBackgroundThread.pas',
  AIStates in 'Mob\AIStates.pas',
  Agatha in 'PacketHandlers\NPCs\Janelas\Agatha.pas',
  Aylin in 'PacketHandlers\NPCs\Janelas\Aylin.pas',
  Compounder in 'PacketHandlers\NPCs\Janelas\Compounder.pas',
  Lindy in 'PacketHandlers\NPCs\Janelas\Lindy.pas',
  MestreGriffo in 'PacketHandlers\NPCs\Janelas\MestreGriffo.pas',
  Shany in 'PacketHandlers\NPCs\Janelas\Shany.pas',
  Tiny in 'PacketHandlers\NPCs\Janelas\Tiny.pas',
  AttackState in 'Mob\AI\States\AttackState.pas',
  IdleState in 'Mob\AI\States\IdleState.pas',
  PatrolState in 'Mob\AI\States\PatrolState.pas',
  PursuitState in 'Mob\AI\States\PursuitState.pas',
  ReviveNPCsBackgroundThread in 'Threads\ReviveNPCsBackgroundThread.pas',
  MobGenerData in 'Data\MobGenerData.pas',
  Position in 'Data\Position.pas',
  Generics.Nullable in 'Functions\Util\Generics.Nullable.pas',
  Winapi.Windows,
  DbServerConnection in 'Connection\DbServerConnection.pas',
  DbPacketHandlers in 'PacketHandlers\DbPacketHandlers.pas',
  PacketsDbServer in '..\DataBase Server\Data\PacketsDbServer.pas',
  EncDec in 'Connection\EncDec.pas',
  ThreadPingDbServer in 'Threads\ThreadPingDbServer.pas',
  PlayerDataClasses in 'Data\PlayerDataClasses.pas',
  ConstDefs in 'Data\ConstDefs.pas',
  InitialCharactersLoader in 'Data\InitialCharactersLoader.pas';

var
  stay: string;
  a: string;

function ConsoleEventProc(CtrlType: DWORD): BOOL; stdcall;
begin

  if (CtrlType = CTRL_CLOSE_EVENT) then
  begin
    if (Assigned(Server)) then
      Server.DisconnectAll;
    if (Assigned(DbClient)) then
      DbClient.Disconnect;
  end;

  Result := True;
end;

begin

  try
    SetConsoleCtrlHandler(@ConsoleEventProc, True);
    CurrentDir := ExtractFileDir(ParamStr(0));

    Logger := TLog.Create;

    if (not TLoad.CarregarConfiguracoes) then
      raise Exception.Create('Não foi possível ler o arquivo de configurações do servidor. Ou o arquivo não foi configurado corretamente');

    Server := TServerSocket.Create(ConfiguracoesGameServer.Porta);

    Neighbors[0] := TPosition.Create(0, 1);
    Neighbors[1] := TPosition.Create(0,-1);
    Neighbors[2] := TPosition.Create(1, 0);
    Neighbors[3] := TPosition.Create(-1,0);
    Neighbors[4] := TPosition.Create(1, 1);
    Neighbors[5] := TPosition.Create(-1,-1);
    Neighbors[6] := TPosition.Create(1,-1);
    Neighbors[7] := TPosition.Create(-1,1);

    NpcFuncs  := TNpcFunctions.Create;
    ItemFuncs := TItemFunctions.Create;

    PlayersNick    := TDictionary<string, word>.Create;

    TInitialCharactersLoader.Load;
    TLoad.ItemsList;
    TLoad.HeightMap;
    TLoad.MobBaby;
    TLoad.TeleportList;
    TLoad.SkillData;
    TLoad.GuildList;
    TLoad.QuestList;

    TLoad.MobList;

    DbClient := TDbServerConnection.Create(ConfiguracoesDbServer.Porta, ConfiguracoesDbServer.Ip);
    if not(DbClient.DbConnect) then
      raise Exception.Create('Ocorreu um erro ao se conectar com a DBServer');

    Server.StartServer;
    while(Server.IsActive) do
	  begin
      ReadLn(a);
    end;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      Readln(stay);
    end;
  end;
end.
