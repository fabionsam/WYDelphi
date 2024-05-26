unit PursuitState;

interface
uses State, NPC;

type TPursuitState = class(TState<TNpc>)
  public
    procedure OnEnter(var entity : TNpc; previousState: TState<TNpc>); override;
    procedure OnExecute(var entity : TNpc); override;
    procedure OnExit(var entity : TNpc; nextState: TState<TNpc>); override;
end;

implementation
uses BaseMob, AIStates, Functions, Position, GlobalDefs, ConstDefs;

procedure TPursuitState.OnEnter(var entity : TNpc; previousState: TState<TNpc>);
begin

end;

procedure TPursuitState.OnExecute(var entity : TNpc);
var target: TBaseMob;
  pos : TPosition;
begin
  target := entity.Target;

  if (target = nil) or
     (target.Character.CurrentScore.CurHP <= 0) or
     (entity.CurrentPosition.Distance(entity.GenerData.SpawnSegment.Position) > 10) or
     (target.CurrentPosition.Distance(entity.CurrentPosition) > 20) then
  begin
    entity.Target := nil;
//    TFunctions.GetEmptyMobGrid(entity.ClientId, entity.GenerData.SpawnSegment.Position, 2);
//    entity.SendMovement(entity.GenerData.SpawnSegment.Position);
    entity.StateMachine.ChangeState(TAIStates.Patrol);
    exit;
  end;

  pos := target.CurrentPosition;
  if (not entity.IsMoving) and
     (target.CurrentPosition.Distance(entity.CurrentPosition) > entity.GetMobAbility(EF_RANGE)) and
     (TFunctions.GetEmptyMobGrid(entity.ClientId, pos, 2)) then
  begin
    entity.SendMovement(pos);
    exit;
  end;

  if (not entity.IsMoving) then
    entity.StateMachine.ChangeState(TAIStates.Attack);
end;

procedure TPursuitState.OnExit(var entity : TNpc; nextState: TState<TNpc>);
begin
end;

end.
