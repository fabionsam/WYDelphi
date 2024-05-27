unit DbServerConnection;

interface

uses
  System.Classes, ThreadPingDbServer;

type
  TDbServerLoopThread = class(TThread)
    public
      procedure Execute; override;
  end;

  TDbServerConnection = Class
    private
      FPort: Integer;
      FIp : String;
      FSocket: Integer;
      FStarted : Boolean;
      FDbServerLoopThread : TDbServerLoopThread;
      FThreadPingDbServer : TThreadPingDbServer;
      FLastPing : TDateTime;
    public
      ServerId : BYTE;
      property DbSocket : Integer read FSocket;
      property Started : Boolean read FStarted;
      property LastPing : TDateTime read FLastPing;
      function DbConnect(): Boolean;
      procedure SendPacket(packet : pointer; size : WORD);
      procedure SendSignal(code : Integer);
      procedure Disconnect();
      function PacketControl(var buffer: Array of Byte; size : Word): Boolean;
    published
      constructor Create(APort: Integer; AIp: String);
  End;

implementation

uses
  Winapi.Winsock, GlobalDefs, Log, Winapi.Windows, PacketsDbServer,
  System.SysUtils, DbPacketHandlers, EncDec;

constructor TDbServerConnection.Create(APort: Integer; AIp: String);
begin
  FPort := APort;
  FIp := AIp;
end;

function TDbServerConnection.DbConnect(): Boolean;
var
  wsa: WSADATA;
  addr: sockaddr_in;
  packet: TDbPacketHeader;
  ip : Array[0..15] of AnsiChar;
begin
  result := false;

  if(WSAStartup(MAKEWORD(2, 2), wsa) <> 0) then
  begin
    Logger.Write('DB: Ocorreu um erro ao inicializar o Winsock 2', TLogType.ServerStatus);
    exit;
  end;

  FSocket := socket(AF_INET,SOCK_STREAM,0);
  if(FSocket = -1) then
  begin
    Logger.Write('DB: Ocorreu um erro ao criar o socket.', TLogType.ServerStatus);
    exit;
  end;

  StrPLCopy(ip, FIp, Length(FIp));

  addr.sin_family := AF_INET;
  addr.sin_port := htons(FPort);
  addr.sin_addr.S_addr := inet_addr(ip);

  if(connect(FSocket,addr,sizeof(addr)) = -1) then
  begin
    Logger.Write('DB: Ocorreu um erro ao conectar-se com a DBServer.', TLogType.ServerStatus);
    exit;
  end;

  FStarted := True;
  FDbServerLoopThread := TDbServerLoopThread.Create(false);
  FThreadPingDbServer := TThreadPingDbServer.Create(false);

  ZeroMemory(@packet, 12);
  packet.Size := 12;
  packet.Code := $1;
  SendPacket(@packet, 12);

 result := True;
end;

procedure TDbServerConnection.Disconnect;
begin
  FStarted := False;
  Logger.Write('DB: Conexão com a DataBase Server foi finalizada.', TLogType.ServerStatus);
  if (Assigned(Server)) and (Server.IsActive) then
    Server.CloseServer;
end;

function TDbServerConnection.PacketControl(var buffer: Array of Byte; size: Word): Boolean;
var
  Header : TDbPacketHeader absolute buffer;
begin
  Logger.Write('DB: Recv - Code: ' + Format('0x%x', [header.Code]) + ' / Size : ' + IntToStr(header.Size) + '|' + IntToStr(size), TLogType.Packets);

  case header.Code of
    $2: Result := TDbPacketHandlers.ReceiveId(buffer);
    $4: Result := TDbPacketHandlers.ReceiveAccount(buffer);
    $6: Result := TDbPacketHandlers.ReceiveCreateCharacter(buffer);
    $50:
    begin
      FLastPing := Now;
      Result := True;
    end;
    $51: Result := TDbPacketHandlers.ReceiveDisconnectDbServer();
    $52: Result := TDbPacketHandlers.ReceiveDisconnectAccount(buffer);
    else
    begin
      Logger.Write('DB: PacketId desconhecido: Recv - Code: ' + Format('0x%x', [header.Code]) + ' / Size : ' + IntToStr(header.Size), TLogType.Warnings);
    end;
  end;
end;

procedure TDbServerConnection.SendPacket(packet: pointer; size: WORD);
var
  retval: integer;
  header : TDbPacketHeader;
begin
  if(FSocket = -1) then exit;

  header := TDbPacketHeader(packet^);
  Logger.Write('DB: Send - Code: ' + Format('0x%x', [header.Code]) + ' / Size : ' + IntToStr(header.Size) +
    ' / GameServer : ' + IntToStr(header.Index), TLogType.Packets);

  packet := TEncDec.Encrypt(packet, size);

	retval := Send(FSocket, packet^, size, 0);
  if (retval = SOCKET_ERROR) then
  begin
    Logger.Write('DB: Send failed with error: ' + IntToStr(WSAGetLastError), TLogType.Warnings);
    CloseSocket(FSocket);
    WSACleanup();
    exit;
  end;
end;

procedure TDbServerConnection.SendSignal(code: Integer);
var
  signal : TDbPacketHeader;
begin
  ZeroMemory(@signal, sizeof(TDbPacketHeader));
  signal.Size := 12;
  signal.Index := self.ServerId;
  signal.Code := code;

  self.SendPacket(@signal, sizeof(TDbPacketHeader));
end;

{ TDbServerLoopThread }

procedure TDbServerLoopThread.Execute;
var
  size : Integer;
  Buffer: Array[0..10000] of Byte;
begin
  Priority := tpHighest;
  FreeOnTerminate := True;
  ZeroMemory(@Buffer,10000);
  while(DBClient.Started) do
	begin
    try
      size := recv(DbClient.DbSocket,Buffer,10000,0); // Recebe dados do servidor
      if (size > 0) then
      begin
        TEncDec.Decrypt(Buffer[0], size);
        DbClient.PacketControl(Buffer, size);
        ZeroMemory(@Buffer,10000);
      end
      else
      begin
        if (size = -1) then //disconnect
          DbClient.Disconnect;
      end;
    except
      on E : Exception do
      begin
        Logger.Write('DB: Error in dbclient thread: ' + E.Message, TLogType.Warnings);
        continue;
      end;
    end;
  end;

  // Encerra
  closesocket(DbClient.DbSocket);
  WSACleanup();
  inherited;
end;

end.
