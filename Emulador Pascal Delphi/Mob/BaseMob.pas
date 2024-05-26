unit BaseMob;

interface

uses Windows, PlayerData, MiscData, Packets, Generics.Collections, SysUtils,
  DateUtils, Diagnostics, Position, ConstDefs;

type TBaseMob = class(TObject)
  published
    constructor Create(index: WORD);
    destructor Destroy();

  private
    _cooldown: TDictionary<Byte, TTime>;

    procedure DeterminMoveDirection(const pos: TPosition);

    function  GetEquipDamage(LR : Integer): WORD;
    procedure ApplyDamage(attacker: TBaseMob; damage: Integer);
    procedure GetMobMotion(var packet: TProcessAttackOneMob);

  public
    ClientId : WORD;
    Character : TCharacter;
    AttackSpeed : WORD;
    Mobbaby : WORD;
    PartyId : WORD;
    PartyRequestId : WORD;
    VisibleMobs : TList<WORD>;
    Target : TBaseMob;

    IsDirty : Boolean;
    CurrentPosition : TPosition;
    PreviusPosition : TPosition;


    //agora somente para npc
    IsMoving : Boolean;
    StartMoveTime : TDateTime;
    EstimatedMoveTime : Double;
    InitialPosition, FinalPosition : TPosition;

    procedure SendPacket(packet : pointer; size : WORD);

    procedure AddToVisible(var mob : TBaseMob; revive: boolean = false);
    procedure RemoveFromVisible(mob : TBaseMob);


    property LeftDamage  : WORD Index 7 read GetEquipDamage;
    property RightDamage : WORD Index 8 read GetEquipDamage;

    function IsPlayer : boolean;
    function IsDead : boolean;
    function InBattle : boolean;

    procedure UpdateVisibleList(removeNotRange : boolean = true; addNewRange : boolean = true);

    function CheckCooldown(skillId: Byte): Boolean;
    procedure UsedSkill(skillId: Byte);
    procedure AddToEnemyList(target: TBaseMob); virtual;

    // Sends
    procedure SendMovement(destination : TPosition; calcDirection: Boolean = true); overload;
    procedure SendMovement(destX, destY : SmallInt; calcDirection: Boolean = true); overload;
    procedure SendMovement(packet: TMovementPacket; sendToSelf: boolean = true); overload;

    procedure SendRemoveMob(delType: integer = 0; sendTo : WORD = 0);
    procedure SendChat(str: AnsiString);
    procedure SendCurrentHPMP();
    procedure SendScore();
    procedure SendCreateMob(spawnType : WORD = SPAWN_NORMAL; sendTo : WORD = 0);
    procedure SendEmotion(effType, effValue: smallint);
    procedure SendToVisible(packet : pointer; size : WORD; sendToSelf : Boolean = true);
    procedure SendParty(leader, member : WORD); overload;
    procedure SendParty; overload;
    procedure SendDamage(target: TBaseMob; skillId : ShortInt; damage: Integer = -1); overload;
    procedure SendDamage(targets: TList<WORD>; skillId : ShortInt; damage: Integer = -1); overload;
    procedure SendMobDead(killer: TBaseMob); virtual;
    procedure SendAffects();
    procedure SendEquipItems(sendSelf : Boolean = True);
    procedure SendEtc;

    procedure SendSignal(pIndex, opCode: WORD); overload;
    procedure SendSignal(headerClientId, packetCode: WORD; data: Integer); overload;
    procedure SendSignal2(headerClientId, packetCode: WORD; data: Integer; data2: Integer);

    //Gets
    procedure GetCurrentScore();
    procedure CalcAtackSpeed(); inline;
    procedure GetAffectScore;
    function GetFirstSlot(itemId: WORD; invType: BYTE): Integer;
    function GetItemAmount(itemId: Integer; inv: array of TItem): TItemAmount;
    function GetCurrentHP(): Integer;
    function GetCurrentMP(): Integer;
    function GetEmptySlot(): Byte;
    procedure GetCreateMob(out packet : TSendCreateMobPacket);
    function GetMaxAbility(eff: integer): integer;
    function GetMobAbility(eff: integer):integer;
    function GetDamage(target: TBaseMob; master: Byte): smallint;


    function Teleport(x, y : SmallInt) : Boolean; overload;
    function Teleport(position : TPosition) : Boolean; overload;

    function AddAffect(affect: TAffect):Boolean; overload;
    function AddAffect(affect: TAffect; acumula : Boolean):Boolean; overload;
    function FindAffect(Index: BYTE): Byte;
    procedure SetAffect(affectId: Byte; affect: TAffect);
    procedure CleanAffect(affectId: Byte);

    procedure RemoveItem(slot, slotType: BYTE);
    function  CalcExp(expbase: Cardinal; attackerLevel, targetLevel : WORD): Integer;
    procedure AddExp(exp: Cardinal; partyMultiplier: Real = 0);

    procedure GenerateBabyMob;
    procedure UngenerateBabyMob(ungenEffect: WORD);

    procedure ForEachInRange(range: Byte; proc: TProc<TPosition, TBaseMob, TBaseMob>); overload;
    procedure ForEachVisible(proc: TProc<TBaseMob>);

    procedure GridMulticast(pos: TPosition; packet: pointer; Index: WORD);
    procedure SendGridMob(spawn: WORD);

    class function GetMob(index: WORD; out mob: TBaseMob): boolean; overload; static;
    class function GetMob(pos: TPosition; out mob: TBaseMob): boolean; overload; static;

    class procedure ForEach(proc: TProc<TBaseMob>); static;
    class procedure ForEachInRange(pos: TPosition; range: Byte; proc: TProc<TPosition, TBaseMob>); overload; static;
end;

type
  TProcedureMobPosition = procedure(mob: TBaseMob; pos : TPosition) of object;

const HPIncrementPerLevel: array[0..3] of integer = (
  3, // Transknight
  1, // Foema
  1, // BeastMaster
  2  // Hunter
);

const MPIncrementPerLevel: array[0..3] of integer = (
  1, // Transknight
  3, // Foema
  2, // BeastMaster
  1  // Hunter
);

implementation

uses GlobalDefs, Player, ItemFunctions, Functions, NPC, Log, Util, BuffsData, System.Threading;

procedure TBaseMob.SendGridMob(spawn: WORD);
var
  posX, posY,mobID: smallint;
  nY,nX,VisX,VisY,minPosX,minPosY,maxPosX,maxPosY: integer;
  mob : TBaseMob;
  packet: TSendCreateMobPacket;
begin
  if(self.ClientId <= 0) or (self.ClientId >= 8192) then
    exit;

  posX := Trunc(CurrentPosition.X);
  posY := Trunc(CurrentPosition.Y);

  VisX := 23; VisY := 23;
  minPosX := (posX - 11);
  minPosY := (posY - 11);

	if((minPosX + VisX) >= 4096)then
		VisX := (VisX - (VisX + minPosX - 4096));

	if((minPosY + VisY) >= 4096)then
		VisY := (VisY - (VisY + minPosY - 4096));

  if(minPosX < 0)then
  begin
    minPosX := 0;
    VisX := (VisX + minPosX);
  end;

	if(minPosY < 0)then
	begin
		minPosY := 0;
		VisY := (VisY + minPosY);
	end;

  maxPosX := (minPosX + VisX);
  maxPosY := (minPosY + VisY);

  for nY := minPosY to maxPosY do
  begin
    for nX := minPosX to maxPosX do
    begin
      mobID := MobGrid[nY][nX];
      if(mobID <= 0) or (self.ClientId = mobID) then
        continue;

      GetMob(mobID, mob);
      if (not mob.VisibleMobs.Contains(self.ClientId)) then
      begin
        if (self.IsPlayer) then
          mob.VisibleMobs.Add(self.ClientId);
        if (mob.IsPlayer) then
          self.SendCreateMob(spawn, mobID);
      end;

      if (self.IsPlayer) and (not self.VisibleMobs.Contains(mobID)) then
      begin
        GetMob(mobID, mob);
        self.VisibleMobs.Add(mobID);
        mob.SendCreateMob(SPAWN_NORMAL, self.ClientId);
      end;
    end;
  end;
end;

procedure TBaseMob.GridMulticast(pos: TPosition; packet: pointer; Index: WORD);
var mobID,nY,nX,Visx,VisY,minPosX,minPosY,maxPosX,maxPosY: integer;
  size: smallint;
  player: TPlayer;
begin
  size := TPacketHeader(packet^).Size;

  VisX := 23; VisY := 23;
  minPosX := (pos.X - 11);
  minPosY := (pos.Y - 11);

	if((minPosX + VisX) >= 4096)then
		VisX := (VisX - (VisX + minPosX - 4096));

	if((minPosY + VisY) >= 4096)then
		VisY := (VisY - (VisY + minPosY - 4096));

  if(minPosX < 0)then
  begin
    minPosX := 0;
    VisX := (VisX + minPosX);
  end;

	if(minPosY < 0)then
	begin
		minPosY := 0;
		VisY := (VisY + minPosY);
	end;

  maxPosX := (minPosX + VisX);
  maxPosY := (minPosY + VisY);

  for nY := minPosY to maxPosY do
  begin
    for nX := minPosX to maxPosX do
    begin
      mobID := MobGrid[nY][nX];
      if(mobID <= 0) or (Index = mobID)then
          continue;

      if(size = 0) or (mobID >= 1000)then
          continue;

      if(nX < minPosX) or (nX >= maxPosX) or
        (nY < minPosY) or (nY >= maxPosY)then
      begin
        if(mobID < 1000)then
          self.SendRemoveMob(DELETE_NORMAL, mobID);
      end;

      Server.SendPacketTo(mobID, packet, size);
    end;
  end;
end;

function TBaseMob.CheckCooldown(skillId: Byte): Boolean;
begin
  result := true;
  if (skillId <= -1) or (skillId in [151, 153]) or (SkillsData.Count < skillId) then
  begin
    exit;
  end;

  if not(_cooldown.ContainsKey(skillId)) then
  begin
    exit;
  end;

  if SecondsBetween(_cooldown[skillId], Now) < SkillsData[skillId].Delay then
  begin
    Result := false;
  end
  else
  begin
    _cooldown.Remove(skillId);
  end;
end;

procedure TBaseMob.CleanAffect(affectId: Byte);
var affect: TAffect;
begin
  ZeroMemory(@affect, sizeof(TAffect));
  SetAffect(affectId, affect);
end;

constructor TBaseMob.Create(index: WORD);
begin
  VisibleMobs := TList<WORD>.Create;
  VisibleMobs.Clear;
  IsDirty := false;
  ClientId := index;

  _cooldown := TDictionary<Byte, TTime>.Create;
end;

destructor TBaseMob.Destroy();
begin
  if Character.ClientId > 0 then
    MobGrid[CurrentPosition.Y][CurrentPosition.X] := 0;

  _cooldown.Free;
  VisibleMobs.Free;
end;


function TBaseMob.GetEquipDamage(LR : Integer): WORD;
begin
  result := TItemFunctions.GetItemAbility(Character.Equip[LR], EF_DAMAGE) +
                 TItemFunctions.GetItemAbility(Character.Equip[LR],EF_DAMAGE2)+
                 TItemFunctions.GetItemAbility(Character.Equip[LR],EF_DAMAGEADD);
end;

function TBaseMob.GetFirstSlot(itemId: WORD; invType: BYTE): Integer;
var inv: TList<TItem>;
  i: BYTE;
begin
  inv := TList<TItem>.Create;

  case invType of
    EQUIP_TYPE: inv.AddRange(Character.Equip);
    INV_TYPE: inv.AddRange(Character.Inventory);
    STORAGE_TYPE:
    begin
      if not(IsPlayer) then
      begin
        Result := -1;
        FreeAndNil(inv);
        exit;
      end;
      inv.AddRange(TPlayer.Players[ClientId].Account.Header.StorageItens);
    end;
  end;

  for i := 0 to inv.Count - 1 do
  begin
    if(inv[i].Index = itemId) then
    begin
      Result := i;
      FreeAndNil(inv);
      exit;
    end;
  end;

  FreeAndNil(inv);
end;

procedure TBaseMob.SendPacket(packet : pointer; size : WORD);
begin
  Server.SendPacketTo(clientId, packet, size);
end;

procedure TBaseMob.SendParty;
var
  party: PParty;
  i: WORD;
  member: TBaseMob;
begin
  if(partyId = 0) then
    exit;

  party := @Parties[partyId];

  for i in party.Members do
  begin
    if (not self.GetMob(i, member)) then
      continue;

    if member.IsPlayer then
      member.SendParty(255 + party.Leader, ClientId);

    if self.IsPlayer then
      SendParty(255 + party.Leader, member.ClientId);
  end;
end;

procedure TBaseMob.SendParty(leader, member: WORD);
var packet: TSendPartyMember;
other : TBaseMob;
begin
  if not(self.IsPlayer) then exit;

  if not(GetMob(member, other)) then
    exit;

  packet.Header.Size := sizeof(TSendPartyMember);
  packet.Header.Code := $37D;
  packet.Header.Index := $7530;
  packet.unk2 := 52428;
  packet.LiderID := leader;
  packet.ClientId := member;

  packet.Level:= other.Character.CurrentScore.Level;
  packet.MaxHp:= other.Character.CurrentScore.MaxHP;
  packet.CurHp:= other.Character.CurrentScore.CurHP;
  Move(other.Character.Name[0],packet.Nick[0],16);

  SendPacket(@packet,packet.Header.Size);
end;

procedure TBaseMob.SendSignal(pIndex, opCode: WORD);
begin
  Server.SendSignalTo(ClientId, pIndex, opCode);
end;

procedure TBaseMob.SendSignal(headerClientId, packetCode: WORD; data: Integer);
var signal : TSignalData;
begin
  ZeroMemory(@signal, sizeof(TSignalData));
  signal.Header.Size := 16;
  signal.Header.Index := headerClientId;
  signal.Header.Code := packetCode;
  signal.Data := data;

  SendPacket(@signal, signal.Header.Size);
end;

procedure TBaseMob.SendSignal2(headerClientId, packetCode: WORD; data, data2: Integer);
var signal : TSignalData2;
begin
  ZeroMemory(@signal, sizeof(TSignalData2));
  signal.Header.Size := 20;
  signal.Header.Index := headerClientId;
  signal.Header.Code := packetCode;
  signal.Data := data;
  signal.Data2 := data2;

  SendPacket(@signal, signal.Header.Size);
end;

procedure TBaseMob.SendToVisible(packet : pointer; size : WORD; sendToSelf : Boolean);
var
  mobId: WORD;
  player: TPlayer;
begin
  sendToSelf := IfThen(sendToSelf, IsPlayer, false);

  if(sendToSelf) then
    SendPacket(packet, size);

  for mobId in VisibleMobs do
  begin
    if(TPlayer.GetPlayer(mobId, player)) then
    begin
      player.SendPacket(packet, size);

      if (TPacketHeader(packet^).Code = $165) then
        player.VisibleMobs.Remove(self.ClientId);
    end;
  end;
end;

procedure TBaseMob.SendRemoveMob(delType: integer = DELETE_NORMAL; sendTo : WORD = 0);
var packet: TSignalData;
  i: WORD;
begin
  packet.Header.Size := sizeof(TSignalData);
  packet.Header.Code := $165;
  packet.Header.Index := self.ClientId;

  packet.Data := delType;
  if(sendTo = 0) then
    SendToVisible(@packet, packet.Header.Size)
  else
    Server.SendPacketTo(sendTo, @packet, packet.Header.Size);
end;

procedure TBaseMob.SendMobDead(killer: TBaseMob);
var packet: TSendMobDeadPacket; exp : Cardinal;
begin
  if(self.IsPlayer and killer.IsPlayer) then
  begin
    if not(TPlayer.Players[ClientId].PlayerCharacter.PlayerKill) then //0 = false
    begin
      if(TPlayer.Players[ClientId].PlayerCharacter.CP > -25)
        and (TPlayer.Players[ClientId].PlayerCharacter.CP < 50) then
        dec(TPlayer.Players[killer.ClientId].PlayerCharacter.CP, 2)
      else
      if(TPlayer.Players[ClientId].PlayerCharacter.CP >= 50) then
        dec(TPlayer.Players[killer.ClientId].PlayerCharacter.CP, 3)
      else
        dec(TPlayer.Players[killer.ClientId].PlayerCharacter.CP, 1);
    end;
  end;

  Target := nil;

  packet.Header.Size := sizeof(TSendMobDeadPacket);
  packet.Header.Code := $338;
  packet.Header.Index := $7530;

  packet.Hold := killer.Character.ChaosPoint;
  packet.Killer := killer.ClientId;
  packet.Killed := ClientId;

  if not(self.IsPlayer) then
  begin
    exp := CalcExp(Character.Exp ,killer.Character.CurrentScore.Level, self.Character.CurrentScore.Level);
    packet.Exp := killer.Character.Exp + exp;
    TNPC.NPCs[ClientId].TimeKill := Now;
    MobGrid[CurrentPosition.Y][CurrentPosition.X] := 0;
    killer.VisibleMobs.Remove(self.ClientId);
  end
  else
    packet.Exp := 0;

  Character.CurrentScore.CurHP := 0; // Provavelmente já está zerado, mas vamos garantir

  SendToVisible(@packet, packet.Header.Size, true);
  killer.AddExp(exp, 1);
  SendRemoveMob(DELETE_DEAD);

  //finalmente apos enviar pra todos posso limpar o visible list
  if not(self.IsPlayer) then
    VisibleMobs.Clear;
end;

function TBaseMob.AddAffect(affect: TAffect): Boolean;
var affectSlot: Byte;
  emptySlot: Int8;
begin
  emptySlot := -1;
  result := false;
  for affectSlot := 0 to MAXBUFFS do
  begin
    if(Character.Affects[affectSlot].Index = affect.Index) then
    begin
      Character.Affects[affectSlot] := affect;
      exit;
    end
    else if (emptySlot = -1) AND (Character.Affects[affectSlot].Index = 0) then
    begin
      emptySlot := affectSlot;
    end;
  end;
  if emptySlot > -1 then
  begin
    Character.Affects[emptySlot] := affect;
    result := true;
  end;
end;

function TBaseMob.AddAffect(affect: TAffect; acumula: Boolean): Boolean;
var affectSlot: Byte;
  emptySlot: Int8;
begin
  emptySlot := -1;
  result := false;
  for affectSlot := 0 to MAXBUFFS do
  begin
    if(Character.Affects[affectSlot].Index = affect.Index) then
    begin
      if acumula then
        inc(Character.Affects[affectSlot].Time,affect.Time)
      else
        Character.Affects[affectSlot] := affect;
      exit;
    end
    else if (emptySlot = -1) AND (Character.Affects[affectSlot].Index = 0) then
    begin
      emptySlot := affectSlot;
    end;
  end;
  if emptySlot > -1 then
  begin
    Character.Affects[emptySlot] := affect;
    result := true;
  end;
end;

function TBaseMob.FindAffect(Index: BYTE): Byte;
var affectSlot: Byte;
begin
  result := 255;
  for affectSlot := 0 to MAXBUFFS do
  begin
    if(Character.Affects[affectSlot].Index = Index) then
    begin
      result := affectSlot;
      exit;
    end;
  end;
end;

procedure TBaseMob.CalcAtackSpeed;
begin
  AttackSpeed := 100 + (Character.CurrentScore.DEX div 5) + GetMobAbility(EF_ATTSPEED);
  AttackSpeed := IfThen(AttackSpeed > 300, 300, AttackSpeed);
end;

function TBaseMob.CalcExp(expbase: Cardinal; attackerLevel, targetLevel : WORD): Integer;
var multiexp: integer;
begin
  inc(attackerLevel);
  inc(targetLevel);

  multiexp := (targetLevel * 100) div attackerLevel;
  if(multiexp < 80) and (attackerLevel >= 50) then
    multiexp := (multiexp * 2) - 100
  else if(multiexp > 200) then multiexp := 200;

  if(multiexp < 0) then
    multiexp := 0;

  case self.Character.Equip[13].Index of
    3900, //
    3903, //
    3906, // Fadas Verdes
    3911, //
    3912, //
    3913, //
    3902, //

    3905, // Fadas Vermelhas
    3908, //

    3914: // Fada Prateada
      expbase := expbase + ((expbase * 16) div 100);

    3915: // Fada Dourada
      expbase := expbase + ((expbase * 18) div 100);
  end;

  expbase:= IfThen(FindAffect(39) <> 255, expbase*2, expbase);

  result := expbase * multiexp div 100;
end;

procedure TBaseMob.AddExp(exp: Cardinal; partyMultiplier: Real);
var levels : WORD;
  party: PParty;
  player : TPlayer;
  member: TBaseMob;
  i: Word;
  initExp: Cardinal;
  nextLevelExp: Cardinal;
  expToRegen : array[1..3] of Cardinal;
begin
  initExp := Character.Exp;
  nextLevelExp := exp_Mortal_Arch[Character.BaseScore.Level] - exp_Mortal_Arch[Character.BaseScore.Level - 1];
  expToRegen[1] := Round(1 * nextLevelExp / 4) + exp_Mortal_Arch[Character.BaseScore.Level - 1];
  expToRegen[2] := Round(2 * nextLevelExp / 4) + exp_Mortal_Arch[Character.BaseScore.Level - 1];
  expToRegen[3] := Round(3 * nextLevelExp / 4) + exp_Mortal_Arch[Character.BaseScore.Level - 1];

  if(Character.Exp + exp > 4100000000) then
  begin
    Character.Exp := 4100000000;
    exp := Character.Exp - initExp;
  end
  else
    Inc(Character.Exp, exp);


  levels := 0;
  while(Character.Exp >= exp_Mortal_Arch[Character.BaseScore.Level + levels]) do
  begin
    Inc(levels);
  end;

  if(levels > 0) then
  begin
    Inc(Character.BaseScore.Level, levels);

    Inc(Character.pStatus, 5 * levels);
    Inc(Character.pSkill, 3 * levels);
    Inc(Character.pMaster, 3 * levels);

    SendScore;
  end;

  if (levels > 0) OR
    ((initExp < expToRegen[1]) AND (Character.Exp >= expToRegen[1])) OR
    ((initExp < expToRegen[2]) AND (Character.Exp >= expToRegen[2])) OR
    ((initExp < expToRegen[3]) AND (Character.Exp >= expToRegen[3])) then
  begin
    Character.BaseScore.CurHP := Character.BaseScore.MaxHP;
    Character.BaseScore.CurMP := Character.BaseScore.MaxMP;

    Character.CurrentScore.CurHP := Character.CurrentScore.MaxHP;
    Character.CurrentScore.CurMP := Character.CurrentScore.MaxMP;
    SendCurrentHPMP;
  end;

  if(IsPlayer) then
  begin
    player := TPlayer.Players[ClientId];
    player.SendEtc;

    if (levels > 0) then
    begin
      player.SendClientMessage('+ + +   Subiu de nível   + + +');
      player.SendEmotion(14, 1);
      player.SendEmotion(100, 0);
    end;

    if(partyMultiplier <> 0) AND (player.PartyId <> 0) then
    begin
      party := @Parties[player.PartyId];
      if (player.GetMob(party.Leader, member)) and (party.Leader <> player.ClientId) and ((member.Character.Equip[0].Effects[1].Index <> 98) or (member.Character.Equip[0].Effects[1].Value < 2))then
      begin
        member.AddExp(Round(exp * partyMultiplier), 0);
      end;

      for i in party^.Members do
      begin
        if (player.GetMob(i, member)) and (i <> player.ClientId) and ((member.Character.Equip[0].Effects[1].Index <> 98) or (member.Character.Equip[0].Effects[1].Value < 2))then
        begin
          member.AddExp(Round(exp * partyMultiplier), 0);
        end;
      end;
    end;
  end;
end;

procedure TBaseMob.AddToEnemyList(target: TBaseMob);
begin
  self.Target := target;
end;

procedure TBaseMob.AddToVisible(var mob: TBaseMob; revive: boolean = false);
begin
  if not(VisibleMobs.Contains(mob.ClientId)) then
  begin
      VisibleMobs.Add(mob.ClientId);
      if(self.IsPlayer) then
        mob.SendCreateMob(ifThen(revive, SPAWN_TELEPORT, SPAWN_NORMAL), self.ClientId);
  end;

  if not(mob.VisibleMobs.Contains(self.ClientId)) then
  begin
      mob.VisibleMobs.Add(self.ClientId);
      if(mob.IsPlayer) then
        self.SendCreateMob(ifThen(revive, SPAWN_TELEPORT, SPAWN_NORMAL), mob.ClientId);
  end;
{
  if(self.IsPlayer) then
  begin
    if not(VisibleMobs.Contains(mob.ClientId)) then
    begin
      VisibleMobs.Add(mob.ClientId);
      mob.AddToVisible(self);
      if(sendCreateMob) then
        mob.SendCreateMob(SPAWN_NORMAL, self.ClientId);
    end;
  end
  else
    if(mob.IsPlayer) then
    begin
      VisibleMobs.Add(mob.ClientId);
      if not(mob.VisibleMobs.Contains(self.ClientId)) then
        mob.VisibleMobs.Add(self.ClientId);
    end;
}
end;

procedure TBaseMob.RemoveFromVisible(mob : TBaseMob);
begin
  VisibleMobs.Remove(mob.ClientId);
  if (self.IsPlayer) then
    mob.SendRemoveMob(0, self.ClientId);

  mob.VisibleMobs.Remove(self.ClientId);
  if(mob.IsPlayer) then
    self.SendRemoveMob(0, mob.ClientId);

  if (Target <> NIL) AND (Target.ClientId = mob.ClientId) then
    Target := NIL;

  if (mob.Target <> NIL) AND (mob.Target.ClientId = self.ClientId) then
    mob.Target := NIL;

{
  VisibleMobs.Remove(mob.ClientId);
  if(self.IsPlayer) then
    mob.SendRemoveMob(0, self.ClientId);

  if(mob.VisibleMobs.Contains(self.ClientId)) then
    mob.RemoveFromVisible(self);

  if (Target <> NIL) AND (Target.ClientId = mob.ClientId) then
    Target := NIL;
}
end;

procedure TBaseMob.RemoveItem(slot, slotType: BYTE);
var item: PItem;
begin
  if(slot < 0) then exit;
  TItemFunctions.GetItem(item, self, slot, slotType);
  if(item <> nil) then
    ZeroMemory(item, sizeof(TItem));
end;

procedure TBaseMob.UpdateVisibleList(removeNotRange : boolean = true; addNewRange : boolean = true);
var mob : TBaseMob;
  i: WORD;
begin
  IsDirty := false;
  if(VisibleMobs.Count > 0) then // Talvez possamos remover essa verificação
  begin
    for i in VisibleMobs do
    begin
      if(GetMob(i, mob) = false) then
      begin
        VisibleMobs.Remove(i);
        continue;
      end;

      if (not(CurrentPosition.InRange(mob.CurrentPosition, DISTANCE_TO_FORGET)) and (removeNotRange)) then
        RemoveFromVisible(mob);
    end;
  end;

  if (addNewRange) then
  begin
    self.ForEachInRange(DISTANCE_TO_WATCH, procedure(p: TPosition; me, m: TBaseMob)
    begin
      if me.VisibleMobs.Contains(m.ClientId) then
        exit;
      me.AddToVisible(m);
    end);
  end;
end;

procedure TBaseMob.UsedSkill(skillId: Byte);
begin
  if _cooldown.ContainsKey(skillId) then
    _cooldown[skillId] := Now
  else
    _cooldown.Add(skillId, Now);
end;

procedure TBaseMob.SendAffects;
var packet : TSendAffectsPacket;
  i : Integer;
begin
  ZeroMemory(@packet, sizeof(TSendAffectsPacket));

  packet.Header.Code := $3B9;
	packet.Header.Size := sizeof(TSendAffectsPacket);
	packet.Header.Index := ClientId;
	for i := 0 to MAXBUFFS - 1 do
	begin
    if(Character.Affects[i].Time >= 0) and (Character.Affects[i].Index <> 0) then
      Move(Character.Affects[i], packet.Affects[i], sizeof(TAffect));
	end;
	SendPacket(@packet, packet.Header.Size);
end;

procedure TBaseMob.SendEtc;
var packet: TRefreshEtcPacket;
begin
  ZeroMemory(@packet, sizeof(TRefreshEtcPacket));

  packet.Header.Size := sizeof(TRefreshEtcPacket);
	packet.Header.Code := $337;
	packet.Header.Index := ClientId;

	packet.hold := Character.ChaosPoint;
	packet.exp := Character.Exp;
	packet.learn := Character.Learn;
  packet.Gold:= Character.Gold;
	packet.StatusPoint := Character.pStatus;
	packet.MasterPoint := Character.pMaster;
	packet.SkillsPoint := Character.pSkill;
	packet.MagicIncrement := Character.MagicIncrement;

  SendPacket(@packet, packet.Header.Size);
end;

procedure TBaseMob.SendChat(str: AnsiString);
var packet: TChatPacket;
begin
  ZeroMemory(@packet, sizeof(TChatPacket));
  packet.Header.Size := sizeof(TChatPacket);
  packet.Header.Code := $333;
  packet.Header.Index := ClientId;
  StrPLCopy(packet.Chat, str, 95);
  SendToVisible(@packet, packet.Header.Size, true);
end;

procedure TBaseMob.SendEquipItems(sendSelf : Boolean = True);
var packet: TRefreshEquips; x: BYTE; sItem: TItem;
effValue : BYTE;
begin

  packet.Header.Size  := sizeof(TRefreshEquips);
  packet.Header.Code  := $36B;
  packet.Header.Index := self.ClientId;

  for x := 0 to 15 do
  begin
    Move(Character.Equip[x],sItem,8);

    if(x = 14)then
        if(sItem.Index >= 2360) and (sItem.Index <= 2389)then
            if(sItem.Effects[0].Index = 0)then
                sItem.Index := 0;

    effValue := TItemFunctions.GetSanc(sItem);
    packet.itemIDEF[x] := sItem.Index;
    packet.Sanc[x]     := effValue;

    packet.pAnctCode[x] := TItemFunctions.GetAnctCode(sItem);
  end;

  SendToVisible(@packet, packet.Header.Size, sendSelf);
end;

procedure TBaseMob.SendCreateMob(spawnType : WORD = SPAWN_NORMAL; sendTo : WORD = 0);
var player : TPlayer;
    packet : TSendCreateMobPacket;
    tradePacket : TSendCreateMobTradePacket;
begin
  if(TPlayer.GetPlayer(ClientId, player)) AND (player.PlayerCharacter.IsStoreOpened) then
  begin
    player.GetCreateMobTrade(tradePacket);
    tradePacket.spawnType := spawnType;
    if(sendTo > 0) then
      Server.SendPacketTo(sendTo, @tradePacket, tradePacket.Header.Size)
    else
      SendToVisible(@tradePacket, tradePacket.Header.Size, true);
    exit;
  end
  else if Character.CurrentScore.CurHp <= 0 then
    exit;

  GetCreateMob(packet);
  packet.SpawnType := spawnType;
  if(sendTo > 0) then
    Server.SendPacketTo(sendTo, @packet, packet.Header.Size)
  else
    SendToVisible(@packet, packet.Header.Size);
end;

procedure TBaseMob.SendEmotion(effType, effValue: smallint);
var packet: TSendEmotionPacket;
begin
  packet.Header.Size := sizeof(TSendEmotionPacket);
  packet.Header.Code := $36A;
  packet.Header.Index := ClientId;

  packet.effType := effType;
  packet.effValue := effValue;
  packet.Unknown1 := 0;

  SendToVisible(@packet, packet.Header.Size);
end;

procedure TBaseMob.SendScore;
var packet : TSendScorePacket;
    i : Byte;
begin
  ZeroMemory(@packet, sizeof(TSendScorePacket));

  packet.Header.Size := sizeof(TSendScorePacket);
  packet.Header.Code := $336;
  packet.Header.Index := ClientId;

  GetCurrentScore;

  packet.Critical := Trunc((Character.Critical/10)*5);
  packet.SaveMana := Character.SaveMana;
  packet.GuildIndex := Character.GuildIndex;
  packet.GuildMemberType := Character.GuildMemberType;
  packet.CurHP := Character.CurrentScore.CurHP;
  packet.CurMP := Character.CurrentScore.CurMP;

  packet.RegenHP := Character.RegenHP;
	packet.RegenMP := Character.RegenMP;
  packet.MagicIncrement := Character.MagicIncrement;

  for i := 0 to 3 do
  begin
    packet.Resist[i] := Character.Resist[i];
  end;
  packet.Score := Character.CurrentScore;

  //Character.Affects[0].Index := 102;
  //Character.Affects[0].Time := 100;

  for i := 0 to MAXBUFFS - 1 do begin
    packet.Affects[i].Index := Character.Affects[i].Index;
    packet.Affects[i].Time := Character.Affects[i].Time;
  end;
  SendToVisible(@packet, packet.Header.Size);
  SendEtc;
end;

procedure TBaseMob.SendCurrentHPMP;
var packet: TSendCurrentHPMPPacket;
begin
  ZeroMemory(@packet, sizeof(TSendCurrentHPMPPacket));

	packet.Header.Size := sizeof(TSendCurrentHPMPPacket);
	packet.Header.Code := $181;
	packet.Header.Index := ClientId;

  packet.CurHP := Character.CurrentScore.CurHP;
	packet.MaxHP := {Character.CurrentScore.CurHP;//}Character.CurrentScore.MaxHP;
	packet.CurMP := Character.CurrentScore.CurMP;
	packet.MaxMP := {Character.CurrentScore.CurMP;//}Character.CurrentScore.MaxMP;

  SendToVisible(@packet, packet.Header.Size);
end;

procedure TBaseMob.ApplyDamage(attacker: TBaseMob; damage: Integer);
var i: Integer;
  sId: Byte;
  mana: Boolean;
  cur: Integer;
  Item: TItemList;
  montaria: WORD;
  damageMontaria: Integer;
  vidaMontaria : Integer;
begin
  mana := false;
  for i := 0 to 14 do
  begin
    if (Character.Affects[i].Index = FM_CONTROLE_MANA) then
    begin
      mana := true;
      sId := i;
      break;
    end;
  end;

  montaria := Character.Equip[Integer(TEquipSlot.Mount)].Index;
	if (self.IsPlayer) and (montaria >= 2360) and (montaria < 2390) and (Character.Equip[Integer(TEquipSlot.Mount)].Effects[0].Value > 0) then
  begin
	  damageMontaria := ((damage * 3) shr 2);
    if (damageMontaria <= 0) then
      damageMontaria := 1;

    if (damageMontaria div 256) > 0 then
    begin
      Dec(Character.Equip[Integer(TEquipSlot.Mount)].Effects[0].Value, (damageMontaria div 256));
      damageMontaria := damageMontaria - ((damageMontaria div 256) * 256);
    end;

    vidaMontaria := Character.Equip[Integer(TEquipSlot.Mount)].Effects[0].Index;
    if (vidaMontaria - damageMontaria < 0) then
    begin
      Character.Equip[Integer(TEquipSlot.Mount)].Effects[0].Index := (vidaMontaria + 256) - damageMontaria;
      Dec(Character.Equip[Integer(TEquipSlot.Mount)].Effects[0].Value, 1);
    end
    else
      Dec(Character.Equip[Integer(TEquipSlot.Mount)].Effects[0].Index, damageMontaria);

    TPlayer.GetPlayer(self.ClientId).SendItem(EQUIP_TYPE, Integer(TEquipSlot.Mount));
  end;

  cur := IfThen(mana, Character.CurrentScore.CurMP, Character.CurrentScore.CurHP);
  Dec(cur, (damage - damageMontaria));

  if mana then
  begin
    Character.CurrentScore.CurMP := IfThen(cur < 0, 0, cur);
    if(cur <= 0) then
    begin
      ZeroMemory(@Character.Affects[sId], SizeOf(TAffect));
      Character.CurrentScore.CurHP := Character.CurrentScore.CurHP + cur;
    end;
  end
  else
  begin
    cur := IfThen(cur < 0, 0, cur);
    Character.CurrentScore.CurHP := cur;
  end;

  self.SendScore;

  if(Character.CurrentScore.CurHP <= 0) then
    SendMobDead(attacker);
end;

procedure TBaseMob.GetMobMotion(var packet: TProcessAttackOneMob);
var
  _rand : BYTE;
  special, special2 : smallint;
  skillb3: BYTE;
  insttype: integer;
  leader: WORD;
  hp: Word;
  lhp: Word;
  leaderMob: TBaseMob;
  _mob: Word;
  Resist: Word;
begin
  if (self.CurrentPosition.Distance(target.CurrentPosition) >= 3) then
  begin
    special  := (*pMob[mob].MOB.BaseScore.Special[2]*)self.Character.SkillBar1[2];
    special2 := (*pMob[mob].MOB.BaseScore.Special[3]*)self.Character.SkillBar1[3];
  end
  else
  begin
    special  := (*pMob[mob].MOB.BaseScore.Special[0]*)self.Character.SkillBar1[0];
    special2 := (*pMob[mob].MOB.BaseScore.Special[1]*)self.Character.SkillBar1[1];
  end;

  packet.Motion := 0;

  if (special = 255) then
    special := -1;

  case (special) of
  121:
    begin
      packet.SkillIndex := 103;
      packet.SkillParm := 5;
    end;
  122:
    begin
      packet.SkillIndex := 105;
      packet.SkillParm := 1;
    end;
  123:
    begin
      packet.SkillIndex := 101;
      packet.SkillParm := 1;
    end;
  124:
    begin
      packet.SkillIndex := 101;
      packet.SkillParm := 2;
    end;
  125:
    begin
      packet.SkillIndex := 40;
      packet.SkillParm := 1;
    end;
  126:
    begin
      packet.SkillIndex := 40;
      packet.SkillParm := 2;
    end;
  127:
    begin
      packet.SkillIndex := 40;
      packet.SkillParm := 3;
    end;
  128:
    begin
      packet.SkillIndex := 33;
      packet.SkillParm := -4;
      packet.Motion := -4;
    end;
  else
    begin
      packet.SkillIndex := special;
      packet.SkillParm := 1;
    end;
  end;
  if (special2 <> 0) then
  begin
    packet.Motion := 4;
    _rand := Random(4);

    case (special2) of
    3:
      begin
        if (_rand <= 1) then
          inc(packet.Motion);
      end;
    6:
      begin
        if (_rand > 1) then
          inc(packet.Motion, 2)
        else
          inc(packet.Motion);
      end;
    7:
      begin
      if (_rand = 1) then
        inc(packet.Motion)
      else
        inc(packet.Motion, 2);
      end;
    15:
      begin
        case (_rand) of
          1: inc(packet.Motion);
          2: inc(packet.Motion, 2);
          3: inc(packet.Motion, 3);
        end;
      end;
    24:
      begin
        if (_rand > 1) then
          inc(packet.Motion, 4)
        else
          inc(packet.Motion, 3);
      end;
    27:
      begin
        case (_rand) of
          1: inc(packet.Motion);
          2: inc(packet.Motion, 3);
          3: inc(packet.Motion, 4);
        end
      end;
    23:
      begin
        case (_rand) of
          1: inc(packet.Motion);
          2: inc(packet.Motion, 2);
          3: inc(packet.Motion, 4);
        end;
      end;
    else
      packet.SkillParm := 1;
    end;
  end;
  _rand := Random(100);
  if (self.Character.SkillBar1[3] <> -1) and ((_rand >= 25) and (_rand <= 64))then
  begin
    skillb3 := self.Character.SkillBar1[3];

    insttype := SkillsData[skillb3].InstanceType;

    leader := TNpc(self).MobLeaderId;
    if (leader <= 0) then
      leader := self.ClientId;

    hp := self.Character.CurrentScore.CurHP;
    hp := hp * 10;
    hp := Trunc(hp/(self.Character.CurrentScore.MaxHP+1));

    TBaseMob.GetMob(leader, leaderMob);
    lhp := leaderMob.Character.CurrentScore.CurHP;
    lhp := lhp * 10;
    lhp := Trunc(lhp/(leaderMob.Character.CurrentScore.MaxHP+1));

    if (insttype = 6) then
    begin
      if (hp <= 8) or (lhp <= 8) then
      begin
        _mob := 0;

        packet.SkillIndex := insttype;

        _mob := self.ClientId;
        if (hp > lhp) then
          _mob := leader;

        TBaseMob.GetMob(_mob, leaderMob);
        packet.Target.Index  := _mob;
        packet.Target.Damage := Trunc(leaderMob.Character.CurrentScore.MaxHp / 10);
      end;
    end;
  end;
  if (self.Character.SkillBar1[0] = -1) or (_rand < 0) or (_rand > 49) then
  begin
    if (self.Character.SkillBar1[1] = -1) or (_rand < 50) or (_rand > 84) then
    begin
      if (self.Character.SkillBar1[2] <> -1) and (_rand >= 85) and (_rand <= 99) then
      begin
        Resist := SkillsData[self.Character.SkillBar1[2]].InstanceType - 2;
        packet.SkillIndex := self.Character.SkillBar1[2];
      end;
    end
    else
    begin
      Resist := SkillsData[self.Character.SkillBar1[1]].InstanceType - 2;
      packet.SkillIndex := self.Character.SkillBar1[1];
    end;
  end
  else
  begin
    Resist := SkillsData[self.Character.SkillBar1[0]].InstanceType - 2;
    packet.SkillIndex := self.Character.SkillBar1[0];
  end;
end;

procedure TBaseMob.SendDamage(target: TBaseMob; skillId: ShortInt; damage: Integer = -1);
var packet: TProcessAttackOneMob;
  wRange: integer;
begin
  ZeroMemory(@packet, sizeof(TProcessAttackOneMob));
//  SendAffects;

  packet.Header.Size := sizeof(TProcessAttackOneMob);
  packet.Header.Index := ClientId;
  packet.Header.Code := $39D;

  packet.CurrentMp := Character.CurrentScore.CurMP;
  packet.CurrentExp := Character.Exp;
  packet.Motion := Random(3) + 4;

  packet.AttackerID := ClientId;
  packet.AttackCount := 1;
  packet.AttackerPos := CurrentPosition;

  packet.Target.Index := target.ClientId;
  packet.TargetPos := target.CurrentPosition;

//  packet.Hold := Character.ChaosPoint;
  packet.SkillIndex := skillId;
  if not(self.IsPlayer) then
    GetMobMotion(packet)
  else
  begin
    If (packet.SkillIndex > -1) and not(skillId in [151, 153]) then
      packet.ReqMp := SkillsData[skillId].ManaSpent
    else
      packet.ReqMp := 0;
  end;

  damage := IfThen(damage = -1, GetDamage(target, 1), damage);
  packet.Target.Damage := IfThen(damage <= 0, -3, damage); // MMMJR

  target.SendToVisible(@packet, packet.Header.Size);
  target.ApplyDamage(self, damage);

  DeterminMoveDirection(packet.TargetPos);
end;

procedure TBaseMob.SendDamage(targets: TList<WORD>; skillId: ShortInt; damage: Integer);
var packet: TProcessAoEAttack;
  wRange: integer;
  target: TBaseMob;
  targetCount: Byte;
  targetId: WORD;
  I: Integer;
begin
  ZeroMemory(@packet, sizeof(TProcessAoEAttack));
//  SendAffects;

  packet.Header.Size := sizeof(TProcessAoEAttack);
  packet.Header.Index := ClientId;
  packet.Header.Code := $36C;

  packet.CurrentMp := Character.CurrentScore.CurMP;
  packet.CurrentExp := Character.Exp;
  packet.Motion := 5;

  packet.AttackerID := ClientId;
  packet.AttackCount := 1;
  packet.AttackerPos := CurrentPosition;
  packet.TargetPos := CurrentPosition;

//  packet.Hold := Character.ChaosPoint;

  packet.SkillIndex := skillId;
//  if not(self.IsPlayer) then
//    GetMobMotion(packet)
//  else

  If (packet.SkillIndex > -1) then
    packet.ReqMp := SkillsData[skillId].ManaSpent
  else
    packet.ReqMp := 0;

  targetCount := 0;
  for targetId in targets do
  begin
    if not(GetMob(targetId, target)) then
      continue;

    packet.Targets[targetCount].Index := targetId;
    damage := IfThen(damage = -1, GetDamage(target, 1), damage);
    packet.Targets[targetCount].Damage := IfThen(damage <= 0, -3, damage); // MMMJR
    Inc(targetCount);
  end;

  SendToVisible(@packet, packet.Header.Size);

  for i := 0 to targetCount do
  begin
    targetId := packet.Targets[i].Index;
    if not(GetMob(targetId, target)) then
      continue;

    damage := IfThen(damage = -1, GetDamage(target, 1), damage);
    target.ApplyDamage(self, damage);
  end;

  DeterminMoveDirection(packet.TargetPos);
end;

function TBaseMob.GetItemAmount(itemId: Integer; inv: array of TItem): TItemAmount;
var slot: Integer;
begin
  ZeroMemory(@Result, sizeof(TItemAmount));
  if(itemId < 0) OR (itemId > ItemList.Count) then
    exit;

  Result.ItemId := itemId;
  for slot := 0 to Length(inv) do
  begin
    if(inv[slot].Index = itemId) then
    begin
      Result.Slots[Result.SlotsCount] := slot;
      Inc(Result.SlotsCount);
      Inc(Result.Amount, TItemFunctions.GetItemAmount(inv[slot]));
    end;
  end;
end;

function TBaseMob.GetMaxAbility(eff: integer): integer;
var MaxAbility,i: integer;
ItemAbility: smallint;
begin
  MaxAbility:=0;
  for i := 0 to 15 do begin
    if(Character.Equip[i].Index = 0) then
      continue;

    if(i = Integer(TEquipSlot.Mount)) and (Character.Equip[i].Effects[0].Value = 0) then
      continue;

    ItemAbility:= TItemFunctions.GetItemAbility(Character.Equip[i], eff);
    if(MaxAbility < ItemAbility) then
      MaxAbility := ItemAbility;
  end;
  result:=MaxAbility;
end;

class function TBaseMob.GetMob(index: WORD; out mob: TBaseMob): boolean;
begin
  result := false;
  if(index = 0) OR (index > MAX_SPAWN_ID) then
  begin
    exit;
  end;

  if(index <= MAX_CONNECTIONS) then
    mob := TPlayer.Players[index]
  else
    mob := TNPC.NPCs[index];

  if (mob = nil) then
    exit;

  result := Assigned(mob);
end;


class function TBaseMob.GetMob(pos: TPosition; out mob: TBaseMob): boolean;
begin
  Result := GetMob(MobGrid[pos.Y][pos.X], mob);
end;

function TBaseMob.GetMobAbility(eff: integer) : integer;
var LOCAL_1,LOCAL_2,LOCAL_19,LOCAL_20,dam1,dam2,arm1,arm2,unique1:integer;
porc,unique2,LOCAL_28: integer;
LOCAL_18: array[0..15] of integer;
begin
  LOCAL_1:=0;
  if(eff = EF_RANGE) then
  begin
    LOCAL_1 := GetMaxAbility(eff);

    LOCAL_2 := Trunc((Character.Equip[0].Index / 10));
    if(LOCAL_1 < 2) and (LOCAL_2 = 3) then
        if((Character.Learn and $100000) <> 0) then
            LOCAL_1 := 2;

    result:=LOCAL_1;
    exit;
  end;

  for LOCAL_19 := 0 to 15 do
  begin
      LOCAL_18[LOCAL_19] := 0;

      LOCAL_20 := Character.Equip[LOCAL_19].Index;
      if(LOCAL_20 = 0) and (LOCAL_19 <> 7) then
          continue;

      if(LOCAL_19 >= 1) and (LOCAL_19 <= 5) then
          LOCAL_18[LOCAL_19] := ItemList[LOCAL_20].Unique;

      if(eff = EF_DAMAGE) and (LOCAL_19 = 6) then
          continue;

      if(eff = EF_MAGIC) and (LOCAL_19 = 7) then
          continue;

      if(LOCAL_19 = 7) and (eff = EF_DAMAGE) then
      begin
        dam1 := (TItemFunctions.GetItemAbility(Character.Equip[6], EF_DAMAGE) +
                    TItemFunctions.GetItemAbility(Character.Equip[6], EF_DAMAGE2));
        dam2 := (TItemFunctions.GetItemAbility(Character.Equip[7], EF_DAMAGE) +
                    TItemFunctions.GetItemAbility(Character.Equip[7], EF_DAMAGE2));

        arm1 := Character.Equip[6].Index;
        arm2 := Character.Equip[7].Index;

        unique1 := 0;
        if(arm1 > 0) and (arm1 < 6500) then
            unique1 := ItemList[arm1].Unique;

        unique2 := 0;
        if(arm2 > 0) and (arm2 < 6500) then
            unique2 := ItemList[arm2].Unique;

        if(unique1 <> 0) and (unique2 <> 0) then
        begin
          if(unique1 = unique2) then
              porc := 30
          else
              porc := 20;

          if(dam1 > dam2) then
              LOCAL_1 := Trunc(((LOCAL_1 + dam1) + ((dam2 * porc) / 100)))
          else
              LOCAL_1 := Trunc(((LOCAL_1 + dam2) + ((dam1 * porc) / 100)));

          continue;
        end;

        if(dam1 > dam2) then
            inc(LOCAL_1,dam1)
        else
            inc(LOCAL_1,dam2);

        continue;
      end;

      LOCAL_28 := TItemFunctions.GetItemAbility(Character.Equip[LOCAL_19], eff);
      if(eff = EF_ATTSPEED) and (LOCAL_28 = 1) then
          LOCAL_28 := 10;

      inc(LOCAL_1,LOCAL_28);
    end;

    if(eff = EF_AC) and (LOCAL_18[1] <> 0) then
        if(LOCAL_18[1] = LOCAL_18[2]) and (LOCAL_18[2] = LOCAL_18[3]) and
           (LOCAL_18[3] = LOCAL_18[4]) and (LOCAL_18[4] = LOCAL_18[5]) then
            LOCAL_1 := Trunc(((LOCAL_1 * 105) / 100));

    result := LOCAL_1;
end;

function TBaseMob.InBattle: boolean;
begin
  Result := IfThen(Target <> nil);
end;

function TBaseMob.IsDead: boolean;
begin
  Result := IfThen(Character.CurrentScore.CurHP <= 0);
end;

function TBaseMob.IsPlayer: boolean;
begin
  Result := IfThen(ClientId <= MAX_CONNECTIONS);
end;

procedure TBaseMob.GetCreateMob(out packet : TSendCreateMobPacket);
var i : Byte;
    item : TItem;
  ChaosPoints: Byte;
  CurrentKill: Byte;
  TotalKill: Word;
begin
  ZeroMemory(@packet, sizeof(TSendCreateMobPacket));

  packet.Header.Size := sizeof(TSendCreateMobPacket);
  packet.Header.Code := $364;
  packet.Header.Index := $7530;

  if Clientid > 750 then
    Move(Character.Name[0], packet.Values[0], 16)
  else
  begin
    ChaosPoints  := 250;//GetGuilty(Clientid);
    CurrentKill  := 100;//GetCurKill(Clientid);
    TotalKill    := 10;//GetTotKill(Clientid);

    Move(Character.Name[0], packet.Values[0], 12);
    Move(ChaosPoints, packet.Values[12], 1);
    Move(CurrentKill, packet.Values[13], 1);
    Move(TotalKill, packet.Values[14], 2);
  end;

  packet.Status := Character.CurrentScore;
  packet.ClientId := Clientid;
  packet.Position := self.Character.Last;
  packet.MemberType := Character.GuildMemberType;
  packet.GuildIndex := Character.GuildIndex;

  for i := 0 to 15 do begin
    packet.Affect[i].Time  := (Character.Affects[i].Time) shr 8;
    packet.Affect[i].Index := Character.Affects[i].Index;
  end;

  for i := 0 to 15 do
  begin
    Move(Character.Equip[i],Item,8);

    if(i = 14)then
        if(Item.Index >= 2360) and (Item.Index <= 2389)then
            if(Item.Effects[0].Value = 0)then
                Item.Index := 0;

    packet.itemEFF[i] := Item.Index;
    packet.Sanc[i]    := TItemFunctions.GetSanc(Item);

    packet.AnctCode[i] := TItemFunctions.GetAnctCode(Item);
  end;

  packet.Tab := 'WYDelphi'
end;

function TBaseMob.GetCurrentHP(): Integer;
var hp_inc,hp_perc: integer;
begin
  hp_inc := GetMobAbility(EF_HP);
  hp_perc := GetMobAbility(EF_HPADD);

  inc(hp_inc, InitialCharacters[Character.ClassInfo].BaseScore.MaxHP);
  inc(hp_inc, (HPIncrementPerLevel[Character.ClassInfo] * Character.BaseScore.Level));
  inc(hp_inc, (Character.CurrentScore.CON shl 1));
  inc(hp_inc, Trunc(((hp_inc * hp_perc) / 100)));

  if(hp_inc > 64000) then //32
      hp_inc := 64000 //32
  else if(hp_inc <= 0) then
      hp_inc := 1;

  result:=hp_inc;
end;

function TBaseMob.GetCurrentMP(): Integer;
var mp_inc,mp_perc: integer;
begin
  mp_inc := GetMobAbility(EF_MP);
  mp_perc := GetMobAbility(EF_MPADD);

  inc(mp_inc, InitialCharacters[Character.ClassInfo].BaseScore.MaxMP);
  inc(mp_inc, (HPIncrementPerLevel[Character.ClassInfo] * Character.BaseScore.Level));
  inc(mp_inc, (Character.CurrentScore.INT shl 1));
  inc(mp_inc, Trunc(((mp_inc * mp_perc) / 100)));

  if(mp_inc > 64000) then //32
      mp_inc := 64000 //32
  else if(mp_inc <= 0) then
      mp_inc := 1;

  result:=mp_inc;
end;

procedure TBaseMob.GetCurrentScore;
var special: array[0..3] of smallInt;
  special_all,resist,magic,atk_inc,def_inc,i,critical,body: integer;
  evasion: WORD;
  moveSpeed: Byte;
begin
  if (ClientId > MAX_CONNECTIONS) then
    exit;

  special_all := GetMobAbility(EF_SPECIALALL);

  special[0] := Character.BaseScore.wMaster + GetMobAbility(EF_SPECIAL1);
  special[1] := Character.BaseScore.fMaster + GetMobAbility(EF_SPECIAL2);
  special[2] := Character.BaseScore.sMaster + GetMobAbility(EF_SPECIAL3);
  special[3] := Character.BaseScore.tMaster + GetMobAbility(EF_SPECIAL4);


  resist := 0;
  if(TItemFunctions.GetSanc(Character.Equip[1]) >= 9) then
    resist := 30;

  Character.Resist[0] := GetMobAbility(EF_RESIST1) + resist + TItemFunctions.GetItemAbility(Character.Equip[14], EF_RESIST1);
  Character.Resist[1] := GetMobAbility(EF_RESIST2) + resist + TItemFunctions.GetItemAbility(Character.Equip[14], EF_RESIST2);
  Character.Resist[2] := GetMobAbility(EF_RESIST3) + resist + TItemFunctions.GetItemAbility(Character.Equip[14], EF_RESIST3);
  Character.Resist[3] := GetMobAbility(EF_RESIST4) + resist + TItemFunctions.GetItemAbility(Character.Equip[14], EF_RESIST4);

  for i := 0 to 3 do
  begin
    Inc(special[i], special_all);
    special[i] := IfThen(special[i] > 255, 255, special[i]);
    Character.Resist[i] := IfThen(Character.Resist[i] > 100, 100, Character.Resist[i]);
  end;

  Character.CurrentScore.wMaster := special[0];
  Character.CurrentScore.fMaster := special[1];
  Character.CurrentScore.sMaster := special[2];
  Character.CurrentScore.tMaster := special[3];

  magic := (GetMobAbility(EF_MAGIC)+TItemFunctions.GetItemAbility(Character.Equip[14], EF_MAGIC) shr 1);
  Character.MagicIncrement := IfThen(magic > 255, 255, magic);

  critical := (GetMobAbility(EF_CRITICAL) div 10) * 5;
  Character.Critical := IfThen(critical > 255, 255, critical);

  Character.RegenHP := GetMobAbility(EF_REGENHP);
  Character.RegenMP := GetMobAbility(EF_REGENMP);
  Character.SaveMana := GetMobAbility(EF_SAVEMANA);

  Character.CurrentScore.STR := Character.BaseScore.STR + GetMobAbility(EF_STR);
  Character.CurrentScore.INT := Character.BaseScore.INT + GetMobAbility(EF_INT);
  Character.CurrentScore.DEX := Character.BaseScore.DEX + GetMobAbility(EF_DEX);
  Character.CurrentScore.CON := Character.BaseScore.CON + GetMobAbility(EF_CON);


  evasion := Character.CurrentScore.DEX+TItemFunctions.GetItemAbility(Character.Equip[14], EF_PARRY) div 60;
  Character.AffectInfo.Evasion := 1;//IfThen(evasion > 15, 15, evasion);
  Character.CurrentScore.MoveSpeed := Character.BaseScore.MoveSpeed;
  Character.CurrentScore.Level := Character.BaseScore.Level;
//  Character.CurrentScore._MerchDir := Character.BaseScore._MerchDir;
  Character.CurrentScore.Merchant := Character.BaseScore.Merchant;
  Character.CurrentScore.Direction := Character.BaseScore.Direction;

  Character.BaseScore.ChaosRate := Character.CurrentScore.ChaosRate;

  moveSpeed := Character.BaseScore.MoveSpeed + GetMaxAbility(EF_RUNSPEED) + Character.AffectInfo.SlowMov;
  Character.AffectInfo.SpeedMov := 0;

  if(Character.Equip[5].Index > 0) then
    Inc(moveSpeed, 1);

  Character.CurrentScore.MoveSpeed := moveSpeed;

  if (Character.CurrentScore.MoveSpeed > 6) then
    Character.CurrentScore.MoveSpeed := 6;

  Character.CurrentScore.maxHP := GetCurrentHP; //+ Character.bStatus.MaxHP;
  Character.CurrentScore.maxMP := GetCurrentMP; //+ Character.bStatus.MaxMP;

  if(Character.CurrentScore.MaxHP < Character.CurrentScore.CurHP) then
      Character.CurrentScore.CurHP := Character.CurrentScore.MaxHP;

  if(Character.CurrentScore.MaxMP < Character.CurrentScore.CurMP) then
      Character.CurrentScore.CurMP := Character.CurrentScore.MaxMP;

  CalcAtackSpeed();

  atk_inc := Character.BaseScore.Attack;
  inc(atk_inc, GetMobAbility(EF_DAMAGE));
  inc(atk_inc, GetMobAbility(EF_DAMAGEADD));
  inc(atk_inc, Trunc(((Character.CurrentScore.STR / 5) * 2)));
  inc(atk_inc, Character.CurrentScore.wMaster);
  inc(atk_inc, Character.CurrentScore.Level);
  inc(atk_inc, TItemFunctions.GetItemAbility(Character.Equip[14], EF_DAMAGE));
  Character.CurrentScore.Attack := atk_inc;

  def_inc := Character.BaseScore.Defense;
  inc(def_inc,GetMobAbility(EF_AC));
  inc(def_inc,GetMobAbility(EF_ACADD));
  inc(def_inc,Trunc((Character.CurrentScore.Level * 2)));
  Character.CurrentScore.Defense := def_inc;

  body := Character.Equip[0].Index;
  body := IfThen(body = 32, 21, body);
  Character.ClassInfo := body div 10;


  // Not Implemented
  {
    Character.CapeInfo := 0;
    Character.GuildIndex := 0;
    Character.AffectInfo := 0;
    Character.GuildMemberType := 0;
  }
  GetAffectScore;
end;

procedure TBaseMob.GetAffectScore;
begin
  BuffsData.GetAffectScore(@Character);
end;

function TBaseMob.GetDamage(target: TBaseMob; master: Byte): smallint;
var resultDamage: Int16;
  masterFactory, randFactory: Integer;
begin
  ResultDamage := Character.CurrentScore.Attack - (target.Character.CurrentScore.Defense shr 1);
  master := master shr 1;
  master := IfThen(master > 7, 7, master);

  masterFactory := 12 - master;
  if(masterFactory <= 0) then
    masterFactory := 2;
//	masterFactory := IfThen(masterFactory <= 0, 2);

	randFactory := (TFunctions.Rand mod masterFactory) + master + 99;

	ResultDamage := (ResultDamage * RandFactory) div 100;
	if (ResultDamage < -50) then
		ResultDamage := 0
	else if (ResultDamage >= -50) AND (ResultDamage < 0) then
		ResultDamage := (ResultDamage + 50) div 7
	else if (ResultDamage >= 0) AND (ResultDamage <= 50) then
		ResultDamage := ((ResultDamage * 5) shr 2) + 7;

  ResultDamage := IfThen(ResultDamage <= 0, 1, ResultDamage);
	Result := ResultDamage;
end;

function TBaseMob.GetEmptySlot: Byte;
var i: BYTE;
begin
  for i := 0 to MAX_INV-1 do
  begin
    if(Character.Inventory[i].Index = 0) then
    begin
      result := i;
      exit;
    end;
  end;
  result := 254;
end;

procedure TBaseMob.GenerateBabyMob;
var
  babyId, babyClientId: WORD;
  party : PParty;
  i, j: Byte;
  pos: TPosition;
begin
  if Character.Equip[14].Index = 0 then
    exit;

  babyId := Character.Equip[14].Index - 2330 + 8;
  if (MobBabyList[babyId].Equip[0].Index = 0) then
    exit;

  babyClientId := TFunctions.GetFreeMob;
  if(babyClientId = 0) then
    exit;

  pos := Character.Last;
  if(not TFunctions.GetEmptyMobGrid(babyClientId, pos.X, pos.Y)) then
    exit;

  TNPC.NPCs[babyClientId].Create(MobBabyList[babyId], babyClientId, ClientId);
  TNPC.NPCs[babyClientId].Character.CurrentScore.Level := Character.CurrentScore.Level;
  TNPC.NPCs[babyClientId].Character.CurrentScore.CurHP := 100;

  party := @Parties[PartyId];

  if(PartyId = 0) then // Não está em grupo
  begin
    party.Leader     := ClientId;
    party.Members[0] := babyClientId;
    SendParty(ClientId, ClientId);
    SendParty(256, babyClientId);
  end
  else
  begin
//    i := TFunctions.FindInParty(ClientId,0);
    if (i = 11) then
    begin
      TPlayer.Players[ClientId].SendClientMessage('O grupo está cheio.');
      exit;
    end;
    //enviar bixo para o grupo q em q o player está
    TNPC.NPCs[babyClientId].MobLeaderId := ClientId;
    party.Members[i] := babyClientId;
    TPlayer.Players[party.Leader].SendParty(256, babyClientId);
    for j := 0 to 10 do
      TPlayer.Players[party.Members[j]].SendParty(256, babyClientId);
  end;

  self.Mobbaby := babyClientId;

  TNPC.NPCs[babyClientId].Character.Last.X := pos.x;
  TNPC.NPCs[babyClientId].Character.Last.X := pos.y;

  MobGrid[pos.Y][pos.X] := babyClientId;
  TNPC.NPCs[babyClientId].UpdateVisibleList;
  TNPC.NPCs[babyClientId].SendCreateMob(SPAWN_BABYGEN);
end;

procedure TBaseMob.UngenerateBabyMob(ungenEffect: WORD);
//var pos: TPosition; i,j: BYTE; party : PParty; find: boolean;
begin
{
  find := false;
  pos.x:= TNPC.NPCs[Mobbaby].Character.Last.X;
  pos.y:= TNPC.NPCs[Mobbaby].Character.Last.Y;

  party := @Parties[Parties[TNPC.NPCs[Mobbaby].MobLeaderId].Leader];
  i := TFunctions.FindInParty(party.Leader, Mobbaby);
  if(i < 11) then
  begin
    TPlayer.Players[party.Leader].SendExitParty(party.Leader, party.Members[i], 0);
    for j := 0 to 10 do
    if(party.Members[j] < 1000) and (party.Members[j] > 0) then
    begin
      find := true;
      TPlayer.Players[party.Members[j]].SendExitParty(party.Leader, party.Members[i], 0);
    end;
  end;

  party.Members[i] := 0;
  TNPC.NPCs[Mobbaby].Base.SendRemoveMob(DELETE_UNSPAWN);
  ZeroMemory(@TNPC.NPCs[Mobbaby], sizeof(TNpc));

  MobGrid[pos.y][pos.x]:=0;
  self.Mobbaby:=0;

  if not(find) then
    ZeroMemory(party, sizeof(TParty));
}
end;

procedure TBaseMob.ForEachInRange(range: Byte; proc: TProc<TPosition, TBaseMob, TBaseMob>);
begin
  if not(CurrentPosition.isValid) then
    exit;

  CurrentPosition.ForEach(range, Pointer(self), procedure(pme: Pointer; pos: TPosition)
  var
    me : TBaseMob;
    mobId, index: WORD;
    mob : TBaseMob;
  begin
    me := TBaseMob(pme);
    mobId := MobGrid[pos.Y][pos.X];
    if(mobId = 0) OR (mobId = me.ClientId) then
      exit;

    if(mobId <= MAX_CONNECTIONS) then
      mob := TPlayer.Players[mobId]
    else
      mob := TNPC.NPCs[mobId];

    if not(Assigned(mob)) then
      exit;

    proc(pos, me, mob);
  end);
end;

class procedure TBaseMob.ForEach(proc: TProc<TBaseMob>);
var
  i: Integer;
begin
  for i := 1 to TPlayer.InstantiatedPlayers do
  begin
    if Assigned(TPlayer.Players[i]) then
      proc(TPlayer.Players[i]);
  end;

  for i := 1001 to TNPC.InstantiatedNPCs do
  begin
    if Assigned(TNPC.NPCs[i]) then
      proc(TNPC.NPCs[i]);
  end;
end;

class procedure TBaseMob.ForEachInRange(pos: TPosition; range: Byte; proc: TProc<TPosition, TBaseMob>);
begin
  if not(pos.isValid) then
    exit;

  pos.ForEach(range, procedure(p: TPosition)
  var
    mobId: WORD;
    mob: TBaseMob;
  begin
    mobId := MobGrid[pos.Y][pos.X];
    if(mobId = 0) then
      exit;

    if(GetMob(mobId, mob)) then
      proc(p, mob);
  end);
end;

procedure TBaseMob.ForEachVisible(proc: TProc<TBaseMob>);
var mobId: Integer;
  mob: TBaseMob;
begin
  for mobId in VisibleMobs do
  begin
    if TBaseMob.GetMob(mobId, mob) then
      proc(@mob);
  end;
end;

procedure TBaseMob.SetAffect(affectId: Byte; affect: TAffect);
var i: Byte;
begin
  for i := 0 to MAXBUFFS do
  begin
    if Character.Affects[i].Index = affectId then
    begin
      ZeroMemory(@Character.Affects[i], sizeof(TAffect));
      SendScore;
      if IsPlayer then
        TPlayer.Players[ClientId].SendEtc;
    end;
  end;
end;

procedure TBaseMob.DeterminMoveDirection(const pos: TPosition);
var
  moveVector: TPosition;
  dir: BYTE;
begin
  dir := 0;
  moveVector := pos - CurrentPosition;

  if(moveVector.X = 0) AND (moveVector.Y = 0) then
    dir := Character.CurrentScore.Direction
  else if(moveVector.X < 0) AND (moveVector.Y = 0) then
    dir := 0
  else if(moveVector.X = 0) AND (moveVector.Y < 0) then
    dir := 8
  else if(moveVector.X > 0) AND (moveVector.Y = 0) then
    dir := 6
  else if(moveVector.X = 0) AND (moveVector.Y > 0) then
    dir := 2
  else if(moveVector.X < 0) AND (moveVector.Y < 0) then
    dir := 1
  else if(moveVector.X > 0) AND (moveVector.Y < 0) then
    dir := 3
  else if(moveVector.X < 0) AND (moveVector.Y > 0) then
    dir := 7
  else if(moveVector.X > 0) AND (moveVector.Y > 0) then
    dir := 9;

  Character.CurrentScore.Direction := dir;
end;


procedure TBaseMob.SendMovement(destination: TPosition; calcDirection: Boolean = true);
begin
  SendMovement(TFunctions.GetAction(self, destination, MOVE_NORMAL));
end;

procedure TBaseMob.SendMovement(destX, destY : SmallInt; calcDirection: Boolean = true);
begin
  SendMovement(destX, destY, calcDirection);
end;

procedure TBaseMob.SendMovement(packet: TMovementPacket; sendToSelf: boolean);
begin
//  DeterminMoveDirection(packet.Destination);

  Self.Character.Last := packet.Destination;

  MobGrid[packet.Source.Y][packet.Source.X]           := 0;
  MobGrid[packet.Destination.Y][packet.Destination.X] := ClientId;

  if not(self.IsPlayer) then
  begin
    IsMoving := true;
    PreviusPosition := CurrentPosition;
    InitialPosition := CurrentPosition;
    FinalPosition := packet.Destination;
    StartMoveTime := NOW;
    EstimatedMoveTime := (FinalPosition.Distance(InitialPosition) / Character.CurrentScore.MoveSpeed)*1000; //milisegundos
    packet.Source.Y := packet.Source.Y-1;
    packet.Source.X := packet.Source.X-1;
  end
  else
  begin
    CurrentPosition := packet.Destination;
    PreviusPosition := CurrentPosition;
  end;

  IsDirty := True;

  SendToVisible(@packet, packet.Header.Size, sendToSelf);
end;

function TBaseMob.Teleport(x, y: SmallInt) : Boolean;
var packet: TMovementPacket;
  src, dest: TPosition;
begin
	packet.Destination.X := x;
	packet.Destination.Y := y;

  Result := TFunctions.UpdateWorld(ClientId, packet.Destination, WORLD_MOB);
  if not Result then
    exit;

  MobGrid[CurrentPosition.Y][CurrentPosition.X]       := 0;
  MobGrid[packet.Destination.Y][packet.Destination.X] := self.ClientId;

  packet := TFunctions.GetAction(self, packet.Destination, MOVE_TELEPORT);
  src := packet.Source;
  dest := packet.Destination;
  SendToVisible(@packet, packet.Header.Size, true);
  //SendRemoveMob(SPAWN_TELEPORT);

  Character.Last := dest;
  PreviusPosition := src;
  CurrentPosition := dest;

  UpdateVisibleList();
  SendCreateMob(SPAWN_TELEPORT);
end;

function TBaseMob.Teleport(position: TPosition) : Boolean;
begin
  Result := Teleport(position.X, position.Y);
end;

end.
