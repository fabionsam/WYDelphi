unit Shany;

interface

Uses MiscData, PlayerData,
   Windows, Messages, SysUtils, Variants, Classes,
   ScktComp, Packets, Player, MMSystem;


  type
    ShanyClass = class(TObject)
    public
      function GetMatchCombine(var player : TPlayer; slot : Byte) : boolean;
      function ShanyProc(var player : TPlayer; var buffer: array of Byte) : Boolean;
  end;

var pedras: array[0..4] of WORD = (540,541,631,632,633);

implementation

Uses GlobalDefs, NpcFunctions, ItemFunctions;

function ShanyClass.ShanyProc(var player : TPlayer; var buffer: array of Byte): Boolean;
var
  i: Byte;
  packet : TCompoundersPacket absolute buffer;
  find: array[0..2] of boolean;
begin
 if(player.Character.Equip[0].Effects[1].Index <> 98) or (player.Character.Equip[0].Effects[1].Value < 2) or
   (player.Character.BaseScore.Level < 355)then
  begin
    player.SendClientMessage('Necessário ser arch level 356 ou superior.');
    player.SendSignal($7530, $3A7);
		exit;
  end;

  result := True;
  if(player.Character.Gold < 500000)then
  begin
    player.SendClientMessage('Deve ter pelo menos 500.000 de gold no inventário.');
    player.SendSignal($7530, $3A7);
		exit;
  end;

  for i := 0 to 1 do
    if(TItemFunctions.GetSanc(packet.item[i]) <> 9)then
    begin
      player.SendClientMessage('Os itens devem ser +9.');
      player.SendSignal($7530, $3A7);
		  exit;
    end;

  for i := 0 to 5do
  begin
    if(packet.item[0].Index = pedras[i])then
      find[0] := true;
    if(packet.item[1].Index = pedras[i])then
      find[1] := true;
    if(packet.item[2].Index = pedras[i])then
      find[2] := true;
  end;

  if(not find[0]) or (not find[1]) or (not find[2]) or (not CompareMem(@packet.Item[0], @player.Character.Inventory[packet.slot[0]], sizeof(TItem)))
  or (not CompareMem(@packet.Item[1], @player.Character.Inventory[packet.slot[1]], sizeof(TItem))) or
  (not CompareMem(@packet.Item[2], @player.Character.Inventory[packet.slot[2]], sizeof(TItem)))then
  begin
    player.SendClientMessage('Combinação incorreta.');
    player.SendSignal($7530, $3A7);
    exit;
  end;
  for i := 3 to 6 do
  begin
    if (packet.Item[i].Index <> 413) or (player.Character.Inventory[packet.slot[i]].Index <> 413)
    or (packet.item[i].Index = 0) or (player.Character.Inventory[packet.slot[i]].Index = 0 )then
    begin
      player.SendClientMessage('Deve adicionar as 4 poeiras de lactolerium.');
      player.SendSignal($7530, $3A7);
      exit;
    end;
  end;
  randomize;
  if (Random(100)+1 <= 40)then
  begin
    player.SendClientMessage('Falhou na composição.');
    for i := 2 to 6 do
      TItemFunctions.DeleteItemSlot(player, packet.slot[i]);
    dec(player.Character.Gold, 500000);
    player.SendSignal($7530, $3A7);
    player.SendEtc;
  end
  else
  begin
    player.SendClientMessage('Obteve sucesso na composição.');
    for i := 0 to 6 do
      TItemFunctions.DeleteItemSlot(player, packet.slot[i]);
    GetMatchCombine(player,packet.slot[0]);
    dec(player.Character.Exp, 2000000);
    player.SendSignal($7530, $3A7);
    player.SendEtc;
  end;
end;

function ShanyClass.GetMatchCombine(var player : TPlayer; slot : Byte) : boolean;
var num: BYTE;
begin
  (*Dano magico 6 ~ 9% + HP 50 ~ 80 ou Defesa 18 ~ 23
  Dano fisico 15 ~ 18 + Critico 3 ~ 5 ou Defesa 15 ~ 19 {antigo}*)
//  player.Character.Inventory[slot].Index := pedras[Random(3)+2];
//  player.Character.Inventory[slot].Effects[0].Index := EF_HP;
//  player.Character.Inventory[slot].Effects[0].Value := 100;
//  player.SendCreateItem(INV_TYPE, slot, player.Character.Inventory[slot]);
  randomize;
  case Random(1) of
    0:
    begin
      randomize;
      player.Character.Inventory[slot].Effects[0].Index := 60;
      player.Character.Inventory[slot].Effects[0].Value := Random(4) + 6;
      randomize;
      if (Random(2) = 0) then
      begin
        randomize;
        player.Character.Inventory[slot].Effects[1].Index := 4;
        player.Character.Inventory[slot].Effects[1].Value := Random(31) + 50;
      end
      else
      begin
        randomize;
        player.Character.Inventory[slot].Effects[1].Index := 3;
        player.Character.Inventory[slot].Effects[1].Value := Random(6) + 18;
      end;
      player.Character.Inventory[slot].Effects[2].Index := 43;
      player.Character.Inventory[slot].Effects[2].Value := 0;
    end;
    1:
    begin
      randomize;
      player.Character.Inventory[slot].Effects[0].Index := 2;
      player.Character.Inventory[slot].Effects[0].Value := Random(4) + 15;
      randomize;
      if (Random(2) = 0) then
      begin
        randomize;
        player.Character.Inventory[slot].Effects[1].Index := 42;
        player.Character.Inventory[slot].Effects[1].Value := Random(3) + 3;
      end
      else
      begin
        randomize;
        player.Character.Inventory[slot].Effects[1].Index := 3;
        player.Character.Inventory[slot].Effects[1].Value := Random(5) + 15;
      end;
      player.Character.Inventory[slot].Effects[2].Index := 43;
      player.Character.Inventory[slot].Effects[2].Value := 0;
    end;
  end;
end;

end.
