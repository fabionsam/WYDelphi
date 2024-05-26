unit Lindy;

interface

Uses MiscData, PlayerData,
   Windows, Messages, SysUtils, Variants, Classes,
   ScktComp, Packets, Player, MMSystem;


  type
    LindyClass = class(TObject)
    public
      function LindyProc(var player : TPlayer; var buffer: array of Byte) : Boolean;
  end;

implementation

Uses GlobalDefs, NpcFunctions, ItemFunctions;

function LindyClass.LindyProc(var player : TPlayer; var buffer: array of Byte) : Boolean;
var
  i: BYTE;
  find : boolean;
  packet : TCompoundersPacket absolute buffer;
begin
  result := true;
  if(player.Character.Equip[0].Effects[1].Index <> 98) or (player.Character.Equip[0].Effects[1].Value < 2)then
  begin
    player.SendClientMessage('Necessário ser arch lvl 355 ou 370.');
    player.SendSignal($7530, $3A7);
		exit;
  end;

  find := true;
  for i := 3 to 6 do
  begin
    if player.Character.Inventory[packet.Slot[i]].Index <> 413 then
    begin
      find := false;
      break;
    end;
  end;

  if (TItemFunctions.GetItemAmount(player.Character.Inventory[packet.Slot[0]]) <> 10) or
     (TItemFunctions.GetItemAmount(player.Character.Inventory[packet.Slot[1]]) <> 10) or
     (player.Character.Inventory[packet.Slot[2]].Index <> 4127) or
     (not find)then
  begin
    player.SendClientMessage('Combinação incorreta.');
    player.SendSignal($7530, $3A7);
		exit;
  end;

  if(player.Character.BaseScore.Level = 354) or (player.Character.BaseScore.Level = 369)then
  begin
    if (player.Character.BaseScore.Level = 354) then
      player.PlayerCharacter.CharacterQuests.ArchDesbloq355 := True;

    if(player.Character.BaseScore.Level = 369) and (player.PlayerCharacter.Fame < 1)then
    begin
      player.SendClientMessage('É necessário ter ao menos 1 de fama.');
      player.SendSignal($7530, $3A7);
      exit;
    end
    else
    begin
      dec(player.PlayerCharacter.Fame);
      player.PlayerCharacter.CharacterQuests.ArchDesbloq370 := True;
    end;

    for i := 0 to 6 do
      TItemFunctions.DeleteItemSlot(player, packet.slot[i]);
    player.SendSignal($7530, $3A7);
    player.SendClientMessage('Desbloqueio feito com sucesso!');
  end
  else
  begin
    player.SendClientMessage('Level inapropriado.');
    player.SendSignal($7530, $3A7);
  end;
end;

end.
