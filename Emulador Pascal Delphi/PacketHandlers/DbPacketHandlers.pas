unit DbPacketHandlers;

interface

type TDbPacketHandlers = class(TObject)
  public
    class function ReceiveId(var buffer: array of Byte): Boolean;
    class function ReceiveAccount(var buffer: array of Byte): Boolean;
    class function ReceiveDisconnectDbServer(): Boolean;
    class function ReceiveCreateCharacter(var buffer: array of Byte): Boolean;
    class function ReceiveDisconnectAccount(var buffer: array of Byte): Boolean;
end;

implementation

uses
  PacketsDbServer, GlobalDefs, Player, Functions, PlayerData, Log, InitialCharactersLoader;

{ TDbPacketHandlers }

class function TDbPacketHandlers.ReceiveCreateCharacter(var buffer: array of Byte): Boolean;
var
  packet: TRespCreateCharacterDb absolute buffer;
  player : TPlayer;
begin
  TPlayer.GetPlayer(packet.ClientId, player);
  if (packet.Exists) then begin
    player.SendClientMessage('Este nome já está sendo utilizado.');
    exit;
  end;

  Move(InitialCharacters[packet.ClassIndex], player.Account.Characters[packet.SlotIndex].Base, sizeof(TCharacter));
  Move(packet.CharacterName, player.Account.Characters[packet.SlotIndex].Base.Name[0], 16);
  player.Account.Characters[packet.SlotIndex].Base.ChaosPoint := 0;
  player.Account.Characters[packet.SlotIndex].Base.CurrentScore.MoveSpeed := 2;
  player.Account.Characters[packet.SlotIndex].Base.Last := TFunctions.GetStartXY(player, packet.SlotIndex);
  player.SendCharList($110);
  player.WaitingDbServer := False;
  Result := True;
end;

class function TDbPacketHandlers.ReceiveDisconnectAccount(
  var buffer: array of Byte): Boolean;
var
  packet : TAccountDisconnect absolute buffer;
  accountId : String;
begin
  accountId := packet.AccountId;
  TPlayer.ForEach(procedure(player : TPlayer)
  begin
    if (Player.Account.Header.AccountId = accountId) then
      player.Disconnect;
  end
  );
end;

class function TDbPacketHandlers.ReceiveDisconnectDbServer(): Boolean;
begin
  DbClient.Disconnect;
end;

class function TDbPacketHandlers.ReceiveId(
  var buffer: array of Byte): Boolean;
var
  packet: TSendRecServerId absolute buffer;
begin
  DbClient.ServerId := packet.ServerId;
  Result := True;
end;

class function TDbPacketHandlers.ReceiveAccount(var buffer: array of Byte): Boolean;
var
  packet : TReceiveAccount absolute buffer;
  player : TPlayer;
  passWord : String;
begin
  TPlayer.GetPlayer(packet.ClientId, player);
  if not(packet.Found) then
  begin
    player.Status := AccNotFound;
    player.SendClientMessage('Conta não encontrada!');
    player.Disconnect();
    exit;
  end;

  if(packet.WrongPassWord) then
  begin
    player.SendClientMessage('Senha incorreta!');
    player.Disconnect();
    exit;
  end;

  if(packet.IsActive) then
  begin
    player.SendClientMessage('Conexão anterior finalizada!');
    player.Disconnect();
    exit;
  end;

  Move(packet.Account, player.Account, sizeof(TAccountFile));
  player.SendCharListFromLogin;
  player.WaitingDbServer := False;
  Result := true;
end;

end.
