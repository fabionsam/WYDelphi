unit GuildFunctions;

interface

Uses MiscData, DateUtils,
   Windows, Messages, SysUtils, Variants, Classes,
   Packets, Player, BaseMob, Functions;

type TGuildFunctions = class(TObject)
  public
    class function CreateGuild(var player: TPlayer; packet: TCommandPacket) : integer;
    class function RecruitGuildMember(var player: TPlayer; var buffer: array of BYTE) : integer;
    class function RemoveGuildMember(var player: TPlayer; var buffer: array of BYTE) : integer;
    class function DeclareAlliance(var player: TPlayer; var buffer: array of BYTE) : integer;
  private
    class function GuildExists(name: string) : Boolean;
end;

implementation

uses GlobalDefs, ConstDefs, ItemFunctions;

class function TGuildFunctions.DeclareAlliance(var player: TPlayer;
  var buffer: array of BYTE): integer;
var
  packet: TDeclareAlliance absolute buffer;
  otherPlayer : TPlayer;
  guild: TGuildData;
  DataFile : TextFile;
begin
  player.GetPlayer(packet.otherClient, otherPlayer);
  if (otherPlayer.Character.GuildIndex = player.Character.GuildIndex) or (player.Character.GuildMemberType <> 2) then
  begin
    player.SendClientMessage('Não é possivel declarar aliança.');
    exit;
  end;

  Guilds[player.Character.GuildIndex].Alianca := otherPlayer.Character.GuildIndex;
  //Guilds[otherPlayer.Character.GuildIndex].Alianca := player.Character.GuildIndex;


  TFunctions.SendWorldMessage('Guild '+ Guilds[player.Character.GuildIndex].Nome + ' se aliou à guild ' + Guilds[otherPlayer.Character.GuildIndex].Nome);
end;

class function TGuildFunctions.GuildExists(name: string) : Boolean;
begin
  if(FileExists(CurrentDir+'\Guilds\' + Trim(name))) then
    result := true
  else
    result := false;
end;

class function TGuildFunctions.CreateGuild(var player: TPlayer; packet: TCommandPacket) : integer;
var guild: TGuildData; DataFile : TextFile; item: TItem;
begin
  if player.Character.Gold < 100000000 then
  begin
    player.SendClientMessage('Gold insuficiente.');
    exit;
  end;

  if player.Character.Equip[integer(TEquipSlot.Guild)].Index <> 0 then
  begin
    player.SendClientMessage('Você já faz parte de uma guild.');
    exit;
  end;


  if not(GuildExists(packet.Value)) then
  begin
    inc(LastGuildId);
    guild.ID      := LastGuildId;
    guild.Alianca := 0;
    guild.Nome    := packet.Value;

    AssignFile(DataFile, CurrentDir+'\Guilds\' + Trim(guild.Nome));
    ReWrite(DataFile);
    WriteLn(DataFile, guild.ID);
    CloseFile(DataFile);

    AssignFile(DataFile, 'Guilds.txt');
    Append(DataFile);
    WriteLn(DataFile, guild.ID, ',0,', guild.Nome);
    CloseFile(DataFile);

    Guilds.Add(guild.ID, guild);

    item.Index            := 509;
    item.Effects[0].Index := 56;
    item.Effects[1].Index := 57;
    item.Effects[2].Index := 85;
    item.Effects[0].Value := WordRec(guild.ID).Hi;
    item.Effects[1].Value := WordRec(guild.ID).Lo;
    item.Effects[2].Value := 2;
    Move(item,player.Character.Equip[integer(TEquipSlot.Guild)],8);
    player.SendCreateItem(EQUIP_TYPE, integer(TEquipSlot.Guild), item);
    player.Character.GuildIndex := guild.ID;
    player.Character.GuildMemberType := 2;

    Dec(player.Character.Gold, 100000000);
    player.RefreshInventory;
    player.SendClientMessage('Guild criada com sucesso.');
  end
  else
    player.SendClientMessage('Nome de guild já utilizado. Escolha outro nome.');
end;

class function TGuildFunctions.RecruitGuildMember(var player: TPlayer; var buffer: array of BYTE) : integer;
var packet : TRecruitGuildMember absolute buffer; otherPlayer : TPlayer; item: TItem;
begin
  if player.Character.Gold < 4000000 then
  begin
    player.SendClientMessage('Gold insuficiente.');
    exit;
  end;

  player.GetPlayer(packet.otherClient, otherPlayer);
  if otherPlayer.Character.Equip[integer(TEquipSlot.Guild)].Index <> 0 then
  begin
    player.SendClientMessage('O outro player já faz parte de uma guild.');
    exit;
  end;

  item.Index            := 508;
  item.Effects[0].Index := 56;
  item.Effects[1].Index := 57;
  item.Effects[2].Index := 85;
  item.Effects[0].Value := WordRec(player.Character.GuildIndex).Hi;
  item.Effects[1].Value := WordRec(player.Character.GuildIndex).Lo;
  item.Effects[2].Value := player.Character.Equip[integer(TEquipSlot.Guild)].Effects[2].Value;
  Move(item,otherPlayer.Character.Equip[integer(TEquipSlot.Guild)],8);
  otherPlayer.SendCreateItem(EQUIP_TYPE, integer(TEquipSlot.Guild), item);
  otherPlayer.Character.GuildIndex := player.Character.GuildIndex;
  otherPlayer.Character.GuildMemberType := packet.memberType;

  Dec(player.Character.Gold, 4000000);
  player.RefreshInventory;
  otherPlayer.SendClientMessage('Você foi recrutado para a guild '+Guilds[otherPlayer.Character.GuildIndex].Nome);
  player.SendClientMessage('Membro recutado com sucesso.');

end;

class function TGuildFunctions.RemoveGuildMember(var player: TPlayer; var buffer: array of BYTE) : integer;
var packet : TRemoveGuildMember absolute buffer; otherPlayer : TPlayer;
begin
  player.GetPlayer(packet.otherClient, otherPlayer);
  if (otherPlayer.Character.GuildIndex <> player.Character.GuildIndex) or (player.Character.GuildMemberType < otherPlayer.Character.GuildMemberType) then
  begin
    player.SendClientMessage('Não é possivel expulsar.');
    exit;
  end;

  ZeroMemory(@otherPlayer.Character.Equip[integer(TEquipSlot.Guild)],8);
  otherPlayer.SendCreateItem(EQUIP_TYPE, integer(TEquipSlot.Guild), otherPlayer.Character.Equip[integer(TEquipSlot.Guild)]);
  otherPlayer.Character.GuildIndex := player.Character.GuildIndex;

  player.RefreshInventory;
  otherPlayer.SendClientMessage('Você foi expulso da guild '+Guilds[otherPlayer.Character.GuildIndex].Nome);
  player.SendClientMessage('Membro expulso com sucesso.');

end;

{
3d5 - dar guild 20
e12 - desafio pvp 20
39f - aliado 20
e0e - guerra 20
28c - expulsar 16

}

end.
