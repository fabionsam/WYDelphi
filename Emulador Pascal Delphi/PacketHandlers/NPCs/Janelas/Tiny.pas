unit Tiny;

interface

Uses MiscData, PlayerData, ItemFunctions,
   Windows, Messages, SysUtils, Variants, Classes,
   ScktComp, Packets, Player, MMSystem;


  type
    TinyClass = class(TObject)
    public
      function GetMatchCombine(item: TItem; var player : TPlayer; slot: BYTE) : integer;
      function CompareArmasArch(itemId: integer): boolean;
      function GetSancBonus(sanc: WORD; typ: BYTE) : integer;
      function TinyProc(var player : TPlayer; var buffer: array of Byte): Boolean;
  end;

implementation

Uses GlobalDefs, NpcFunctions;

const
  itens       : array[0..9] of WORD = (826,841,811,912,871,937,886,856,904,903);
  itensDmenor : array[0..9] of WORD = (869,960,809,970,2137,2127,839,824,884,907);
  itensDmaior : array[0..9] of WORD = (870,911,810,936,855,2130,2128,840,825,885);
  itensE      : array[0..9] of WORD = (3571,3591,3551,3596,3566,3581,3582,3561,3556,3576);

function TinyClass.TinyProc(var player : TPlayer; var buffer: array of Byte): Boolean;
var p : TCompoundersPacket absolute buffer; chance,
    timesrv: integer; i: BYTE; ret: boolean;
begin
  result := True;
  ret := CompareArmasArch(p.Item[0].Index);

	if(not ret) or (not CompareMem(@p.Item[0],@player.Character.Inventory[p.slot[0]],8)) or
  (not CompareMem(@p.Item[1],@player.Character.Inventory[p.slot[1]],8)) or
  (not CompareMem(@p.Item[2],@player.Character.Inventory[p.slot[2]],8)) or
	(ItemList[p.Item[0].Index].Pos <> ItemList[p.Item[1].Index].Pos) or
  (TItemFunctions.GetSanc(player.Character.Inventory[p.slot[2]]) < 9)then
  begin
		player.SendClientMessage('Combinação incorreta.');
		player.SendSignal($7530, $3A7);
    exit;
	end;
	if(player.Character.Gold < 100000000)then
  begin
		player.SendClientMessage('Necessário 100 Milhões de gold.');
		player.SendSignal($7530, $3A7);
		exit;
	end;
  //isso pode estar errado
  if(ItemList[p.Item[2].Index].Grade < 4)then
  begin
		player.SendClientMessage('Item deve ser grade [D] ou maior.');
		player.SendSignal($7530, $3A7);
		exit;
	end;
	chance := GetMatchCombine(p.Item[1], player, p.slot[1]);
	if (chance = 0)then
  begin
		player.SendClientMessage('Combinação incorreta.');
		player.SendSignal($7530, $3a7);
		exit;
	end;
  Randomize;
	timesrv := random(100);
  inc(timesrv);
	if(timesrv <= chance)then
  begin
		player.SendClientMessage('Falhou na transferência dos adicionais.');
		dec(player.Character.Gold,100000000);
		for i := 0 to 2 do
    begin
      ZeroMemory(@player.Character.Inventory[p.slot[i]], 8);
    end;
    player.RefreshInventory;
		player.SendSignal($7530, $3a7);
		exit;
	end
  else
  begin
		player.SendClientMessage('Obteve sucesso na transferência dos adicionais.');
		dec(player.Character.Gold,100000000);
		Move(player.Character.Inventory[p.slot[1]].Effects[0].Index, player.Character.Inventory[p.slot[0]].Effects[0].Index,6);
    TItemFunctions.SetSanc(player.Character.Inventory[p.slot[0]],7);
		for i := 1 to 2 do
      ZeroMemory(@player.Character.Inventory[p.slot[i]], 8);
    player.RefreshInventory;
    player.SendSignal($7530, $3a7);
		exit;
	end;
end;


function TinyClass.CompareArmasArch(itemId: integer): boolean;
var i: BYTE; dif: integer;
begin
  result := false;
	for i := 0 to 9 do begin
		dif := itemId - ItemList[itens[i]].Extreme;
		if(dif >= 0) and (dif <= 3)then
			result := true;
	end;
end;


function TinyClass.GetMatchCombine(item: TItem; var player : TPlayer; slot: BYTE): integer;
var ref,chance,dif,dif2,dif3 : WORD; i: BYTE;
begin
	ref    := TItemFunctions.GetSanc(player.Character.Inventory[slot]);
	chance := 0;
  result := 0;
	for i := 0 to 9 do
  begin
		dif  := item.Index - ItemList[itensDmenor[i]].Extreme;
		dif2 := item.Index - ItemList[itensDmaior[i]].Extreme;
		dif3 := item.Index - ItemList[itensE[i]].Extreme;
		if(dif >= 0) and (dif <= 3) then begin
			chance := GetSancBonus(ref,1);
      inc(chance,19);
			result := chance;
      break;
		end else if(dif2 >= 0) and (dif2 <= 3) then begin
			chance := GetSancBonus(ref,2);
      inc(chance,19);
			result := chance;
      break;
		end else if(dif3 >= 0) and (dif3 <= 3) then begin
			chance := GetSancBonus(ref,3);
      inc(chance,19);
			result := chance;
      break;
		end else result := 0;
  end;
end;

function TinyClass.GetSancBonus(sanc: WORD; typ: BYTE) : integer;
begin
  result := 0;
	if(sanc=9)then
	begin
		if (typ = 1)then
		  result := 6;
		if (typ = 2)then
		  result := 10;
		if (typ = 3)then
		  result := 14;
	end;
	if(sanc=10)then
	begin
		if (typ = 1)then
		  result := 18;
		if (typ = 2)then
		  result := 22;
		if (typ = 3)then
		  result := 26;
  end;
	if(sanc=11)then
	begin
		if (typ = 1)then
		  result := 23;
		if (typ = 2)then
		  result := 28;
		if (typ = 3)then
		  result := 34;
	end;
end;

end.
