unit ItemFunctions;

interface

Uses MiscData, DateUtils,
   Windows, Messages, SysUtils, Variants, Classes,
   Packets, Player, BaseMob, Position;

type TItemFunctions = class(TObject)
  public
    class function GetAnctCode(item: TItem) : integer;
    class function GetEffectValue(itemid: integer; eff:shortint) : smallint;
    class function GetItemAbility(const item : TItem; eff: integer) : integer;
    class function GetSanc(item : TItem) : smallint; static;
    class function GetSancBonus(item : TItem): smallint;
    class procedure IncreaseSanc(var item : TItem; value: Byte); static;
    class procedure SetSanc(var item: TItem; value: Byte); static;
    class function GetItem(var item : TItem; mob: TBaseMob; slot, slotType: BYTE): Boolean; overload; static;
    class function GetItem(out item : PItem; mob: TBaseMob; slot, slotType: BYTE): Boolean; overload; static;
    class function GetItemAmount(item: TItem) : BYTE; static;
    class procedure SetItemAmount(var item: TItem; quant: BYTE); static;
    class function GetEmptySlot(const player : TPlayer) : BYTE; static;
    class function CanCarry(const player: TPlayer; Dest: TItem; DestX, DestY: integer; error: pInteger): Boolean; //00409360 - ok
    class function PutItem(var player: TPlayer; item : TItem): BYTE;
    class function CanTrade(const player: TPlayer): Boolean;
    class procedure DeleteItem(var player : TPlayer; itemId : integer; quant : WORD);
    class procedure DeleteItemSlot(var player : TPlayer; slot: BYTE);
    class function FreeInitItem(): WORD;
    class function GetEmptyItemGrid(var position: TPosition): Boolean;
    class procedure DeleteVisibleDropList(initId : WORD);
    class procedure DecreaseAmount(var item: TItem; quant: BYTE = 1); static;
  private
end;


var Power : array[0..4] of integer = (220, 250, 280, 320, 370);


implementation


Uses GlobalDefs, ConstDefs, PlayerData, Util;

class procedure TItemFunctions.DecreaseAmount(var item: TItem; quant: BYTE = 1);
var
  i: Byte;
begin
  for i := 0 to 3 do
  begin
    if(item.Effects[i].Index = EF_SANC) then
    begin
      if item.Effects[i].Value > quant then
        Dec(item.Effects[i].Value, quant)
      else
        ZeroMemory(@item, SizeOf(TItem));

      exit;
    end;
  end;
end;

class procedure TItemFunctions.DeleteItem(var player : TPlayer; itemId : integer; quant : WORD);
var i,j,lastslot : BYTE;
begin
  lastslot := 0;
  for j := 1 to quant do
  begin
    for i := lastslot to MAX_INV - 1 do
    begin
      if (player.Character.Inventory[i].Index = itemId) then
      begin
        ZeroMemory(@player.Character.Inventory[i], 8);
        player.RefreshInventory;
        lastslot := i;
        break;
      end;
    end;
  end;
end;

class procedure TItemFunctions.DeleteItemSlot(var player : TPlayer; slot: BYTE);
begin
  ZeroMemory(@player.Character.Inventory[slot], 8);
  player.SendCreateItem(INV_TYPE, slot, player.Character.Inventory[slot]);
end;

class function TItemFunctions.CanCarry(const player: TPlayer; Dest : TItem; DestX, DestY: integer; error: pInteger): Boolean; //00409360 - ok
var ItemGrid, i, x, y, pInvX, pInvY: integer; pGridDest, pGridInv: array[0..7] of BYTE; invSlots : array[0..MAX_INVEN] of BYTE;
begin
	ItemGrid := GetItemAbility(Dest, EF_GRID);

	Move(g_pItemGrid[ItemGrid],pGridDest,8);

	FillChar(invSlots, MAX_INVEN, 0);

	for i := 0 to MAX_INVEN-1 do
  begin
		if(player.Character.Inventory[i].Index = 0) then
      continue;

		ItemGrid := GetItemAbility(Dest, EF_GRID);

	  Move(g_pItemGrid[ItemGrid], pGridInv, 8);

		pInvX := (i mod 9);
    pInvY := (i div 9);
		for y := 0 to 3 do
    begin
      for x := 0 to 1 do
      begin
        if(pGridInv[(y * 2) + x] = 0)then
          continue;

        if((y + pInvY) < 0) or ((y + pInvY) >= 7)then
          continue;

        if((x + pInvX) < 0) or ((x + pInvX) >= 9)then
          continue;

        invSlots[(y + pInvY) * 9 + x + pInvX] := (i + 1);
      end;
    end;
	end;

	for y := 0 to 3 do
  begin
    for x := 0 to 1 do
    begin
      if(pGridDest[(y * 2) + x] = 0)then
        continue;

      if((y + DestY) <  0) or ((x + DestX) <  0) or ((y + DestY) >= 7) or ((x + DestX) >= 9)then
      begin
        error^ := -1;
        result := FALSE;
        exit;
      end;

      if(invSlots[(y + DestY) * 9 + x + DestX] = 0)then
        continue;

      error^ := invSlots[(y + DestY) * 9 + x + DestX];
      result := FALSE;
      exit;
    end;
  end;

	result := TRUE;
end;

class function TItemFunctions.PutItem(var player: TPlayer; item : TItem): BYTE;
var pos: BYTE; DestX,DestY,error : integer;
begin
  {for pos := 0 to MAX_CARRY-1 do
  begin
    DestX := pos mod CARRYGRIDX;
    DestY := pos div CARRYGRIDX;
    error := 0;
    if (CanCarry(player,item,DestX,DestY,@error)) then
      break;
  end;  }

  //if (pos >= 0) and (pos < MAX_CARRY - 1) and not(error = -1)then
  //begin
    //Move(item, player.Character.Base.Inventory[pos], 8);
    //player.SendCreateItem(INV_TYPE, pos, item);
  //end
  //else
  //begin
    //randomize;
    //CreateItem(pMob[conn].TargetX,pMob[conn].TargetY,item,rand() mod 4,1);// create item in 1965,1769;
  //end;
  //Result := IFThen(error = -1, -1, pos);

  pos := GetEmptySlot(player);
  if pos <> 254 then
  begin
    Move(item, player.Character.Inventory[pos], 8);
    player.SendCreateItem(INV_TYPE, pos, item);
    result := pos;
  end
  else
    result := 255;
end;


class function TItemFunctions.CanTrade(const player: TPlayer): Boolean;
var i: Byte;
  item: TItem;
  pos: Byte;
  DestX, DestY, error: Integer;
begin
  for i := 0 to 11 do
  begin
    for pos := 0 to (MAX_CARRY - 1) do
    begin
      DestX := pos mod CARRYGRIDX;
      DestY := pos div CARRYGRIDX;
      error := 0;
      if not(CanCarry(player, item, DestX, DestY, @error)) then
      begin
        result := false;
        exit;
      end;
    end;
  end;
  result := true;
end;

class function TItemFunctions.GetAnctCode(item: TItem) : integer;
var value: integer;
 i: BYTE;
begin
  value:=0;

  for i := 0 to 2 do
  begin
    if(item.Effects[i].Index >= 116) and (item.Effects[i].Index <= 125)then
    begin
      result := item.Effects[i].Index;
      exit;
    end;
  end;

  if(item.Effects[0].Index = 43)then
      value := item.Effects[0].Value
  else if(item.Effects[1].Index = 43)then
      value := item.Effects[1].Value
  else if(item.Effects[2].Index = 43)then
      value := item.Effects[2].Value;

  if(value = 0)then
  begin
      result:= 0;
      exit;
  end;

	if(value < 230)then
  begin
		result:= 43;
    exit;
  end;

  case (value mod 4) of
    0:  begin  result := $30; exit; end;
    1:  begin  result := $40; exit; end;
    2:  begin  result := $10; exit; end;
    else begin result := $20; exit; end;
  end;
end;

class function TItemFunctions.GetEffectValue(itemid: integer; eff:shortint) : smallint;
var i: BYTE;
begin
  for i := 0 to 11 do begin
    if(ItemList[itemid].Effects[i].Index = eff) then
    begin
      result := ItemList[itemid].Effects[i].Value;
      exit;
    end;
  end;
  result:= 0;
end;


class function TItemFunctions.GetItemAbility(const item : TItem; eff: integer) : integer;
var resultt,itemid,unique,pos,i,val,ef2,sanc,x: integer;
begin
  resultt:=0;
  itemid:=item.Index;

  if(itemid <= 0) or (itemid >= 6500) then
  begin
    result:=0;
    exit;
  end;

  if(eff = EF_PRICE) then
  begin
    Result := ItemList[itemid].Price;
    exit;
  end;

  unique:=ItemList[itemid].Unique;
  pos:=ItemList[itemid].Pos;

  if(eff = EF_DAMAGEADD) or (eff = EF_MAGICADD)then
      if(unique < 41) or (unique > 50)then begin
          result:= 0;
          exit;
      end;

  if(eff = EF_CRITICAL)then
      if(item.Effects[1].Index = EF_CRITICAL2) or (item.Effects[2].Index = EF_CRITICAL2)then
          eff := EF_CRITICAL2;

  if(eff = EF_DAMAGE) and (pos = 32)then
      if(item.Effects[1].Index = EF_DAMAGE2) or (item.Effects[2].Index = EF_DAMAGE2)then
          eff := EF_DAMAGE2;

  if(eff = EF_MPADD)then
      if(item.Effects[1].Index = EF_MPADD2) or (item.Effects[2].Index = EF_MPADD2)then
          eff := EF_MPADD2;

  if(eff = EF_ACADD)then
      if(item.Effects[1].Index = EF_ACADD2) or (item.Effects[2].Index = EF_ACADD2)then
          eff := EF_ACADD2;

  if(eff = EF_LEVEL) and (itemID >= 2330) and (itemID < 2360) then
      resultt := (item.Effects[1].Index - 1)
  else if(eff = EF_LEVEL)then
      inc(resultt,ItemList[itemID].Level);

  if(eff = EF_REQ_STR)then
      inc(resultt,ItemList[itemID].Str);
  if(eff = EF_REQ_INT)then
      inc(resultt,ItemList[itemID].Int);
  if(eff = EF_REQ_DEX)then
      inc(resultt,ItemList[itemID].Dex);
  if(eff = EF_REQ_CON)then
      inc(resultt,ItemList[itemID].Con);

  if(eff = EF_POS)then
      inc(resultt,ItemList[itemID].Pos);

  if(eff <> EF_INCUBATE)then
  begin
      for i := 0 to 11 do
      begin
          if(ItemList[itemID].Effects[i].Index <> eff)then
              continue;

          val := ItemList[itemID].Effects[i].Value;
          if(eff = EF_ATTSPEED) and (val = 1)then
              val := 10;

          inc(resultt,val);
          break;
      end;
  end;

    if(item.Index >= 2330) and (item.Index < 2390)then
    begin
      if(eff = EF_MOUNTHP)then begin
          result:=item.Effects[1].Index;
          exit;
      end;

      if(eff = EF_MOUNTSANC)then begin
          result:=item.Effects[1].Index;
          exit;
      end;

      if(eff = EF_MOUNTLIFE)then begin
          result:=item.Effects[1].Value;
          exit;
      end;

      if(eff = EF_MOUNTFEED)then begin
          result:=item.Effects[2].Index;
          exit;
      end;

      if(eff = EF_MOUNTKILL)then begin
          result:=item.Effects[2].Value;
          exit;
      end;

      if(item.Index >= 2362) and (item.Index < 2390) and (item.Effects[0].Index > 0)then
      begin
          ef2 := item.Effects[1].Index;

          if(eff = EF_DAMAGE)then begin
              result:=Trunc(((GetEffectValue(item.Index, EF_DAMAGE) * (ef2 + 20)) / 100));
              exit;
          end;

          if(eff = EF_MAGIC)then begin
              result:=Trunc(((GetEffectValue(item.Index, EF_MAGIC) * (ef2 + 15)) / 100));
              exit;
          end;

          if(eff = EF_PARRY)then begin
              result:=GetEffectValue(item.Index, EF_PARRY);
              exit;
          end;

          if(eff = EF_RUNSPEED)then begin
              result:=GetEffectValue(item.Index, EF_RUNSPEED);
              exit;
          end;

          if(eff = EF_RESIST1) or (eff = EF_RESIST2) or
             (eff = EF_RESIST3) or (eff = EF_RESIST4) then begin
              result:=GetEffectValue(item.Index, EF_RESISTALL);
              exit;
          end;
      end;
    end;

    if(item.Effects[0].Index = eff)then begin

      val := item.Effects[0].Value;
      if(eff = EF_ATTSPEED) and  (val = 1)then
          val := 10;

      inc(resultt,val);
    end
    else
    begin
       if(item.Effects[1].Index = eff)then begin

        val := item.Effects[1].Value;
        if(eff = EF_ATTSPEED) and  (val = 1)then
            val := 10;

        inc(resultt,val);
      end
      else
      begin
         if(item.Effects[2].Index = eff)then begin

          val := item.Effects[2].Value;
          if(eff = EF_ATTSPEED) and  (val = 1)then
              val := 10;

          inc(resultt,val);
        end;
      end;
    end;

    if(eff = EF_RESIST1) or (eff = EF_RESIST2) or
       (eff = EF_RESIST3) or (eff = EF_RESIST4) then
    begin
      for i := 0 to 11 do begin
        if(ItemList[itemID].Effects[i].Index <> EF_RESISTALL)then
            continue;

        inc(resultt,ItemList[itemID].Effects[i].Value);
        break;
      end;

      if(item.Effects[0].Index = EF_RESISTALL)then
        inc(resultt,item.Effects[0].Value)
      else
      if(item.Effects[1].Index = EF_RESISTALL)then
        inc(resultt,item.Effects[1].Value)
      else
      if(item.Effects[2].Index = EF_RESISTALL)then
        inc(resultt,item.Effects[2].Value);
    end;

    sanc := GetSanc(item);
    if(item.Index <= 40)then
        sanc := 0;

    if(sanc >= 9) and ((pos and $F00) <> 0) then
        inc(sanc,1);

    if(sanc <> 0) and (eff <> EF_GRID) and (eff <> EF_CLASS) and
       (eff <> EF_POS) and (eff <> EF_WTYPE) and (eff <> EF_RANGE) and
       (eff <> EF_LEVEL) and (eff <> EF_REQ_STR) and (eff <> EF_REQ_INT) and
       (eff <> EF_REQ_DEX) and (eff <> EF_REQ_CON) and (eff <> EF_VOLATILE) and
       (eff <> EF_INCUBATE) and (eff <> EF_INCUDELAY)then
    begin
        if(sanc <= 10)then
            resultt := Trunc((((sanc + 10) * resultt) / 10))
        else
        begin
          val := Power[sanc - 11];
          resultt := Trunc(((((resultt * 10) * val) / 100) / 10));
        end;
    end;

    if(eff = EF_RUNSPEED)then
    begin
        if(resultt >= 3)then
            resultt := 2;

        if(resultt > 0) and (sanc >= 9)then
            inc(resultt,1);
    end;

    if(eff = EF_HWORDGUILD) or (eff = EF_LWORDGUILD)then
    begin
        x := resultt;
        resultt := x;
    end;

    if(eff = EF_GRID)then
        if(resultt < 0) or (resultt > 7)then
            resultt := 0;

    result:=resultt;
end;

class function TItemFunctions.GetItem(var item : TItem; mob: TBaseMob; slot, slotType: BYTE): Boolean;
begin
  result := false;
  if(slot < 0) OR (slot >= MAX_CARGO) then exit;

  case(slotType) of
    INV_TYPE:
    begin
      if(slot < MAX_INV) then
        item := mob.Character.Inventory[slot]
      else exit;
    end;

    EQUIP_TYPE:
    begin
      if(slot < MAX_EQUIPS) then
        item := mob.Character.Equip[slot]
      else exit;
    end;

    STORAGE_TYPE:
    begin
      if not(mob.IsPlayer) then exit;
      item := TPlayer.Players[mob.ClientId].Account.Header.StorageItens[slot];
    end;
  end;
  result := true;
end;

class function TItemFunctions.GetItem(out item: PItem; mob: TBaseMob; slot,
  slotType: BYTE): Boolean;
begin
  result := false;
  if(slot < 0) OR (slot >= MAX_CARGO) then exit;

  case(slotType) of
    INV_TYPE:
    begin
      if(slot < MAX_INV) then
        item := @mob.Character.Inventory[slot]
      else exit;
    end;

    EQUIP_TYPE:
    begin
      if(slot < MAX_EQUIPS) then
        item := @mob.Character.Equip[slot]
      else exit;
    end;

    STORAGE_TYPE:
    begin
      if not(mob.IsPlayer) then exit;
      item := @TPlayer.Players[mob.ClientId].Account.Header.StorageItens[slot];
    end;
  end;
  result := true;
end;
{
class function TItemFunctions.GetItemPointer(out item : PItem; player : TPlayer; slot, slotType: BYTE): Boolean;
begin
  result := false;
  if(slot < 0) then exit;

  case(slotType) of
    INV_TYPE:
    begin
      if(slot < 64) then
        item := @player.Character.Base.Inventory[slot]
      else exit;
    end;

    EQUIP_TYPE:
    begin
      if(slot < 16) then
        item := @player.Character.Base.Equip[slot]
      else exit;
    end;

    STORAGE_TYPE:
    begin
      if(slot < 128)then
        item := @player.Account.Header.StorageItens[slot]
      else exit;
    end;
  end;
  result := true;
end;
}
class function TItemFunctions.GetItemAmount(item: TItem): BYTE;
begin
  result := 1;
  if(item.Index = 0) then
    result := 0
  else if(item.Effects[0].Index = EF_AMOUNT) then
    result := item.Effects[0].Value
  else if(item.Effects[1].Index = EF_AMOUNT) then
    result := item.Effects[1].Value
  else if(item.Effects[2].Index = EF_AMOUNT) then
    result := item.Effects[2].Value;
end;

class function TItemFunctions.GetSanc(item : TItem): smallint;
var value, i: BYTE;
begin
  value:=0;

  if(item.Index >= 2360) and (item.Index <= 2389) then
  begin
    //Montarias.
    value := Trunc((item.Effects[2].Index / 10));

    if(value > 9) then
        value := 9;

    result := value;
    exit;
  end;

 if(item.Index >= 2330) and (item.Index <= 2359) then
 begin
      //Crias.
      result:= 0;
      exit;
 end;

 for i := 0 to 2 do
    if(item.Effects[i].Index = 43) or ((item.Effects[i].Index >= 116) and (item.Effects[i].Index <= 125))then
      value := item.Effects[i].Value;

  if(value >= 230)then
  begin
      value := Trunc(10 + ((value - 230) / 4));
      if(value > 15)then
          value := 15;
  end
  else
      value := (value mod 10);

  if value = 0 then
  begin
    for i := 0 to 2 do
      if(item.Effects[i].Index = 0)then
      begin
        value := 0;
        break;
      end
      else value := 255;
  end;

  result:=value;
end;

class function TItemFunctions.GetSancBonus(item : TItem): smallint;
var value, i, sanc, bonus: BYTE;
begin
  for i := 0 to 2 do
    if(item.Effects[i].Index = 43) or ((item.Effects[i].Index >= 116) and (item.Effects[i].Index <= 125))then
      value := item.Effects[i].Value;

  if(value > 9) and (value < 253)then
  begin
    sanc := value mod 10;
    bonus:= value div 10;
    case sanc of
      1..2: value := 5*bonus;
      3..4: value := 4*bonus;
      5..6: value := 3*bonus;
         7: value := 2*bonus;
         8: value := bonus;
    end;
  end
  else
    value := 0;

  result:=value;
end;

class procedure TItemFunctions.IncreaseSanc(var item: TItem; value: Byte);
var
  i: Integer;
begin
  for i := 0 to 2 do
  begin
    if(item.Effects[i].Index = EF_SANC)
      OR ((item.Effects[i].Index >= 116) AND (item.Effects[i].Index <= 125)) then
    begin
	    Inc(item.Effects[i].Value, value);
      exit;
    end;
  end;

  for i := 0 to 2 do
  begin
    if(item.Effects[i].Index = EF_NONE) then
    begin
      item.Effects[i].Index := EF_SANC;
      item.Effects[i].Value := value;
      exit;
    end;
  end
end;

class procedure TItemFunctions.SetSanc(var item: TItem; value: Byte);
var
  i: Integer;
begin
  for i := 0 to 2 do
  begin
    if(item.Effects[i].Index = EF_SANC)
      OR ((item.Effects[i].Index >= 116) AND (item.Effects[i].Index <= 125)) then
    begin
      item.Effects[i].Value := value;
      exit;
    end;
  end;

  for i := 0 to 2 do
  begin
    if(item.Effects[i].Index = EF_NONE)then
    begin
      item.Effects[i].Index := EF_SANC;
      item.Effects[i].Value := value;
      exit;
    end;
  end;
end;

class procedure TItemFunctions.SetItemAmount(var item : TItem; quant: BYTE);
begin
  if(item.Index = 0) then
    exit
  else if(item.Effects[0].Index = EF_AMOUNT) then
    item.Effects[0].Value := quant
  else if(item.Effects[1].Index = EF_AMOUNT) then
    item.Effects[1].Value := quant
  else if(item.Effects[2].Index = EF_AMOUNT) then
    item.Effects[2].Value := quant;
end;

class function TItemFunctions.GetEmptySlot(const player : TPlayer) : BYTE;
var i: BYTE;
begin
  for i := 0 to MAX_INV-1 do
  begin
    if(player.Character.Inventory[i].Index = 0)then
    begin
      result := i;
      exit;
    end;
  end;
  result := 254;
end;

class function TItemFunctions.FreeInitItem(): WORD;
var i: WORD;
begin
  for i := 1 to MAX_INITITEM_LIST do
  begin
    if(InitItems[i].Item.Index = 0)then
    begin
      result := i;
      exit;
    end;
  end;
  result := 0;
end;

class function TItemFunctions.GetEmptyItemGrid(var position: TPosition): Boolean;
var nY, nX : WORD;
begin
    if(ItemGrid[Position.Y][Position.X] = 0)then
    begin
        if(HeightGrid.p[Position.Y][Position.X] <> 127)then
        begin
            result := true;
            exit;
        end;
    end;

    for nY := Position.Y - 1 to Position.Y + 1 do
    begin
        for nX := Position.X - 1 to Position.X + 1 do
        begin
            if(nX < 0) or (nY < 0) or (nX >= 4096) or (nY >= 4096)then
                continue;

            if(ItemGrid[nY][nX] = 0)then
            begin
                if(ItemGrid[nY][nX] <> 127)then
                begin
                    Position.X := nX;
                    Position.Y := nY;
                    result := true;
                    exit;
                end;
            end;
        end;
    end;

    result := false;
end;

class procedure TItemFunctions.DeleteVisibleDropList(initId : WORD);
var
    initItem : TInitItem;
begin
  try
    initItem := InitItems[initId];
  except
    exit;
  end;

  if(MinutesBetween(Now, initItem.TimeDrop) < 1) then
  begin
    exit;
  end;

  initItem.Pos.ForEach(17, initId, procedure(id: Word; pos: TPosition)
  var
    player : TPlayer;
    mobId : WORD;
  begin
    mobId := MobGrid[pos.Y][pos.X];
    if(mobId = 0) OR (mobId > MAX_CONNECTIONS)  then
      exit;

    player := TPlayer.Players[mobId];
    if not(Assigned(player)) then
      exit;

    player.SendDeleteDropItem(initId + 10000, True);
  end);
  {
  for x := initItem.Pos.X - 17 to initItem.Pos.X + 17 do
  begin
    for y := initItem.Pos.Y - 17 to initItem.Pos.Y + 17 do
    begin
      if (x > 4096) or (x < 0) or (y > 4096) or (y < 0) then
        continue;

      mobId := MobGrid[y][x];
      if(mobId = 0) then
        continue;

      if(mobId <= MAXCONNECTIONS) then
        player := Players[mobId]
      else
        exit;

      if not(player.Base.IsActive) then
        continue;

      player.SendDeleteDropItem(initId + 10000, True);
    end;
  end;
  }
end;


end.
