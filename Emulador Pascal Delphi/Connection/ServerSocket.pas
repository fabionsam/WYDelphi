unit ServerSocket;

interface

uses PlayerData, Functions, PacketHandlers, ClientConnection, BackgroundThread, Log, Commands,
    Volatiles, NpcFunctions, Player, Packets, CombatHandlers, EncDec, Util, System.Threading,
    WinSock2, Windows, SysUtils, Variants, Diagnostics, DateUtils, ShareMem, Classes,
    Generics.Collections;


type TServerLoopThread = class(TThread)
  public
    procedure Execute; override;
  private
    procedure BuildSets(var readSet, exceptSet: TFDSet);
    procedure HandleClients(readSet: TFDSet; exceptSet: TFDSet);
end;

type TServerSocket = class(TObject)
  UpTime: TDateTime;
  Sock : TSocket;
  ServerAddr : TSockAddrIn;
  Port : Integer;
  IsActive : Boolean;
  ServerLoopThread : TServerLoopThread;

  published
    constructor Create(p: integer);

  public
    function StartServer() : Boolean;
    procedure CloseServer();
    function AddPlayer(sock : TSocket; clientInfo : PSockAddr) : Boolean;
    procedure Disconnect(player : TPlayer); overload;
    //procedure Disconnect(clientId : WORD); overload;
    procedure Disconnect(userName : string); overload;
    procedure DisconnectAll();

    function OnReceivePacket(player : TPlayer; var buffer : array of Byte; size : Integer) : Boolean;

    procedure SendPacketTo(clientId : Integer; packet : pointer; size : WORD);
    procedure SendSignalTo(clientId : Integer; pIndex, opCode: WORD);
    procedure SendToAll(packet : pointer; size : WORD);

  private
    procedure StartThreads();
    function PacketControl(player : TPlayer; size : integer; var buffer : array of Byte; initialOffset : integer) : Boolean;
end;

implementation

uses GlobalDefs, ConstDefs, NPCHandlers, GuildFunctions;

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
//  TBackgroundThread.StopThreads;
  if(Sock = -1) or not(IsActive) then
    exit;
  IsActive := false;
  DisconnectAll();
  ZeroMemory(@Parties, sizeof(TParty) * Length(Parties));
  CloseSocket(sock);
  Sock := INVALID_SOCKET;

  Logger.Write('Servidor finalizado!', TLogType.ServerStatus);
end;

constructor TServerSocket.Create(p: integer);
begin
  Port := p;
  UpTime := Now;
end;

procedure TServerSocket.StartThreads;
var
  thread: TBackgroundThread;
begin
  ServerLoopThread := TServerLoopThread.Create(false);
  TBackgroundThread.AddThreads();

  for thread in TBackgroundThread.BackgroundThreads do
  begin
    thread.Start;
  end;

end;

procedure TServerSocket.DisconnectAll;
var
  cnt: WORD;
begin
  TPlayer.ForEach(procedure(player: TPlayer)
  begin
    player.Disconnect;
    Inc(cnt);
  end);
  ZeroMemory(@TPlayer.Players, SizeOf(TPlayer.Players));
  if(cnt > 0) then
    Logger.Write('[' + IntToStr(cnt) + '] TPlayer.Players foram desconectados.', TLogType.ConnectionsTraffic);
end;

procedure TServerSocket.Disconnect(player : TPlayer);
var
  clientId: WORD;
begin
  if (not(Assigned(player))) or (player.Disposing) then
    exit;
  player.Disposing := True;

  try
    PlayersNick.Remove(player.Character.Name);
  except
    Logger.Write('Jogador '+player.Character.Name+' não encontrado no dicionário.', TLogType.Warnings);
  end;

  clientId := player.ClientId;
  TPlayer.Players[clientId].Destroy;
  TPlayer.Players[clientId] := nil;
end;

procedure TServerSocket.Disconnect(userName: string);
begin
  TPlayer.ForEach(procedure(player : TPlayer)
  begin
    if (AnsiCompareText(player.Account.Header.Username, userName) = 0) then
    begin
      player.Disconnect;
      exit
    end;
  end);
end;

function TServerSocket.OnReceivePacket(player : TPlayer; var buffer : array of Byte; size : Integer) : Boolean;
var
  initialOffset : Integer;
begin
  result := true;
  if (size < sizeof(TPacketHeader)) then
  begin
    exit;
  end;

  initialOffset := 0;
  if(player.Connection.ReceivedPackets = 0) and (size > 116) then
  begin
    initialOffset := 4;
  end;
  Inc(player.Connection.ReceivedPackets);

  Dec(size, initialOffset);
  TEncDec.Decrypt(buffer[initialOffset], size);
  PacketControl(player, size, buffer, initialOffset);
end;

procedure TServerSocket.SendPacketTo(clientId: Integer; packet : pointer; size : WORD);
var player: TPlayer;
begin
  if TPlayer.GetPlayer(clientId, player) then
    player.SendPacket(packet, size);
end;

procedure TServerSocket.SendSignalTo(clientId: Integer; pIndex, opCode: WORD);
var signal : TPacketHeader;
begin
  if(clientId > MAX_CONNECTIONS) or not(Assigned(TPlayer.Players[clientId])) then exit;

  ZeroMemory(@signal, sizeof(TPacketHeader));
  signal.Size := 12;
  signal.Index := pIndex;
  signal.Code := opCode;

  TPlayer.Players[clientId].SendPacket(@signal, sizeof(TPacketHeader));
end;

procedure TServerSocket.SendToAll(packet : pointer; size : WORD);
var player : TPlayer;
begin
  for player in TPlayer.Players do
  begin
    player.SendPacket(packet, size);
  end;
end;


function TServerSocket.PacketControl(player : TPlayer; size : integer; var buffer : array of Byte; initialOffset : integer) : Boolean;
var
  header : TPacketHeader;
begin
  Result := false;
  try
    ZeroMemory(@header, sizeof(TPacketHeader));
    if(initialOffset <> 0) then
      Move(buffer[initialOffset], buffer, size);
    Move(buffer, header, sizeof(TPacketHeader));
    if(header.Size <> size) then
      exit;
  finally
    Logger.Write('Recv - Code: ' + Format('0x%x', [header.Code]) + ' / Size : ' + IntToStr(header.Size) +
    ' / ClientId : ' + IntToStr(header.Index), TLogType.Packets);

    if (player.WaitingDbServer) and (header.Code <> $3A0) then
      Result := True
    else
    case header.Code of
      $20D: Result := TPacketHandlers.CheckLogin(player, buffer);
      $FDE: Result := TPacketHandlers.NumericToken(player, buffer);
      $20F: Result := TPacketHandlers.CreateCharacter(player, buffer);
      $211: Result := TPacketHandlers.DeleteCharacter(player, buffer);
      $213: Result := TPacketHandlers.SelectCharacter(player, buffer);
      $215: Result := player.BackToCharList;
      $270: Result := TPacketHandlers.PickItem(player, buffer);
      $272: Result := TPacketHandlers.DropItem(player, buffer);
      $277: Result := TPacketHandlers.AddPoints(player, buffer);
      $28B, $28E: Result := TNPCHandlers.Handle(player, buffer);

      $AD9: Result := NpcFuncs.NpcMestreGriffo.MestreGriffoProc(player, buffer);
      $3A6: Result := NpcFuncs.NpcCompounder.CompounderProc(player, buffer);
      $3C0: Result := NpcFuncs.NpcTiny.TinyProc(player, buffer);
      $3B5: Result := NpcFuncs.NpcAylin.AylinProc(player, buffer);
      $2C4: Result := NpcFuncs.NpcShany.ShanyProc(player, buffer);
      $3BA: Result := NpcFuncs.NpcAgatha.AgathaProc(player, buffer);

      $290: Result := TPacketHandlers.Gates(player, buffer);
      $291: Result := TPacketHandlers.ChangeCity(player, buffer);
      $36A: Result := TPacketHandlers.RequestEmotion(player, buffer);
      $373: Result := TVolatiles.UseItem(player, buffer);
      $376: Result := TPacketHandlers.MoveItem(player, buffer);
      $27B: Result := TPacketHandlers.SendNPCSellItens(player, buffer);
      $2E4: Result := TPacketHandlers.DeleteItem(player, buffer);
      $2E5: Result := TPacketHandlers.UngroupItem(player, buffer);
      $333: Result := TPacketHandlers.SendClientSay(player, buffer);
      $334: Result := TCommands.Received(player, buffer);
      $366, $367: Result := TPacketHandlers.MovementCommand(player, buffer);
      $369: Result := TPacketHandlers.MobNotInView(player, buffer); //verificar este packet pois nao sei o que faz e é enviado varias vezes pelo client
      $378: Result := TPacketHandlers.ChangeSkillBar(player, buffer);
      $379: Result := TPacketHandlers.BuyNpcItens(player, buffer);
      $37A: Result := TPacketHandlers.SellItemsToNPC(player, buffer);
      $383: Result := TPacketHandlers.Trade(player, buffer);
      $384: Result := TPacketHandlers.CloseTrade(player);
      $387: Result := TPacketHandlers.CargoGoldToInventory(player, buffer);
      $388: Result := TPacketHandlers.InventoryGoldToCargo(player, buffer);
      $3A0: Result := True; //Susposto pacote de ping
      $3AE: Result := TPacketHandlers.LogOut(player, buffer);
      $397: Result := TPacketHandlers.RequestOpenStoreTrade(player, buffer);
      $398: Result := TPacketHandlers.BuyStoreTrade(player, buffer);
      $399: Result := TPacketHandlers.PKMode(player, buffer);
      $39A: Result := TPacketHandlers.OpenStoreTrade(player, buffer);
      $37F: Result := TPacketHandlers.RequestParty(player, buffer);
      $37E: Result := TPacketHandlers.ExitParty(player, buffer);
      $3AB: Result := TPacketHandlers.AcceptParty(player, buffer);
      $39D, $39E: Result := TCombatHandlers.HandleSingleTarget(player, buffer);
      $36C: Result := TCombatHandlers.HandleAoE(player, buffer);
      $289:
      begin
        if (player.IsDead) then
        begin
          player.Character.CurrentScore.CurHP := player.Character.CurrentScore.MaxHP;
          player.Teleport(TFunctions.GetStartXY(player));

          player.SendAffects;
          player.SendScore;
          player.SendWeather;
        end;
      end;
      $3D5: TGuildFunctions.RecruitGuildMember(player, buffer);
      $28C: TGuildFunctions.RemoveGuildMember(player, buffer);
      $E12: TGuildFunctions.DeclareAlliance(player, buffer);
      else
      begin
        Logger.Write('PacketId desconhecido: Recv - Code: ' + Format('0x%x', [header.Code]) + ' / Size : ' + IntToStr(header.Size) +
        ' / ClientId : ' + IntToStr(header.Index), TLogType.Warnings);
      end;
    end;
  end;
end;


{ TServerLoopThread }
procedure TServerLoopThread.Execute;
var
  newSocket : TSocket;
  ClientInfo: PSockAddr;
  activity: Integer;
  timeout : TTimeVal;
  readSet, exceptSet: TFdSet;
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
          Server.AddPlayer(newSocket, ClientInfo);
        end;
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
     function TServerSocket.AddPlayer(sock : TSocket; clientInfo : PSockAddr) : Boolean;
var clientId : WORD;
  clientConnection: TClientConnection;
  packet: TClientMessagePacket;
  errorStr: string;
  ipsCount : Byte;
  i: Integer;
  player: TPlayer;
begin
  Result := false;
  errorStr := '';
  clientId := TFunctions.FreeClientId;
  clientConnection := TClientConnection.Create(sock);

  if(clientId = 0) then
  begin
    errorStr := 'Limite de conexões atingida.';
  end
  else
  begin
    // Infelizmente se precisar dar exit, não da pra dar break, não da pra usar TPlayer.ForEach
    for i := 1 to TPlayer.InstantiatedPlayers do
    begin
      if(ipsCount >= 5) then
      begin
        errorStr := 'Limite de conexões por IP atingido.';
        break;
      end;

      if not(Assigned(TPlayer.Players[i])) then continue;

      if(clientConnection.IpAddress = TPlayer.Players[i].Connection.IpAddress) then
      begin
        Inc(ipsCount);
      end;
    end;
  end;

  if(errorStr <> '') then
  begin
    ZeroMemory(@packet, sizeof(TClientMessagePacket));
    packet.Header.Size := sizeof(TClientMessagePacket);
    packet.Header.Code := $101;
    packet.Header.Index := 0;
    StrPLCopy(packet.Message, errorStr, 96);

    clientConnection.SendPacket(@packet, packet.Header.Size);
    clientConnection.Destroy;
    FreeAndNil(clientConnection);
    exit;
  end;

  // Aqui verificamos se o proximo clientId disponivel é maior que o numero de TPlayer.Players
  // Se for, nós definimos InstantiatedTPlayer.Players, como esse clientId
  // O valor de InstantiatedTPlayer.Players, continuara a subir com o login de novos TPlayer.Players
  // mas cada vez que a TLoginDisconnectThread for executada esse número é recalculado
  // Isso evita que o loop por todos os TPlayer.Players, seja MAXCONNECTIONS
  // sendo sempre um número igual ou próximo ao valor real de TPlayer.Players logados
  if(clientId > TPlayer.InstantiatedPlayers) then
    TPlayer.InstantiatedPlayers := clientId;

  player := TPlayer.Create(clientId, clientConnection);
  TPlayer.Players[clientId] := player;
  TPlayer.Players[clientId].Status := TPlayerStatus.WaitingLogin;
  Result := true;
end;

procedure TServerLoopThread.BuildSets(var readSet, exceptSet: TFDSet);
var i : WORD;
    player : TPlayer;
begin
  FD_ZERO(readSet);
  _FD_SET(Server.Sock, readSet);

  FD_ZERO(exceptSet);
  _FD_SET(Server.Sock, exceptSet);

  for i := 1 to TPlayer.InstantiatedPlayers do
  begin
    player := TPlayer.Players[i];
    if not Assigned(player) then
      continue;

    if not(player.IsDiconnecting) AND (player.Connection.Socket <> INVALID_SOCKET) AND (player.Connection.Socket <> SOCKET_ERROR) then
    begin
      _FD_SET(player.Connection.Socket, readSet);
      _FD_SET(player.Connection.Socket, exceptSet);
    end
    else
      Server.Disconnect(player);
  end;
end;

procedure TServerLoopThread.HandleClients(readSet: TFDSet; exceptSet: TFDSet);
var i : WORD;
  player : TPlayer;
begin
  for i := 1 to TPlayer.InstantiatedPlayers do
  begin
    player := TPlayer.Players[i];
    if not(Assigned(player)) OR (player.Connection.Socket = INVALID_SOCKET) OR (player.Connection.Socket = SOCKET_ERROR) then
    begin
      FreeAndNil(TPlayer.Players[i]);
      continue;
    end;

    if(FD_ISSET(player.Connection.Socket, readSet)) then
    begin
      if not(player.ReceiveData) then
        Server.Disconnect(player);
    end;

    if(FD_ISSET(player.Connection.Socket, exceptSet)) then
    begin
      Logger.Write('Exceção no socket do jogador: ' + inttostr(player.ClientId), TLogType.Warnings);
      Server.Disconnect(player);
    end;
  end;
end;

end.
