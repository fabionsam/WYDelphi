unit GameServer;

interface

uses
  ClientConnection, Windows, System.SysUtils, System.Threading;

type TGameServer = class
  published
    class constructor Create;
    constructor Create(clientId : WORD; conn: TClientConnection);
    destructor Destroy;
  public
    clientId: Byte;
    Connection : TClientConnection;

    class var InstantiatedServers: Integer;
    class var Servers : array[1..10] of TGameServer;

    procedure SendPacket(packet : pointer; size : WORD);
    function ReceiveData() : Boolean;
    procedure Disconnect;

    class function GetServer(index: WORD): TGameServer; overload; static;
    class function GetServer(index: WORD; out gameServer: TGameServer): boolean; overload; static;
    class procedure ForEach(proc: TProc<TGameServer, TParallel.TLoopState>); overload; static;
    class procedure ForEach(proc: TProc<TGameServer>); overload; static;
end;

implementation

uses
  GlobalDefs, Winapi.Winsock2;

{ TGameServer }

constructor TGameServer.Create(clientId: WORD; conn: TClientConnection);
begin
  inherited Create;
  self.clientId := clientId;
  self.Connection := conn;
end;

class constructor TGameServer.Create;
begin
  ZeroMemory(@Servers, SizeOf(Servers));
  InstantiatedServers := 0;
end;

destructor TGameServer.Destroy;
begin
  Connection.Destroy;
  inherited Destroy;
end;

class function TGameServer.GetServer(index: WORD): TGameServer;
begin
  if(index = 0) OR (index > MAX_CONNECTIONS) then
    exit;

  result := Servers[index];
end;

class function TGameServer.GetServer(index: WORD; out gameServer: TGameServer): boolean;
begin
  Result := false;
  if(index = 0) OR (index > MAX_CONNECTIONS) then
    exit;

  gameServer := Servers[index];
  Result := Assigned(gameServer);
end;

class procedure TGameServer.ForEach(proc: TProc<TGameServer, TParallel.TLoopState>);
begin
  TParallel.For(1, InstantiatedServers, procedure(i : Integer; state : TParallel.TLoopState)
  var gameServer: TGameServer;
  begin
    gameServer := Servers[i];
    if not(Assigned(gameServer)) then
      exit;
    proc(gameServer, state);
  end);
end;

class procedure TGameServer.ForEach(proc: TProc<TGameServer>);
begin
  TParallel.For(1, InstantiatedServers, procedure(i : Integer)
  var gameServer: TGameServer;
  begin
    gameServer := Servers[i];
    if not(Assigned(gameServer)) then
      exit;
    proc(gameServer);
  end);
end;

procedure TGameServer.Disconnect;
begin
  Server.SendSignalTo(clientId, 7000, $51);
  Server.Disconnect(self);
end;

procedure TGameServer.SendPacket(packet : pointer; size : WORD);
begin
  if(Connection.Socket = -1) then exit;
  Connection.SendPacket(packet, size);
end;

function TGameServer.ReceiveData() : Boolean;
var ReceivedBytes : integer;
begin
  Result := false;
	ZeroMemory(@Connection.RecvBuffer, 5500);
	ReceivedBytes := Recv(Connection.Socket, Connection.RecvBuffer, 5500, 0);
	if(ReceivedBytes <= 0) then
  begin
    exit;
  end;
  Result := Server.OnReceivePacket(self, Connection.RecvBuffer, ReceivedBytes);
end;

end.
