unit Functions;

interface

type
  TFunctions = class
  public
    class procedure DisconnectAccount(ServerId: Word; AccountId : String);
    class function Clock: Cardinal; static;
    class function FreeClientId: WORD;
  end;

implementation

uses
  Winapi.Windows, GlobalDefs, GameServer, PacketsDbServer;

class procedure TFunctions.DisconnectAccount(ServerId: Word; AccountId : String);
var
  packet: TAccountDisconnect;
begin
  ZeroMemory(@packet, sizeof(TAccountDisconnect));
  packet.Header.Size := sizeof(TAccountDisconnect);
  packet.Header.Code := $52;
  packet.Header.Index := 7000;
  packet.AccountId := AccountId;
  Server.SendPacketTo(ServerId, @packet, packet.Header.Size);
end;

class function TFunctions.Clock() : Cardinal;
begin
  result := GetTickCount();
end;

class function TFunctions.FreeClientId: WORD;
var i: WORD;
begin
  result := 0;

  if(TGameServer.InstantiatedServers + 1 > MAX_CONNECTIONS) then
    exit;

  for i := 1 to (MAX_CONNECTIONS - 1) do
  begin
    if not(Assigned(TGameServer.Servers[i])) then
    begin
      result := i;
      exit;
    end;
  end;
end;

end.
