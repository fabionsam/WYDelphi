unit PatrolState;

interface
uses State, NPC, MiscData, Player, Position, Functions;

type TPatrolState = class(TState<TNpc>)
  public
    procedure OnEnter(var entity : TNpc; previousState: TState<TNpc>); override;
    procedure OnExecute(var entity : TNpc); override;
    procedure OnExit(var entity : TNpc; nextState: TState<TNpc>); override;
end;

implementation
uses DateUtils, SysUtils, Util, AIStates, Math, GlobalDefs, ConstDefs;
{ TPatrolState }

procedure TPatrolState.OnEnter(var entity: TNpc; previousState: TState<TNpc>);
begin
  if(entity.CurrentSegmentId >= 0) then
  begin
    if(previousState = TAIStates.Idle) then
    begin
      Inc(entity.CurrentSegmentId);
      if(entity.CurrentSegmentId >= entity.GenerData.Segments.Count) then
        entity.CurrentSegmentId := 0;
    end;
  end;
end;

procedure TPatrolState.OnExecute(var entity: TNpc);
var currentSegment : TAISegment;
    pos: TPosition;
begin
  if(entity.Target <> nil) then
  begin
    entity.StateMachine.ChangeState(TAIStates.Pursuit);
    exit;
  end;

  if(entity.CurrentSegmentId < 0) then
  begin
    entity.StateMachine.ChangeState(TAIStates.Idle);
    exit;
  end;

  pos := entity.GenerData.Segments[entity.CurrentSegmentId].Position;
  Inc(pos.X, RandomRange(-3,3));
  Inc(pos.Y, RandomRange(-3,3));
  if TFunctions.GetEmptyMobGrid(entity.ClientId, pos, 6) then
  begin
    entity.SendMovement(pos);
    entity.SendGridMob(SPAWN_NORMAL);
    entity.LastActionTime := IncSecond(Now, RandomRange(-2,2));
  end;

  entity.StateMachine.ChangeState(TAIStates.Idle);
end;

procedure TPatrolState.OnExit(var entity: TNpc; nextState: TState<TNpc>);
begin

end;

end.
