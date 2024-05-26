unit ClientConnection;

interface

uses SysUtils, Windows, WinSock2;

type TClientConnection = class
  published
    constructor Create(sock : TSocket);
    destructor Destroy();

  public
    Socket : TSocket;
    IpAddress : string;
    ReceivedPackets : Integer;
    RecvBuffer : array[0..5500] of Byte;

    procedure SendPacket(packet : pointer; size : WORD);
  private
end;

implementation

uses GlobalDefs, Log, Functions, PacketsDbServer, EncDec;


constructor TClientConnection.Create(sock : TSocket);
var result: Integer;
  address : TSockAddrIn;
  addressLength : Integer;
begin
  self.Socket := sock;
  addressLength := SizeOf(TSockAddrIn);
  result := getpeername(sock, TSockAddr(address), addressLength);
  IpAddress := inet_ntoa(address.sin_addr);
end;

destructor TClientConnection.Destroy;
begin
  CloseSocket(self.Socket);
end;

procedure TClientConnection.SendPacket(packet : Pointer; size : WORD);
var
  retVal : integer;
begin
  TDbPacketHeader(packet^).Time := TFunctions.Clock;

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
