unit Volatiles;

interface

uses Windows, Packets, Player, MiscData, ItemFunctions, Functions, PlayerData, SysUtils, BaseMob;

type TVolatiles = class(TObject)
  public
    class function UseItem(var player: TPlayer; var buffer: array of Byte): Boolean; static;

  private
    class function ReturnScroll(var player : TPlayer) : Boolean; static;
    class function SeloDoGuerreiro(var player : TPlayer) : Boolean; static;
    class function Potion(var player : TPlayer; potionId : WORD): Boolean; static;
    class function Poeiras(var player: TPlayer; var srcItem, dstItem : TItem; slot: BYTE): Boolean; static;
    class function FogosDeArtificios(var player: TPlayer): Boolean; static;
    class function Frango(var player: TPlayer): Boolean; static;
    class function Bau(var player: TPlayer): Boolean; static;
    class function Feijao(var player: TPlayer; var srcItem, dstItem : TItem; slot: BYTE): Boolean; static;
    class function BarrasDePrata(var player: TPlayer; var srcItem : TItem): Boolean;
    class function Gemas(var player: TPlayer; var srcItem, dstItem : TItem; slot: BYTE): Boolean;
    class function BoxExp(var player: TPlayer; var srcItem : TItem): Boolean;
    class function Replations(var player: TPlayer; var srcItem, dstItem: TItem; slot: BYTE): Boolean;
    class function VolatileGemaEstelar(var player: TPlayer): Boolean; static;
    class function PergaminhoDoTeleporte(var player: TPlayer): Boolean;
    class function PedrasLendarias(var player: TPlayer; var srcItem, dstItem: TItem; slot: BYTE): Boolean;
    class function MolarDoGargula(var player: TPlayer): Boolean;
    class function PilulaMagica(var player: TPlayer): Boolean;
    class function CristaisArch(var player: TPlayer; var srcItem: TItem): Boolean;
    class function Racoes(var player: TPlayer; var srcItem, dstItem: TItem): Boolean;
    class function PoeiraDeFada(var player: TPlayer): Boolean;
    class function OlhoCrescente(var player: TPlayer): Boolean;
    class function LivroSephira(var player: TPlayer; volatile : BYTE; itemId : WORD): Boolean;
    class function Amagos(var player: TPlayer; var srcItem, dstItem: TItem): Boolean;
end;

implementation

Uses GlobalDefs, ConstDefs, Position;

class function TVolatiles.UseItem(var player: TPlayer; var buffer: array of Byte): Boolean;
var packet : TUseItemPacket absolute buffer;
    srcItem, dstItem : PItem;
    ammount : Byte;
    volatile : word;
    used : Boolean;
begin
  Result := true;

  {player.SendClientMessage(inttostr(packet.Position.X)+ ' ' +inttostr(packet.Position.Y));
  player.SendClientMessage(inttostr(player.Character.Base.Last.X)+ ' ' +inttostr(player.Character.Base.Last.Y));
  if((packet.Position.X <> player.Character.Base.Last.X) or
    (packet.Position.Y <> player.Character.Base.Last.Y)) and
    ((packet.Position.X <> 0) and (packet.Position.Y <> 0)) then
    exit;}

  //player.SendClientMessage(inttostr(packet.SrcSlot)+ ' ' +inttostr(packet.SrcType));
  if not(TItemFunctions.GetItem(srcItem, player, packet.SrcSlot, packet.SrcType)) then
    exit;

  TItemFunctions.GetItem(dstItem, player, packet.DstSlot, packet.DstType);

  ammount := TItemFunctions.GetItemAmount(srcItem^);
  if(ammount < 1) then
    exit;

  volatile := TItemFunctions.GetEffectValue(srcItem^.Index, EF_VOLATILE);
  used := False;
  player.SendClientMessage(inttostr(volatile));
  case volatile of
    0: //selo do guerreiro
      used := SeloDoGuerreiro(player);
    1: //Poçao HP
      used := Potion(player, srcItem^.Index);
    5: //poeiras
    begin
      if packet.DstType = EQUIP_TYPE then
        used := Poeiras(player, srcItem^, dstItem^, packet.DstSlot);
    end;
    6: //pilula do poder magico
      used := PilulaMagica(player);
    7://poeira de fada
      used := PoeiraDeFada(player);
    8://olho crescente
      used := OlhoCrescente(player);
    9: //pedras lendarias
    begin
      if packet.DstType = EQUIP_TYPE then
        used := PedrasLendarias(player, srcItem^, dstItem^, packet.DstSlot);
    end;
    11: //Pergaminho de Retorno
      used := ReturnScroll(player);
    12: //gema estelar
      used := VolatileGemaEstelar(player);
    13: //scroll teleporte gema estelar
      used := PergaminhoDoTeleporte(player);
    15:
      used := Racoes(player,srcItem^, dstItem^);
    16:
      if (packet.DstType = EQUIP_TYPE) and (packet.DstSlot = 14) then
        used := Amagos(player, srcItem^, dstItem^);
    19: //fogos de artificio
      used := FogosDeArtificios(player);
    31..38:
      used := LivroSephira(player, volatile, srcItem^.Index);
    63: //frango
      used := Frango(player);
    180..183: //gemas
    begin
      if packet.DstType = EQUIP_TYPE then
        used := Gemas(player, srcItem^, dstItem^, packet.DstSlot);
    end;
    185: //barras de gold
      used := BarrasDePrata(player, srcItem^);
    186: //feijoes
    begin
      if packet.DstType = EQUIP_TYPE then
        used := Feijao(player, srcItem^, dstItem^, packet.DstSlot);
    end;
    187: //cristais quest arch
      used := CristaisArch(player, srcItem^);
    190: //replations
    begin
      if packet.DstType = INV_TYPE then
        used := Replations(player, srcItem^, dstItem^, packet.DstSlot);
    end;
    191: //bau xp quests
      used := BoxExp(player, srcItem^);
    194: //molar do gargula
      used := MolarDoGargula(player);
    198: //bau de xp
      used := Bau(player);
    else
    begin
      player.SendClientMessage('Item ainda não implementado.');
      used := false;
    end;
  end;

  if not(used) then
  begin
    player.SendCreateItem(packet.SrcType, packet.SrcSlot, srcItem^);
    exit;
  end;

  if(ammount > 1)then
    TItemFunctions.SetItemAmount(srcItem^, ammount - 1)
  else
    ZeroMemory(srcItem, sizeof(TItem));

  player.SendCreateItem(packet.SrcType, packet.SrcSlot, srcItem^);
end;


class function TVolatiles.ReturnScroll(var player: TPlayer): Boolean;
var position : TPosition;
begin
  result:= true;
  position := TFunctions.GetStartXY(player.PlayerCharacter.CurrentCity);

  player.Teleport(position);
  player.SendEmotion(14, 3);
end;

class function TVolatiles.Potion(var player : TPlayer; potionId : WORD): Boolean;
var qtdCura : WORD;
    potionType : BYTE;//0-hp 1-mp
const
  quant: array[0..4] of Word = (50,200,300,400,500);
begin
  {
  item = quant
  400 = 50 hp
  401 = 200
  402 = 300
  403 = 400
  404 = 500
  405 = 50 mp
  406 = 200
  407 = 300
  408 = 400
  409 = 500
  3322 = 500hp
  3323 = 500mp
  }
  if (potionId < 400) or ((potionId > 409) and (potionId <> 3322) and (potionId <> 3323))then
  begin
    result := false;
    exit;
  end;

  result:= true;
  case potionId of
    400..404: // HP
    begin
      potionType := 0;
      qtdCura    := quant[potionId-400];
    end;
    405..409:  // MP
    begin
      potionType := 1;
      qtdCura    := quant[potionId-405];
    end;
    3322:
    begin
      potionType := 0;
      qtdCura    := 500;
    end;
    3323:
    begin
      potionType := 1;
      qtdCura    := 500;
    end;
  end;

  if potionType = 0 then
  begin
    if (player.Character.CurrentScore.CurHP < player.Character.CurrentScore.MaxHP)then
      inc(player.Character.CurrentScore.CurHP,qtdCura)
    else
      result := false;
    if (player.Character.CurrentScore.CurHP > player.Character.CurrentScore.MaxHP)then
      player.Character.CurrentScore.CurHP := player.Character.CurrentScore.MaxHP;
  end
  else
  begin
    if (player.Character.CurrentScore.CurMP < player.Character.CurrentScore.MaxMP)then
      inc(player.Character.CurrentScore.CurMP,qtdCura)
    else
      result := false;
    if (player.Character.CurrentScore.CurMP > player.Character.CurrentScore.MaxMP)then
      player.Character.CurrentScore.CurMP := player.Character.CurrentScore.MaxMP;
  end;
  player.SendCurrentHPMP;
end;

class function TVolatiles.Poeiras(var player: TPlayer; var srcItem, dstItem : TItem; slot: BYTE): Boolean;
var position : TPosition;
chance, sanc: BYTE;
num: Integer;
begin
  //player.SendClientMessage(inttostr(srcItem.Index));
  case srcItem.Index of
    412://ori
    begin
      sanc := TItemFunctions.GetSanc(dstItem);
      if (sanc >= 6) or (sanc = 255) then
      begin
        player.SendClientMessage('Impossível refinar.');
        result := false;
        exit;
      end;

      if (sanc < 2)then
        chance := 100
      else
        chance := 100-((sanc-1)*10);

      inc(chance, TItemFunctions.GetSancBonus(dstItem));

      Randomize();
	    num := random(100);
      inc(num);
	    if chance >= num then
      begin
        player.SendClientMessage('Obtece sucesso ao refinar.');
        TItemFunctions.SetSanc(dstItem, sanc+1);
        player.SendCreateItem(EQUIP_TYPE, slot, dstItem);
        result := true;
        exit;
      end
      else
      begin
        player.SendClientMessage('Falhou ao refinar.');
        TItemFunctions.IncreaseSanc(dstItem, 10);
        player.SendCreateItem(EQUIP_TYPE, slot, dstItem);
        result := true;
        exit;
      end;
    end;

    413://lac
    begin
      sanc := TItemFunctions.GetSanc(dstItem);
      //player.SendClientMessage(inttostr(sanc));
      if (sanc >= 9) or (sanc = 255) then
      begin
        //if () then

        player.SendClientMessage('Impossível refinar.');
        result := false;
        exit;
      end;

      if (sanc < 4)then
        chance := 100
      else
        chance := 100-((sanc-4)*10);
      //player.SendClientMessage('chance: '+ inttostr(chance));
      inc(chance, TItemFunctions.GetSancBonus(dstItem));

      Randomize();
	    num := random(100);
      inc(num);
	    if chance >= num then
      begin
        player.SendClientMessage('Obtece sucesso ao refinar.');
        TItemFunctions.SetSanc(dstItem, sanc+1);
        player.SendCreateItem(EQUIP_TYPE, slot, dstItem);
        result := true;
        exit;
      end
      else
      begin
        player.SendClientMessage('Falhou ao refinar.');
        TItemFunctions.IncreaseSanc(dstItem, 10);
        player.SendCreateItem(EQUIP_TYPE, slot, dstItem);
        result := true;
        exit;
      end;
    end;
  end;

end;

class function TVolatiles.FogosDeArtificios(var player: TPlayer): Boolean;
begin
  Randomize();
  player.SendEmotion(100, random(6));
  result := True;
end;

class function TVolatiles.Frango(var player: TPlayer): Boolean;
var Affects : TAffect;
begin
  if player.Character.Affects[player.FindAffect(30)].Time + 900 > 1800 then
  begin
    player.SendClientMessage('Tempo limite do buff é de 4 horas.');
    result := false;
    exit;
  end;

  Affects.Index  := 30;
  Affects.Master := 1;
  Affects.Value  := 0;
  Affects.Time   := 900;

  result := player.AddAffect(Affects, true);
end;

class function TVolatiles.Bau(var player: TPlayer): Boolean;
var Affects : TAffect;
begin
  if player.Character.Affects[player.FindAffect(39)].Time + 450 > 1800 then
  begin
    player.SendClientMessage('Tempo limite do buff é de 4 horas.');
    result := false;
    exit;
  end;

  Affects.Index  := 39;
  Affects.Master := 1;
  Affects.Value  := 0;
  Affects.Time   := 450;

  result := player.AddAffect(Affects, true);
end;

class function TVolatiles.VolatileGemaEstelar(var player: TPlayer): Boolean;
var
  Pos: TGemaEstelar;
begin
  for Pos in GemaEstelar do
  begin
    if (player.CurrentPosition.X >= Pos.Local[0].X) and (player.CurrentPosition.Y >= Pos.Local[0].Y) and
       (player.CurrentPosition.X <= Pos.Local[1].X) and (player.CurrentPosition.Y <= Pos.Local[1].Y)then
    begin
      player.SendClientMessage('Não pode usar aqui.');
      result := false;
      exit;
    end;
  end;
  player.SendClientMessage('Localização armazenada.');
  player.PlayerCharacter.GemaEstelar := player.CurrentPosition;
  result := true;
end;

class function TVolatiles.PergaminhoDoTeleporte(var player: TPlayer): Boolean;
begin
  player.Teleport(player.PlayerCharacter.GemaEstelar);
  result := true;
end;

class function TVolatiles.Feijao(var player: TPlayer; var srcItem, dstItem : TItem; slot: BYTE): Boolean;
var Tintura, i: BYTE;
find: boolean;
item : TItemList;
begin
		case srcItem.Index of
      3407: Tintura := 116;

			3408: Tintura := 117;

			3409: Tintura := 118;

			3410: Tintura := 119;

			3411: Tintura := 120;

			3412: Tintura := 121;

			3413: Tintura := 122;

			3414: Tintura := 123;

			3415: Tintura := 124;

			3416: Tintura := 125;

			3417: Tintura := 43;

      else begin result := false; exit; end;
    end;

    item := ItemList[dstItem.Index];
    if (item.Pos = 2) or (item.Pos = 4) or (item.Pos = 8) or
       (item.Pos = 16) or (item.Pos = 32) or (item.Pos = 64) or
       (item.Pos = 192) then
    begin
      find := false;
      for i := 0 to 2 do
      begin
        if(dstItem.Effects[i].Index = 43) or ((dstItem.Effects[i].Index >= 116) and (dstItem.Effects[i].Index <= 125))then
        begin
          find := true;
          break;
        end;
      end;

      if not find then
      begin
        for i := 0 to 2 do
        begin
          if(dstItem.Effects[i].Index = 0)then
          begin
            find := true;
            break;
          end;
        end;
      end;

      if not find then
      begin
        player.SendClientMessage('Item inválido.');
        result := false;
        exit;
      end;

      if (Tintura <> 43)then
      begin
        if(dstItem.Effects[i].Index <> Tintura) then
        begin
          dstItem.Effects[i].Index := Tintura;

          player.SendEmotion(14, 3);

          player.SendCreateItem(EQUIP_TYPE, slot, dstItem);
          player.SendCreateMob();
          player.SendClientMessage('Item Pintado com sucesso.');
          result := true;
        end
        else
        begin
          player.SendClientMessage('Item já está pintado nessa cor.');
          result := false;
        end;
      end
      else
      begin
        if(dstItem.Effects[i].Index >= 116) and (dstItem.Effects[i].Index <= 125) then
        begin
          dstItem.Effects[i].Index := 43;

          player.SendEmotion(14, 3);
          player.SendCreateItem(EQUIP_TYPE, slot, dstItem);
          player.SendCreateMob();
          player.SendClientMessage('Tintura removida com sucesso.');
          result := true;
        end
        else
        begin
          player.SendClientMessage('Item não está colorido.');
          result := false;
        end;
      end;
    end
    else
    begin
      player.SendClientMessage('Item inválido.');
      result := false;
    end;
end;

class function TVolatiles.BarrasDePrata(var player: TPlayer; var srcItem : TItem): Boolean;
var addGold: integer;
begin
  // Moedas/Barras de prata
  result := false;
  case srcItem.Index of
    4010: addGold := 100000000;

    4011: addGold := 1000000000;

    4026: addGold := 1000000;

    4027: addGold := 5000000;

    4028: addGold := 10000000;

    4029: addGold := 50000000;
  end;

	if(addGold + player.Character.Gold >= 2000000000)then
	  player.SendClientMessage('Limite de gold ultrapassado.')
  else
	begin
		player.SendClientMessage(inttostr(addGold)+' de gold foi adicionado ao inventário.');
		inc(player.Character.Gold, addGold);

	  player.SendEtc();
    result := true;
  end
end;

class function TVolatiles.Gemas(var player: TPlayer; var srcItem, dstItem : TItem; slot: BYTE): Boolean;
var
  item: TItemList;
  anct, i: BYTE;
  find: boolean;
  sanc : BYTE;
begin
  result := false;
  item := ItemList[dstItem.Index];

  case srcItem.Index of
    3386: anct := 5; //Diamante
    3387: anct := 6; //Esmeralda
    3388: anct := 7; //Coral
    3389: anct := 8; //Garnet
  end;

  if (item.Grade >= 5) and (item.Grade <= 8) then
  begin//itens anct
    if (anct = item.Grade) then
      exit;

    dstItem.Index := dstItem.Index + (anct-item.Grade);
    player.SendEquipItems(true);
    result := true;
  end;

  find := false;
  for i := 0 to 2 do
  begin
    if((dstItem.Effects[i].Index = 43) or ((dstItem.Effects[i].Index >= 116) and (dstItem.Effects[i].Index <= 125))) and
      (dstItem.Effects[i].Value >= 230) then
    begin
      find := true;
      break;
    end;
  end;
  if find then
  begin
    sanc := 230+(anct-5)+(((dstItem.Effects[i].Value-230) div 4)*4);
    if sanc = dstItem.Effects[i].Value then
      exit;
    dstItem.Effects[i].Value := sanc;
    result := true;
  end
  else
  begin
    if (result = false) then
    begin
      player.SendClientMessage('Gema deve ser usada em itens ancientes ou com refinação superior a +10.');
      result := False;
    end;
  end;
  if result = True then
  begin
    player.SendClientMessage('Refinado com sucesso.');
    player.SendCreateItem(EQUIP_TYPE, slot, dstItem);
    player.SendCreateMob();
  end;
end;

class function TVolatiles.BoxExp(var player: TPlayer; var srcItem: TItem): Boolean;
var
  expAdd: Integer;
  party: PParty;
  i: Word;
  member: TBaseMob;
begin
  result := true;
  if not(player.Character.Equip[0].Effects[1].Index <> 98) or not(player.Character.Equip[0].Effects[1].Value < 2)then
  begin
    player.SendClientMessage('Personagem deve ser mortal.');
    player.SendSignal($7530, $3A7);
		exit;
  end;

  case(srcItem.Index)of
    4117: // Caixa da Sabedoria
    begin
      if(player.Character.BaseScore.Level < 39) or (player.Character.BaseScore.Level > 115)then
      begin
        player.SendClientMessage('Level inadequado.');
        exit;
      end;

      expAdd := 7500;
    end;

    4118: // Lagrima Angelical
    begin
      if(player.Character.BaseScore.Level < 116) or (player.Character.BaseScore.Level > 190)then
      begin
        player.SendClientMessage('Level inadequado.');
        exit;
      end;

      expAdd := 15000;
    end;

    4119: // Coração do Kaizen
    begin
      if(player.Character.BaseScore.Level < 191) or (player.Character.BaseScore.Level > 264)then
      begin
        player.SendClientMessage('Level inadequado.');
        exit;
       end;

      expAdd := 75000;
    end;

    4120: // Olho de Sangue
    begin
      if(player.Character.BaseScore.Level < 265) or (player.Character.BaseScore.Level > 319)then
      begin
        player.SendClientMessage('Level inadequado.');
        exit;
      end;

      expAdd := 150000;
    end;

    4121: // Pedra Espiritual dos Elfos
    begin
      if(player.Character.BaseScore.Level < 320) or (player.Character.BaseScore.Level > 349)then
      begin
        player.SendClientMessage('Level inadequado.');
        exit;
      end;

      expAdd := 300000;
    end;
  end;

  player.AddExp(expAdd, 0.1);
  player.SendClientMessage('+++ ' + inttostr(expAdd) + ' EXP +++');

end;

class function TVolatiles.PedrasLendarias(var player: TPlayer; var srcItem, dstItem: TItem; slot: BYTE): Boolean;
var find : Boolean;
begin
  result := false;
  find   := false;
  case srcItem.Index of
    575:
    begin
      if ((dstItem.Index >= 1596) and (dstItem.Index <= 1610)) or
         ((dstItem.Index >= 1161) and (dstItem.Index <= 1175)) or
         ((dstItem.Index >= 1260) and (dstItem.Index <= 1262)) or
         ((dstItem.Index >= 1272) and (dstItem.Index <= 1274)) or
         ((dstItem.Index >= 1284) and (dstItem.Index <= 1286)) or
         ((dstItem.Index >= 1296) and (dstItem.Index <= 1298)) or
         ((dstItem.Index >= 1308) and (dstItem.Index <= 1310)) or
         ((dstItem.Index >= 1446) and (dstItem.Index <= 1460)) then
           find := True;
    end;
    576:
    begin
      if ((dstItem.Index >= 1596) and (dstItem.Index <= 1610)) or
         ((dstItem.Index >= 1161) and (dstItem.Index <= 1175)) or
         ((dstItem.Index >= 1260) and (dstItem.Index <= 1262)) or
         ((dstItem.Index >= 1272) and (dstItem.Index <= 1274)) or
         ((dstItem.Index >= 1284) and (dstItem.Index <= 1286)) or
         ((dstItem.Index >= 1296) and (dstItem.Index <= 1298)) or
         ((dstItem.Index >= 1308) and (dstItem.Index <= 1310)) or
         ((dstItem.Index >= 1446) and (dstItem.Index <= 1460)) or
         ((dstItem.Index >= 1176) and (dstItem.Index <= 1190)) or
         ((dstItem.Index >= 1461) and (dstItem.Index <= 1475)) or
         ((dstItem.Index >= 1611) and (dstItem.Index <= 1625)) or
         ((dstItem.Index >= 1311) and (dstItem.Index <= 1325)) then
           find := True;
    end;
    577:
    begin
      if ((dstItem.Index >= 1191) and (dstItem.Index <= 1205)) or
         ((dstItem.Index >= 1326) and (dstItem.Index <= 1340)) or
         ((dstItem.Index >= 1476) and (dstItem.Index <= 1490)) or
         ((dstItem.Index >= 1626) and (dstItem.Index <= 1640)) then
           find := True;
    end;
    578:
    begin
      if ((dstItem.Index >= 1341) and (dstItem.Index <= 1355)) or
         ((dstItem.Index >= 1209) and (dstItem.Index <= 1220)) or
         ((dstItem.Index >= 1491) and (dstItem.Index <= 1505)) or
         ((dstItem.Index >= 1641) and (dstItem.Index <= 1655)) then
           find := True;
    end;
  end;

  if find then
  begin
    dstItem.Index := ItemList[dstItem.Index].Extreme;
    player.SendCreateItem(EQUIP_TYPE, slot, dstItem);
    player.SendClientMessage('Item refinado com sucesso.');
    result := True;
  end
  else
    player.SendClientMessage('Item inválido.');
end;

class function TVolatiles.Replations(var player: TPlayer; var srcItem, dstItem: TItem; slot: BYTE): Boolean;
var
  successRate: BYTE;
  doRefine: Boolean;
  Effects : array[0..2] of TItemEffect;
  item: TItemList;
  i, sanc: byte;
begin
  // Bloqueia que seja colocado add caso o item esteja maior que +6
  sanc := TItemFunctions.GetSanc(dstItem);
  if(sanc > 6) and (sanc <> 255) then
  begin
    player.SendClientMessage('Impossível refinar item superior a +6');
    result := false;
    exit;
  end
  else if((dstItem.Index >= 1221) and (dstItem.Index <= 1224))
    or ((dstItem.Index >= 1356) and (dstItem.Index <= 1359))
    or ((dstItem.Index >= 1506) and (dstItem.Index <= 1509))
    or ((dstItem.Index >= 1656) and (dstItem.Index <= 1659)) then
  begin
    player.SendClientMessage('Item inadequado.');
    result := false;
    exit;
  end
  else if((dstItem.Index >= 1230) and (dstItem.Index <= 1233))
    or ((dstItem.Index >= 1365) and (dstItem.Index <= 1368))
    or ((dstItem.Index >= 1515) and (dstItem.Index <= 1518))
    or ((dstItem.Index >= 1665) and (dstItem.Index <= 1668)) then
  begin
    player.SendClientMessage('Item inadequado.');
    result := false;
    exit;
  end;


  Randomize();
  successRate := random(100);
  inc(successRate);
  doRefine := FALSE;
  case srcItem.Index of
    4016,4021:
    begin
      if(successRate <= 95)then
        if(GlobalDefs.Replations[0].Contains(dstItem.Index))then
          doRefine := TRUE;
    end;

    4017,4022:
    begin
      if(successRate <= 90)then
        if(GlobalDefs.Replations[1].Contains(dstItem.Index))then
          doRefine := TRUE;
    end;

    4018,4023:
    begin
      if(successRate <= 85)then
        if(GlobalDefs.Replations[2].Contains(dstItem.Index))then
          doRefine := TRUE;
    end;

    4019,4024:
    begin
      if(successRate <= 80)then
        if(GlobalDefs.Replations[3].Contains(dstItem.Index))then
          doRefine := TRUE;
    end;

    4020:
    begin
      if(successRate <= 41)then
        if(GlobalDefs.Replations[4].Contains(dstItem.Index))then
          doRefine := TRUE;
    end;
  end;

  if(doRefine)then
  begin
    item := ItemList[dstItem.Index];
    ZeroMemory(@Effects[0],sizeof(Effects));
    //player.SendClientMessage(inttostr(item.pos));
    // Verifica a posição que o item está equipado para determinar quais effects colocar.
    if(item.Pos = 2)then
    begin // Elmo
      for i := 0 to 2 do
      begin
        Randomize();
        Effects[i].Index:=effs_elmo[random(6)];
      end;
    end
    else if(item.Pos = 4)then
    begin // Armadura
      for i := 0 to 2 do
      begin
        Randomize();
        Effects[i].Index:=effs_armadura[random(6)];
      end;
    end
    else if(item.Pos = 8)then
    begin // Calça
      for i := 0 to 2 do
      begin
        Randomize();
        Effects[i].Index:=effs_calca[random(6)];
      end;
    end
    else if(item.Pos = 16)then
    begin // Manopla
      for i := 0 to 2 do
      begin
        Randomize();
        Effects[i].Index:=effs_manopla[random(6)];
      end;
    end
    else if(item.Pos = 32)then
    begin // Bota
      for i := 0 to 2 do
      begin
        Randomize();
        Effects[i].Index:=effs_bota[random(5)];
      end;
    end;

    if Effects[0].Index = Effects[1].Index then
      Effects[1].Index := EF_NONE;

    if Effects[0].Index = Effects[2].Index then
      Effects[2].Index := EF_NONE;

    if Effects[1].Index = Effects[2].Index then
      Effects[2].Index := EF_NONE;

    if (Effects[0].Index = EF_NONE) then
    begin
      Effects[0].Index := Effects[1].Index;
      Effects[1].Index := Effects[2].Index;
    end;

    if (Effects[0].Index = EF_NONE) then
      Effects[0].Index := Effects[1].Index;

    // Atribuição dos valores dos effects
    for i := 0 to 2 do
    begin
      if(Effects[i].Index <> EF_NONE)then
      begin
        Randomize();
        if(Effects[i].Index = EF_ATTSPEED)then
          Effects[i].Value := add_attspeed[random(7)]
        else if(Effects[i].Index = EF_CRITICAL)then
          Effects[i].Value := add_critical[random(6)]
        else if(Effects[i].Index = EF_ACADD)then
          Effects[i].Value := add_ac[random(5)]
        else if(Effects[i].Index = EF_DAMAGE)then
          Effects[i].Value := add_damage[random(4)]
        else if(Effects[i].Index = EF_MAGIC)then
          Effects[i].Value := add_magic[random(4)]
        else if(Effects[i].Index = EF_HP)then
          Effects[i].Value := add_hp[random(3)]
        else if(Effects[i].Index = EF_SPECIALALL)then
          Effects[i].Value := add_skill[random(8)]
        else if(Effects[i].Index = EF_SANC)then
          Effects[i].Value := add_sanc[random(6)];
      end;
    end;
    for i := 0 to 2 do//move nao funciona
    begin
      dstItem.Effects[i].Index := Effects[i].Index;
      dstItem.Effects[i].Value := Effects[i].Value;
    end;
    player.SendCreateItem(INV_TYPE, slot, dstItem);
    player.SendClientMessage('Item refinado com sucesso.');
  end
  else
    player.SendClientMessage('A tentativa de refinar o item falhou.');

  result := true;
end;

class function TVolatiles.MolarDoGargula(var player: TPlayer): Boolean;
var i: BYTE;
begin
  if (player.PlayerCharacter.CharacterQuests.MolarDoGargula) then
  begin
    player.SendClientMessage('Você já completou essa quest.');
    result := False;
    exit;
  end;

  result := True;
  for i := 1 to 7 do
  begin
    if (TItemFunctions.GetSanc(player.Character.Equip[i]) < 4) then
    begin
      TItemFunctions.SetSanc(player.Character.Equip[i], 4);
      player.SendCreateItem(EQUIP_TYPE, i, player.Character.Equip[i]);
    end;
  end;
  player.PlayerCharacter.CharacterQuests.MolarDoGargula := True;
  player.SendClientMessage('Itens refinados com sucesso.');
end;

class function TVolatiles.PilulaMagica(var player: TPlayer): Boolean;
begin
  if (player.PlayerCharacter.CharacterQuests.PilulaMagica) then
  begin
    player.SendClientMessage('Você já completou essa quest.');
    result := False;
    exit;
  end;

  result := True;
  inc(player.Character.pSkill, 9);
  player.PlayerCharacter.CharacterQuests.PilulaMagica := True;
  player.SendEtc;
  player.SendClientMessage('+9 Pontos de skill adicionados.');
end;

class function TVolatiles.CristaisArch(var player: TPlayer; var srcItem: TItem): Boolean;
begin
  if(player.Character.Equip[0].Effects[1].Index <> 98) or (player.Character.Equip[0].Effects[1].Value < 2) or
    (player.Character.BaseScore.Level < 354)then
  begin
    player.SendClientMessage('Necessário ser arch lvl 355.');
    result := False;
		exit;
  end;

  if (player.PlayerCharacter.CharacterQuests.CristaisArch[3]) then
  begin
    player.SendClientMessage('Você já completou essa quest.');
    result := False;
    exit;
  end;

  case srcItem.Index of
    4106://Elime
    begin
      if (player.PlayerCharacter.CharacterQuests.CristaisArch[0]) then
      begin
        player.SendClientMessage('Você já completou essa quest.');
        result := False;
        exit;
      end;
      inc(player.Character.BaseScore.MaxHP,80);
      player.PlayerCharacter.CharacterQuests.CristaisArch[0] := True;

      player.SendClientMessage('MP máximo aumentado em +80.');
    end;
    4107://Simer
    begin
      if not(player.PlayerCharacter.CharacterQuests.CristaisArch[0]) then
      begin
        player.SendClientMessage('Use o Cristal Elime primeiro.');
        result := False;
        exit;
      end;

      if (player.PlayerCharacter.CharacterQuests.CristaisArch[1]) then
      begin
        player.SendClientMessage('Você já completou essa quest.');
        result := False;
        exit;
      end;
      inc(player.Character.BaseScore.Defense,30);
      player.PlayerCharacter.CharacterQuests.CristaisArch[1] := True;

      player.SendClientMessage('Defesa aumentada em +30.');
    end;
    4108://Thelion
    begin
      if not(player.PlayerCharacter.CharacterQuests.CristaisArch[1]) then
      begin
        player.SendClientMessage('Use o Cristal Simer primeiro.');
        result := False;
        exit;
      end;

      if (player.PlayerCharacter.CharacterQuests.CristaisArch[2]) then
      begin
        player.SendClientMessage('Você já completou essa quest.');
        result := False;
        exit;
      end;
      inc(player.Character.BaseScore.MaxHP,80);
      player.PlayerCharacter.CharacterQuests.CristaisArch[2] := True;

      player.SendClientMessage('HP máximo aumentado em +80.');
    end;
    4109://Noas
    begin
      if not(player.PlayerCharacter.CharacterQuests.CristaisArch[2]) then
      begin
        player.SendClientMessage('Use o Cristal Thelion primeiro.');
        result := False;
        exit;
      end;

      if (player.PlayerCharacter.CharacterQuests.CristaisArch[3]) then
      begin
        player.SendClientMessage('Você já completou essa quest.');
        result := False;
        exit;
      end;
      inc(player.Character.BaseScore.MaxHP,60);
      inc(player.Character.BaseScore.MaxMP,60);
      inc(player.Character.BaseScore.Defense,30);
      player.PlayerCharacter.CharacterQuests.CristaisArch[3] := True;

      player.SendClientMessage('HP/MP/DEF aumentado em +60/60/30.');
    end;
  end;
  result := True;
  dec(player.Character.Exp,100000000);
  player.SendEtc;
  player.SendScore;
end;

class function TVolatiles.SeloDoGuerreiro(var player: TPlayer): Boolean;
begin
  inc(player.PlayerCharacter.Fame, 10);
  player.SendClientMessage('+10 de Fama');
  result := True;
end;

class function TVolatiles.Racoes(var player: TPlayer; var srcItem, dstItem: TItem): Boolean;
var mountindex: BYTE;
begin
  result := false;
	if(dstItem.Index >= 2360) and (dstItem.Index <= 2388) then
	begin
		if(dstItem.Index = 2360)then mountIndex := 0;
		if(dstItem.Index = 2361)then mountIndex := 1;
		if(dstItem.Index = 2362)then mountIndex := 2;
		if(dstItem.Index = 2363)then mountIndex := 3;
		if(dstItem.Index = 2364)then mountIndex := 4;
		if(dstItem.Index = 2365)then mountIndex := 5;
		if(dstItem.Index >= 2366) and (dstItem.Index <= 2370)then mountIndex := 6;
		if(dstItem.Index = 2371)then mountIndex := 9;
		if((dstItem.Index >= 2372) and (dstItem.Index <= 2375)) or (dstItem.Index = 2387)then mountIndex := 6;
		if(dstItem.Index = 2376)then mountIndex := 16;
		if(dstItem.Index = 2378)then mountIndex := 18;
		if(dstItem.Index = 2371) or (dstItem.Index = 2381) or (dstItem.Index = 2382) or (dstItem.Index = 2383) or (dstItem.Index = 2388)then
			mountIndex := 9;
		if(dstItem.Index = 2377)then mountIndex := 17;
		if(dstItem.Index = 2380)then mountIndex := 8;
		if(dstItem.Index >= 2384) and (dstItem.Index <= 2386)then mountIndex := 10;
    if((mountIndex + 2420) = srcItem.Index)then
		begin
			(*EF2 = level
			EFV2 = vitalidade
			EF3 = ração
			EFV1 = HP*)
			if(dstItem.Effects[0].Value >= 100) or (dstItem.Effects[0].Value = 0)then
				exit;
			if(dstItem.Effects[0].Value + 30 > 100)then
				dstItem.Effects[0].Value := 100
      else
        inc(dstItem.Effects[0].Value,30);

			if(dstItem.Effects[2].Index + 1 > 100)then
				dstItem.Effects[2].Index := 100
      else
        inc(dstItem.Effects[2].Index,1);

      result := true;
		end
    else
			player.SendClientMessage('Tipo não confere');
	end
  else
		player.SendClientMessage('Usado apenas em montarias');
end;

class function TVolatiles.PoeiraDeFada(var player: TPlayer): Boolean;
begin
  result := false;
  if (((player.Character.ClassLevel <= TClassLevel.Arch) and (player.Character.BaseScore.Level < 399)) or
     ((player.Character.ClassLevel >= TClassLevel.Celestial) and (player.Character.BaseScore.Level < 199)))then
  begin
    Randomize();
    if(random(2) = 1)then
    begin
      player.SendClientMessage('Falhou em passar de level');
      if(player.Character.Equip[0].Index div 10 = 0)then
        player.SendEmotion(20, 0)
      else
        player.SendEmotion(15, 0);
      exit;
    end;

    if(player.Character.ClassLevel <= TClassLevel.Arch)then
      player.Character.Exp := exp_Mortal_Arch[player.Character.BaseScore.Level + 1]
    else
      player.Character.Exp := exp_list_celestial[player.Character.BaseScore.Level + 1];

    player.SendEmotion(14, 1);
    player.SendEmotion(100, 0);

    inc(player.Character.BaseScore.Level,1);
    Inc(player.Character.pStatus, 5);
    Inc(player.Character.pSkill, 3);
    Inc(player.Character.pMaster, 3);

    player.SendScore;
    player.SendEtc;

    result := True;
  end
  else
    player.SendClientMessage('Level máximo atingido.');
end;

class function TVolatiles.OlhoCrescente(var player: TPlayer): Boolean;
begin
  player.AddExp(3000);
  player.SendClientMessage('*** EXP +3000 ***');
  player.SendEmotion(14, 0);
  result := True;
end;

class function TVolatiles.LivroSephira(var player: TPlayer; volatile : BYTE; itemId : WORD): Boolean;
var calcSkill: BYTE;
    SkillLearn : Cardinal;
begin
  result := False;

  if (player.Character.ClassLevel = TClassLevel.Mortal) and (player.Character.BaseScore.Level < 255) then
  begin
    player.SendClientMessage('Level insuficiente.');
    exit;
  end;

  calcSkill  := Volatile - 7;
  SkillLearn := 1 shl calcSkill;
  if((player.Character.Learn and SkillLearn) <> 0)then
  begin
    player.SendClientMessage('Você já aprendeu esta skill.');
    exit;
  end;

  player.Character.Learn := player.Character.Learn or SkillLearn;
  player.SendClientMessage('Aprendeu a skill sephira ' + ItemList[itemId].Name);
  player.SendEtc();
  result := True;
  //SetAffect(conn, 44, 20, 20);
end;

class function TVolatiles.Amagos(var player: TPlayer; var srcItem, dstItem: TItem): Boolean;
var MountID, AmagoID : WORD;
  Rate, _random, MountLive: WORD;
  MountLevel: BYTE;
begin
  result := False;
  if(dstItem.Index < 2330) or (dstItem.Index >= 2390) or (dstItem.Effects[1].Index <= 0)then
    exit;

  MountID := (dstItem.Index - 2330) mod 30;
  AmagoID := (srcItem.Index - 2390) mod 30;
  if(MountID <> AmagoID)then
  begin
    player.SendClientMessage('Montaria não compatível');
    exit;
  end;

  //dstItem.MOUNT_LIFE = 20000;
  //dstItem.MOUNT_GROWTH = 100;
  //char MountLevel = dstItem.MOUNT_LVL;

  if(MountLevel >= 120) and (dstItem.Index >= 2360) and (dstItem.Index < 2390)then
  begin
    player.SendClientMessage('Não é possivel evoluir mais.');
    exit;
  end;

  if(dstItem.Index >= 2360) and (dstItem.Index < 2390)then
  begin
    rate := 0;//= BASE_GetGrowthRate(pDestPointer);
    Randomize;
    _random := random(100);
    if(_random > rate)then
    begin
      if(player.Character.Equip[0].Index div 10 = 0)then
        player.SendEmotion(20, 0)
      else
        player.SendEmotion(15, 0);

      player.SendClientMessage('Falhou em refinar');

      //rand para reduzir a vitalidade da montaria em caso de falha do amago
      //Randomize;
      //if((random(5) = 0) and (dstItem.MOUNT_LIVE > 0))then
      //  pDestPointer->MOUNT_LIVE = pDestPointer->MOUNT_LIVE - 1;

      exit;
    end;
    player.SendClientMessage('Montaria cresceu');
  end;

  //MountLevel := MountLevel + 1;
  //dstItem.MOUNT_LVL := MountLevel;
  //dstItem.MOUNT_EXP := 1;
  if((MountLevel >= 25) and (dstItem.Index = 2330)) or    ((MountLevel >= 50) and (dstItem.Index = 2331)) or    ((MountLevel >= 100) and (dstItem.Index >= 2332) and    (dstItem.Index < 2360))then
  begin
    //dstItem.Index := dstItem.Index + 30;
    //MountLive := dstItem.MOUNT_LIVE;
    Randomize;
    MountLive := (random(20)+1) + MountLive;
    //dstItem.MOUNT_LVL := 0;
    //MountProcess(conn, 0);
  end;


  player.SendEmotion(14, 3);
  //if(dstItem.Index >= 2330) and (dstItem.Index < 2360)then
    //MountProcess(conn, 0);
  //if(dstItem.Index >= 2360) and (dstItem.Index < 2390)then
    //ProcessAdultMount(conn, 0);
end;

end.
