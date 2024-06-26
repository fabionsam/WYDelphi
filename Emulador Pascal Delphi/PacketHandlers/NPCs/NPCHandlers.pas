unit NPCHandlers;

interface

uses Windows, SysUtils, Math, Position, InitialCharactersLoader,
  Player, Packets, NPC, PlayerData, ItemFunctions, MiscData;

type TNPCHandlers = class(TObject)
  public
    class function Handle(var player: TPlayer; var buffer: array of Byte): Boolean; static;

  private
    class function Sephirot(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean; static;
    class function Juli(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean; static;
    class function GuardaReal(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean; static;
    class function Kibita(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean; static;
    class function MestreHab(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean; static;
    class function GodGovernament(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean; static;
    class function EntradasQuest(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean; static;
    class function KingdomBroker(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean; static;
    class function Oraculo(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean; static;
    class function Cosmos(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean; static;
    class function Kingdom(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean; static;
    class function Arch(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean; static;
    class function Khadin(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean; static;
    class function NpcDeTroca(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean; static;
    class function QuestCapaVerde(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean; static;
    class function Unis(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean; static;
    class function CarbWind(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean; static;
end;

implementation

uses GlobalDefs, ConstDefs, Util;

{ TNPCHandlers }
class function TNPCHandlers.Handle(var player: TPlayer; var buffer: array of Byte): Boolean;
var packet: TNpcPacket absolute buffer;
  npc: TNpc;
  handler: TVarFunc<TPlayer, TNpc, TNpcPacket, Boolean>;
begin
  if(packet.NpcIndex > TNPC.InstantiatedNPCs) OR (packet.NpcIndex < MAX_CONNECTIONS) then
    exit;

  npc := TNPC.NPCs[packet.NpcIndex];
  if(npc.CurrentPosition.Distance(player.CurrentPosition) > 10) then
    exit;

  case npc.Character.Merchant of
    4:
    begin
      case npc.Character.BaseScore.Level of
        1: handler := EntradasQuest;
        11: handler := CarbWind;
      end;
    end;
    19:
    begin
      if(player.Character.Equip[10].Index = 1742) then
        handler := Sephirot;
    end;
    30:
    begin
      case npc.Character.BaseScore.Level of
        1, 2: handler := Juli;
        3: handler := GuardaReal;
      end;
    end;
    42:
    begin
      case npc.Character.BaseScore.Level of
        1: handler := Kibita;
        2: handler := MestreHab;
        3: handler := GodGovernament;
        4, 5, 6, 7, 8: handler := EntradasQuest;
        9: handler := KingdomBroker;
        10: handler := Oraculo;
        11: handler := Cosmos;
        33: handler := Kingdom;
        34: handler := Arch;
        35: handler := Khadin;
        36: handler := NpcDeTroca;
      end;
    end;
    43:
    begin
      case npc.Character.BaseScore.Level of
        1: Result := true;
        3, 4: handler := QuestCapaVerde;
        5, 6, 7:handler := Unis;
        8: handler := CarbWind;
      end;
    end;
    58:
    begin
      //reviver montarias
    end;
  end;

  if (Result = true) then
    exit;

  if not(assigned(handler)) then
  begin
    npc.SendChat('Ainda n�o estou pronto');
    exit;
  end;

  Result := handler(player, npc, packet);  
end;

class function TNPCHandlers.Sephirot(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean;
var stones : array[0..7] of smallint;
  hasStones: Boolean;
  i: BYTE;
  seph: TItem;
begin
  if(packet.Confirm = 1) then
  begin
    if(player.Character.Gold < 30000000) then
    begin
      npc.SendChat('S�o necess�rios 30 milh�es de gold para compor o Sephirot.');
      exit;
    end;

    for i := 0 to Length(stones) do
    begin
      stones[i] := player.GetFirstSlot(1744 + i, INV_TYPE);
      if(stones[i] = -1) then
      begin
        hasStones := false;
				break;
      end;
    end;

    if not(hasStones) then
    begin
      npc.SendChat('Traga-me todas as oito pedras.');
      exit;
    end;

    for i := 0 to Length(stones) do
    begin
      ZeroMemory(@player.Character.Inventory[i], SizeOf(TItem));
    end;
    ZeroMemory(@seph, SizeOf(TItem));
    seph.Index := 1760 + npc.Character.ClassInfo;

    TItemFunctions.PutItem(player, seph);
    Dec(player.Character.Gold, 30000000);

    player.SendEtc;
    player.RefreshInventory;
    npc.SendChat('Recebeu Sephirot. Equipe-o e procure o rei.');
  end
  else
  begin
    npc.SendChat('Deseja compor o Sephirot?');
  end;
  Result := true;
end;

class function TNPCHandlers.Juli(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean;
var dest: TPosition;
begin
  if(player.Character.Gold < 1000) then
    npc.SendChat('Para ser teleportado traga-me 1.000 de gold.')
  else
  begin
    // Level 1, vai pra um lugar, Diferente disso vai pra outro
    // Caso precise de mais fazemos uma lista e colocamos pra um switch ou ler em um arquivo
    dest.X := IFThen(npc.Character.CurrentScore.Level = 1, 3649, 2480);
    dest.Y := IFThen(npc.Character.CurrentScore.Level = 1, 3133, 1651);
    player.Teleport(dest);
  end;
end;

class function TNPCHandlers.GuardaReal(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean;
begin
  if (player.Character.ClassLevel <> TClassLevel.Mortal) then
  begin
    npc.SendChat('Quest exclusiva aos Mortais.');
    exit;
  end;

  if(player.Character.BaseScore.Level <= 219)
    OR (player.Character.BaseScore.Level >= 250) then
  begin
    npc.SendChat('Level inadequado [221~251].');
    exit;
  end;

  player.Teleport(1729, 1732);
  npc.SendChat('Quest iniciada para ' + player.Character.Name);
end;

class function TNPCHandlers.Kibita(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean;
var lacSlot: Integer;
begin
  {
	if(player.Character.Citizenship <> TCitizenship.None) then
	begin
		if(player.Character.Base.Gold < 5000000) then
		begin
			player.SendClientMessage('Preciso de 5 Milh�es(5kk) para cadastrar voc� nesse servidor.');
			exit;
		end;
		Dec(player.Character.Base.Gold, 5000000);
		player.Character.Citizenship := CurrentServer;
		player.SendClientMessage('Voc� se cadastrou nesse servidor.');
		exit;
	end;

  if (DayOfWeek >= 2) AND (DayOfWeek() <= 6) AND (HourOf(Now) = 21) then
  begin
    npc.SendChat('Retorne durante a semana as 21h');
    exit;
  end;

  if not(player.Character.Base.IsMortal) then
  begin
    npc.SendChat('Exclusivo aos Mortais');
    exit;
  end;

  if (player.Character.Base.bStatus.Level >= 369) then
  begin
    npc.SendChat('Level inadequado [1~368].');
    exit;
  end;
  lacSlot := player.GetFirstSlot(420, INV_TYPE);

  if(lacSlot = -1) then
  begin
    npc.SendChat('Traga-me um Resto de Lactolerium.');
    exit;
  end;

			bool hasSoulOn := false;

			for(INT8 i := 0; i < 16; i++)
			begin
				if(mBuffer[clientId].Affects[i].Index = 29)
				begin
					hasSoulOn := true;
					mBuffer[clientId].Affects[i].Master := 11;
					mBuffer[clientId].Affects[i].Time := 10800;
					mBuffer[clientId].Affects[i].Value := 4;
					break;
				end;
				if(!hasSoulOn)
				begin
					if(!mBuffer[clientId].Affects[i].Index)
					begin
						mBuffer[clientId].Affects[i].Index := 29;
						mBuffer[clientId].Affects[i].Master := 11;
						mBuffer[clientId].Affects[i].Time := 10800;
						mBuffer[clientId].Affects[i].Value := 4;
						break;
					end;
				end;
			end;

			DoTeleport(clientId, 2463, 1841);

			GetCurrentScore(clientId);

			AmountMinus(&player->Inventory[RestLac]);

			SendItem(clientId, INVENTORY, RestLac, &player->Inventory[RestLac]);

			exit;
		end;

		const WORD szStones [4] := begin5334, 5336, 5335, 5337end;;

		if(player.Character.Base.Equip[15].Index <> 3194 && player.Character.Base.Equip[15].Index <> 3195 && player.Character.Base.Equip[15].Index <> 3196)
		begin
			if(player.Character.Base.bStatus.Level >= 369 && player.Character.Base.Equip[0].EFV2 = MORTAL)
			begin
				if(player->ClassInfo < 0 || player->ClassInfo > 3)
				begin
					player.SendClientMessage('H� um erro na sua conta. Favor contatar a administra��o');

					exit;
				end;

				INT16 slotId := GetFirstSlot(clientId, szStones[player->ClassInfo], INVENTORY);

				if(slotId = -1)
				begin
					char szMsg[256];

					sprintf(szMsg, " Traga-me a %s para adiquirir a soul.", ItemList[szStones[player->ClassInfo]].Name);

					player.SendClientMessage(szMsg);

					exit;
				end;

				memset(&player.Character.Base.Equip[15], 0, sizeof st_Item);
				memset(&player->Inventory[slotId], 0, sizeof st_Item);

				INT16 kingDom := 0;

				if(player->CapeInfo = 7)
					kingDom := 3194;
				if(player->CapeInfo = 8)
					kingDom := 3195;
				else
					kingDom := 3196;

				player.Character.Base.Equip[15].Index := kingDom;

				SendItem(clientId, EQUIP, 15, &player.Character.Base.Equip[15]);

				player->Learn |=  (1 << 30);

				SendCharList(clientId);

				player.SendClientMessage('Que os Deuses de Kersef ilumine seu caminho.');

				SendClientSignalParm(clientId, clientId, 0x3B4, wdBuffer[clientId].Ingame.LoggedMob);
			end;
		end;
	end;
  }
	npc.SendChat('Desculpe.');
end;

class function TNPCHandlers.MestreHab(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean;
var safires: TItemAmount;
  i: Integer;
  classInfo: BYTE;
  offset: BYTE;
  stat, initialStat: PWORD;
begin
	safires := player.GetItemAmount(4131, player.Character.Inventory);
	if(safires.Amount < 3) then
	begin
		npc.SendChat('Traga-me 3 safira(s).');
		exit;
	end;
  {
	for(INT8 i := 1; i < 8; i++)
	begin
		if(player.Character.Base.Equip[i].Index <> 0)
		begin
			npc.SendChat('Desequipe seus equipamentos.');
			exit;
		end;
	end;
  }
  classInfo := player.Character.ClassInfo;
	if(classInfo > 3) OR (classInfo < 0) then
	begin
		player.SendClientMessage('Ocorreu um erro com sua conta, contate � Administra��o!');
		exit;
	end;

	for i := 0 to 3 do
	begin
    ZeroMemory(@player.Character.Inventory[safires.Slots[i]], SizeOf(TItem));
		//SendItem(clientId, INVENTORY, Safiras.Slots[i], &player->Inventory[Safiras.Slots[i]]);
	end;

  for offset := 0 to 8 do
  begin
    stat := @player.Character.BaseScore.STR;
    Inc(stat, offset);
    initialStat := @InitialCharacters[classInfo].BaseScore.STR;
    Inc(initialStat, offset);
    if (stat^ - 100) < initialStat^ then
		  stat := initialStat
    else
      Dec(stat, 100);
  end;
  {
	BASE_GetBonusSkillPoint(player);
	BASE_GetBonusScorePoint(player);
	BASE_GetHpMp(player);
  }
	player.SendEtc;
	player.SendScore;
	//player.SendStats(clientId);

	npc.SendChat('Resetado com sucesso.');
	player.SendCreateMob;
end;

class function TNPCHandlers.GodGovernament(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean;
begin
	if(player.Character.ClassLevel >= TClassLevel.Hardcore) then
	begin
		if(TItemFunctions.GetSanc(player.Character.Equip[1]) < 9) then
    begin
			if(player.PlayerCharacter.Fame >= 100) then
			begin
        TItemFunctions.IncreaseSanc(player.Character.Equip[1], 1);
				//SendItem(clientId, EQUIP, 1, &player->Equip[1]);
				Dec(player.PlayerCharacter.Fame, 100);
				player.SendClientMessage('Quest concluida.');
			end
			else player.SendClientMessage('Traga-me 100 de fame para a refina��o.');
			exit;
    end;
  end;

	if(player.PlayerCharacter.TotalKill < 100) then
	begin
		npc.SendChat('Troco 100 de Frags por 10 Fames Player/Guild.');
		exit;
	end;

  Dec(player.PlayerCharacter.Fame, 10);
	//Guilds[player.Character.Base.GuildIndex].FAME += 10;
  Dec(player.PlayerCharacter.TotalKill, 100);

	player.SendEtc;
	player.SendScore;
	//player.SendStats;

	player.SendCreateMob;

	npc.SendChat('Troca realizada com sucesso.');
end;

class function TNPCHandlers.EntradasQuest(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean;
var questId: Byte;
  questItemSlot: Int8;
  quest: TQuest;
begin
  if(player.Character.ClassLevel <> TClassLevel.Mortal) then
  begin
    npc.SendChat('Quest exclusiva aos Mortais.');
    exit;
  end;

  questId := npc.Character.BaseScore.Level - 3;
  if Quests.Count < questId then exit;

  quest := Quests[questId-1];
  if (quest.LevelMin > (player.Character.CurrentScore.Level+1)) or
     (quest.LevelMax < (player.Character.CurrentScore.Level+1)) then
  begin
    npc.SendChat('Level inv�lido para realizar a quest.');
    exit;
  end;


  if quest.ItemId <> -1 then
  begin
    questItemSlot := player.GetFirstSlot(quest.ItemId, INV_TYPE);
    if(questItemSlot = -1) then
    begin
      npc.SendChat('Onde est� o item ' + ItemList[quest.ItemId].Name + '?');
      exit;
    end;
  end;

  if(quest.Players.Count = quest.Players.Capacity) then
  begin
    npc.SendChat('J� tem gente de mais l�. � melhor voc� esperar.');
    exit;
  end;

  TItemFunctions.DeleteItemSlot(player, questItemSlot);
  //TItemFunctions.DecreaseAmount(player.Character.Inventory[questItemSlot]);
  player.RefreshInventory;

  quest.Players.Add(player.ClientId);
  player.Teleport(quest.QuestPosition);
  player.PlayerCharacter.CurrentQuest := quest.Index;
  player.PlayerCharacter.QuestEntraceTime := Now;

  npc.SendChat('Quest iniciada');
end;

class function TNPCHandlers.KingdomBroker(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean;
var fame: WORD;
begin
  if(player.Character.CapeInfo <> 7) OR (player.Character.CapeInfo <> 8) then
	begin
		npc.SendChat('Voc� n�o pertence a nenhum Reino.');
		exit;
	end;

	if(player.Character.ClassLevel = TClassLevel.Mortal) then
		fame := 100
	else if(player.Character.ClassLevel = TClassLevel.Arch) then
		fame := 200
	else if(player.Character.ClassLevel >= TClassLevel.Celestial) then
		fame := 500;

	if(Fame > player.PlayerCharacter.Fame) then
	begin
		npc.SendChat('Voc� precisa de ' + IntToStr(fame) + ' pontos de Fame.');
		exit;
	end;
  {
	INT16 Cape := 0;
	if(player.Character.Base.Equip[15].Index = KingDomCape[0][0] || player.Character.Base.Equip[15].Index = KingDomCape[1][0])
		Cape := CapeBroker[0];
	else if(player.Character.Base.Equip[15].Index = KingDomCape[0][1] || player.Character.Base.Equip[15].Index = KingDomCape[1][1])
		Cape := CapeBroker[1];
	else if(player.Character.Base.Equip[15].Index = KingDomCape[0][2] || player.Character.Base.Equip[15].Index = KingDomCape[1][2])
		Cape := CapeBroker[2];
	else if(player.Character.Base.Equip[15].Index = KingDomCape[0][3] || player.Character.Base.Equip[15].Index = KingDomCape[1][3])
		Cape := CapeBroker[3];
	else if(player.Character.Base.Equip[15].Index = KingDomCape[0][4] || player.Character.Base.Equip[15].Index = KingDomCape[1][4])
		Cape := CapeBroker[4];

	player.Character.Base.Equip[15].Index := Cape;
  }
  Dec(player.PlayerCharacter.Fame, fame);
	player.SendCharListFromLogin;
	player.SendClientMessage('Que a luz de Sephira esteja com voc�.');
end;
 
class function TNPCHandlers.Oraculo(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean;
var uni, fenix: Integer;
  safires: TItemAmount;
  i: BYTE;
  imor: TItem;
  slot: BYTE;
begin
	uni := player.GetFirstSlot(1740, INV_TYPE);
  if(uni = -1) then
  begin
    npc.SendChat('Traga a alma de unic�rnio');
    exit;
  end;

	fenix := player.GetFirstSlot(1741, INV_TYPE);
  if(fenix = -1) then
  begin
    npc.SendChat('Traga a alma de f�nix');
    exit;
  end;

	safires := player.GetItemAmount(697, player.Character.Inventory);
  if(safires.Amount < 30) then
  begin
    npc.SendChat('Voc� tamb�m precisa trazer 30 safiras');
    exit;
  end;

  if ((uni + 1) mod 9 <> 0) AND ((uni + 1) = fenix) then
  begin
    for i := 0 to safires.SlotsCount do
    begin
      ZeroMemory(@player.Character.Inventory[i], SizeOf(TItem));
      //SendItem(p->Header.ClientId, INVENTORY, Safiras.Slots[i], &player->Inventory[Safiras.Slots[i]]);
    end;

    // Almas s�o agrupaveis?
    ZeroMemory(@player.Character.Inventory[uni], SizeOf(TItem));
    ZeroMemory(@player.Character.Inventory[fenix], SizeOf(TItem));
    //SendItem(p->Header.ClientId, INVENTORY, Fenix, &player->Inventory[Fenix]);
    //SendItem(p->Header.ClientId, INVENTORY, Uni, &player->Inventory[Uni]);

    ZeroMemory(@imor, SizeOf(TItem));
    imor.Index := 1742;
    slot := TItemFunctions.PutItem(player, imor);
    //SendItem(p->Header.ClientId, INVENTORY, Uni, &player->Inventory[slot]);

    player.RefreshInventory;
    npc.SendChat('Imortalidade composta com sucesso, boa sorte !');
    exit;
  end
  else npc.SendChat('Voc� precisa alinhar as Almas.');
end;

class function TNPCHandlers.Cosmos(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean;
begin
  if (player.Character.ClassLevel <> TClassLevel.Mortal) then
  begin
    npc.SendChat('Quest exclusiva aos Mortais.');
    exit;
  end;

  if(player.Character.BaseScore.Level < 200)
    OR (player.Character.BaseScore.Level > 249) then
  begin
    npc.SendChat('N�vel permitido: 201 ao 250.');
    exit;
  end;

  player.Teleport(798, 4062);
  npc.SendChat('Quest iniciada para ' + player.Character.Name);
end;

class function TNPCHandlers.Kingdom(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean;
begin

end;

class function TNPCHandlers.Arch(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean;
var freeSlot: Integer;
  i: Integer;
  archClass, face: BYTE;
  archMob: TCharacterDB;
begin
	if (player.Character.CurrentScore.Level < 299) then
	begin
		npc.SendChat('Somente do n�vel 300 acima.');
		exit;
	end
	else if (player.Character.ClassLevel <> TClassLevel.Mortal) then
	begin
		npc.SendChat('Somente mortais.');
		exit;
	end
	else if (player.Character.Equip[10].Index <> 1742) then
	begin
		npc.SendChat('Onde est� a Imortalidade ?');
		exit;
	end
	else if (player.Character.Equip[11].Index < 1760)
    OR (player.Character.Equip[11].Index > 1763) then
	begin
		npc.SendChat('Traga-me um sephirot para a composi��o.');
		exit;
	end;

	freeSlot := -1;
  for i := 0 to 3 do
  begin
    if(player.Account.Characters[i].Base.Equip[0].Index <> 0) then
    begin
      freeSlot := i;
      break;
    end;
  end;

	if(freeSlot = -1) then
	begin
		npc.SendChat('Voc� n�o tem espa�o suficiente para um novo personagem.');
		exit;
	end;

	archClass := player.Character.Equip[11].Index - 1760;
  ZeroMemory(@player.Character.Equip[10], SizeOf(TItem) * 2); // Tira o item, em 10 e 11

  ZeroMemory(@archMob, SizeOf(TCharacterDB));
  Move(archMob, player.PlayerCharacter, SizeOf(TCharacterDB));
	archMob.Base.ClassInfo := archClass;
  archMob.Base.Name := player.Character.Name;

  face := IFThen(player.Character.ClassInfo = 2,
    (21 + 5) + archClass,
    player.Character.Equip[0].Index + 5 + archClass);

	archMob.Base.Equip[0].Index := face;
	archMob.Base.Equip[0].Effects[1].Value := BYTE(TClassLevel.Arch);
	archMob.Base.Equip[0].Effects[2].Value := face;

	archMob.Base.BaseScore.MoveSpeed := 3;
	archMob.Base.CurrentScore.MoveSpeed := 3;

	player.SendCharListFromLogin;
  player.SendSignal(packet.Header.Index, $34B, freeSlot);
end;

class function TNPCHandlers.Khadin(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean;
var face: WORD;
begin
	if(player.Character.ClassLevel < TClassLevel.Celestial) then
    //OR (player.Character.Base.Equip[0].Effects[1].Value > SUBCELESTIAL) then
	begin
		npc.SendChat('Somente celestiais ou acima.');
		exit;
	end;

	if(player.Character.Equip[11].Index < 1760)
    OR (player.Character.Equip[11].Index > 1763) then
	begin
		npc.SendChat('Traga-me o Sephirote da classe desejada.');
		exit;
	end;

	if(player.PlayerCharacter.Fame < 200) then
	begin
		npc.SendChat('Necess�rio possuir 200 de Fame para prosseguir.');
		exit;
	end;

	player.Character.ClassInfo := player.Character.Equip[11].Index - 1760;
	face := 0;
  {
	// Puxa a face que deveria ser pela face do mortal
	// Caso seja bm transformado faz 21 (face de bm mortal) + 5 (para ir para as faces de arch) + classInfo (j� alterada para a nova)
	// Caso n�o, pega diretamente pela face do mortal soma 5 e a clasInfo
	if((Users[clientId].CharList.Equip[wdBuffer[clientId].Chars[wdBuffer[clientId].Ingame.LoggedMob].RespectiveMortal][0].Index >= 22 &&
		Users[clientId].CharList.Equip[wdBuffer[clientId].Chars[wdBuffer[clientId].Ingame.LoggedMob].RespectiveMortal][0].Index <= 25) ||
		Users[clientId].CharList.Equip[wdBuffer[clientId].Chars[wdBuffer[clientId].Ingame.LoggedMob].RespectiveMortal][0].Index = 32)
		face := 21 + 5 + player->ClassInfo;
	else
		face := Users[clientId].CharList.Equip[wdBuffer[clientId].Chars[wdBuffer[clientId].Ingame.LoggedMob].RespectiveMortal][0].Index + 5 + player->ClassInfo;

	player.Character.Base.Equip[0].Index := face;
	player.Character.Base.Equip[0].EFV3  := face;

	wdBuffer[clientId].Chars[wdBuffer[clientId].Ingame.LoggedMob].Fame -= 200;

	memset(&player.Character.Base.Equip[11], 0, sizeof(st_Item));

  }
	player.SendClientMessage('Sua classe foi alterada.');
	player.SendCharListFromLogin;
	exit;
end;

class function TNPCHandlers.NpcDeTroca(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean;
begin

end;

class function TNPCHandlers.QuestCapaVerde(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean;
var errorStr : string;
begin
	if(player.Character.Equip[15].Index <> 0) then
	begin
		errorStr := 'Voc� j� completou a quest.';
	end
	else if (player.Character.ClassLevel <> TClassLevel.Mortal) then
  begin
		errorStr := 'Quest exclusiva aos Mortais.';
  end
  else if(player.Character.BaseScore.Level < 100)
    OR (player.Character.BaseScore.Level >= 150) then
	begin
		errorStr := 'Level inadequado [101~151].';
	end;

  if(errorStr <> '') then
  begin
    npc.SendChat(errorStr);
    exit;
  end;


	if(npc.Character.Merchant = 43) AND (npc.Character.BaseScore.Level = 4) then
	begin
    player.Teleport(2243, 1580);
		npc.SendChat('Quest iniciada para ' + player.Character.Name);
	end
	else if(npc.Character.Merchant = 43) AND (npc.Character.BaseScore.Level = 3) then
	begin
		if(player.Character.Equip[13].Index <> 4080) then
		begin
			npc.SendChat('Traga-me o Emblema da Aprendizagem equipado.');
			exit;
		end;

		player.Character.Equip[15].Index := 4006;
    ZeroMemory(@player.Character.Equip[13], SizeOf(TItem));

    player.SendEquipItems();
		//SendItem(p->Header.ClientId, EQUIP, 13, &player.Character.Base.Equip[13]);
		//SendItem(p->Header.ClientId, EQUIP, 15, &player.Character.Base.Equip[15]);

		npc.SendChat('Parab�ns, adquiriu o Manto do Aprendiz.');
	end;
end;

class function TNPCHandlers.Unis(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean;
var neededItem, neededSlot: Integer;
  prize: TItem;
  i: Integer;
begin
  if(player.Character.CurrentScore.Level < 4) OR (player.Character.CurrentScore.Level > 254)
    OR (player.Character.ClassLevel <> TClassLevel.Mortal) then
  begin
    npc.SendChat('Somente mortais entre os n�veis 5 e 255.');
    exit;
  end;

  neededItem := npc.Character.Inventory[0].Index;
  if(neededItem <> 0) then
  begin
    neededSlot := player.GetFirstSlot(neededItem, INV_TYPE);
    if(neededSlot <> -1) then
    begin
      if(TItemFunctions.GetSanc(player.Character.Inventory[neededSlot]) <> 3) then
      begin
        npc.SendChat('� necess�rio que a refina��o do item seja +3');
        exit;
      end;
      ZeroMemory(@player.Character.Inventory[neededSlot], SizeOf(TItem));
    end
    else
    begin
      npc.SendChat('Traga-me ' + ItemList[neededItem].Name + ' para realizar a troca.');
      exit;
    end;
  end;

  // Loop pra procurar todos os items em sequencia no invent�rio
  // Permite darmos premios variados
  for i := 1 to MAX_INV do
  begin
    if(i = 0) then break;
  end;

  prize := npc.Character.Inventory[RandomRange(1, i - 1)];
  neededSlot := TItemFunctions.PutItem(player, prize);
  //player.SendItem(INV_TYPE, neededSlot);
  player.RefreshInventory; // Trocar pelo sendItem
  npc.SendChat('Acho que esse pr�mio ir� agrada-lo');
end;

class function TNPCHandlers.CarbWind(var player: TPlayer; var npc: TNpc; var packet: TNpcPacket): Boolean;
var
  npcBuffId: Integer;
  npcAffect: TAffect;
begin
	if (player.Character.ClassLevel <> TClassLevel.Mortal)
    OR (player.Character.BaseScore.Level >= 35) then
	begin
		npc.SendChat('Voc� precisa ser mortal e ter um n�vel inferior a 35.');
		exit;
	end;

  for npcBuffId := 0 to MAXBUFFS do
  begin
    npcAffect := npc.Character.Affects[npcBuffId];
    if(npcAffect.Index <> 0) then
      player.AddAffect(npcAffect);
  end;

	player.SendScore;
  npc.SendChat('Sente-se mais forte agora?');
end;

end.
