unit Aylin;

interface

Uses MiscData, PlayerData,
   Windows, Messages, SysUtils, Variants, Classes,
   ScktComp, Packets, Player, MMSystem;


  type
    AylinClass = class(TObject)
    public
      function GetMatchCombine(quantidade : integer) : integer;
      procedure GetRefineMachine(var item, item2: TItem; var player : TPlayer; slot, sanc: BYTE);
      function AylinProc(var player : TPlayer; var buffer: array of Byte): Boolean;
  end;

implementation

Uses GlobalDefs, NpcFunctions, ItemFunctions;

function AylinClass.AylinProc(var player : TPlayer; var buffer: array of Byte): Boolean;
var
  i : WORD; find : boolean; quant : BYTE; sanc : BYTE;	item1 : integer; item2 : integer;
  anct : integer; idjoia : WORD; timesrv : integer; chance : integer; packet : TCompoundersPacket absolute buffer;
begin
  result := True;
  if (player.Character.Gold < 50000000) then
	begin
		player.SendClientMessage('Custo de 50 milh�es de gold.');
		player.SendSignal($7530, $3A7);
		exit;
	end;
	for i := 0 to 3 do
	begin
		if (packet.slot[i] = 255) then
		begin
			player.SendClientMessage('Ocorreu um erro.');
			player.SendSignal($7530, $3a7);
			exit;
		end;
	end;
	if ((packet.Item[0].Index <> packet.Item[1].Index) OR (player.Character.Inventory[packet.slot[0]].Index <> player.Character.Inventory[packet.slot[1]].Index)) then begin
		player.SendClientMessage('Itens devem ser iguais.');
		player.SendSignal($7530, $3A7);
		exit;
	end;
	item1 := TItemFunctions.GetSanc(player.Character.Inventory[packet.slot[0]]);
	item2 := TItemFunctions.GetSanc(player.Character.Inventory[packet.slot[1]]);
	if (item1 <> 9) OR (item2 <> 9) then
	begin
		player.SendClientMessage('Itens devem ser +9.');
		player.SendSignal($7530, $3a7);
		exit;
	end;
	if ((packet.Item[2].Index <> 1774) OR (player.Character.Inventory[packet.slot[2]].Index <> 1774)) then begin
		player.SendClientMessage('Deve adicionar uma pedra do s�bio.');
		exit;
	end;
	anct := ItemList[packet.Item[0].Index].Grade;
	idjoia := NpcFuncs.GetIdJoia(anct);
	if (idjoia = 0) then
	begin
		find := false;
		for i := 2441 to 2443 do
    begin
			if ((packet.Item[3].Index = i) AND (player.Character.Inventory[packet.slot[3]].Index = i)) then
      begin
				find := true;
				break;
			end;
		end;
		if not(find) then begin
			player.SendClientMessage('Deve adicionar pelo menos uma j�ia.');
			exit;
		end;
	end
	else
	begin
		if (packet.Item[3].Index <> idjoia) or (player.Character.Inventory[packet.slot[3]].Index <> idjoia) then
		begin
			player.SendClientMessage('Deve adicionar a j�ia correspondente ao item anciente.');
			player.SendSignal($7530, $3A7);
			exit;
		end;
	end;
	quant := 1;
	for i := 4 to 6 do
  begin
		if ((packet.Item[3].Index <> packet.Item[i].Index) or (player.Character.Inventory[packet.slot[3]].Index <> player.Character.Inventory[packet.slot[i]].Index))
			AND ((packet.Item[i].Index <> 0)) then
		begin
			player.SendClientMessage('J�ias devem ser iguais.');
			player.SendSignal($7530, $3A7);
			exit;
		end
		else
  		inc(quant);
	end;

	for i := 0 to 1 do
  begin
		if (not CompareMem(@packet.Item[i], @player.Character.Inventory[packet.slot[i]], sizeof(TItem))) then
    begin
			player.SendClientMessage('Ocorreu um erro.');
			player.SendSignal($7530, $3A7);
			exit;
		end;
	end;

	chance := GetMatchCombine(quant);
  Randomize();
	timesrv := (Random(100));
  inc(timesrv);
	if (timesrv <= chance) then
  begin
		player.SendClientMessage('Falhou na composi��o do item ['+ ItemList[packet.Item[0].Index].Name + ' +10].');
		TItemFunctions.DeleteItem(player, packet.item[3].Index, quant);
		TItemFunctions.DeleteItemSlot(player, packet.slot[2]);
		Dec(player.Character.Gold, 50000000);
		player.SendSignal($7530, $3A7);
    player.RefreshInventory;
		exit;
	end
	else
	begin
		sanc := NpcFuncs.GetSancId(packet.Item[3].Index);
		GetRefineMachine(packet.Item[0], packet.Item[1], player, packet.slot[0],sanc);
		player.SendClientMessage('Obteve sucesso na composi��o do item ['+ ItemList[packet.Item[0].Index].Name +' +10].');
		TItemFunctions.DeleteItemSlot(player, packet.slot[1]);
		TItemFunctions.DeleteItem(player, packet.item[3].Index, quant);
		TItemFunctions.DeleteItemSlot(player, packet.slot[2]);
		Dec(player.Character.Gold, 50000000);
		player.SendSignal($7530, $3A7);
    player.RefreshInventory;
		exit;
	end;
end;

procedure AylinClass.GetRefineMachine(var item, item2: TItem; var player : TPlayer; slot, sanc: BYTE);
var i1add2 : integer; i1add1 : integer; i2add1 : integer; i2add2 : integer;
	i1value2 : integer; i1value1 : integer; i2value1 : integer; i2value2 : integer;
	num : integer;
begin
	{
	1:Add todo da primeira arma
	2:Add todo da segunda arma
	3: Segundo add (diferente da refina��o) da segunda + primeiro add(diferente da refina��o) da primeira
	4: Segundo add (diferente da refina��o) da primeira + primeiro add(diferente da refina��o) da segunda
	}
	if (item.Effects[0].Index = 43) then
	begin
		i1value1 := item.Effects[1].Value;
		i1value2 := item.Effects[2].Value;
		i1add1 := item.Effects[1].Index;
		i1add2 := item.Effects[2].Index;
	end
	else if (item.Effects[1].Index = 43) then
	begin
		i1value1 := item.Effects[0].Value;
		i1value2 := item.Effects[2].Value;
		i1add1 := item.Effects[0].Index;
		i1add2 := item.Effects[2].Index;
	end
	else if (item.Effects[2].Index = 43) then
	begin
		i1value1 := item.Effects[0].Value;
		i1value2 := item.Effects[1].Value;
		i1add1 := item.Effects[0].Index;
		i1add2 := item.Effects[1].Index;
	end;
	if (item2.Effects[0].Index = 43) then
	begin
		i2value1 := item2.Effects[1].Value;
		i2value2 := item2.Effects[2].Value;
		i2add1 := item2.Effects[1].Index;
		i2add2 := item2.Effects[2].Index;
	end
	else if (item2.Effects[1].Index = 43) then
	begin
		i2value1 := item2.Effects[0].Value;
		i2value2 := item2.Effects[2].Value;
		i2add1 := item2.Effects[0].Index;
		i2add2 := item2.Effects[2].Index;
	end
	else if (item2.Effects[1].Index = 43) then
	begin
		i2value1 := item2.Effects[0].Value;
		i2value2 := item2.Effects[1].Value;
		i2add1 := item2.Effects[0].Index;
		i2add2 := item2.Effects[1].Index;
	end;

  if (i2add1 = i2add2) then
  begin
    inc(i2value1, i2value2);
    i2add2 := 0;
    i2value2 := 0;
  end;

	Randomize();
	num := random(4);
	case num of
	  0:
		begin
			player.Character.Inventory[slot].Effects[0].Index := 43;
			player.Character.Inventory[slot].Effects[0].Value := sanc;
			player.Character.Inventory[slot].Effects[1].Index := i1value1;
			player.Character.Inventory[slot].Effects[1].Value := i1add1;
			player.Character.Inventory[slot].Effects[2].Index := i1value2;
			player.Character.Inventory[slot].Effects[2].Value := i1add2;
		end;
		1:
		begin
			player.Character.Inventory[slot].Effects[0].Index := 43;
			player.Character.Inventory[slot].Effects[0].Value := sanc;
			player.Character.Inventory[slot].Effects[1].Index := i2value1;
			player.Character.Inventory[slot].Effects[1].Value := i2add1;
			player.Character.Inventory[slot].Effects[2].Index := i2value2;
			player.Character.Inventory[slot].Effects[2].Value := i2add2;
		end;
		2:
		begin
			player.Character.Inventory[slot].Effects[0].Index := 43;
			player.Character.Inventory[slot].Effects[0].Value := sanc;
			player.Character.Inventory[slot].Effects[1].Index := i2value2;
			player.Character.Inventory[slot].Effects[1].Value := i2add2;
			player.Character.Inventory[slot].Effects[2].Index := i1value1;
			player.Character.Inventory[slot].Effects[2].Value := i1add1;
		end;
    3:
		begin
			player.Character.Inventory[slot].Effects[0].Index := 43;
			player.Character.Inventory[slot].Effects[0].Value := sanc;
			player.Character.Inventory[slot].Effects[1].Index := i1value1;
			player.Character.Inventory[slot].Effects[1].Value := i1add1;
			player.Character.Inventory[slot].Effects[2].Index := i2value2;
			player.Character.Inventory[slot].Effects[2].Value := i2add2;
		end;
	end;
end;

function AylinClass.GetMatchCombine(quantidade : integer) : integer;
var chance : integer; i,value : integer;
begin
	chance := 12; //chance inicial
	value := 2;   //base
	for i := 0 to quantidade do //exponente
	begin;
		value := value * 2;
	end;
	inc(chance,value);
	if (quantidade = 3) then
	begin;
		dec(chance); //15% ��
	end;
	{
	1 j�ia: +4% Sucesso.
    2 j�ias: +8% Sucesso.
    3 j�ias: +15% Sucesso.
    4 j�ias: +32% Sucesso.
	}
	if (chance > 32) then result := 32 else result := chance;

end;

end.

