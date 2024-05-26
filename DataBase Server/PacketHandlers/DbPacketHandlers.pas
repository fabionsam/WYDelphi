unit DbPacketHandlers;

interface

uses
  GameServer;

type TDbPacketHandlers = class(TObject)
  public
    class function ReceiveRequestId(gameServer: TGameServer; var buffer: array of Byte): Boolean;
    class function ReceiveRequestAccount(gameServer: TGameServer; var buffer: array of Byte): Boolean;
    class function ReceiveRequestCreateCharacter(gameServer: TGameServer; var buffer: array of Byte): Boolean;
    class function ReceiveRequestSaveAccount(gameServer: TGameServer; var buffer: array of Byte): Boolean;
end;

implementation

uses
  GlobalDefs, PacketsDbServer, Winapi.Windows, U_DMDataBase,
  FireDAC.Phys.MongoDBWrapper, REST.Json, PlayerData, PlayerDataClasses,
  System.JSON, DTOAccount, Functions;

{ TDbPacketHandlers }

class function TDbPacketHandlers.ReceiveRequestCreateCharacter(
  gameServer: TGameServer; var buffer: array of Byte): Boolean;
var
  packet : TCreateCharacterDb absolute buffer;
  packetResp : TRespCreateCharacterDb;
begin
  ZeroMemory(@packetResp, sizeof(TRespCreateCharacterDb));
  packetResp.Header.Size := sizeof(TRespCreateCharacterDb);
  packetResp.Header.Code := $6;
  packetResp.Header.Index := 7000;
  packetResp.ClientId := packet.ClientId;
  if (DMDataBase.CharacterNameInUse(packet.CharacterName)) then
  begin
    packetResp.Exists := True;
    gameServer.SendPacket(@packetResp, packetResp.Header.Size);
    exit;
  end;

  packetResp.SlotIndex := packet.SlotIndex;
  Move(packet.CharacterName, packetResp.CharacterName, sizeof(packet.CharacterName));
  packetResp.ClassIndex := packet.ClassIndex;
  gameServer.SendPacket(@packetResp, packetResp.Header.Size);
end;

class function TDbPacketHandlers.ReceiveRequestId(gameServer: TGameServer;
  var buffer: array of Byte): Boolean;
var
  packet : TSendRecServerId;
begin
  ZeroMemory(@packet, sizeof(TSendRecServerId));
  packet.Header.Size := sizeof(TSendRecServerId);
  packet.Header.Code := $2;
  packet.Header.Index:= 7000;
  packet.ServerId := gameServer.clientId;
  Server.SendPacketTo(gameServer.clientId, @packet, packet.Header.Size);
end;

class function TDbPacketHandlers.ReceiveRequestSaveAccount(
  gameServer: TGameServer; var buffer: array of Byte): Boolean;
var
  packet : TSaveAccount absolute buffer;
begin
  DMDataBase.UpdateAccount(TDTOAccount.AccountStructToClass(packet.Acc), packet.Acc.Header.AccountId);
end;

class function TDbPacketHandlers.ReceiveRequestAccount(gameServer: TGameServer;
  var buffer: array of Byte): Boolean;
var
  packet : TResquestAccount absolute buffer;
  crs: IMongoCursor;
  packetResp : TReceiveAccount;
  Account: TAccountFileClass;
  Found : Boolean;
  json : string;
  accountId : String;
begin
  crs := DMDataBase.FConMongo['wyd']['account'].Find().Match.Add('header.username', packet.Login).&End;
  Found := crs.Next;
  if (Found) then
  begin
    json := crs.Doc.AsJSON;
    Account := TJson.JsonToObject<TAccountFileClass>(json);
  end;

  ZeroMemory(@packetResp, sizeof(TReceiveAccount));
  packetResp.Header.Size := sizeof(TReceiveAccount);
  packetResp.Header.Code := $4;
  packetResp.Header.Index := 7000;
  packetResp.ClientId := packet.ClientId;
  packetResp.Found := Found;
  if (not Found) then
  begin
    gameServer.SendPacket(@packetResp, 20);
    exit;
  end;

  if (Account.Header.Password <> packet.PassWord) then
  begin
    packetResp.WrongPassWord := True;
    gameServer.SendPacket(@packetResp, 24);
    exit;
  end;

  accountId := TJSONObject.ParseJSONValue(json).GetValue<string>('_id.$oid');
  if (Account.Header.IsActive) then
  begin
    packetResp.IsActive := True;
    gameServer.SendPacket(@packetResp, 28);
    TFunctions.DisconnectAccount(Account.Header.ServerIdActive, accountId);
    DMDataBase.UpdateActive(False, accountId, 0);
    exit;
  end;

  ZeroMemory(@packetResp.Account, sizeof(TAccountFile));
  packetResp.Account := Account;
  packetResp.Account.Header.AccountId := accountId;
  gameServer.SendPacket(@packetResp, packetResp.Header.Size);

  Account.Header.IsActive := True;
  DMDataBase.UpdateActive(True, accountId, gameServer.clientId);
end;

end.

