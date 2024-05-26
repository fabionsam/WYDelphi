unit Compounder;

interface

Uses MiscData, PlayerData,
   Windows, Messages, SysUtils, Variants, Classes,
   ScktComp, Packets, Player, MMSystem;


  type
    CompounderClass = class(TObject)
    public
      function GetMatchCombine(chance : Byte) : boolean;
      procedure GetRefineMachine(var player : TPlayer; slot: BYTE; joia : WORD);
      function CompounderProc(var player : TPlayer; var buffer: array of Byte) : Boolean;
  end;

implementation

Uses GlobalDefs, ConstDefs, NpcFunctions, ItemFunctions;

function CompounderClass.CompounderProc(var player : TPlayer; var buffer: array of Byte): Boolean;
var sanc : BYTE;
  i: Byte;
  chance : Byte;
  packet : TCompoundersPacket absolute buffer;
begin
  result := true;
  //verificar se os itens no packet são os mesmos que estão no inventário
  for i := 0 to 5 do
  begin
    if (not CompareMem(@packet.Item[i], @player.Character.Inventory[packet.slot[i]], sizeof(TItem)))then
    begin
      player.SendClientMessage('Ocorreu um erro.');
			player.SendSignal($7530, $3A7);
			exit;
    end;
  end;
  //fim verificar

  sanc := TItemFunctions.GetSanc(packet.Item[0]);
  if (sanc <> 9)then
  begin
		player.SendClientMessage('Item deve ser +9.');
		player.SendSignal($7530, $3A7);
		exit;
	end;

  if (packet.Item[1].Index < 2441) or (packet.Item[1].Index > 2444) then
  begin
    player.SendClientMessage('Jóia inválida.');
		player.SendSignal($7530, $3A7);
		exit;
  end;

  chance := 0;
  for i := 2 to 5 do
  begin
    sanc := TItemFunctions.GetSanc(packet.Item[i]);
    if (sanc < 7) or (sanc > 10) then
    begin
      player.SendClientMessage('Itens devem ser no mínimo +7 e no máximo +10.');
		  player.SendSignal($7530, $3A7);
		  exit;
    end
    else
    begin
      case sanc of
        7:  inc(chance,2);
        8:  inc(chance,4);
        9:  inc(chance,10);
        10: inc(chance,12);
      end;
    end;
  end;

  if GetMatchCombine(chance) then
  begin
    player.SendClientMessage('Obteve sucesso na composição do item anciente.');
    GetRefineMachine(player, packet.slot[0], packet.Item[1].Index);
    for i := 1 to 5 do
      TItemFunctions.DeleteItemSlot(player, packet.slot[i]);
		player.SendSignal($7530, $3A7);
		exit;
  end
  else
  begin
    player.SendClientMessage('Falhou na composição do item anciente.');
    for i := 0 to 5 do
      TItemFunctions.DeleteItemSlot(player, packet.slot[i]);
		player.SendSignal($7530, $3A7);
		exit;
  end;


end;

procedure CompounderClass.GetRefineMachine(var player : TPlayer; slot: BYTE; joia : WORD);
begin
  player.Character.Inventory[slot].Index := ItemList[player.Character.Inventory[slot].Index].Extreme + (joia - 2441);
  player.SendCreateItem(INV_TYPE, slot, player.Character.Inventory[slot]);
end;

function CompounderClass.GetMatchCombine(chance : Byte) : boolean;
var tchance : Byte; timesrv: BYTE;
begin
	tchance := chance+1; //1 de chance inicial
	if (tchance > 49) then tchance := 49;

  Randomize();
	timesrv := (Random(100));
  inc(timesrv);
  if timesrv <= tchance then
    result := true
  else
    result := false;
end;

end.

