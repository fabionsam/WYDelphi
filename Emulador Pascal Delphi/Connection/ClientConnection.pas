unit ClientConnection;

interface

uses SysUtils, Windows, WinSock2, EncDec, Packets;

type TClientConnection = class
  published
    constructor Create(sock : TSocket);
    destructor Destroy();

  public
    Socket : TSocket;
    IpAddress : string;
    AdapterName: array[0..3] of integer;
    ReceivedPackets : Integer;
    RecvBuffer : array[0..3000] of Byte;

    procedure SendPacket(packet : pointer; size : WORD);
  private
    //SendBuffer : array[0..3000] of Byte;
end;

implementation

uses GlobalDefs, Player, Log, Functions;


constructor TClientConnection.Create(sock : TSocket);
var result: Integer;
  address : TSockAddrIn;
  addressLength : Integer;
//  addressInternet: PSockAddrIn;
begin
  //ZeroMemory(@self, sizeof(TClientConnection));
  self.Socket := sock;
  addressLength := SizeOf(TSockAddrIn);
  result := getpeername(sock, TSockAddr(address), addressLength);
  IpAddress := inet_ntoa(address.sin_addr);
end;

destructor TClientConnection.Destroy;
begin
  try
    CloseSocket(self.Socket);
  except

  end;
end;

procedure TClientConnection.SendPacket(packet : Pointer; size : WORD);
var
  retVal : integer;
  header : TPacketHeader;
begin
  TPacketHeader(packet^).Time := TFunctions.Clock;
  header := TPacketHeader(packet^);
  Logger.Write('Send - Code: ' + Format('0x%x', [header.Code]) + ' / Size : ' + IntToStr(header.Size) +
    ' / ClientId : ' + IntToStr(header.Index), TLogType.Packets);

//  TFunctions.SavePacket(Enviado, packet);

  packet := TEncDec.Encrypt(packet, size);
  
	retval := Send(Socket, packet^, size, 0);
  if (retval = SOCKET_ERROR) then
  begin
    Logger.Write('Send failed with error: ' + IntToStr(WSAGetLastError), TLogType.Warnings);
    CloseSocket(Socket);
    WSACleanup();
    exit;
  end;
end;

end.
