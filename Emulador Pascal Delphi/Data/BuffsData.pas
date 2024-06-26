unit BuffsData;

interface
uses PlayerData, System.Generics.Collections;

procedure GetAffectScore(Character: PCharacter);
procedure AddBMBuff(Character: PCharacter; affect: TAffect);

implementation

uses Windows, GlobalDefs, ConstDefs, Util, ItemFunctions;

procedure AddBMBuff(Character: PCharacter; affect: TAffect);
var att, latk, ldef, skillID: Integer;
  def: Integer;
begin
  att := (affect.Value * 2);

  if(affect.Master = LOBISOMEM) then
  begin
    Inc(att, 50 + Character.CurrentScore.Level div 3);
    latk := 450;
    ldef := -80;

    Inc(Character.Critical, 37);
    Inc(Character.RegenHP, 40);
    Inc(Character.RegenMP, 30);
    Character.CurrentScore.MoveSpeed := Character.CurrentScore.MoveSpeed + 2;
    Inc(Character.CurrentScore.MaxHP, (affect.Value * 2) div 3);
  end
  else if(affect.Master = URSO) then
  begin
    Inc(att, 80 + Character.CurrentScore.Level div 2);
    latk := 130;
    ldef := 120;

    Inc(Character.Critical, 15);
    Inc(Character.RegenHP, 40);
    Inc(Character.RegenMP, 30);
    Character.CurrentScore.MoveSpeed := Character.CurrentScore.MoveSpeed + 1;
    Inc(Character.CurrentScore.MaxHP, affect.Value * 3);
  end
  else if(affect.Master = ASTAROTH) then
  begin
    Inc(att, 100 + Character.CurrentScore.Level div 3);
    latk := 300;
    ldef := 120;

    Inc(Character.Critical, 15);
    Inc(Character.RegenHP, 40);
    Inc(Character.RegenMP, 30);
    Character.CurrentScore.MoveSpeed := Character.CurrentScore.MoveSpeed + 1;
    Inc(Character.CurrentScore.MaxHP, (affect.Value * 2) div 3);
  end
  else if(affect.Master = TITAN) then
  begin
    Inc(att, 150 + Character.CurrentScore.Level div 2);
    latk := 250;
    ldef := 250;

    Inc(Character.Critical, 27);
    Inc(Character.RegenHP, 40);
    Inc(Character.RegenMP, 30);
    Character.CurrentScore.MoveSpeed := Character.CurrentScore.MoveSpeed + 1;
    Inc(Character.CurrentScore.MaxHP, affect.Value * 2);
  end
  else if(affect.Master = EDEN) then
  begin
    Inc(att, 250 + Character.CurrentScore.Level div 2);
    latk := 580;
    ldef := 300;

    Inc(Character.Critical, 45);
    Inc(Character.RegenHP, 120);
    Inc(Character.RegenMP, 120);
    Character.CurrentScore.MoveSpeed := Character.CurrentScore.MoveSpeed + 2;
    Inc(Character.CurrentScore.MaxHP, affect.Value * 4);
  end;

  skillID := 69 mod 24;
  if((Character.Learn AND (1 shl skillID)) <> 0) then
  begin
    Inc(latk, 60);
    Inc(ldef, 40);
  end;

  att := IfThen(att > latk, latk, att);
  Inc(Character.CurrentScore.Attack, att);

  def := ldef + (affect.Value div 2);
  Inc(Character.CurrentScore.Defense, def);
end;

procedure GetAffectScore(Character: PCharacter);
var x, i: Byte;
  value: Byte;
  affect: TAffect;
  aux, aux2: Integer;
  passive: Integer;
begin
  for x := 0 to MAXBUFFS do
  begin
    if(Character.Affects[x].Index = 0) then
      continue;

    if(Character.Affects[x].Index >= 0) then
    begin
      affect := Character.Affects[x];
      value := affect.Value;
      if(affect.Index = BM_MUTACAO) then
      begin
        if(affect.Master >= LOBISOMEM) AND (affect.Master <= EDEN) then
          AddBMBuff(Character, affect)
        else exit;
      end
      else
      begin
        case affect.Index of
          HT_EVASAO_APRIMORADA:
          begin
            Character.AffectInfo.Evasion := Character.AffectInfo.Evasion + (value div 17);
          end;

          HT_MEDITACAO:
          begin
            aux := 90 + (value * 2);
            aux := IfThen(aux > 550, 550, aux);
            Inc(Character.CurrentScore.Attack, aux);
          end;

          HT_IMUNIDADE:
          begin
            for i := 0 to 3 do
            begin
              aux := Character.Resist[i] + 15;
              aux := IfThen(aux > 100, 100, aux);
              Character.Resist[i] := aux;
            end;
            Inc(Character.CurrentScore.Defense, 35);
          end;

          HT_LIGACAO_ESPCTRAL:
          begin
            Inc(Character.CurrentScore.Attack, value * 2);
          end;

          HT_ESCUDO_DOURADO:
          begin
            Inc(Character.CurrentScore.Defense, (value div 3) * 2);
          end;

          HT_GELO:
          begin
            Character.AffectInfo.SpeedMov := Character.AffectInfo.SpeedMov + 1;
          end;

          HT_TROCAESP:
          begin
            aux := ((Character.CurrentScore.MaxMP * 55) div 100);
            Inc(Character.CurrentScore.MaxHP, aux);
            Dec(Character.CurrentScore.MaxMP, aux);
          end;

          FM_ESCUDO_MAGICO:
          begin
            Inc(Character.CurrentScore.Defense, value * 2);
          end;

          FM_SKILLS:
          begin
            Inc(Character.CurrentScore.fMaster, 30);
            Inc(Character.CurrentScore.tMaster, 30);
            Inc(Character.CurrentScore.sMaster, 30);
          end;

          FM_VELOCIDADE:
          begin
            Character.CurrentScore.MoveSpeed := Character.CurrentScore.MoveSpeed + 1;
          end;

          FM_BUFFATK:
          begin
            aux := 150 + (value * 2);
            aux := IfThen(aux > 550, 550, aux);
            Inc(Character.CurrentScore.Attack, aux);
          end;

          FM_CONTROLE_MANA:
          begin
            aux := (Character.CurrentScore.MaxMP div 100) * (value div 7);
            Inc(Character.CurrentScore.MaxHP, aux);
            Dec(Character.CurrentScore.MaxMP, aux);
          end;

          TK_POSSUIDO:
          begin
            Inc(Character.CurrentScore.Defense, value);
            if(Character.Equip[6].Index <> 0) OR (Character.Equip[7].Index <> 0) then
            begin
              if(ItemList[Character.Equip[6].Index].Pos = 128) then
              begin
                for i := 0 to 3 do
                  Inc(Character.Resist[i], 10);
              end;
            end;
          end;

          TK_SAMARITANO:
          begin
            Inc(Character.CurrentScore.maxHP, 100);
            aux := 15 + ((value * 2) div 3);
            Inc(Character.CurrentScore.maxHP, aux * 4);
          end;

          TK_ASSALTO:
          begin
            aux := 50 + (value * 2);
            aux := IfThen(aux > 500, 500, aux);
            Inc(Character.CurrentScore.Attack, aux);
  //          int def = 10;
  //          def += ((value / 3) * 2);
          end;

          TK_AURAVIDA:
          begin
            Inc(Character.RegenHP, value div 4);
            Inc(Character.RegenHP, Character.CurrentScore.maxHP div 40);
          end;

          LENTIDAO:
          begin
            Character.CurrentScore.MoveSpeed := Character.CurrentScore.MoveSpeed - 2;
          end;

          RESISTENCIA_N:
          begin
            for i := 0 to 3 do
            begin
              aux := Character.Resist[i] - 10;
              aux := IfThen(aux <= 0, 0, aux);
              Character.Resist[i] := aux;
            end;
          end;
          {
          VENENO:
          begin
            Character.HPDRAIN := (-((Character.Status.maxHP * 5) / 100));
          end;
          }

          ATKMENOS:
          begin
            Dec(Character.CurrentScore.Attack, value);
          end;

        end;
      end;
    end;
  end;

  if(Character.ClassInfo = 0) then
  begin
    passive := (9 mod 24); // Mestre_Armas
    if((Character.Learn AND (1 shl passive)) <> 0) then
    begin
      if(Character.Equip[6].Index <> 0) AND (Character.Equip[7].Index <> 0) then
        Inc(Character.CurrentScore.Attack, (Character.CurrentScore.sMaster * 3) div 2);
    end;

    passive := (14 mod 24); // Nocao_Combate
    if((Character.Learn AND (1 shl passive)) <> 0) then
    begin
      Inc(Character.CurrentScore.Attack, Character.CurrentScore.sMaster div 2);
    end;

    passive := (15 mod 24); // Armadura_critica
    if((Character.Learn AND (1 shl passive)) <> 0) then
    begin
      Inc(Character.CurrentScore.Defense, Character.CurrentScore.sMaster * 3);
      Inc(Character.Critical, 30);
    end;
  end
  else if(Character.ClassInfo = 2) then
  begin
    aux := TItemFunctions.GetItemAbility(Character.Equip[6], 87); // Escudo1
    aux2 := TItemFunctions.GetItemAbility(Character.Equip[7], 87); // Escudo2
    passive := (65 mod 24);  // Armadura elemental
    if((Character.Learn AND (1 shl passive)) <> 0) then
    begin
//      Character.Absorcao += 10;
//      if(aux > 0) OR (aux2 > 0) then
//        Character.Absorcao += 7;
    end;

    passive := (67 mod 24); //Escudo_Tormento
    if((Character.Learn AND (1 shl passive)) <> 0) then
    begin
//      Inc(Character.Absorcao, 5);
      if(aux > 0) OR (aux2 > 0) then
        Inc(Character.CurrentScore.Defense, (Character.CurrentScore.tMaster * 3) div 2);
    end;
  end
  else if(Character.ClassInfo = 3) then
  begin
    passive := (74 mod 24); // Agressividade
    if((Character.Learn AND (1 shl passive)) <> 0) then
    begin
      Inc(Character.CurrentScore.Attack, (Character.CurrentScore.fMaster * 3) div 2);
    end;

    passive := (82 mod 24); // Pericia_Cacador
    if((Character.Learn AND (1 shl passive)) <> 0) then
    begin
      if(Character.Equip[6].Index <> 0) AND (Character.Equip[7].Index = 0) then
        Inc(Character.CurrentScore.Attack, (Character.CurrentScore.sMaster * 3) div 2);
    end;

    passive := (90 mod 24); // Visao_Cacadora
    if((Character.Learn AND (1 shl passive)) <> 0) then
    begin
      Inc(Character.Critical, Character.CurrentScore.DEX div 50);
    end;

    passive := (93 mod 24);  // Lamina_Aerea
    if((Character.Learn AND (1 shl passive)) <> 0) then
    begin
      Inc(Character.CurrentScore.Attack, 150);
    end;

    passive := (93 mod 24); // ProtecaoSombras
    if((Character.Learn AND (1 shl passive)) <> 0) then
    begin
      Inc(Character.CurrentScore.Defense, (Character.CurrentScore.tMaster * 3) div 2);
    end;
  end;
end;

{
1.	Lentid�o
2.	Velocidade(+)
3.	Resist�ncia(-)
4.	Ataque_B�nus
5.	Evas�o(-)
6.	Evas�o(+)
7.	Velocidade(-)
8.	J�ia(s)
9.	Dano(+)
10.	Ataque(-)
11.	Escudo_M�gico
12.	Defesa(-)
13.	Assalto
14.	Possu�do
15.	T�cnica(+)
16.	Transforma��o
17.	Aura_da_Vida
18.	Controle_de_Mana
19.	Imunidade
20.	Veneno
21.	Medita��o
22.	Trov�o
23.	Aura_Bestial
24.	Samaritano
25.	Prote��o_Elemental
26.	Evas�o(+)
27.	Congelamento
28.	Invisibilidade
29.	Limite_da_Alma
30.	B�nus_PvM
31.	Escudo_Dourado
32.	Cancelamento
33.	Transforma��o
34.	Comida
35.	B�nus_HP/MP
36.	Veneno
37.	Liga��o_Espectral
38.	Troca_de_Esp�rito
39.	B�nus_EXP
}

end.


