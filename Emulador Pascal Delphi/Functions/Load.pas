unit Load;

interface

uses MobGenerData, Windows, SysUtils, Classes, MiscData, PlayerData, Functions, NPC, CombatHandlers, IniFiles;

type TLoad = class
  public
    class function CarregarConfiguracoes(): Boolean; static;
    class procedure InitCharacters(); static;
    class procedure ItemsList(); static;
    class procedure QuestList(); static;
    class procedure GuildList; static;
    class procedure MobList(); static;
    class procedure InstantiateNPCs; static;
    class function InstantiateNPC(var npc: TNpc; npcId: WORD; const mobGenerData: TMobGenerData; leaderId: Integer) : Boolean; static;
    class procedure TeleportList(); static;
    class function HeightMap: Boolean; static;
    class procedure SkillData(); static;
    class procedure MobBaby(); static;
    class procedure LocaisGemaEstelar(); static;
    class procedure CarregarReplations(); static;

    //Replations
    class procedure ReplationA();
    class procedure ReplationB();
    class procedure ReplationC();
    class procedure ReplationD();
    class procedure ReplationE();
end;

Const
  MAX_ITEMLIST = 6500;

implementation
{ TLoad }

uses GlobalDefs, Log, Util, Generics.Collections, AIStates, ConstDefs;

class function TLoad.HeightMap: Boolean;
var f: file of THeightMap;
  local: string;
begin
  ZeroMemory(@HeightGrid, SizeOf(THeightMap));
  local := 'HeightMap.dat';
  AssignFile(f, local);
  Reset(f);
  Read(f, HeightGrid);
  CloseFile(f);

  Logger.Write('HeightMap carregado com sucesso!', TLogType.ServerStatus);
  Result := true;
end;

class procedure TLoad.InitCharacters;
begin
  // TK
  ZeroMemory(@InitialCharacters[0], 4 * sizeof(TCharacter));
  InitialCharacters[0].ClassInfo:=0;
  InitialCharacters[0].Merchant:=1;
  InitialCharacters[0].BaseScore.Level:=0;
  InitialCharacters[0].Equip[0].Index:=1;
  InitialCharacters[0].BaseScore.Str:=8;
  InitialCharacters[0].BaseScore.Int:=4;
  InitialCharacters[0].BaseScore.Dex:=7;
  InitialCharacters[0].BaseScore.Con:=6;
  InitialCharacters[0].pSkill:=0;
  InitialCharacters[0].BaseScore.CurHP:=80;
  InitialCharacters[0].BaseScore.MaxHP:=80;
  InitialCharacters[0].BaseScore.Defense:=10;
  InitialCharacters[0].BaseScore.CurMP:=45;
  InitialCharacters[0].BaseScore.MaxMP:=45;
  InitialCharacters[0].BaseScore.Attack:=10;
  InitialCharacters[0].CurrentScore.CurHP:=80;
  InitialCharacters[0].CurrentScore.MaxHP:=80;
  InitialCharacters[0].RegenHP:=8;
  InitialCharacters[0].CurrentScore.CurMP:=45;
  InitialCharacters[0].CurrentScore.MaxMP:=45;
  InitialCharacters[0].RegenMP:=8;
  InitialCharacters[0].Equip[1].Index:=1106;
  InitialCharacters[0].Equip[2].Index:=1118;
  InitialCharacters[0].Equip[3].Index:=1130;
  InitialCharacters[0].Equip[4].Index:=1142;
  InitialCharacters[0].Equip[5].Index:=1154;
  InitialCharacters[0].Equip[byte(TEquipSlot.LWeapon)].Index := 861;
  InitialCharacters[0].Gold:=1000;
  InitialCharacters[0].BaseScore.MoveSpeed := 1;

  //InitialCharacters[0].Equip[0].Effects[1].Index:=98;
  //InitialCharacters[0].Equip[0].Effects[1].Value:=1;
  FillChar(InitialCharacters[0].SkillBar1[0], 4, 255);
  FillChar(InitialCharacters[0].SkillBar2[0], 16, 255);

  //FM
  InitialCharacters[1].ClassInfo:=1;
  InitialCharacters[1].Merchant:=11;
  InitialCharacters[1].BaseScore.Level:=0;
  InitialCharacters[1].Equip[0].Index:=11;
  InitialCharacters[1].BaseScore.Str:=5;
  InitialCharacters[1].BaseScore.Int:=8;
  InitialCharacters[1].BaseScore.Dex:=5;
  InitialCharacters[1].BaseScore.Con:=5;
  InitialCharacters[1].pSkill:=0;
  InitialCharacters[1].BaseScore.CurHP:=60;
  InitialCharacters[1].BaseScore.MaxHP:=60;
  InitialCharacters[1].BaseScore.Defense:=10;
  InitialCharacters[1].BaseScore.CurMP:=65;
  InitialCharacters[1].BaseScore.MaxMP:=65;
  InitialCharacters[1].BaseScore.Attack:=10;
  InitialCharacters[1].CurrentScore.CurHP:=60;
  InitialCharacters[1].CurrentScore.MaxHP:=60;
  InitialCharacters[1].RegenHP:=8;
  InitialCharacters[1].CurrentScore.CurMP:=65;
  InitialCharacters[1].CurrentScore.MaxMP:=65;
  InitialCharacters[1].RegenMP:=8;
  InitialCharacters[1].Equip[1].Index:=1256;
  InitialCharacters[1].Equip[2].Index:=1268;
  InitialCharacters[1].Equip[3].Index:=1280;
  InitialCharacters[1].Equip[4].Index:=1292;
  InitialCharacters[1].Equip[5].Index:=1304;
  InitialCharacters[1].Equip[byte(TEquipSlot.LWeapon)].Index := 891;
  InitialCharacters[1].Gold:=1000;
  InitialCharacters[1].BaseScore.MoveSpeed := 1;
  //InitialCharacters[1].Equip[0].Effects[1].Index:=98;
  //InitialCharacters[1].Equip[0].Effects[1].Value:=1;
  FillChar(InitialCharacters[1].SkillBar1[0], 4, 255);
  FillChar(InitialCharacters[1].SkillBar2[0],16, 255);

  //BM
  InitialCharacters[2].ClassInfo:=2;
  InitialCharacters[2].Merchant:=21;
  InitialCharacters[2].BaseScore.Level:=0;
  InitialCharacters[2].Equip[0].Index:=21;
  InitialCharacters[2].BaseScore.Str:=6;
  InitialCharacters[2].BaseScore.Int:=6;
  InitialCharacters[2].BaseScore.Dex:=9;
  InitialCharacters[2].BaseScore.Con:=5;
  InitialCharacters[2].pSkill:=0;
  InitialCharacters[2].BaseScore.CurHP:=70;
  InitialCharacters[2].BaseScore.MaxHP:=70;
  InitialCharacters[2].BaseScore.Defense:=10;
  InitialCharacters[2].BaseScore.CurMP:=55;
  InitialCharacters[2].BaseScore.MaxMP:=55;
  InitialCharacters[2].BaseScore.Attack:=10;
  InitialCharacters[2].CurrentScore.CurHP:=70;
  InitialCharacters[2].CurrentScore.MaxHP:=70;
  InitialCharacters[2].RegenHP:=8;
  InitialCharacters[2].CurrentScore.CurMP:=55;
  InitialCharacters[2].CurrentScore.MaxMP:=55;
  InitialCharacters[2].RegenMP:=8;
  InitialCharacters[2].Equip[1].Index:=1418;
  InitialCharacters[2].Equip[2].Index:=1421;
  InitialCharacters[2].Equip[3].Index:=1424;
  InitialCharacters[2].Equip[4].Index:=1427;
  InitialCharacters[2].Equip[5].Index:=1430;
  InitialCharacters[2].Equip[byte(TEquipSlot.LWeapon)].Index := 861;
  InitialCharacters[2].Gold:=1000;
  InitialCharacters[2].BaseScore.MoveSpeed := 1;
  //InitialCharacters[2].Equip[0].Effects[1].Index:=98;
  //InitialCharacters[2].Equip[0].Effects[1].Value:=1;
  FillChar(InitialCharacters[2].SkillBar1[0], 4, 255);
  FillChar(InitialCharacters[2].SkillBar2[0],16, 255);

  //HT
  InitialCharacters[3].ClassInfo:=3;
  InitialCharacters[3].Merchant:=31;
  InitialCharacters[3].BaseScore.Level:=0;
  InitialCharacters[3].Equip[0].Index:=31;
  InitialCharacters[3].BaseScore.Str:=8;
  InitialCharacters[3].BaseScore.Int:=9;
  InitialCharacters[3].BaseScore.Dex:=13;
  InitialCharacters[3].BaseScore.Con:=6;
  InitialCharacters[3].pSkill:=0;
  InitialCharacters[3].BaseScore.CurHP:=75;
  InitialCharacters[3].BaseScore.MaxHP:=75;
  InitialCharacters[3].BaseScore.Defense:=10;
  InitialCharacters[3].BaseScore.CurMP:=60;
  InitialCharacters[3].BaseScore.MaxMP:=60;
  InitialCharacters[3].BaseScore.Attack:=10;
  InitialCharacters[3].CurrentScore.CurHP:=75;
  InitialCharacters[3].CurrentScore.MaxHP:=75;
  InitialCharacters[3].RegenHP:=8;
  InitialCharacters[3].CurrentScore.CurMP:=50;
  InitialCharacters[3].CurrentScore.MaxMP:=50;
  InitialCharacters[3].RegenMP:=8;
  InitialCharacters[3].Equip[1].Index:=1567;
  InitialCharacters[3].Equip[2].Index:=1571;
  InitialCharacters[3].Equip[3].Index:=1574;
  InitialCharacters[3].Equip[4].Index:=1577;
  InitialCharacters[3].Equip[5].Index:=1580;
  InitialCharacters[3].Equip[byte(TEquipSlot.LWeapon)].Index := 816;
  InitialCharacters[3].Gold:=1000;
  InitialCharacters[3].BaseScore.MoveSpeed := 1;
  //InitialCharacters[3].Equip[0].Effects[1].Index:=98;
  //InitialCharacters[3].Equip[0].Effects[1].Value:=1;
  FillChar(InitialCharacters[3].SkillBar1[0], 4, 255);
  FillChar(InitialCharacters[3].SkillBar2[0],16, 255);
end;

class procedure TLoad.ItemsList;
var f: TFileStream;
buffer: array of BYTE;
local: string;
I,j, size: Integer;
ItemListB: array of TItemList;
begin
  if(ItemList = nil) then   ItemList := TDictionary<integer, TItemList>.Create
  else                      ItemList.Clear;

  local := getcurrentdir+'\ItemList.bin';
  if not(FileExists(local)) then
  begin
    Logger.Write('Arquivo não encontrado. Coloque o ItemList.bin na mesma pasta que o Leitor de ItemList.', TLogType.Warnings);
    exit;
  end;

  F := TFileStream.Create(local, fmOpenRead);
  size := F.Size;
  SetLength(buffer,size);
  F.Read(buffer[0],size);
  F.Free;

  for I := 0 to size do
  begin
    buffer[i] := $5A xor buffer[i];
  end;

  setlength(ItemListB, Round(size/140));
  Move(buffer[0], ItemListB[0], size);

  j := Round(size/140);
  for I := 0 to j do
  begin
    //ZeroMemory(@Item,sizeof(TItemList));
    //Move(ItemListB[i].Name[0],Item.Name,sizeof(TItemListConvert));
    //Item.Index := i;
    ItemList.Add(i, ItemListB[i]);
  end;

  Logger.Write('ItemList carregado com sucesso!', TLogType.ServerStatus);
end;

class procedure TLoad.MobBaby;
  var i: BYTE;
      local : string;
      fs: File of TCharacterOld;
      erro: boolean;
      mob : TCharacterOld;
      errorCount: integer;
begin
  if(MobBabyList = nil) then  MobBabyList := TList<TCharacterOld>.Create
  else                        MobBabyList.Clear;
  erro := false;
  errorCount := 0;
  for i := 0 to (MAX_MOB_BABY - 1) do
  begin
    try
      if(MobBabyNames[i] = '')then
          continue;

      local := CurrentDir + '\npc_base\' + MobBabyNames[i];
      if(FileExists(local) = false) then
      begin
        Logger.Write('NpcBase: ' + MobBabyNames[i] + ' não encontrado.', TLogType.Warnings);
        inc(errorCount);
        erro := true;
        //Showmessage('Npc: ' + MobBabyNames[i] + ' não encontrado.');
        continue;
      end;
      AssignFile(fs, local);
      Reset(fs);
      Read(fs, mob);
      CloseFile(fs);
      mob.CurrentScore := mob.BaseScore;
      MobBabyList.Add(mob);
    except
      erro := true;
      inc(errorCount);
      Logger.Write('NpcBase: ' + MobBabyNames[i] + ' com erro de leitura.', TLogType.Warnings);
      CloseFile(fs);
    end;
  end;
  if(erro)then
    Logger.Write('MountBaby carregado com ' + inttostr(errorCount) + ' erro(s)!', TLogType.ServerStatus)
  else Logger.Write('MountBaby carregado com sucesso!', TLogType.ServerStatus);
end;

class procedure TLoad.InstantiateNPCs;
var errorsCount, errorsRead : Integer;
    mobGenerData: TMobGenerData;
    npcId, followerId, leaderId: WORD;

begin
  npcId := 1001;
  errorsCount := 0;
  errorsRead  := 0;

  for mobGenerData in MobGener.Values do
  begin
    try
      if not(InstantiateNpc(TNPC.NPCs[npcId], npcId, mobGenerData, npcId)) then
      begin
        Inc(errorsCount);
        continue;
      end;

      Inc(npcId);
      if(mobGenerData.MinGroup < 1) AND (mobGenerData.MaxGroup < 1) then
        continue;

      leaderId := npcId - 1;
      for followerId := mobGenerData.MinGroup to mobGenerData.MaxGroup do
      begin
        if not(InstantiateNPC(TNPC.NPCs[npcId], npcId, mobGenerData, leaderId)) then
        begin
          inc(errorsCount);
          continue;
        end;
        inc(npcId);
      end;
    except
      Inc(errorsRead);
    end;
  end;
  TNPC.InstantiatedNPCs := npcId;

  if(errorsCount > 0) then
    Logger.Write(IntToStr(errorsCount)+ ' mobs não encontrados!', TLogType.ServerStatus);

  if(errorsRead > 0) then
    Logger.Write(IntToStr(errorsRead) + ' mobs com erro de leitura!', TLogType.ServerStatus);
end;

class function TLoad.InstantiateNPC(var npc: TNpc; npcId: WORD; const mobGenerData: TMobGenerData; leaderId: Integer) : Boolean;
var npcName: string;
  npcDirectory: string;
  storeCount, nextSlot: BYTE;
  npcFile: file of TCharacterOld;
  npcCharacter: TCharacterOld;
  i: BYTE;
//  aGener : TMobGenerData;
begin
  Result := false;
  try
    npcName := IfThen(leaderId = npcId, mobGenerData.Leader, mobGenerData.Follower);
    npcDirectory := CurrentDir + '\NPC\' + npcName;
    if(FileExists(npcDirectory) = false) then
    begin
      Logger.Write('Npc: ' + npcName + ' não encontrado.', TLogType.Warnings);
      exit;
    end;

    ZeroMemory(@npcCharacter, Sizeof(TCharacterOld));
    AssignFile(npcFile, npcDirectory);
    Reset(npcFile);
    Read(npcFile, npcCharacter);
    CloseFile(npcFile);

    TFunctions.StringToAnsiChar(TFunctions.TrocaCaracterEspecial(npcCharacter.Name, True), npcCharacter.Name);

//    aGener := TMobGenerData.Create();
//    aGener.Assign(mobGenerData);

    npc := nil;
    npc := TNPC.Create(npcCharacter, mobGenerData, npcId, leaderId);
    npc.Character.Last := mobGenerData.SpawnSegment.Position;
//    npc.InitialPosition := npc.Character.Last;
    npc.CurrentPosition := npc.Character.Last;
//    npc.FinalPosition := npc.Character.Last;
    if (npc.StateMachine <> nil) then npc.StateMachine.CurrentState := TAIStates.Idle;
    npc.CalcAtackSpeed;
    npc.Character.CurrentScore := npc.Character.BaseScore;
    npc.Character.CurrentScore.CurHP := npc.Character.CurrentScore.MaxHP;
    npc.Character.CurrentScore.CurMP := npc.Character.CurrentScore.MaxMP;
    //Logger.Write('3', TLogType.ServerStatus);

    if(npc.Character.Merchant = 1) then
    begin
      storeCount := 0;
      for i := 0 to MAX_INV - 1 do
      begin
        if(storeCount >= 26) then
          break;
        if(npc.Character.Inventory[i].Index = 0) then
        begin
          for nextSlot := i + 1 to MAX_INV - 1 do
          begin
            if(npc.Character.Inventory[nextSlot].Index <> 0) then
            begin
              Move(npc.Character.Inventory[nextSlot], npc.Character.Inventory[i], SizeOf(TItem));
              ZeroMemory(@npc.Character.Inventory[nextSlot], SizeOf(TItem));
              Inc(storeCount);
              break;
            end;
          end;
        end
        else Inc(storeCount);
      end;
    end
    else if(npc.Character.Merchant = 19) then
    begin
      storeCount := 0;
      for i := 0 to MAX_INV - 1 do
      begin
        if(npc.Character.Inventory[i].Index <> 0) and (storeCount <= 26) then
        begin
          Move(npc.Character.Inventory[i], npc.Character.Inventory[storeCount], SizeOf(TItem));
          inc(storeCount);
          if(storeCount = 8) or (storeCount = 17) then
            inc(storeCount);
        end;
      end;
    end;

    if (mobGenerData.MinuteGenerate >= 0) then
    begin
      if not(TFunctions.GetEmptyMobGrid(npcId, npc.Character.Last, 8)) then
      begin
        Result := false;
        exit;
      end;
      MobGrid[npc.Character.Last.Y][npc.Character.Last.X] := npc.ClientId;
    end
    else
    begin
      npc.Character.CurrentScore.CurHP := 0;
      npc.TimeKill := Server.UpTime;
    end;

    if(npc.Character.BaseScore.MoveSpeed > 10) then
      npc.Character.BaseScore.MoveSpeed := 2
    else if(npc.Character.BaseScore.MoveSpeed = 0) then
      npc.Character.BaseScore.MoveSpeed := 1;
    npc.Character.CurrentScore.MoveSpeed := npc.Character.BaseScore.MoveSpeed;
  except
    begin
      Logger.Write('Npc: ' + npcName + ' com erro de leitura.', TLogType.Warnings);
      Result := false;
      exit;
    end;
  end;
  Result := true;
end;

class procedure TLoad.MobList;
var DataFile : TextFile;
  line : string;
  aux: TMobGenerData;
  i : BYTE;
  cnt: Integer;
begin
  if(MobGener = nil) then MobGener := TDictionary<integer, TMobGenerData>.Create
  else                    MobGener.Clear;

  AssignFile(DataFile, 'NPCGener.txt');
  Reset(DataFile);

  cnt := 0;
  aux := TMobGenerData.Create;
  aux.ID := -1;
  while not EOF(DataFile) do
  begin
    readln(DataFile, line);
    if (Trim(line) = '') then
      continue;

    if Pos('#',line) > 0 then
    begin
      Delete(line, Pos('#',line), 1);
      Delete(line, Pos('[',line), 1);
      Delete(line, Pos(']',line), 1);
      aux.ID := StrToIntDef(Trim(line),0);
      continue;
    end
    else if Pos('MinuteGenerate',line) > 0 then
    begin
      Delete(line,Pos('MinuteGenerate',line),Length('MinuteGenerate'));
      Delete(line,Pos(':',line),1);
      aux.MinuteGenerate := StrToIntDef(Trim(line),0);
    end
    else if Pos('MaxNumMob',line) > 0 then
    begin
      Delete(line,Pos('MaxNumMob',line),Length('MaxNumMob'));
      Delete(line,Pos(':',line),1);
      aux.MaxNumMob := StrToIntDef(Trim(line),0);
    end
    else if Pos('MinGroup',line) > 0 then
    begin
      Delete(line,Pos('MinGroup',line),Length('MinGroup'));
      Delete(line,Pos(':',line),1);
      aux.MinGroup := StrToIntDef(Trim(line),0);
    end
    else if Pos('MaxGroup',line) > 0 then
    begin
      Delete(line,Pos('MaxGroup',line),Length('MaxGroup'));
      Delete(line,Pos(':',line),1);
      aux.MaxGroup := StrToIntDef(Trim(line),0);
    end
    else if (Pos('Leader',line) > 0) and (Pos('Follower',line) = 0) then
    begin
      Delete(line,Pos('Leader',line), Length('Leader'));
      Delete(line,Pos(':',line),1);
      aux.Leader := Trim(line);
    end
    else if Pos('Follower',line) > 0 then
    begin
      Delete(line,Pos('Follower',line),Length('Follower'));
      Delete(line,Pos(':',line),1);
      aux.Follower := Trim(line);
    end
    else if Pos('RouteType',line) > 0 then
    begin
      Delete(line,Pos('RouteType',line),Length('RouteType'));
      Delete(line,Pos(':',line),1);
      aux.RouteType := StrToIntDef(Trim(line),0);
    end
    else if Pos('Formation',line) > 0 then
    begin
      Delete(line,Pos('Formation',line),Length('Formation'));
      Delete(line,Pos(':',line),1);
      aux.Formation := StrToIntDef(Trim(line),0);
    end
    else if Pos('StartX',line) > 0 then
    begin
      Delete(line,Pos('StartX', line),Length('StartX'));
      Delete(line,Pos(':',line),1);
      aux.SpawnSegment.Position.X := StrToIntDef(Trim(line),0);
    end
    else if Pos('StartY',line) > 0 then
    begin
      Delete(line,Pos('StartY',line),Length('StartY'));
      Delete(line,Pos(':',line),1);
      aux.SpawnSegment.Position.Y := StrToIntDef(Trim(line),0);
    end
    else if Pos('StartWait',line) > 0 then
    begin
      Delete(line,Pos('StartWait',line),Length('StartWait'));
      Delete(line,Pos(':',line), 1);
      aux.SpawnSegment.WaitTime := StrToIntDef(Trim(line),0);
    end
    else if Pos('StartRange',line) > 0 then
    begin
      Delete(line,Pos('StartRange',line),Length('StartRange'));
      Delete(line,Pos(':',line), 1);
      aux.SpawnSegment.Range := StrToIntDef(Trim(line),0);
    end
    else if Pos('DestX',line) > 0 then
    begin
      Delete(line,Pos('DestX', line),Length('DestX'));
      Delete(line,Pos(':',line),1);
      aux.DestSegment.Position.X := StrToIntDef(Trim(line),0);
    end
    else if Pos('DestY',line) > 0 then
    begin
      Delete(line,Pos('DestY',line),Length('DestY'));
      Delete(line,Pos(':',line),1);
      aux.DestSegment.Position.Y := StrToIntDef(Trim(line),0);
    end
    else if Pos('DestWait',line) > 0 then
    begin
      Delete(line,Pos('DestWait',line),Length('DestWait'));
      Delete(line,Pos(':',line), 1);
      aux.DestSegment.WaitTime := StrToIntDef(Trim(line),0);
    end
    else if Pos('DestRange',line) > 0 then
    begin
      Delete(line,Pos('DestRange',line),Length('DestRange'));
      Delete(line,Pos(':',line), 1);
      aux.DestSegment.Range := StrToIntDef(Trim(line),0);
    end
    else if (Pos('Segment',line) > 0) and (Pos('X',line) > 0) then
    begin
      Delete(line,Pos('Segment',line),Length('Segment'));
      i := StrToIntDef(Copy(Trim(line),1,1), 0);
      if i = 0 then
        continue;
      Delete(line,Pos(inttostr(i),line),1);
      Delete(line,Pos('X',line),1);
      Delete(line,Pos(':',line),1);

      aux.AddSegmentData(i, StrToIntDef(Trim(line), 0), -1);
    end
    else if (Pos('Segment',line) > 0) and (Pos('Y', line) > 0) then
    begin
      Delete(line,Pos('Segment',line), Length('Segment'));
      i := StrToIntDef(Copy(Trim(line),1,1), 0);
      if i = 0 then
        continue;
      Delete(line,Pos(inttostr(i),line),1);
      Delete(line,Pos('Y',line),1);
      Delete(line,Pos(':',line),1);
      aux.AddSegmentData(i, -1, StrToIntDef(Trim(line), 0));
    end
    else if (Pos('Segment',line) > 0) and (Pos('Wait', line) > 0) then
    begin
      Delete(line,Pos('Segment',line), Length('Segment'));
      i := StrToIntDef(Copy(Trim(line),1,1), 0);
      if i = 0 then
        continue;
      Delete(line,Pos(inttostr(i),line),1);
      Delete(line,Pos('Wait',line), Length('Wait'));
      Delete(line,Pos(':',line),1);
      aux.AddSegmentData(i, StrToIntDef(Trim(line), 0));
    end
    else if (Pos('Segment',line) > 0) and (Pos('Action', line) > 0) then
    begin
      Delete(line,Pos('Segment',line), Length('Segment'));
      i := StrToIntDef(Copy(Trim(line),1,1), 0);
      if i = 0 then
        continue;
      Delete(line, Pos(inttostr(i),line),1);
      Delete(line, Pos('Action', line), Length('Action'));
      Delete(line, Pos(':',line), 1);
      aux.AddSegmentData(i, Trim(line));
    end
    else if Pos('********************', line) > 0 then
    begin
      if aux.ID = -1 then
        continue;
      MobGener.Add(cnt, aux);
      Inc(cnt);
      aux := TMobGenerData.Create;
    end;
  end;
  CloseFile(DataFile);

  TLoad.InstantiateNPCs;
  Logger.Write(IntToStr(TNPC.InstantiatedNPCs - 1001) + ' mobs foram instanciados!', TLogType.ServerStatus)
end;

class procedure TLoad.QuestList;
var DataFile : TextFile;
    lineFile : String;
    fileStrings : TStringList;
    quest: TQuest;
begin
  if(Quests = nil) then Quests := TList<TQuest>.Create
  else                  Quests.Clear;

  if(FileExists('QuestList.txt') = false) then
  begin
    Logger.Write('Arquivo de quests não encontrado.', TLogType.Warnings);
    exit;
  end;

  quest := TQuest.Create;
  AssignFile(DataFile, 'QuestList.txt');
  Reset(DataFile);
  fileStrings := TStringList.Create;
  while not EOF(DataFile) do
  begin
    Readln(DataFile, lineFile);
    ExtractStrings([','],[' '],PChar(Linefile),fileStrings);
    if(fileStrings.Count = 0) OR (TFunctions.IsNumeric(fileStrings.strings[0], quest.Index) = false) then begin
      filestrings.Clear;
      continue;
    end;

    quest.ItemId := StrToInt(fileStrings.strings[1]);
    quest.ResetTime := StrToInt(fileStrings.strings[2]);
    quest.QuestPosition.X := StrToInt(fileStrings.strings[3]);
    quest.QuestPosition.Y := StrToInt(fileStrings.strings[4]);
    quest.QuestArea.BottomLeft.X := StrToInt(fileStrings.strings[5]);
    quest.QuestArea.BottomLeft.Y := StrToInt(fileStrings.strings[6]);
    quest.QuestArea.TopRigth.X := StrToInt(fileStrings.strings[7]);
    quest.QuestArea.TopRigth.Y := StrToInt(fileStrings.strings[8]);
    quest.LevelMin := StrToInt(fileStrings.strings[9]);
    quest.LevelMax := StrToInt(fileStrings.strings[10]);

    quest.Players := TList<WORD>.Create;
    quest.Players.Capacity := StrToInt(fileStrings.strings[11]);
    quest.Name := fileStrings.strings[12];

    filestrings.Clear;
    Quests.Add(quest)
  end;
  fileStrings.Free;
  Logger.Write('QuestList carregado com sucesso!', TLogType.ServerStatus);
  CloseFile(DataFile);
end;

class procedure TLoad.GuildList;
var DataFile : TextFile;
    lineFile : String;
    fileStrings : TStringList;
    guild: TGuildData;
    test: integer;
begin
  if(Guilds = nil) then Guilds:= TDictionary<integer, TGuildData>.Create
  else                  Guilds.Clear;

  if(FileExists('Guilds.txt') = false) then
  begin
    Logger.Write('Arquivo de guildas não encontrado.', TLogType.Warnings);
    exit;
  end;

  guild := TGuildData.Create;
  AssignFile(DataFile, 'Guilds.txt');
  Reset(DataFile);
  fileStrings := TStringList.Create;

  while not EOF(DataFile) do
  begin
    Readln(DataFile, lineFile);
    ExtractStrings([','],[' '],PChar(Linefile),fileStrings);
    if(TFunctions.IsNumeric(fileStrings.strings[0], test) = false) then
    begin
      filestrings.Clear;
      continue;
    end;

    guild.ID      := StrToInt(fileStrings.strings[0]);
    guild.Alianca := StrToInt(fileStrings.strings[1]);
    guild.Nome    := fileStrings.strings[2];

    filestrings.Clear;
    Guilds.Add(guild.ID, guild);
  end;
  LastGuildId := guild.ID;
  fileStrings.Free;
  Logger.Write('GuildList carregado com sucesso!', TLogType.ServerStatus);
  CloseFile(DataFile);
end;

class procedure TLoad.LocaisGemaEstelar;
var DataFile : TextFile;
    lineFile : String;
    fileStrings : TStringList;
    Pos: TGemaEstelar;
    test: integer;
begin
  if(GemaEstelar = nil) then  GemaEstelar:= TList<TGemaEstelar>.Create
  else                        GemaEstelar.Clear;

  if(FileExists('GemaEstelar.txt') = false) then
  begin
    Logger.Write('Arquivo de gemas estrelares não encontrado.', TLogType.Warnings);
    exit;
  end;

  AssignFile(DataFile, 'GemaEstelar.txt');
  Reset(DataFile);
  fileStrings := TStringList.Create;

  while not EOF(DataFile) do
  begin
    ZeroMemory(@Pos, sizeof(Pos));
    Readln(DataFile, lineFile);
    ExtractStrings([','],[' '],PChar(Linefile),fileStrings);
    if(TFunctions.IsNumeric(fileStrings.strings[0], test) = false) then begin
      filestrings.Clear;
      continue;
    end;

    Pos.Local[0].X      := StrToInt(fileStrings.strings[0]);
    Pos.Local[0].Y      := StrToInt(fileStrings.strings[1]);
    Pos.Local[1].X      := StrToInt(fileStrings.strings[2]);
    Pos.Local[1].Y      := StrToInt(fileStrings.strings[3]);

    filestrings.Clear;
    GemaEstelar.Add(Pos);
  end;
  fileStrings.Free;
  Logger.Write('GemaEstelar carregado com sucesso!', TLogType.ServerStatus);
  CloseFile(DataFile);
end;

class procedure TLoad.SkillData;
var DataFile : TextFile;
    lineFile : String;
    fileStrings : TStringList;
    skill : TSkillData;
    skillId : Integer;
begin
  if(SkillsData = nil) then SkillsData := TList<TSkillData>.Create
  else                      SkillsData.Clear;

  if(FileExists('Skilldata.csv') = false) then
  begin
    Logger.Write('SkillData não encontrado.', TLogType.Warnings);
    exit;
  end;

  AssignFile(DataFile, 'Skilldata.csv');
  Reset(DataFile);
  fileStrings := TStringList.Create;

  while not EOF(DataFile) do
  begin
    Readln(DataFile, lineFile);

    if (Trim(Linefile) = '') then
      continue;

    ExtractStrings([','],[' '],PChar(Linefile),fileStrings);
    if(TFunctions.IsNumeric(fileStrings.strings[0], skillId) = false)then begin
      filestrings.Clear;
      continue;
    end;
    skill.Index         := skillId;
    skill.SkillPoint    := StrToIntDef(fileStrings.Strings[1],0);
    skill.TargetType    := StrToIntDef(fileStrings.Strings[2],-1);
    skill.Name          := fileStrings.Strings[22];
    skill.ManaSpent     := StrToIntDef(fileStrings.Strings[3], 0);
    skill.Delay         := StrToIntDef(fileStrings.Strings[4], 0);

    skill.InstanceType  := StrToIntDef(fileStrings.Strings[6], 0);
    skill.InstanceValue := fileStrings.Strings[7];
    skill.AffectValue   := fileStrings.Strings[11];
    skill.AffectTime    := StrToIntDef(fileStrings.Strings[12],0);

    filestrings.Clear;
    if (Trim(skill.Name) <> '') then SkillsData.Add(skill)
  end;
  fileStrings.Free;
  Logger.Write('SkillData carregado com sucesso!', TLogType.ServerStatus);
  CloseFile(DataFile);

  TCombatHandlers.RegisterSkills;
end;


class procedure TLoad.TeleportList;
var DataFile : TextFile;
    lineFile : String;
    fileStrings : TStringList;
    teleport : TTeleport;
begin
  if(TeleportsList = nil) then  TeleportsList  := TList<TTeleport>.Create
  else                          TeleportsList.Clear;

  if(FileExists('Teleports.csv') = false) then
  begin
    Logger.Write('Teleports.csv não encontrado.', TLogType.Warnings);
    exit;
  end;

  AssignFile(DataFile, 'Teleports.csv');
  Reset(DataFile);

  fileStrings := TStringList.Create;

  while not EOF (DataFile) do
  begin
    Readln(DataFile, lineFile);
    ExtractStrings([','], [' '], pChar(Linefile), fileStrings);

    if(TFunctions.IsNumeric(fileStrings.strings[0]) = false)then begin
      filestrings.Clear;
      continue;
    end;

    //Adiciona na estrutura;
    teleport.Scr1.X := strtoint(fileStrings.Strings[0]);
    teleport.Scr1.Y := strtoint(fileStrings.Strings[1]);//nome
    teleport.Dest1.X := strtoint(fileStrings.Strings[2]);//
    teleport.Dest1.Y := strtoint(fileStrings.Strings[3]);//
    teleport.Price := strtoint(fileStrings.Strings[4]);//
    teleport.Time := strtoint(fileStrings.Strings[5]);//
    filestrings.Clear;
    TeleportsList.Add(teleport);
  end;
  fileStrings.Free;
  Logger.Write('Teleportes carregados com sucesso!', TLogType.ServerStatus);
  CloseFile(DataFile);
end;


class procedure TLoad.ReplationA();
var i: BYTE;
    LReplations : TList<WORD>;
const
  ReplationAa: array[0..119] of WORD = ( 1101, 1102, 1103, 1104, 1105, 1106, 1113, 1114, 1115, 1116, 1117,
        1118, 1125, 1126, 1127, 1128, 1129, 1130, 1137, 1138, 1139, 1140, 1141, 1142, 1149,
		    1150, 1151, 1152, 1153, 1154, 1251, 1252, 1253, 1254, 1255, 1256, 1263, 1264, 1265,
		    1266, 1267, 1268, 1275, 1276, 1277, 1278, 1279, 1280, 1287, 1288, 1289, 1290, 1291,
		    1292, 1299, 1300, 1301, 1302, 1303, 1304, 1401, 1402, 1403, 1404, 1405, 1406, 1407,
        1408, 1409, 1410, 1411, 1412, 1413, 1414, 1415, 1416, 1417, 1418, 1419, 1420, 1421,
        1422, 1423, 1424, 1425, 1426, 1427, 1428, 1429, 1430, 1551, 1552, 1553, 1554, 1555,
        1556, 1557, 1558, 1559, 1560, 1561, 1562, 1563, 1564, 1565, 1566, 1567, 1568, 1569,
        1570, 1571, 1572, 1573, 1574, 1575, 1576, 1577, 1578, 1579, 1580 );
begin
  LReplations := TList<WORD>.Create;
	for i := 0 to 119 do
    LReplations.Add(ReplationAa[i]);
  Replations.Add(0, LReplations);
end;

class procedure TLoad.ReplationB();
var i: BYTE;
    LReplations : TList<WORD>;
const
  ReplationBb: array[0..119] of WORD = ( 1107, 1108, 1109, 1110, 1111, 1112, 1119, 1120, 1121, 1122, 1123,
		1124, 1131, 1132, 1133, 1134, 1135, 1136, 1143, 1144, 1145, 1146, 1147, 1148, 1155,
		1156, 1157, 1158, 1159, 1160, 1257, 1258, 1259, 1260, 1261, 1262, 1269, 1270, 1271,
		1272, 1273, 1274, 1281, 1282, 1283, 1284, 1285, 1286, 1293, 1294, 1295, 1296, 1297,
		1298, 1305, 1306, 1307, 1308, 1309, 1310, 1431, 1432, 1433, 1434, 1435, 1436, 1437,
        1438, 1439, 1440, 1441, 1442, 1443, 1444, 1445, 1446, 1447, 1448, 1449, 1450, 1451,
        1452, 1453, 1454, 1455, 1456, 1457, 1458, 1459, 1460, 1581, 1582, 1583, 1584, 1585,
        1586, 1587, 1588, 1589, 1590, 1591, 1592, 1593, 1594, 1595, 1596, 1597, 1598, 1599,
        1600, 1601, 1602, 1603, 1604, 1605, 1606, 1607, 1608, 1609, 1610 );
begin
  LReplations := TList<WORD>.Create;
	for i := 0 to 119 do
    LReplations.Add(ReplationBb[i]);
	Replations.Add(1, LReplations);
end;

class procedure TLoad.ReplationC();
var i: BYTE;
    LReplations : TList<WORD>;
const
  ReplationCc: array[0..74] of WORD = (1161, 1162, 1163, 1164, 1165, 1166, 1167, 1168, 1169, 1170, 1171,
		1172, 1173, 1174, 1175, 1176, 1177, 1178, 1179, 1180, 1181, 1182, 1183, 1184, 1185,
		1186, 1187, 1188, 1189, 1190, 1311, 1312, 1313, 1314, 1315, 1316, 1317, 1318, 1319,
		1320, 1321, 1322, 1323, 1324, 1325, 1461, 1462, 1463, 1464, 1465, 1466, 1467, 1468,
		1469, 1470, 1471, 1472, 1473, 1474, 1475, 1611, 1612, 1613, 1614, 1615, 1616, 1617,
        1618, 1619, 1620, 1621, 1622, 1623, 1624, 1625 );
begin
  LReplations := TList<WORD>.Create;
	for i := 0 to 74 do
    LReplations.Add(ReplationCc[i]);
	Replations.Add(2, LReplations);
end;

class procedure TLoad.ReplationD();
var i: BYTE;
    LReplations : TList<WORD>;
const
  ReplationDd: array[0..119] of WORD = (1191, 1192, 1193, 1194, 1195, 1196, 1197, 1198, 1199, 1200, 1201,
		1202, 1203, 1204, 1205, 1206, 1207, 1208, 1209, 1210, 1211, 1212, 1213, 1214, 1215,
		1216, 1217, 1218, 1219, 1220, 1326, 1327, 1328, 1329, 1330, 1331, 1332, 1333, 1334,
		1335, 1336, 1337, 1338, 1339, 1340, 1341, 1342, 1343, 1344, 1345, 1346, 1347, 1348,
		1349, 1350, 1351, 1352, 1353, 1354, 1355, 1476, 1477, 1478, 1479, 1480, 1481, 1482,
        1483, 1484, 1485, 1486, 1487, 1488, 1489, 1490, 1491, 1492, 1493, 1494, 1495, 1496,
        1497, 1498, 1499, 1500, 1501, 1502, 1503, 1504, 1505, 1626, 1627, 1628, 1629, 1630,
        1631, 1632, 1633, 1634, 1635, 1636, 1637, 1638, 1639, 1640, 1641, 1642, 1643, 1644,
        1645, 1646, 1647, 1648, 1649, 1650, 1651, 1652, 1653, 1654, 1655);
begin
  LReplations := TList<WORD>.Create;
	for i := 0 to 119 do
    LReplations.Add(ReplationDd[i]);
	Replations.Add(3, LReplations);
end;

class procedure TLoad.ReplationE();
var i: BYTE;
    LReplations : TList<WORD>;
const
  ReplationEe: array[0..19] of WORD = (1225, 1226, 1227, 1228, 1229, 1360, 1361, 1362, 1363, 1364, 1510,
		1511, 1512, 1513, 1514, 1660, 1661, 1662, 1663, 1664);
begin
  LReplations := TList<WORD>.Create;
	for i := 0 to 19 do
    LReplations.Add(ReplationEe[i]);
	Replations.Add(4, LReplations);
end;

class function TLoad.CarregarConfiguracoes: Boolean;
var
  iniFile : TIniFile;
begin
  Result := False;
  iniFile := TIniFile.Create(CurrentDir + '\Configuracoes.ini');
  if (not iniFile.SectionExists('GameServer')) then
  begin
    iniFile.WriteInteger('GameServer', 'Porta', 0);
  end;

  if (not iniFile.SectionExists('DataBaseServer')) then
  begin
    iniFile.WriteInteger('DataBaseServer', 'Porta', 0);
    iniFile.WriteString('DataBaseServer', 'Ip', '');
  end;

  ConfiguracoesGameServer.Porta := iniFile.ReadInteger('GameServer', 'Porta', 0);
  if (ConfiguracoesGameServer.Porta = 0) then
  begin
    Logger.Write('Seção [GameServer] no arquivo Configuracoes.ini não configurada.', TLogType.Warnings);
    exit;
  end;

  ConfiguracoesDbServer.Porta := iniFile.ReadInteger('DataBaseServer', 'Porta', 0);
  ConfiguracoesDbServer.Ip := Trim(iniFile.ReadString('DataBaseServer', 'Ip', ''));
  if (ConfiguracoesDbServer.Porta = 0) and (ConfiguracoesDbServer.Ip = '') then
  begin
    Logger.Write('Seção [DataBaseServer] no arquivo Configuracoes.ini não configurada.', TLogType.Warnings);
    exit;
  end;

  Result := True;
end;

class procedure TLoad.CarregarReplations;
begin
  ReplationA;
  ReplationB;
  ReplationC;
  ReplationD;
  ReplationE;

  Logger.Write('Replations carregados com sucesso!', TLogType.ServerStatus);
end;


end.
