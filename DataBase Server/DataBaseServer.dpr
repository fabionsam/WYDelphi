program DataBaseServer;

{$APPTYPE CONSOLE}

{$R *.res}

//{$INLINE AUTO}

uses
  System.SysUtils,
  Winapi.Windows,
  GlobalDefs in 'Data\GlobalDefs.pas',
  ServerSocket in 'Connection\ServerSocket.pas',
  Log in 'Functions\Log.pas',
  GameServer in 'Data\GameServer.pas',
  ClientConnection in 'Connection\ClientConnection.pas',
  Functions in 'Functions\Functions.pas',
  U_DMDataBase in 'Data\U_DMDataBase.pas' {DMDataBase: TDataModule},
  DbPacketHandlers in 'PacketHandlers\DbPacketHandlers.pas',
  PacketsDbServer in 'Data\PacketsDbServer.pas',
  EncDec in '..\Emulador Pascal Delphi\Connection\EncDec.pas',
  MiscData in '..\Emulador Pascal Delphi\Data\MiscData.pas',
  PlayerData in '..\Emulador Pascal Delphi\Data\PlayerData.pas',
  Position in 'Data\Position.pas',
  Util in '..\Emulador Pascal Delphi\Functions\Util.pas',
  PlayerDataClasses in '..\Emulador Pascal Delphi\Data\PlayerDataClasses.pas',
  Load in 'Functions\Load.pas',
  DTOAccount in 'Data\DTO\DTOAccount.pas',
  ConstDefs in '..\Emulador Pascal Delphi\Data\ConstDefs.pas',
  InitialCharactersLoader in '..\Emulador Pascal Delphi\Data\InitialCharactersLoader.pas';

var
  stay: string;
  a: string;

function ConsoleEventProc(CtrlType: DWORD): BOOL; stdcall;
begin

  if (CtrlType = CTRL_CLOSE_EVENT) then
  begin
    Server.DisconnectAll;
  end;

  Result := True;
end;

begin

  try
    SetConsoleCtrlHandler(@ConsoleEventProc, True);
    CurrentDir := ExtractFileDir(ParamStr(0));

    if (not TLoad.CarregarConfiguracoes) then
      raise Exception.Create('Não foi possível ler o arquivo de configurações do servidor. Ou o arquivo não foi configurado corretamente');

    Logger := TLog.Create;
    Server := TServerSocket.Create(ConfiguracoesDbServer.Porta);

    TInitialCharactersLoader.Load;

    DMDataBase := TDMDataBase.Create(nil);
    DMDataBase.UpdateActive(False);

    Server.StartServer;
    while(Server.isActive) do
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
