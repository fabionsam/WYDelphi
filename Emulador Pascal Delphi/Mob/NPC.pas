unit NPC;

interface

uses MiscData, PlayerData, BaseMob, SysUtils, DateUtils, Threading, Diagnostics,
    Generics.Collections, FiniteStateMachine, MobGenerData, Position;

type TNpc = class(TBaseMob)
  published
    class constructor Create;
    constructor Create(npc: TCharacterOld; genData: TMOBGenerData; clientId, leaderId: Integer); overload;

  private
    _isSummon: boolean;

  public
    // Crias e evocações vão ter isso definido como o Id do player  ( < 1000)
    MobLeaderId: smallint;
    LearnedSkills : TList<Byte>;
    TimeKill: TDateTime;
    GenerData: TMobGenerData;
    StateMachine : TStateMachine<TNpc>;
    CurrentSegmentId: ShortInt;
    LastActionTime: TDateTime;
    LastAtackTime : TDateTime;

    class var InstantiatedNPCs: integer;
    class var NPCs : array[1001..30000] of TNpc;

    constructor Create(npc: TCharacterOld; clientId, leaderId: Integer); overload;
    procedure Revive();
    class procedure ForEach(parallel: Boolean; proc : TProc<TNpc>); static;
    class function GetNpc(index : Word; out mob : TNpc): Boolean;
    procedure AddToEnemyList(target: TBaseMob); override;
    procedure SendMobDead(killer: TBaseMob); override;
end;

implementation

uses GlobalDefs, ConstDefs, Windows, Functions, CombatHandlers, Log, Util, IdleState, AIStates;

{ TNpc }
constructor TNpc.Create(npc: TCharacterOld; genData: TMOBGenerData; clientId, leaderId: Integer);
var skill: TSkillData;
begin
  Character := npc;
  inherited Create(clientId);

  InitialPosition := Character.Last;
  CurrentPosition := Character.Last;
  FinalPosition := Character.Last;

  MobLeaderId := leaderId;
  GenerData := genData;

  LearnedSkills := TList<Byte>.Create;

  for skill in SkillsData do
  begin
    if Character.HaveSkill(skill.Index) then
      LearnedSkills.Add(skill.Index);
  end;

  CurrentSegmentId := -1;
  if(GenerData.Segments <> nil) AND (GenerData.Segments.Count > 0) then
    CurrentSegmentId := 0;

  if not(IsDead) then
    StateMachine := TStateMachine<TNpc>.Create(self, TAIStates.Idle);
end;

class constructor TNpc.Create;
begin
  ZeroMemory(@NPCs, SizeOf(NPCs));
  InstantiatedNPCs := 0;
end;

constructor TNpc.Create(npc: TCharacterOld; clientId, leaderId: Integer);
begin
  Create(npc, nil, clientId, leaderId);
  _isSummon := true;
end;

class procedure TNpc.ForEach(parallel: Boolean; proc: TProc<TNpc>);
var i: Integer;
  npc: TNpc;
begin
  try
    if(parallel) then
    begin
      TParallel.For(1001, InstantiatedNpcs - 1, procedure(i : Integer)
      begin
        npc := NPCs[i];
        if not(Assigned(npc)) then
          exit;
        proc(npc);
      end);
    end
    else
    begin
      for i := 1001 to InstantiatedNpcs - 1 do
      begin
        npc := NPCs[i];
        if not(Assigned(npc)) then
          continue;
        proc(npc);
      end;
    end;
  except on e : Exception do
    Logger.Write('[TNpc.ForEach] ' + e.Message, TLogType.Warnings);
  end;
end;

class function TNpc.GetNpc(index: Word; out mob: TNpc): Boolean;
begin
  result := false;
  if(index = 0) OR (index > MAX_SPAWN_ID) then
  begin
    exit;
  end;

  if(index <= MAX_CONNECTIONS) then
    exit
  else
    mob := TNPC.NPCs[index];

  if (mob = nil) then
    exit;

  result := Assigned(mob);
end;

procedure TNpc.Revive;
begin
  self.Character.CurrentScore.CurHP := self.Character.BaseScore.MaxHP;
  self.Character.CurrentScore.CurMP := self.Character.BaseScore.MaxMP;

//  ForEachInRange(10, procedure(pos: TPosition; this, mob: TBaseMob)
//  begin
//    if(mob.IsPlayer) then
//    begin
//      this.AddToVisible(mob, true);
//    end;
//  end);

  Self.SendGridMob(SPAWN_TELEPORT);

  //base.SendCreateMob(SPAWN_TELEPORT);
  if(StateMachine = nil) then
    StateMachine := TStateMachine<TNpc>.Create(self, TAIStates.Idle);
end;

procedure TNpc.AddToEnemyList(target: TBaseMob);
begin
  inherited AddToEnemyList(target);
//  Self.SendMovement(Self.Character.Last);
  Self.StateMachine.ChangeState(TAIStates.Pursuit);
end;


procedure TNpc.SendMobDead(killer: TBaseMob);
begin
  inherited SendMobDead(killer);
end;

//0x2cb

end.

