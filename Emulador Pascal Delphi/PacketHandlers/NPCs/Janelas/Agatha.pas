unit Agatha;

interface

Uses MiscData, PlayerData,
   Windows, Messages, SysUtils, Variants, Classes,
      ScktComp, Packets,  Player, MMSystem;


  type
    AgathaClass = class(TObject)
    public
      function GetMatchCombine(item: TItem; slot: BYTE): BYTE;
      function AgathaProc(var player : TPlayer; var buffer: array of Byte): Boolean;
      function CompareItensArch(itemId: Word): Boolean;
  end;

implementation

Uses GlobalDefs, NpcFunctions, ItemFunctions, Util;

function AgathaClass.AgathaProc(var player : TPlayer; var buffer: array of Byte): Boolean;
var
  i, chance: Byte;
  packet : TCompoundersPacket absolute buffer;
begin
  result := True;
	if (not CompareItensArch(packet.Item[0].Index)) or (not CompareMem(@packet.Item[0], @player.Character.Inventory[packet.slot[0]], sizeof(TItem))) or
     (not CompareMem(@packet.Item[1], @player.Character.Inventory[packet.slot[1]], sizeof(TItem))) or
	   (ItemList[packet.Item[0].Index].Pos <> ItemList[packet.Item[1].Index].Pos)then
  begin
		player.SendClientMessage('Combinação incorreta.');
		player.SendSignal($7530, $3A7);
    exit;
	end;
	chance := GetMatchCombine(packet.Item[1], packet.slot[1]);
	if(chance = 0)then
  begin
		player.SendClientMessage('Combinação incorreta.');
		player.SendSignal($7530, $3A7);
    exit;
	end;
  for i := 2 to 5 do
  begin
    if(packet.Item[i].Index <> 3140) or (player.Character.Inventory[packet.slot[i]].Index <> 3140)then
    begin
      player.SendClientMessage('Deve adicionar 4 pedras da luz.');
      player.SendSignal($7530, $3A7);
      exit;
    end;
  end;

	randomize;
	if (Random(100)+1 <= chance) then
  begin
		player.SendClientMessage('Falhou na transferência dos adicionais.');
		for i := 0 to 5 do
			TItemFunctions.DeleteItemSlot(player,packet.slot[i]);
		player.SendSignal($7530, $3A7);
    player.RefreshInventory;
	end
  else
  begin
		player.SendClientMessage('Obteve sucesso na transferência dos adicionais.');
    Move(player.Character.Inventory[packet.slot[1]].Effects[0].Index, player.Character.Inventory[packet.slot[0]].Effects[0].Index,6);
		TItemFunctions.SetSanc(player.Character.Inventory[packet.slot[0]],7);
		for i := 1 to 5 do
			TItemFunctions.DeleteItemSlot(player,packet.slot[i]);
		player.SendSignal($7530, $3A7);
    player.RefreshInventory;
	end;
end;

function AgathaClass.CompareItensArch(itemId: Word): Boolean;
var dif: Word;
begin
	dif := itemId - 1221;
	if((dif >= 0) and (dif <=3)) or ((dif >= 135) and (dif <= 138)) or ((dif >= 285) and (dif <= 288))
	or ((dif >= 435) and (dif <= 438))then
	  result := true
  else
	  result := false;
end;

function AgathaClass.GetMatchCombine(item: TItem; slot: BYTE): BYTE;
var chance : BYTE;
begin
	chance := ((TItemFunctions.GetSanc(item)-9)*8)+10;
	chance := IfThen(chance in [18,26], chance+19, 19);

	if((item.Index >= 1191) and (item.Index <= 1205)) or ((item.Index >= 1326) and (item.Index <= 1340)) or
	((item.Index >= 1476) and (item.Index <= 1490)) or ((item.Index >= 1626) and (item.Index <= 1640)) or
	((item.Index >= 2181) and (item.Index <= 2185)) or ((item.Index >= 2201) and (item.Index <= 2205)) or
	((item.Index >= 2221) and (item.Index <= 2225)) or ((item.Index >= 2241) and (item.Index <= 2245)) then
		inc(chance,ItemList[item.Index].Grade * 4)
	else
	if((item.Index >= 1206) and (item.Index <= 1220)) or ((item.Index >= 1341) and (item.Index <= 1355)) or
	((item.Index >= 1491) and (item.Index <= 1505)) or ((item.Index >= 1641) and (item.Index <= 1655)) or
	((item.Index >= 2186) and (item.Index <= 2190)) or ((item.Index >= 2206) and (item.Index <= 2210)) or
	((item.Index >= 2226) and (item.Index <= 2230)) or ((item.Index >= 2246) and (item.Index <= 2250)) then
		inc(chance,(ItemList[item.Index].Grade+1) * 6)
	else
	if((item.Index >= 1225) and (item.Index <= 1229)) or ((item.Index >= 1360) and (item.Index <= 1364)) or
	((item.Index >= 1510) and (item.Index <= 1514)) or ((item.Index >= 1660) and (item.Index <= 1664)) or
	((item.Index >= 3801) and (item.Index <= 3805)) or ((item.Index >= 3821) and (item.Index <= 3825)) or
	((item.Index >= 3841) and (item.Index <= 3845)) or ((item.Index >= 3861) and (item.Index <= 3865))then
  begin
		if(ItemList[item.Index].Grade = 1)then inc(chance,26)
		else if(ItemList[item.Index].Grade = 4)then inc(chance,32);
  end
  else
		chance := 0;

	result := IfThen(chance > 77, 77, chance);
end;

end.
