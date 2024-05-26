unit ServerSocket;

interface

uses System.Threading, WinSock2, Windows, SysUtils, Variants, Diagnostics,
     DateUtils, ShareMem, Classes, Generics.Collections, GameServer,
     PacketsDbServer;


type TServerLoopThread = class(TThread)
  public
    procedure Execute; override;
  private
    procedure BuildSets(var readSet, exceptSet: TFDSet);
    procedure HandleClients(readSet: TFDSet; exceptSet: TFDSet);
end;

type TServerSocket = class(TObject)
  UpTime: TDateTime;
  ServerAddr : TSockAddrIn;
  Port : Integer;
  IsActive : Boolean;
  ServerLoopThread : TServerLoopThread;

  published
    constructor Create(p: integer);

  public
    Sock : TSocket;

    function StartServer() : Boolean;
    procedure CloseServer();
    procedure AddServer(sock : TSocket; clientInfo : PSockAddr);

    procedure Disconnect(gameServer : TGameServer); overload;
    procedure Disconnect(clientId : WORD); overload;
    procedure DisconnectAll();

    function OnReceivePacket(gameServer : TGameServer; var buffer : array of Byte; size : Integer) : Boolean;

    procedure SendPacketTo(serverId : Integer; packet : pointer; size : WORD);
    procedure SendSignalTo(serverId : Integer; pIndex, opCode: WORD);
    procedure SendToAll(packet : pointer; size : WORD);

  private
    procedure StartThreads();
    function PacketControl(gameServer: TGameServer; size : integer; var buffer : array of Byte) : Boolean;
end;

implementation

uses GlobalDefs, Log, ClientConnection, Functions, DbPacketHandlers, EncDec,
  U_DMDataBase;

{ TServer }
function TServerSocket.StartServer() : Boolean;
var wsa: TWsaData; timeinit : integer;
  NonBlocking: Cardinal;
begin
  Result := false;
  if(WSAStartup(MAKEWORD(2, 2), wsa) <> 0) then
  begin
    Logger.Write('Ocorreu um erro ao inicializar o Winsock 2', TLogType.ServerStatus);
    exit;
  end;
  self.Sock := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  self.ServerAddr.sin_family := AF_INET;
  self.ServerAddr.sin_port := htons(self.Port);
  self.ServerAddr.sin_addr.S_addr := INADDR_ANY;

  if (bind(Sock, TSockAddr(ServerAddr), sizeof(ServerAddr)) = -1) then
  begin
    Logger.Write('Ocorreu um erro ao configurar o socket.', TLogType.ServerStatus);
		closesocket(sock);
		sock := INVALID_SOCKET;
    exit;
	end;

	if (listen(sock, MAX_CONNECTIONS) = -1) then
  begin
    Logger.Write('Ocorreu um erro ao colocar o socket em modo de escuta.', TLogType.ServerStatus);
		closesocket(sock);
		sock := INVALID_SOCKET;
		exit;
  end;
  NonBlocking := 1;
  if (ioctlsocket(sock, FIONBIO, NonBlocking) = SOCKET_ERROR) then
  begin
    Logger.Write('ioctlsocket() falhou: ' + inttostr(WSAGetLastError()), TLogType.ServerStatus);
    Result := false;
    exit;
  end;
  IsActive := true;
  StartThreads;
  timeinit := MilliSecondsBetween(Now, UpTime);
  Logger.Write('Servidor levou ' + inttostr(timeinit) + ' milisegundos para carregar(aprox: ' + floattostr(timeinit/1000) +' segundos).', TLogType.ServerStatus);
  Result := true;
end;

procedure TServerSocket.CloseServer;
begin
  if(Sock = -1) or not(IsActive) then
    exit;
  IsActive := false;
  DisconnectAll();
  CloseSocket(sock);
  Sock := INVALID_SOCKET;
end;

constructor TServerSocket.Create(p: integer);
begin
  Port := p;
  UpTime := Now;
end;

procedure TServerSocket.StartThreads;
begin
  ServerLoopThread := TServerLoopThread.Create(false);
end;

procedure TServerSocket.AddServer(sock : TSocket; clientInfo : PSockAddr);
var
  serverId : WORD;
  clientConnection: TClientConnection;
  errorStr: string;
  ipsCount : Byte;
  i: Integer;
  gamerServer: TGameServer;
begin
  errorStr := '';
  serverId := TFunctions.FreeClientId;
  clientConnection := TClientConnection.Create(sock);

  if(serverId = 0) then
  begin
    errorStr := 'Limite de conexões atingida.';
  end
  else
  begin
    // Infelizmente se precisar dar exit, não da pra dar break, não da pra usar TPlayer.ForEach
    for i := 1 to TGameServer.InstantiatedServers do
    begin
      if not(Assigned(TGameServer.Servers[i])) then continue;

      if(clientConnection.IpAddress = TGameServer.Servers[i].Connection.IpAddress) then
      begin
        Inc(ipsCount);
      end;
    end;
  end;

  if(errorStr <> '') then
  begin
    clientConnection.Destroy;
    FreeAndNil(clientConnection);
    Disconnect(serverId);
  end;

  if(serverId > TGameServer.InstantiatedServers) then
    TGameServer.InstantiatedServers := serverId;

  gamerServer := TGameServer.Create(serverId, clientConnection);
  TGameServer.Servers[serverId] := gamerServer;
end;

procedure TServerSocket.DisconnectAll;
var
  cnt: WORD;
begin
  TGameServer.ForEach(procedure(gameServer: TGameServer)
  begin
    gameServer.Disconnect;
    Inc(cnt);
  end);
  ZeroMemory(@TGameServer.Servers, SizeOf(TGameServer.Servers));
  if(cnt > 0) then
    Logger.Write('[' + IntToStr(cnt) + '] TGameServer.Servers foram desconectados.', TLogType.ConnectionsTraffic);
end;

procedure TServerSocket.Disconnect(clientId : WORD);
begin
  if(clientId = 0) then
    exit;

  if not(Assigned(TGameServer.Servers[clientId])) then
    exit;

  TGameServer.Servers[clientId].Disconnect;
end;

procedure TServerSocket.Disconnect(gameServer : TGameServer);
begin
  if not(Assigned(gameServer)) then
    exit;

  DMDataBase.UpdateActive(False, gameServer.ClientId);
  TGameServer.Servers[gameServer.ClientId].Destroy;
  TGameServer.Servers[gameServer.ClientId] := nil;
end;


function TServerSocket.OnReceivePacket(gameServer : TGameServer; var buffer : array of Byte; size : Integer) : Boolean;
begin
  result := true;
  if (size < sizeof(TDbPacketHeader)) then
  begin
    exit;
  end;

  TEncDec.Decrypt(buffer[0], size);
  PacketControl(gameServer, size, buffer);
end;

procedure TServerSocket.SendPacketTo(serverId: Integer; packet : pointer; size : WORD);
var gameServer: TGameServer;
begin
  if TGameServer.GetServer(serverId, gameServer) then
    gameServer.SendPacket(packet, size);
end;

procedure TServerSocket.SendSignalTo(serverId: Integer; pIndex, opCode: WORD);
var signal : TDbPacketHeader;
begin
  if(serverId > MAX_CONNECTIONS) or not(Assigned(TGameServer.Servers[serverId])) then exit;

  ZeroMemory(@signal, sizeof(TDbPacketHeader));
  signal.Size := 12;
  signal.Index := pIndex;
  signal.Code := opCode;

  TGameServer.Servers[serverId].SendPacket(@signal, sizeof(TDbPacketHeader));
end;

procedure TServerSocket.SendToAll(packet : pointer; size : WORD);
var server : TGameServer;
begin
  for server in TGameServer.Servers do
  begin
    server.SendPacket(packet, size);
  end;
end;


function TServerSocket.PacketControl(gameServer : TGameServer; size : integer; var buffer : array of Byte) : Boolean;
var
  header : TDbPacketHeader absolute buffer;
begin
  Result := false;
  try
//    ZeroMemory(@header, sizeof(TPacketHeader));
//    Move(buffer, header, sizeof(TPacketHeader));
//    if(header.Size <> size) then
//      exit;
  finally
    Logger.Write('Recv - Code: ' + Format('0x%x', [header.Code]) + ' / Size : ' + IntToStr(header.Size) +
    ' / ServerId : ' + IntToStr(header.Index), TLogType.Packets);

    case header.Code of
      $1: Result := TDbPacketHandlers.ReceiveRequestId(gameServer, buffer);
      $3: Result := TDbPacketHandlers.ReceiveRequestAccount(gameServer, buffer);
      $5: Result := TDbPacketHandlers.ReceiveRequestCreateCharacter(gameServer, buffer);
      $7: Result := TDbPacketHandlers.ReceiveRequestSaveAccount(gameServer, buffer);
      $50:
      begin
        self.SendSignalTo(gameServer.clientId, 7000, $50);
        Result := True;
      end;
      else
      begin
        Logger.Write('PacketId desconhecido: Recv - Code: ' + Format('0x%x', [header.Code]) + ' / Size : ' + IntToStr(header.Size) +
        ' / ServerId : ' + IntToStr(header.Index), TLogType.Warnings);
      end;
    end;
  end;
end;

{ TServerLoopThread }
procedure TServerLoopThread.Execute;
var newSocket : TSocket;
	  ClientInfo: PSockAddr;
    readSet, exceptSet: TFdSet;
    activity: Integer;
    timeout : TTimeVal;
begin
Priority := tpHighest;
  timeout.tv_sec := 0;
  timeout.tv_usec := 2000;

  while(Server.IsActive) do
	begin
    try
      BuildSets(readSet, exceptSet);
		  activity := select(0, @readSet, nil, @exceptSet, @timeout);

		  if (activity < 0) { and (errno != EINTR)} then
      begin
		  	Logger.Write('Select command failed. Error #' + IntToStr(WSAGetLastError), TLogType.Warnings);
		  	Server.IsActive := false;
      end;

      if (activity = 0) then
        continue;

		  if (FD_ISSET(Server.Sock, readSet)) then
      begin
		  	newSocket := accept(Server.Sock, ClientInfo, nil);
        if (NewSocket <> SOCKET_ERROR) AND (NewSocket <> INVALID_SOCKET) then
        begin
          Server.AddServer(newSocket, ClientInfo)
        end
		  	else
        begin
          Logger.Write('Error accepting socket. Error #' + IntToStr(WSAGetLastError), TLogType.Warnings);
        end
		  end;

      if (FD_ISSET(Server.Sock, exceptSet)) then
      begin
		  	Logger.Write('Exceção no socket do servidor' + IntToStr(WSAGetLastError), TLogType.Warnings);
        Server.IsActive := false;
        exit;
		  end;

      HandleClients(readSet, exceptSet);
    except
      on E: Exception do
      begin
        Logger.Write('Error in server thread: ' + E.Message, TLogType.Warnings);
        continue;
      end;
    end;
  end;
  inherited;
end;

procedure TServerLoopThread.BuildSets(var readSet, exceptSet: TFDSet);
var i : WORD;
    gameServer : TGameServer;
begin
  FD_ZERO(readSet);
  _FD_SET(Server.Sock, readSet);

  FD_ZERO(exceptSet);
  _FD_SET(Server.Sock, exceptSet);

  for i := 1 to MAX_CONNECTIONS do
  begin
    gameServer := TGameServer.Servers[i];
    if not Assigned(gameServer) then
      continue;

    if {not(gameServer.IsDiconnecting) AND }(gameServer.Connection.Socket <> INVALID_SOCKET) AND (gameServer.Connection.Socket <> SOCKET_ERROR) then
    begin
      _FD_SET(gameServer.Connection.Socket, readSet);
      _FD_SET(gameServer.Connection.Socket, exceptSet);
    end
    else
      Server.Disconnect(gameServer);
	end;
end;

procedure TServerLoopThread.HandleClients(readSet: TFDSet; exceptSet: TFDSet);
var i : WORD;
    gameServer : TGameServer;
begin
  for i := 1 to (MAX_CONNECTIONS - 1) do
  begin
    gameServer := TGameServer.Servers[i];
    if not(Assigned(gameServer)) OR (gameServer.Connection.Socket = INVALID_SOCKET) OR (gameServer.Connection.Socket = SOCKET_ERROR) then
    begin
      FreeAndNil(TGameServer.Servers[i]);
      continue;
    end;

    if(FD_ISSET(gameServer.Connection.Socket, readSet)) then
    begin
      if not(gameServer.ReceiveData) then
        Server.Disconnect(gameServer);
    end;

    if(FD_ISSET(gameServer.Connection.Socket, exceptSet)) then
    begin
      Logger.Write('Exceção no socket do servidor: ' + inttostr(i), TLogType.Warnings);
      Server.Disconnect(gameServer);
    end;
  end;
end;

end.
