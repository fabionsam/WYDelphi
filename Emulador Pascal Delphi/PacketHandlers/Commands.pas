unit Commands;

interface

  Uses MiscData, Player, BaseMob,
   Windows, Messages, SysUtils, Variants, Classes, DateUtils,
   Packets, MMSystem,
   ItemFunctions, GuildFunctions;

  type
    TCommands = class(TObject)
    public
      class function Received(player : TPlayer; var buffer: array of BYTE) : Boolean;

    private
      class procedure Dir(player : TPlayer; command : TCommandPacket); static;
      class procedure Item(player : TPlayer; packet : TCommandPacket); static;
      class procedure Tab(player : TPlayer; command : TCommandPacket); static;
      class procedure Teleport(player : TPlayer; command : TCommandPacket); static;
      class procedure UpdateArea(player : TPlayer; command : TCommandPacket); static;
      class procedure PrivateMessage(player : TPlayer; packet: TCommandPacket); static;
  end;

implementation

uses GlobalDefs, ConstDefs, Functions, Position;

class procedure TCommands.Dir(player : TPlayer; command: TCommandPacket);
{var year, month, day : Word;
    str : string;}
begin
  player.Character.CurrentScore.Direction := StrToInt(command.Value);
  player.Character.BaseScore.Direction := StrToInt(command.Value);
  player.SendCreateMob(1);
end;

class function TCommands.Received(player : TPlayer; var buffer: array of BYTE) : Boolean;
var packet : TCommandPacket absolute buffer;
begin
  Result := true;
  if(AnsiCompareText(packet.Command, 'day') = 0) then
    player.SendClientMessage('!#11  2')
//    exit
  else if(AnsiCompareText(packet.Command, 'dir') = 0) then
    Dir(player, packet)
  else if(AnsiCompareText(packet.Command, 'item') = 0) then
    Item(player, packet)
  else if(AnsiCompareText(packet.Command, 'tab') = 0) then
    Tab(player, packet)
  else if(AnsiCompareText(packet.Command, 'snd') = 0) then
    player.SND := packet.Value
  else if(AnsiCompareText(packet.Command, 'update') = 0) then
    UpdateArea(player, packet)
  else if(AnsiCompareText(packet.Command, 'create') = 0) then
  begin
    TGuildFunctions.CreateGuild(player, packet);
  end
  else if(AnsiCompareText(packet.Command, 'expulsar') = 0) then
  begin
    if (player.Character.GuildIndex <> 0) and (player.Character.GuildMemberType < 2) then
    begin
      player.Character.GuildIndex := 0;
      player.Character.GuildMemberType := 0;
      ZeroMemory(@player.Character.Equip[integer(TEquipSlot.Guild)],8);
      player.SendCreateItem(EQUIP_TYPE, integer(TEquipSlot.Guild), player.Character.Equip[integer(TEquipSlot.Guild)]);
      player.SendClientMessage('Você saiu da guild.');
    end;
  end
  else if(AnsiCompareText(packet.Command, 'Fim da Aliança') = 0) then
  begin
    //não implementado guilds
  end
  else if(AnsiCompareText(packet.Command, 'goto') = 0) then begin
    Teleport(player, packet);
  end
  else if(AnsiCompareText(packet.Command, 'gold') = 0) then begin
    if(strtoint(packet.Value) > 2000000000)then
      player.Character.Gold := 2000000000
    else
      player.Character.Gold := strtoint(packet.Value);
    player.RefreshMoney;
  end
  else if(AnsiCompareText(packet.Command, 'LearnPoints') = 0) then
  begin
    player.Character.pMaster := strtoint(packet.Value);
    player.SendEtc;
  end
  else if(AnsiCompareText(packet.Command, 'StatPoints') = 0) then
  begin
    player.Character.pStatus := strtoint(packet.Value);
    player.SendEtc;
  end
  else if(AnsiCompareText(packet.Command, 'SkillPoints') = 0) then
  begin
    player.Character.pSkill := strtoint(packet.Value);
    player.SendEtc;
  end
  else if(AnsiCompareText(packet.Command, 'SetLevel') = 0) then
  begin
    player.Character.BaseScore.Level := StrToInt(packet.Value);
    player.SendScore;
  end
  else if(AnsiCompareText(packet.Command, 'Teleport') = 0) then
  begin
    Teleport(player, packet);
  end
  else if(AnsiCompareText(packet.Command, 'GetDirection') = 0) then
  begin
    player.SendClientMessage(inttostr(player.Character.CurrentScore.Direction));
  end
  else if(AnsiCompareText(packet.Command, 'SetDirection') = 0) then
  begin
    player.Character.CurrentScore.Direction := StrToInt(packet.Value);
    player.SendCreateMob(0, player.ClientId);
  end
  else if(AnsiCompareText(packet.Command, 'Disconnect') = 0) then
  begin
    player.Disconnect;
  end
  else if(AnsiCompareText(packet.Command, 'exp') = 0) then
  begin
    player.AddExp(StrToInt(packet.Value), 1);
  end
  else
  begin
    PrivateMessage(player, packet);
  end;
end;

class procedure TCommands.Tab(player: TPlayer; command: TCommandPacket);
begin
  Move(command.Value, player.Character.Tab[0], 26);
  player.SendCreateMob(SPAWN_NORMAL);
end;

class procedure TCommands.Teleport(player: TPlayer; command: TCommandPacket);
var Strings : TStringList; line: string; pos: TPosition;
begin
  line := command.Value;
  Strings := TStringList.Create;
  ExtractStrings([' '], [#0], pChar(line), Strings);

  pos := TPosition.Create(StrToInt(Strings[0]), StrToInt(Strings[1]));
  if not(TFunctions.GetEmptyMobGrid(player.ClientId, pos)) then
  begin
    FreeAndNil(Strings);
    exit;
  end;
  player.Teleport(pos);
  FreeAndNil(Strings);
end;

class procedure TCommands.UpdateArea(player: TPlayer;
  command: TCommandPacket);
begin
  player.ForEachVisible(procedure(mob: TBaseMob)
  begin
    mob.SendCreateMob(SPAWN_NORMAL, 1);
  end);
end;

class procedure TCommands.Item(player : TPlayer; packet: TCommandPacket);
var i: WORD; Strings : TStringList; line: string; item: TItem;
begin
  line := packet.Value;
  Strings := TStringList.Create;
  ExtractStrings([' '], [#0], pChar(line), Strings);
  for i := Strings.Count - 1 to 6 do
    Strings.Add(' ');
  if Strings.Strings[0] = ' ' then
  begin
    FreeAndNil(Strings);
    exit;
  end;

  item.Index            := strtoint(Strings.Strings[0]);
  item.Effects[0].Index := strtointdef(Strings.Strings[1], 0);
  item.Effects[1].Index := strtointdef(Strings.Strings[3], 0);
  item.Effects[2].Index := strtointdef(Strings.Strings[5], 0);
  item.Effects[0].Value := strtointdef(Strings.Strings[2], 0);
  item.Effects[1].Value := strtointdef(Strings.Strings[4], 0);
  item.Effects[2].Value := strtointdef(Strings.Strings[6], 0);

  TItemFunctions.PutItem(player, item);
  FreeAndNil(Strings);
end;

class procedure TCommands.PrivateMessage(player : TPlayer; packet: TCommandPacket);
var otherClient : WORD; otherPlayer : TPlayer;
begin
  if (packet.Command = player.Character.Name) then
  begin
    player.SendClientMessage(player.Character.Name+'  Fama: 0  Level: ' + inttostr(player.Character.CurrentScore.Level+1));
    exit;
  end;

  //mensagem ao player
  if (PlayersNick.TryGetValue(packet.Command,otherClient)) then
  begin
    //player online
    player.GetPlayer(otherClient, otherPlayer);
    if (packet.Value = '') then
    begin
      if (Trim(otherPlayer.SND) <> '') then
        player.SendClientMessage('SND: ' +otherPlayer.SND)
      else
        player.SendClientMessage(otherplayer.Character.Name+'  Fama: 0  Level: ' + inttostr(otherplayer.Character.CurrentScore.Level+1));
    end
    else
    begin
      Move(player.Character.Name, packet.Command, 16);
      otherPlayer.SendPacket(@packet, packet.Header.Size);

      if (Trim(otherPlayer.SND) <> '') then
        player.SendClientMessage('SND: ' +otherPlayer.SND);
    end;
  end
  else
  begin
    //player offline
    player.SendClientMessage('Este jogador não está disponível.');
  end;
end;

end.
