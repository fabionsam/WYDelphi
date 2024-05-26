unit PacketHandlers;

interface

uses Windows, ClientConnection, Packets, Player, Functions, PlayerData, SysUtils, MiscData,
    ItemFunctions, NPC, Position;


type TPacketHandlers = class(TObject)
  private
  public
    class function MovementCommand(var player: TPlayer; var buffer: array of Byte): Boolean;
    class function CheckLogin(var player : TPlayer; var buffer: array of Byte) : Boolean; static;
    class function NumericToken(var player : TPlayer; var buffer: array of Byte) : Boolean; static;
    class function CreateCharacter(var player: TPlayer; var buffer: array of Byte) : Boolean; static;
    class function DeleteCharacter(var player: TPlayer; var buffer: array of Byte) : Boolean; static;
    class function SelectCharacter(var player: TPlayer; var buffer: array of Byte) : Boolean; static;
    class function Gates(var player : TPlayer; var buffer: array of Byte) : Boolean; static;
    class function AddPoints(var player: TPlayer; var buffer: array of Byte): boolean;
    class function ChangeCity(var player : TPlayer; var buffer: array of Byte) : Boolean; static;
    class function MoveItem(var player : TPlayer; var buffer: array of Byte) : Boolean; static;
    class function DeleteItem(var player: TPlayer; var buffer: array of Byte) : Boolean;
    class function UngroupItem(var player: TPlayer; var buffer: array of Byte) : Boolean;
    class function SendNPCSellItens(var player: TPlayer; var buffer: array of Byte) : Boolean; static;
    class function BuyNpcItens(var player: TPlayer; var buffer: array of Byte): Boolean; static;
    class function SellItemsToNPC(var player: TPlayer; var buffer: array of Byte) : Boolean; static;
    class function RequestOpenStoreTrade(var player: TPlayer; var buffer: array of Byte): Boolean; static;
    class function BuyStoreTrade(var player : TPlayer; var buffer: array of Byte) : Boolean; static;
    class function RequestParty(var player: TPlayer; var buffer: array of Byte): Boolean; static;
    class function ExitParty(var player: TPlayer; var buffer: array of Byte): Boolean; static;
    class function AcceptParty(var player: TPlayer; var buffer: array of Byte): Boolean; static;
    class function LogOut(var player: TPlayer; var buffer: array of Byte): Boolean; static;

    class function SendClientSay(var player: TPlayer; var buffer: array of Byte): Boolean;
    class function CargoGoldToInventory(var player: TPlayer; var buffer: array of Byte): Boolean;
    class function InventoryGoldToCargo(var player: TPlayer; var buffer: array of Byte): Boolean;



    class function Trade(var player: TPlayer; var buffer: array of Byte): Boolean;

    class function CloseTrade(var player: TPlayer): Boolean;
    class function OpenStoreTrade(var player: TPlayer; var buffer: array of Byte): boolean;
    class function PKMode(var player: TPlayer; var buffer: array of Byte): boolean;
    class function ChangeSkillBar(var player: TPlayer; var buffer: array of Byte): boolean;
    class function DropItem(var player: TPlayer; var buffer: array of Byte): boolean;
    class function PickItem(var player: TPlayer; var buffer: array of Byte): boolean;
    class function RequestEmotion(var player: TPlayer; var buffer: array of Byte): Boolean;

    class function MobNotInView(var player: TPlayer; var buffer: array of Byte): Boolean;
end;

implementation
uses GlobalDefs, Log, Util, BaseMob, PacketsDbServer, ConstDefs;

class function TPacketHandlers.ChangeCity(var player: TPlayer; var buffer: array of Byte): Boolean;
begin
  Move(buffer[12], player.PlayerCharacter.CurrentCity, 4);
  if(player.PlayerCharacter.CurrentCity < TCity.Armia) or (player.PlayerCharacter.CurrentCity > TCity.Karden) then
  begin
    player.PlayerCharacter.CurrentCity := TCity.Armia;
    exit;
  end;
  Result := true;
end;

class function TPacketHandlers.RequestEmotion(var player: TPlayer; var buffer: array of Byte): Boolean;
var packet : TRequestEmotion absolute buffer;
begin
  Result := false;
  player.SendEmotion(packet.effType, packet.effValue);
  Result := true;
end;

class function TPacketHandlers.CheckLogin(var player : TPlayer; var buffer : array of Byte) : Boolean;
var packet : TRequestLoginPacket absolute buffer;
begin
  Result := false;
  if(TFunctions.DecryptVersion(packet.Version) <> 759) then
  begin
    player.SendClientMessage('Atualize o client!');
    exit;
  end;
  player.WaitingDbServer := True;
  move(packet.AdapterName, player.Connection.AdapterName, 12);
  player.RequestAccount(TFunctions.CharArrayToString(packet.UserName), TFunctions.CharArrayToString(packet.PassWord));
end;

class function TPacketHandlers.NumericToken(var player: TPlayer; var buffer: array of Byte): Boolean;
var packet : TNumericTokenPacket absolute buffer;
begin
  Result := true;
  if((player.Account.Header.NumericToken = '') OR (packet.RequestChange = 1)) then
  begin
    player.Account.Header.NumericToken := packet.Num;
    player.SaveAccount;
    player.SubStatus := Waiting;
    //exit;
  end
  else
  begin
    if (AnsiCompareText(packet.num, player.Account.Header.NumericToken) = 0) then
    begin
      player.SubStatus := WAITING;
    end
    else
    begin
      packet.Header.Code := $FDF;
    end;
    packet.Header.Size := 12;
    packet.Header.Index := 30002;
    player.SendPacket(@packet, 12);
  end;
end;

class function TPacketHandlers.RequestOpenStoreTrade(var player: TPlayer; var buffer: array of Byte): Boolean;
var packet: TRequestOpenPlayerStorePacket absolute buffer; i,z: BYTE;
begin
  if(player.PlayerCharacter.IsStoreOpened = true)then
  begin
    result := true;
    exit;
  end;

  for i := 0 to 11 do
  begin
    if(packet.Trade.Gold[i] = 0)then
      continue;

    if(packet.Trade.Slot[i] >= MAX_CARGO)then
    begin
      result := false;
      exit;
    end;

    z := 0;
    while z < 12 do
    begin
      if(z <> i) and (packet.Trade.Slot[i] = packet.Trade.Slot[z]) and (packet.Trade.Item[z].Index <> 0) then
        break;
      inc(z);
    end;

    if(z <> 12) then
    begin
      result := false;
      exit;
    end;

    if(packet.Trade.Gold[i] > 999999999)then
    begin
      result:=false;
      exit;
    end;

    if(player.Account.Header.StorageItens[packet.Trade.Slot[i]].Index > 6500) then
    begin
      result := false;
      exit;
    end;

    if(CompareMem(@player.Account.Header.StorageItens[packet.Trade.Slot[i]], @packet.Trade.Item[i], 8) = false) then
    begin
      result := false;
      exit;
    end;
  end;

  player.PlayerCharacter.IsStoreOpened := true;
  Move(packet.Trade, player.PlayerCharacter.TradeStore, sizeof(TTradeStore));
  player.SendPacket(@packet, packet.Header.Size);
  player.SendCreateMob;
  result := true;
end;

class function TPacketHandlers.CreateCharacter(var player: TPlayer; var buffer: array of Byte): Boolean;
var
  packet : TCreateCharacterRequestPacket absolute buffer;
  packetDb : TCreateCharacterDb;
begin
  Result := true;
  if (packet.ClassIndex < 0) or (packet.ClassIndex > 3) then begin
    player.SendClientMessage('Classe Inválida.');
    exit;
  end;
  if (packet.SlotIndex < 0) or (packet.SlotIndex > 3) then begin
    player.SendClientMessage('Posição Inválida.');
    exit;
  end;
  if (player.Account.Characters[packet.SlotIndex].Base.Equip[0].Index <> 0) then begin
    player.SendClientMessage('Você já possui personagem nesse slot.');
    exit;
  end;

  ZeroMemory(@packetDb, sizeof(TCreateCharacterDb));
  packetDb.Header.Size := sizeof(TCreateCharacterDb);
  packetDb.Header.Code := $5;
  packetDb.Header.Index := DbClient.ServerId;
  Move(packet.Name, packetDb.CharacterName, sizeof(packet.Name));
  packetDb.SlotIndex := packet.SlotIndex;
  packetDb.ClassIndex := packet.ClassIndex;
  packetDb.ClientId := player.ClientId;
  DbClient.SendPacket(@packetDb, packetDb.Header.Size);

  player.WaitingDbServer := True;
end;


class function TPacketHandlers.DeleteCharacter(var player: TPlayer; var buffer: array of Byte): Boolean;
var packet : TDeleteCharacterRequestPacket absolute buffer;
    local : string;
begin
  Result := true;
  if (packet.Password <> player.Account.Header.Password) then begin
    player.SendClientMessage('Senha incorreta.');
    exit;
  end;

  if (player.Account.Characters[packet.SlotIndex].Base.Equip[0].Index = 0) then begin
    player.SendClientMessage('Você não possui personagem neste slot.');
    exit;
  end;

  if not(TFunctions.CompareCharOwner(player, packet.Name)) then
  begin
    player.SendClientMessage('Este personagem não pertence a esta conta.');
    exit;
  end;

  ZeroMemory(@player.Account.Characters[packet.SlotIndex], sizeof(TCharacterDB));
  player.SendCharList($112);
  player.SaveAccount;
end;

class function TPacketHandlers.Gates(var player: TPlayer; var buffer: array of Byte): Boolean;
var cX, cY : WORD;
    hour : TDateTime;
    teleport: TTeleport;
begin
	cX := ((player.CurrentPosition.X) and $FFC);
	cY := ((player.CurrentPosition.Y) and $FFC);

  for teleport in TeleportsList do
  begin
    if(teleport.Scr1.X = cX) and (teleport.Scr1.Y = cY) then
    begin
      if((player as TBaseMob).Character.Gold >= teleport.Price) then
      begin
        if(teleport.Time = -1) or (hour = teleport.Time) then
        begin
          if player.Teleport(teleport.Dest1) then
          begin
            Dec((player as TBaseMob).Character.Gold, teleport.Price);
            player.RefreshMoney;
            player.SendScore;
          end
          else
            player.SendClientMessage('Ocorreu um erro ao teleporta-lo');
				end
        else
          player.SendClientMessage('Hora incorreta para uso do Teleport');
			end
      else
        player.SendClientMessage('Gold Insuficiente');
      break;
    end;
  end;
	Result := true;
end;

class function TPacketHandlers.AddPoints(var player: TPlayer; var buffer: array of Byte): boolean;
var
  packet : TRequestAddPoints absolute buffer;
  onSuccess:boolean; max,reqclass,skillDiv,skillId,skillId2: integer;
  info: psmallint; master: pbyte; master2: pbyte; item: TItemList;
begin
  result:=true;
  case(packet.Mode)of
    0:
    begin
      if((player as TBaseMob).Character.pStatus <= 0)then
          exit;

      info:=@(player as TBaseMob).Character.BaseScore.Str;
      inc(info,packet.Info);
      if(((packet.Info mod 2) = 0) and (info^ >= 32000)) or (((packet.Info mod 2) <> 0) and (info^ >= 12000))then
      begin
          player.SendClientMessage('Máximo de pontos é 32.000');
          exit;
      end;

      inc(info^);
      dec((player as TBaseMob).Character.pStatus);

      player.GetCurrentScore;
      player.SendEtc;
      player.SendScore;
    end;
    1:
    begin
        if((player as TBaseMob).Character.pMaster <= 0)then
            exit;

        if(((player as TBaseMob).Character.Learn and (128 shl (packet.Info * 8))) = 0)then
        begin
            max := ((((player as TBaseMob).Character.BaseScore.Level + 1) * 3) shr 1);
            if(max > 200)then
                max := 200;
        end
        else
            max := 255;

        master := @(player as TBaseMob).Character.BaseScore.wMaster;
        inc(master,packet.Info);
        if(master^ >= max)then
        begin
            player.SendClientMessage('Máximo de pontos neste atributo.');
            exit;
        end;

        inc(master^);
        dec((player as TBaseMob).Character.pMaster);

        player.SendEtc;
        player.SendScore;
    end;
    2:
    begin
        if(packet.Info < 5000) or (packet.Info > 5095)then
          exit;

        reqclass := TItemFunctions.GetEffectValue(packet.Info, EF_CLASS);

        if reqclass <= 2 then
          reqclass := reqclass - 1;

        if reqclass = 4 then
          reqclass := 2;

        if reqclass = 8 then
          reqclass := 3;

        skillDiv := Trunc(((packet.Info) - (5000 + (24 * reqclass)))/8) + 1;
        skillID := (packet.Info - 5000);
        skillID2 := (packet.Info - 5000) mod 24;

        item:= ItemList[packet.Info];

        info:=@item.STR;
        inc(info, skillDiv);
        master2 := @(player as TBaseMob).Character.CurrentScore.wMaster;
        inc(master2, skillDiv);

        onSuccess := false;

        if(((player as TBaseMob).Character.Learn and (1 shl skillID2)) = 0) then
            if(master2^ >= info^) then
                if((player as TBaseMob).Character.pSkill >= SkillsData[skillId].SkillPoint) then
                    if((player as TBaseMob).Character.Gold >= item.Price) then
                        if((player as TBaseMob).Character.BaseScore.Level >= item.Level) then
                            if(reqclass = (player as TBaseMob).Character.ClassInfo) then
                                onSuccess := true
                            else player.SendClientMessage('Não é possível aprender Skills de outras classes.')
                        else player.SendClientMessage('Level insuficiente para adquirir a Skill.')
                    else player.SendClientMessage('Dinheiro insuficiente para adquirir a Skill.')
                else player.SendClientMessage('Não há Pontos de Skill suficientes.')
            else player.SendClientMessage('Não há Pontos de habilidade suficientes.')
        else player.SendClientMessage('Você já aprendeu esta skill.');

        if(onSuccess = true) then
        begin
            (player as TBaseMob).Character.Learn := (player as TBaseMob).Character.Learn or (1 shl skillID2);
            dec((player as TBaseMob).Character.pSkill,SkillsData[skillid].SkillPoint);


            player.SendScore;
            player.SendEtc;
        end;
    end;
  end;
end;

class function TPacketHandlers.MoveItem(var player: TPlayer; var buffer: array of Byte): Boolean;
var packet : TMoveItemPacket absolute buffer; hadItem : Boolean;
    destItem, srcItem: pItem; aux: TItem; pos: BYTE;  error: integer;
    mob : TBaseMob;
begin
  mob := player;
  if(packet.destSlot < 0) or (packet.srcSlot < 0)then
    exit;
  {
  ZeroMemory(destItem, sizeof(TItem));
  ZeroMemory(srcItem, sizeof(TItem));
  }
  case(packet.DestType) of
    INV_TYPE:
    begin
      if(packet.destSlot < MAX_INV) then
        destItem := @mob.Character.Inventory[packet.destSlot]
      else exit;
    end;
    EQUIP_TYPE:
    begin
      if(packet.destSlot < MAX_EQUIPS) then
        destItem := @mob.Character.Equip[packet.destSlot]
      else exit;
    end;
    STORAGE_TYPE:
    begin
      if(packet.destSlot < MAX_CARGO) then
        destItem := @player.Account.Header.StorageItens[packet.destSlot]
      else exit;
    end;
  end;

  case(packet.srcType) of
    INV_TYPE:
    begin
      if(packet.srcSlot < MAX_INV) then
        srcItem := @mob.Character.Inventory[packet.srcSlot]
      else exit;
    end;
    EQUIP_TYPE:
    begin
      if(packet.srcSlot < MAX_EQUIPS) then
        srcItem := @mob.Character.Equip[packet.srcSlot]
      else exit;
    end;
    STORAGE_TYPE:
    begin
      if(packet.srcSlot < MAX_CARGO)then
        srcItem := @player.Account.Header.StorageItens[packet.srcSlot]
      else exit;
    end;
  end;

  error := 0;
  //if (packet.destType = INV_TYPE) then
  //begin
    //if not(TItemFunctions.CanCarry(player, srcItem^, packet.destSlot mod 9, packet.destSlot div 9, @error)) then
     // exit;
  //end;

  if (destItem.Index = 0) then
  begin
    hadItem := False;
    Move(srcItem^, destItem^, 8);
  end
  else
  begin
    hadItem := True;
    Move(destItem^, aux, 8);
    Move(srcItem^, destItem^, 8);
    Move(aux, srcItem^, 8);
  end;

  if (packet.destType = INV_TYPE) and (packet.srcSlot = 6) and not(mob.Character.Equip[7].Index = 0) then
  begin
    pos := TItemFunctions.GetEffectValue(mob.Character.Equip[7].Index, EF_POS);

		if(pos = 192) then
		begin
			Move(mob.Character.Equip[7], mob.Character.Equip[6], 8);
			ZeroMemory(@mob.Character.Equip[7], 8);
    end;
  end;

  if (packet.destType = EQUIP_TYPE) and (packet.destSlot = 14) and ((destItem^.Index >= 2330) and (destItem^.Index <= 2358)) then
    player.GenerateBabyMob
  else
  begin
    if (packet.srcType = EQUIP_TYPE) and (packet.srcSlot = 14) and ((srcItem^.Index >= 2330) and (srcItem^.Index <= 2358))  then
      player.UngenerateBabyMob(DELETE_UNSPAWN);
  end;

  if not hadItem then
    ZeroMemory(srcItem,8);
  player.SendPacket(@packet, packet.Header.Size);
  player.SendScore;
  player.SendEtc;
  player.SendEquipItems(False);
  player.SaveAccount;
  result := true;
end;

class function TPacketHandlers.DeleteItem(var player: TPlayer; var buffer: array of Byte) : Boolean;
var packet: TDeleteItem absolute buffer;
begin
  result:=false;
  if(packet.slot < 0) or (packet.slot > 60)then
    exit;
  if((player as TBaseMob).Character.Inventory[packet.slot].Index = packet.itemid)then
    ZeroMemory(@(player as TBaseMob).Character.Inventory[packet.slot],8)
  else
    player.RefreshInventory;
  result:=true;
end;

class function TPacketHandlers.UngroupItem(var player: TPlayer; var buffer: array of Byte) : Boolean;
var packet: TGroupItem absolute buffer; i : BYTE; aux: TItem;
begin
  result:=false;
  if(packet.slot < 0) or (packet.slot > 60)then
    exit;
  if((player as TBaseMob).Character.Inventory[packet.slot].Index = packet.itemid)then
  begin
    for i := 0 to 2 do
    begin
      if ((player as TBaseMob).Character.Inventory[packet.slot].Effects[i].Index = 61) then
      begin
        Move((player as TBaseMob).Character.Inventory[packet.slot], aux, 8);
        aux.Effects[i].Value := packet.quant;
        if (TItemFunctions.PutItem(player, aux) <> 255) then
        begin
          dec((player as TBaseMob).Character.Inventory[packet.slot].Effects[i].Value, packet.quant);
          player.RefreshInventory;
        end
        else
        begin
          player.SendClientMessage('Falta espaço no inventário.');
          //player.RefreshInventory;
        end;
        break;
      end;
    end;
  end;
  //else
  //  RefreshInventory(index);
  result:=true;
end;


class function TPacketHandlers.SendNPCSellItens(var player: TPlayer; var buffer: array of Byte) : Boolean;
var packet: TSendNPCSellItensPacket absolute buffer;
    npc : TNpc;
    npcId : WORD;
begin
  result := true;
  Move(buffer[12], npcId, 2);
  npc := TNPC.Npcs[npcId];

  if not(npc.CurrentPosition.InRange(player.CurrentPosition, 6)) then
    exit;

  packet.Header.Size := 236;
  packet.Header.Code := $17C;
  packet.Header.Index := 30000;

  Move(npc.Character.Inventory, packet.Itens, SizeOf(TItem) * 26);

  case npc.Character.Merchant of
    1://itens
    begin
      packet.Merch := 1;
      packet.Imposto := Taxes;
    end;
    19:
    begin
      packet.Merch := 3;
      {
      j:=0;
      for i := 0 to 64 do
      begin
        if(npc.Inventory[i].Index <> 0) and (j <= 26)then begin
          Move(npc.Inventory[i],packet.Itens[j],8);
          inc(j);
          if(j = 8) or (j = 17)then
            inc(j);
        end;
      end;
      }
      packet.Imposto := 0;
    end;
  end;
  player.SendPacket(@packet, packet.Header.Size);
end;

class function TPacketHandlers.Trade(var player: TPlayer; var buffer: array of Byte): Boolean;
var packet: TTradePacket absolute buffer;
    otherPlayer: TPlayer;
    i, j: Byte;
begin
  otherPlayer := TPlayer.Players[packet.OtherClientId];
	player.PlayerCharacter.Trade.Confirm := packet.Confirm;

	if not(Assigned(otherPlayer)) then
	begin
		player.SendClientMessage('Este jogador não está conectado.');
		exit;
	end;

	if((otherPlayer.PlayerCharacter.PlayerKill) or (player.PlayerCharacter.PlayerKill))then
	begin
		player.SendClientMessage('Desative o modo pk.');
		exit;
	end;
	if(not(player.PlayerCharacter.Trade.isTrading)) and ((not(otherPlayer.PlayerCharacter.Trade.isTrading)) and (packet.TradeItem[0].Index <= 0))then
	begin
    ZeroMemory(@packet, sizeof(TTradePacket));
		packet.OtherClientid := player.ClientId;
		packet.Header.index := otherPlayer.ClientId;
		packet.Header.Size := sizeof(TTradePacket);
		packet.Header.Code := $383;
		for i := 0 to 14 do
    begin
			packet.TradeItemSlot[i] := -1;
      player.PlayerCharacter.Trade.TradeItemSlot[i] := -1;
    end;
		otherPlayer.SendPacket(@packet, packet.Header.Size);
		player.PlayerCharacter.Trade.Timer := now;
		player.PlayerCharacter.Trade.IsTrading := true;
		player.PlayerCharacter.Trade.Waiting := true;
		player.PlayerCharacter.Trade.otherClientid := otherPlayer.ClientId;
		exit;
	end
  else
	begin
		if((not(player.PlayerCharacter.Trade.IsTrading))
      and (otherPlayer.PlayerCharacter.Trade.IsTrading)
      and (otherPlayer.PlayerCharacter.Trade.otherClientid = player.ClientId)
			and (otherPlayer.PlayerCharacter.Trade.Waiting))then
		begin
			ZeroMemory(@packet, sizeof(TTradePacket));
	   	packet.OtherClientid := player.ClientId;
	   	packet.Header.index := otherPlayer.ClientId;
	   	packet.Header.Size := 156;
	   	packet.Header.Code := $383;
	   	for i := 0 to 14 do
      begin
	   		packet.TradeItemSlot[i] := -1;
        player.PlayerCharacter.Trade.TradeItemSlot[i] := -1;
      end;
	   	otherPlayer.SendPacket(@packet, packet.Header.Size);
	   	player.PlayerCharacter.Trade.Timer := now;
	   	player.PlayerCharacter.Trade.IsTrading := true;
	   	player.PlayerCharacter.Trade.Waiting := true;
	   	player.PlayerCharacter.Trade.otherClientid := otherPlayer.ClientId;
      exit;
		end;

		if((player.PlayerCharacter.Trade.IsTrading)
      and (player.PlayerCharacter.Trade.otherClientid <> otherPlayer.ClientId)) then
		begin
			player.SendClientMessage('Você já está em uma negociação.');
			player.PlayerCharacter.Trade.IsTrading := false;
			player.PlayerCharacter.Trade.Waiting := false;
			player.PlayerCharacter.Trade.otherClientid := 0;
			exit;
		end;

		if((otherPlayer.PlayerCharacter.Trade.IsTrading)
      and (otherPlayer.PlayerCharacter.Trade.otherClientid <> player.ClientId)) then
		begin
			player.SendClientMessage('O outro jogador já está em uma negociação.');
			player.PlayerCharacter.Trade.IsTrading := false;
			player.PlayerCharacter.Trade.Waiting := false;
			player.PlayerCharacter.Trade.otherClientid := 0;
			exit;
		end;
	end;
	if((otherPlayer.PlayerCharacter.Trade.OtherClientid <> player.ClientId)
    and (player.PlayerCharacter.Trade.otherClientid <> otherPlayer.ClientId))then
	begin
		player.SendClientMessage('Ocorreu um erro.');
		otherPlayer.SendClientMessage('Ocorreu um erro.');
		player.CloseTrade;
		exit;
	end;
	if(player.PlayerCharacter.Trade.Confirm)then
	begin
		if((now - player.PlayerCharacter.Trade.Timer) < strtotime('00:00:02'))then
		begin
			player.SendClientMessage('Aguarde 2 segundos e aperte o botão.');
			player.PlayerCharacter.Trade.Confirm := false;
			player.PlayerCharacter.Trade.Timer := Now;
			exit;
		end
    else
		begin
			if(otherPlayer.PlayerCharacter.Trade.Confirm)then
			begin

				if not(TFunctions.CheckItensTrade(player, False)) then
				begin
					player.SendClientMessage('Você não tem espaço o suficiente no inventário.');
					otherPlayer.SendClientMessage('O outro player não tem espaço o suficiente no inventário.');
					player.CloseTrade;
					otherPlayer.CloseTrade;
					exit;
				end;
				if not(TFunctions.CheckItensTrade(otherPlayer, False)) then
				begin
					otherPlayer.SendClientMessage('Você não tem espaço o suficiente no inventário.');
					player.SendClientMessage('O outro player não tem espaço o suficiente no inventário.');
					player.CloseTrade;
					otherPlayer.CloseTrade;
					exit;
				end;

				if((player as TBaseMob).Character.Gold + otherPlayer.PlayerCharacter.Trade.Gold <= 2000000000)
					and ((otherPlayer as TBaseMob).Character.Gold + player.PlayerCharacter.Trade.Gold <= 2000000000)then
				begin
					inc((player as TBaseMob).Character.Gold, otherPlayer.PlayerCharacter.Trade.Gold);
					inc((otherPlayer as TBaseMob).Character.Gold, player.PlayerCharacter.Trade.Gold);
					dec((player as TBaseMob).Character.Gold, player.PlayerCharacter.Trade.Gold);
					dec((otherPlayer as TBaseMob).Character.Gold, otherPlayer.PlayerCharacter.Trade.Gold);
          player.RefreshMoney;
          otherPlayer.RefreshMoney;
				end
				else
				begin
					player.SendClientMessage('Limite de 2 Bilhões de gold.');
					otherPlayer.SendClientMessage('Limite de 2 Bilhões de gold.');
					player.CloseTrade;
					otherPlayer.CloseTrade;
					exit;
				end;
				TFunctions.CheckItensTrade(player, True);
				TFunctions.CheckItensTrade(otherPlayer, True);
				player.CloseTrade;
				otherPlayer.CloseTrade;
				exit;

			end
      else
			begin
        if (CompareMem(@packet.TradeItem[0],@player.PlayerCharacter.Trade.Itens[0],8*15) <> true) or (packet.Gold <> player.PlayerCharacter.Trade.Gold)
            or (CompareMem(@packet.TradeItemSlot[0],@player.PlayerCharacter.Trade.TradeItemSlot[0],15) <> true)then
        begin
          player.PlayerCharacter.Trade.Confirm := False;
          otherPlayer.PlayerCharacter.Trade.Confirm := False;
        end;
        player.PlayerCharacter.Trade.Gold := packet.Gold;
        Move(packet.TradeItem[0],player.PlayerCharacter.Trade.Itens[0],8*15);
        Move(packet.TradeItemSlot[0],player.PlayerCharacter.Trade.TradeItemSlot[0],15);
				ZeroMemory(@packet, sizeof(TTradePacket));
        Move(player.PlayerCharacter.Trade.Itens[0],packet.TradeItem[0],8*15);
				Move(player.PlayerCharacter.Trade.TradeItemSlot[0],packet.TradeItemSlot[0],15);
        packet.Gold:= player.PlayerCharacter.Trade.Gold;
        packet.OtherClientid := player.ClientId;
        packet.Header.index := otherPlayer.ClientId;
        packet.Header.Size := 156;
        packet.Header.Code := $383;
        for i := 0 to 14 do
          packet.TradeItemSlot[i] := -1;
        packet.Confirm := player.PlayerCharacter.Trade.Confirm;
				otherPlayer.SendPacket(@packet, packet.Header.Size);
			end;
      exit;
		end;
	end
  else
	begin
		//Recebe os itens e gold para o buffer Trade
		if(packet.Gold > (player as TBaseMob).Character.Gold)then
		begin
			player.SendClientMessage('Ocorreu um erro.');
			otherPlayer.SendClientMessage('Ocorreu um erro.');
			player.CloseTrade;
			otherPlayer.CloseTrade;
			exit;
		end;
		for i := 0 to 14 do
		begin
			if(packet.TradeItemSlot[i] <> -1)then
			begin
				for j := i+1 to 14 do
				begin
					if((packet.TradeItemSlot[i] = packet.TradeItemSlot[j]) and (i <> j))then
					begin
						player.SendClientMessage('Ocorreu um erro.');
            otherPlayer.SendClientMessage('Ocorreu um erro.');
            player.CloseTrade;
            otherPlayer.CloseTrade;
            exit;
					end;
				end;
				if(packet.TradeItemSlot[i] < -1) or (packet.TradeItemSlot[i] > 63)then
        begin
					player.SendClientMessage('Ocorreu um erro.');
          otherPlayer.SendClientMessage('Ocorreu um erro.');
          player.CloseTrade;
          otherPlayer.CloseTrade;
          exit;
				end;
				if((CompareMem(@packet.TradeItem[i],@(player as TBaseMob).Character.Inventory[packet.TradeItemSlot[i]],8) <> true)
					and (packet.TradeItem[i].Index <> 0)) then
				begin
					player.SendClientMessage('Ocorreu um erro.');
          otherPlayer.SendClientMessage('Ocorreu um erro.');
          player.CloseTrade;
          otherPlayer.CloseTrade;
          exit;
				end;
			end
      else
			begin
				if(packet.TradeItem[i].Index > 0) or
					(player.PlayerCharacter.Trade.Itens[i].Index > 0)then
				begin
					player.SendClientMessage('Ocorreu um erro.');
          otherPlayer.SendClientMessage('Ocorreu um erro.');
          player.CloseTrade;
          otherPlayer.CloseTrade;
          exit;
				end;
			end;
		end;
    if (CompareMem(@packet.TradeItem[0],@player.PlayerCharacter.Trade.Itens[0],8*15) <> true) or (packet.Gold <> player.PlayerCharacter.Trade.Gold)
        or (CompareMem(@packet.TradeItemSlot[0],@player.PlayerCharacter.Trade.TradeItemSlot[0],15) <> true)then
    begin
      player.PlayerCharacter.Trade.Confirm := False;
      otherPlayer.PlayerCharacter.Trade.Confirm := False;
    end;
		player.PlayerCharacter.Trade.Gold := packet.Gold;
    Move(packet.TradeItem[0],player.PlayerCharacter.Trade.Itens[0],8*15);
    Move(packet.TradeItemSlot[0],player.PlayerCharacter.Trade.TradeItemSlot[0],15);
    ZeroMemory(@packet, sizeof(TTradePacket));
    packet.OtherClientid := player.ClientId;
    packet.Header.index := otherPlayer.ClientId;
    packet.Header.Size := 156;
    packet.Header.Code := $383;
    packet.Confirm := player.PlayerCharacter.Trade.Confirm;
    Move(player.PlayerCharacter.Trade.Itens[0],packet.TradeItem[0],8*15);
    Move(player.PlayerCharacter.Trade.TradeItemSlot[0],packet.TradeItemSlot[0],15);
    packet.Gold:= player.PlayerCharacter.Trade.Gold;
    player.PlayerCharacter.Trade.Timer := now;
		player.PlayerCharacter.Trade.Confirm := false;
	  otherPlayer.SendPacket(@packet, packet.Header.Size);
		end;
	exit;
end;


class function TPacketHandlers.BuyNpcItens(var player: TPlayer; var buffer: array of Byte): Boolean;
var packet: TBuyNpcItensPacket absolute buffer;
    item : TItem;
    price : Integer;
    slot: BYTE;
    adjustedPrice: integer;
begin
/////////////////////////////////
  if(packet.sellSlot > 8) then Dec(packet.sellSlot, 18);
////////////////////////////////
  item  := TNPC.Npcs[packet.mobID].Character.Inventory[packet.sellSlot];
  if(item.Index = 0) then
    exit;

  price := Trunc(ItemList[item.Index].Price + (ItemList[item.Index].Price*(Taxes/100)));

  if((player as TBaseMob).Character.Gold >= price) then
  begin
    slot := TItemFunctions.GetEmptySlot(player);
    if(slot <> 254) then
    begin
      adjustedPrice := price + Trunc((price * Taxes) / 100);
      Dec((player as TBaseMob).Character.Gold, adjustedPrice);
      player.SendCreateItem(INV_TYPE, slot, item);
      Move(item, (player as TBaseMob).Character.Inventory[slot], sizeof(TItem));
      player.SaveAccount;
      player.RefreshMoney;
    end
    else player.SendClientMessage('Inventário cheio. Impossível Negociar.');
  end
  else player.SendClientMessage('Gold insuficiente.');
end;


class function TPacketHandlers.BuyStoreTrade(var player: TPlayer; var buffer: array of Byte): Boolean;
var
  packet: TBuyStoreItemPacket absolute buffer;
  seller : TPlayer;
  response : TSendItemBoughtPacket;
  i : BYTE;
  find : Boolean;
  branco : TItem;
begin
    result := true;
    if(packet.Slot > 11) or
      (packet.SellerId = player.ClientId) or
      (not(TPlayer.Players[packet.SellerId].PlayerCharacter.IsStoreOpened)) then
    begin
      exit;
    end;

    seller := TPlayer.Players[packet.SellerId];
    if not(Assigned(seller)) then exit;

    if(packet.Gold <> seller.PlayerCharacter.TradeStore.Gold[packet.Slot])then
    begin
      player.SendClientMessage('Item Price changed error.');
      exit;
    end;

    if not(CompareMem(@seller.PlayerCharacter.TradeStore.Item[packet.Slot], @packet.Item, 8)) then
    begin
      player.SendClientMessage('Item changed error.');
      exit;
    end;

    if((player as TBaseMob).Character.Gold < seller.PlayerCharacter.TradeStore.Gold[packet.Slot])then
    begin
      player.SendClientMessage('Não pussui essa quantia.');
      exit;
    end;

    if((seller.PlayerCharacter.TradeStore.Gold[packet.Slot] + seller.Account.Header.StorageGold) > 2000000000)then
    begin
      player.SendClientMessage('O vendedor atingiu o limite de 2.000.000.000 de gold.');
      exit;
    end;

    if (TItemFunctions.PutItem(player, packet.Item) = 255) then
    begin
      player.SendClientMessage('Sem espaço no inventário.');
      exit;
    end;

    //Move(player.Character.Inventory[emptySlot], packet.Item, 8);
    //player.SendCreateItem(INV_TYPE, emptySlot, packet.Item);

    Dec((player as TBaseMob).Character.Gold, packet.Gold);
    player.RefreshMoney;
    Inc(seller.Account.Header.StorageGold, packet.Gold);

    response.Header.Size := sizeof(TSendItemBoughtPacket);
    response.Header.Code := $39B;
    response.Header.Index := $7530;
    response.SellerId := packet.SellerId;
    response.Slot := packet.Slot;

    // Apaga o item na auto-venda para todos os clients visiveis
    seller.SendToVisible(@response, response.Header.Size);

    ZeroMemory(@seller.Account.Header.StorageItens[seller.PlayerCharacter.TradeStore.Slot[packet.Slot]], 8);
    seller.SendCreateItem(STORAGE_TYPE, seller.PlayerCharacter.TradeStore.Slot[packet.Slot], branco);

    seller.SendSignal($7530, $339, seller.Account.Header.StorageGold);

    seller.PlayerCharacter.TradeStore.Gold[packet.Slot] := 0;
    seller.PlayerCharacter.TradeStore.Slot[packet.Slot] := 0;
    ZeroMemory(@seller.PlayerCharacter.TradeStore.Item[packet.Slot],8);
    seller.SendClientMessage('Um produto foi vendido.');

    find := false;
    for i := 0 to 11 do
      if (seller.PlayerCharacter.TradeStore.Item[i].Index <> 0) then
        find := true;

    if not(find) then
    begin
      if (seller.PlayerCharacter.IsStoreOpened) then
      begin
        seller.SendSignal(seller.ClientId, $384);
        seller.PlayerCharacter.IsStoreOpened := False;

        seller.SendCreateMob(SPAWN_NORMAL);
      end;
    end;

    result:= true;
end;

class function TPacketHandlers.SellItemsToNPC(var player: TPlayer; var buffer: array of Byte) : Boolean;
var packet : TSellItemsToNpcPacket absolute buffer;
    item : TItem;
    price, tax : integer;
begin
  if(packet.invType <> INV_TYPE)then
  begin
    player.SendClientMessage('Passe o item para o inventário.');
    exit;
  end;

  if(packet.invSlot > MAX_INV - 1) then
    exit;

  item := (player as TBaseMob).Character.Inventory[packet.invSlot];
  price := TItemFunctions.GetItemAbility(item, EF_PRICE);

  if((player as TBaseMob).Character.Gold + price <= 2000000000)then
  begin
    if(price mod 20000 = 0)then
      price := Trunc((price / (4 + (Round((price / 20000) - 1) * 2))))
    else
      price := Trunc((price / (4 + (Round(price / 20000) * 2))));
    tax := Trunc((price * Taxes) / 100);
    Inc((player as TBaseMob).Character.Gold, price - tax);

    ZeroMemory(@(player as TBaseMob).Character.Inventory[packet.invSlot].Index, 8);
    player.SaveAccount;
    player.RefreshInventory;
  end
  else player.SendClientMessage('Limite de 2 Bilhões de gold.');
end;



class function TPacketHandlers.SelectCharacter(var player: TPlayer; var buffer: array of Byte): Boolean;
var packet : TSelectCharacterRequestPacket absolute buffer;
begin
  if (packet.CharacterId < 0) or (packet.CharacterId > 3) then begin
    player.SendClientMessage('Posição Inválida.');
    exit;
  end;

  if (player.Account.Characters[packet.CharacterId].Base.Equip[0].Index = 0) then
  begin
    player.SendClientMessage('Personagem Inválido.');
    exit;
  end;
  player.SendToWorld(packet.CharacterId);
  //exit;
end;

class function TPacketHandlers.RequestParty(var player: TPlayer; var buffer: array of Byte): boolean;
var
  packet: TPartyRequestPacket absolute buffer;
  party : PParty;
  partyId : WORD;
begin
  result := true;
  if(packet.TargetId < 1) or (packet.TargetId > 1000) or (packet.SenderId <> player.ClientId) then
  begin
    exit;
  end;

  if(TPlayer.Players[packet.TargetId].PartyId <> 0)then
  begin
    player.SendClientMessage('O outro jogador já está em um grupo.');
    exit;
  end;

  if(packet.Level <> (player as TBaseMob).Character.CurrentScore.Level)
    or (packet.MaxHp <> (player as TBaseMob).Character.CurrentScore.MaxHP)
    or (packet.CurHp <> (player as TBaseMob).Character.CurrentScore.CurHP) then
  begin
    result := false;
    exit;
  end;

  if(AnsiCompareStr((player as TBaseMob).Character.Name, packet.Nick) <> 0)then
  begin
    result := false;
    exit;
  end;

  if (player.PartyId <> 0) then
    party := @Parties[player.PartyId]
  else
  begin
    partyId := TFunctions.FindFreePartyId;

    if (partyId >= 751) then
    begin
      player.SendClientMessage('Não existem grupos livres. Favor contactar o administrador.');
      exit;
    end;

    party := @Parties[partyId];
    party^.Leader := player.ClientId;
    player.PartyId := partyId;
  end;

  if(party^.Leader = 0) then
  begin
    player.SendClientMessage('Grupo não encontrado.');
    exit;
  end;

  if (party^.Leader <> player.ClientId) then
  begin
    player.SendClientMessage('Você não é líder. Saia do grupo para criar um novo grupo.');
    exit;
  end;

  TPlayer.Players[packet.TargetId].PartyId := player.PartyId;
  TPlayer.Players[packet.TargetId].SendPacket(@packet, packet.Header.Size);
end;

class function TPacketHandlers.ExitParty(var player: TPlayer; var buffer: array of Byte): boolean;
var packet: TExitPartyPacket absolute buffer;
    i: BYTE;
    party : PParty;
begin
  result := true;
  if(packet.Header.Index <> player.ClientId) then
    exit;

  if(player.PartyId = 0) then
  begin
    player.SendClientMessage('Você não está em um grupo.');
    exit;
  end;

  if not(player.acceptedParty) then
  begin
    player.SendExitParty(0);
    exit;
  end;

  party := @Parties[player.PartyId];
  if(party^.Leader = 0) then
  begin
    player.SendClientMessage('Grupo não encontrado.');
    exit;
  end;

  if(packet.ExitId <> 0) then
  begin
    //lider mandou tirar da pt
    if(player.ClientId <> party^.Leader) then
    begin
      player.SendClientMessage('Somente o lider pode expulsar membros do grupo.');
      exit;
    end
    else
    begin
      TPlayer.Players[party^.Leader].SendExitParty(packet.ExitId);
      for i in party^.Members do
      begin
        if (i < MAX_CONNECTIONS) then
          TPlayer.Players[i].SendExitParty(IfThen(i <> packet.ExitId, packet.ExitId, 0));
      end;

      party^.Members.Remove(packet.ExitId);
      TPlayer.Players[packet.ExitId].PartyId := 0;
      TPlayer.Players[packet.ExitId].acceptedParty := false;
    end;
  end
  else
  begin
    player.acceptedParty := false;
    player.PartyId := 0;
    if(player.ClientId <> party^.Leader) then
    begin
      //Membro Saiu da Pt
      TPlayer.Players[party^.Leader].SendExitParty(player.ClientId);
      for i in party^.Members do
      begin
        if (i < MAX_CONNECTIONS) then
          TPlayer.Players[i].SendExitParty(IfThen(i <> player.ClientId, player.ClientId, 0));
      end;
      party^.Members.Remove(player.ClientId);
    end
    else
    begin
      //Lider Saiu da Pt
      player.SendExitParty(0);
      for i in party^.Members do
      begin
        if (i < MAX_CONNECTIONS) then
          TPlayer.Players[i].SendExitParty(player.ClientId);
      end;

      if (party^.Members.Count > 1) then
      begin
        party^.Leader := party^.Members[0];
        for i in party^.Members do
        begin
          if (i < MAX_CONNECTIONS) then
            TPlayer.Players[i].SendParty(party^.Leader, party^.Leader);
        end;
        party^.Members.Remove(party^.Leader);
      end;
    end;
  end;

  if (party^.Members.Count = 0) then //finalizando party
  begin
    TPlayer.Players[party^.Leader].SendExitParty(0);
    TPlayer.Players[party^.Leader].PartyId := 0;
    TPlayer.Players[party^.Leader].acceptedParty := False;
    ZeroMemory(party, sizeof(TParty));
  end;
end;

class function TPacketHandlers.AcceptParty(var player: TPlayer; var buffer: array of Byte): boolean;
var
  packet: TAcceptPartyPacket absolute buffer;
  party : PParty;
  leader: TPlayer;
  first : Boolean;
begin
  result := true;

  if(player.partyId = 0) then
  begin
    player.SendClientMessage('Grupo não encontrado.');
    exit;
  end;

  party := @Parties[player.partyId];
  if(packet.LeaderId <> party^.Leader) then
    exit;

  if not(TPlayer.GetPlayer(packet.LeaderId, leader)) then
    exit;

  if(AnsiCompareStr(leader.PlayerCharacter.Base.Name, packet.Nick) <> 0)then
    exit;

  first := (not Assigned(party^.Members)) or (party^.Members.Count = 0);
  if not(party^.AddMember(player.ClientId)) then
  begin
    player.SendClientMessage('O grupo está cheio.');
    exit;
  end;

  player.acceptedParty := True;

  //eviar os membros do grupo e o lider para o novo membro
  //para enviar o lider para o novo membro temos q enviar o Clientid com o index do lider
  //e o LeaderId com o clientid do lider
  if (first) then //enviar lider para o lider quando o grupo é formado
  begin
    leader.SendParty(packet.LeaderId, packet.LeaderId);
    leader.acceptedParty := True;
  end;

  leader.SendParty(256, player.ClientId);
  player.SendParty(packet.LeaderId, packet.LeaderId);

  player.SendParty(); // Envia os membros pra esse player,
                         // E o player para os outros membros
end;

class function TPacketHandlers.SendClientSay(var player: TPlayer; var buffer: array of Byte): Boolean;
var packet : TClientMessagePacket absolute buffer; msg: string;
begin
  packet.Message[95] := #0;

  if(AnsiCompareStr(Trim(packet.Message),'guild') = 0)then
  begin
      player.SendClientMessage('Ainda não implementado.');
      result := true;
      exit;
  end;

  msg := packet.Message[0] + packet.Message;
  //player.SendChat(msg);
  player.SendToVisible(@packet, packet.Header.Size, false);
  result:=true;
end;

class function TPacketHandlers.CargoGoldToInventory(var player: TPlayer; var buffer: array of Byte): Boolean;
var packet : TRefreshMoneyPacket absolute buffer;
begin
  if(packet.Gold > player.Account.Header.StorageGold)then
  begin
    player.SendClientMessage('Você não possui essa quantia.');
    exit;
  end;
  if((player as TBaseMob).Character.Gold + packet.Gold > 2000000000)then
  begin
    player.SendClientMessage('Limite de 2 bilhões de gold.');
    exit;
  end;
  inc((player as TBaseMob).Character.Gold, packet.Gold);
  dec(player.Account.Header.StorageGold, packet.Gold);
  player.SaveAccount;
  player.SendPacket(@packet, packet.Header.Size);
  //player.SendSignal(30002, $387, packet.Gold);
end;

class function TPacketHandlers.LogOut(var player: TPlayer; var buffer: array of Byte): Boolean;
var packet : TRefreshMoneyPacket absolute buffer;
  mob: TBaseMob;
begin
  if (Assigned(player.Target)) then
  begin
    player.GetMob(player.Target.ClientId, mob);
    mob.Target := nil;
  end;
  player.SaveAccount;
  player.SendRemoveMob(DELETE_DISCONNECT);
  Result := True;
end;

class function TPacketHandlers.InventoryGoldToCargo(var player: TPlayer; var buffer: array of Byte): Boolean;
var packet : TRefreshMoneyPacket absolute buffer;
begin
  if(packet.Gold > (player as TBaseMob).Character.Gold)then
  begin
    player.SendClientMessage('Você não possui essa quantia.');
    exit;
  end;
  if(player.Account.Header.StorageGold + packet.Gold > 2000000000)then
  begin
    player.SendClientMessage('Limite de 2 bilhões de gold.');
    exit;
  end;
  inc(player.Account.Header.StorageGold,packet.Gold);
  dec((player as TBaseMob).Character.Gold,packet.Gold);
  player.SaveAccount;
  player.SendPacket(@packet, packet.Header.Size);
end;

class function TPacketHandlers.CloseTrade(var player: TPlayer): Boolean;
begin
  if (player.PlayerCharacter.IsStoreOpened) then
  begin
    player.PlayerCharacter.IsStoreOpened := False;

    player.SendCreateMob(SPAWN_NORMAL);
    exit;
  end;
end;

class function TPacketHandlers.OpenStoreTrade(var player: TPlayer; var buffer: array of Byte): boolean;
var packet : TOpenTrade absolute buffer;
begin

  if(TPlayer.Players[packet.OtherClientId].PlayerCharacter.IsStoreOpened = false)then
  begin
    result:= true;
    exit;
  end;

  TPlayer.Players[packet.OtherClientId].SendAutoTrade(player);
  result:=true;
end;

class function TPacketHandlers.PKMode(var player: TPlayer; var buffer: array of Byte): boolean;
var packet : TSignalData absolute buffer;
begin
  if packet.Data > 255 then
  begin
    result := false;
    exit;
  end;

  player.PlayerCharacter.PlayerKill := (packet.Data = 1);
  result := True;
end;

class function TPacketHandlers.ChangeSkillBar(var player: TPlayer; var buffer: array of Byte): boolean;
var packet : TSkillBarChange absolute buffer;
begin
  result := False;
  Move(packet.SkillBar[0], (player as TBaseMob).Character.SkillBar1[0],4);
  Move(packet.SkillBar[4], (player as TBaseMob).Character.SkillBar2[0],16);
  result := True;
end;

class function TPacketHandlers.DropItem(var player: TPlayer; var buffer: array of Byte): boolean;
var packet : TReqDropItem absolute buffer; item : PItem; initItem : TInitItem; Pos : TPosition;
    initId : WORD;
begin
  result := False;
  if not(TItemFunctions.GetItem(item, player, packet.invSlot, packet.invType))then
    exit;

  if(item.Index = 0)then
    exit;

  initId := TItemFunctions.FreeInitItem();
  if(initId = 0) then
    exit;

  Pos := player.CurrentPosition;
  if not(TItemFunctions.GetEmptyItemGrid(Pos))then
  begin
    player.SendClientMessage('Sem espaço para jogar items.');
    result := true;
    exit;
  end;

  Move(item^, initItem.Item, sizeof(TItem));
  player.RemoveItem(packet.invSlot, packet.invType);

  initItem.Pos := Pos;
  initItem.ClientId := player.ClientId;
  initItem.TimeDrop := Now;
  InitItems[initId] := initItem;
  player.KnowInitItems.Add(initId);
  ItemGrid[Pos.Y][Pos.X] := initId;


  player.SendCreateDropItem(initId);

  player.SendDeleteItem(packet.invType, packet.InvSlot);

  result := true;
end;

class function TPacketHandlers.MobNotInView(var player: TPlayer;
  var buffer: array of Byte): Boolean;
var packet : TMobNotInView absolute buffer;
  npc : TNpc;
  otherPlayer : TPlayer;
begin
  result := False;
	if (packet.MobID <= 0) or (packet.MobID >= MAX_SPAWN_ID) then
	begin
    result := True;
		exit;
  end;

  if (packet.MobId < MAX_CONNECTIONS) then
  begin
    TPlayer.GetPlayer(packet.MobId, otherPlayer);
    otherPlayer.SendRemoveMob(DELETE_NORMAL, player.ClientId);
  end
  else
  begin
    TNpc.GetNpc(packet.MobId, npc);

    if (npc.GenerData.Mode = MOB_EMPTY) then
    begin
      npc.SendRemoveMob(DELETE_NORMAL, player.ClientId);
      result := True;
      exit;
    end;

    if (npc.Character.Last.InView(player.Character.Last)) then
			npc.SendCreateMob(SPAWN_NORMAL ,player.ClientId)
		else
			npc.SendRemoveMob(DELETE_NORMAL, player.ClientId);

  end;

  result := True;
end;

class function TPacketHandlers.PickItem(var player: TPlayer; var buffer: array of Byte): boolean;
var packet : TReqPickItem absolute buffer; initItem : TInitItem;
begin
  result := False;

  if((packet.initId-10000) <> ItemGrid[packet.Position.Y][packet.Position.X])then
    exit;

  try
    initItem := InitItems[packet.initId - 10000];
  except
    exit;
  end;

  if(initItem.Item.Index = 0)then
    exit;

  TItemFunctions.PutItem(player, initItem.Item);
  ItemGrid[initItem.Pos.Y][initItem.Pos.X] := 0;
  ZeroMemory(@InitItems[packet.initId-10000], sizeof(TInitItem));
  player.KnowInitItems.Remove(packet.initId-10000);

  player.SendDeleteDropItem(packet.initId);

  result := true;
end;

class function TPacketHandlers.MovementCommand(var player: TPlayer; var buffer: array of Byte): Boolean;
var packet : TMovementPacket absolute buffer;
  //cmm: Boolean;
  //source: TPosition;
  //code: smallint;
begin
  if not(packet.Destination.IsValid) OR (packet.MoveType <> MOVE_NORMAL) then
  begin
    result := false;
    exit;
  end;
  {
  if packet.Destination.Distance(player.CurrentPosition) > 12 then
  begin
    result := true;
    exit;
  end;
  }
  if ((player as TBaseMob).Character.ClassInfo = 3) then
    player.CleanAffect(HT_INIVISIBILIDADE);

  {
    Verificar áreas de guild e o campo de treinamento
  }

  //source := packet.Source;
  //code := packet.Header.Code;

  if (not TFunctions.GetEmptyMobGrid(player.ClientId, packet.Destination, 4)) then
  begin
    player.SendClientMessage('Sem espaço para movimentação');
    packet.Destination := packet.Source;
    player.SendMovement(packet, false);
  end;

  //packet.Source := source;
  //packet.Header.Code := code;
  player.SendMovement(TFunctions.GetAction(player, packet.Destination, MOVE_NORMAL), false);
end;

end.
