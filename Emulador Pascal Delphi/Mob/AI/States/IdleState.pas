unit IdleState;

interface
uses State, NPC, Math;

type TIdleState = class(TState<TNpc>)
  private
    _lastAction: TTime;
    _currentSegmentId: Integer;

  public
    procedure OnEnter(var entity : TNpc; previousState: TState<TNpc>); override;
    procedure OnExecute(var entity : TNpc); override;
    procedure OnExit(var entity : TNpc; nextState: TState<TNpc>); override;
end;

implementation
uses DateUtils, SysUtils, Util, MiscData, AIStates, Position, BaseMob;

procedure TIdleState.OnEnter(var entity : TNpc; previousState: TState<TNpc>);
var msg: string[80];
begin
  if(entity.CurrentSegmentId >= 0) then
  begin
    msg := entity.GenerData.Segments[entity.CurrentSegmentId].Say;
    if Trim(msg) <> '' then
    begin
      if (entity.VisibleMobs.Count > 0) then
        entity.SendChat(msg);
      entity.LastActionTime := IncSecond(Now, RandomRange(-2,2));
    end;
  end;
end;

procedure TIdleState.OnExecute(var entity : TNpc);
var currentSegment : TAISegment;
    position: TPosition;
    possibleTarget: TBaseMob;
    i: byte;
    possibleTargetId: WORD;
begin
  // Merchant = 0; Race = 1 => Mob agressivo
  if (entity.Character.Merchant = 0) AND (entity.Character.CapeInfo = 1) then
  begin
    if (entity.Target = nil) AND (entity.VisibleMobs.Count > 0) then
    begin
      for possibleTargetId in entity.VisibleMobs do
      begin
        if not(TBaseMob.GetMob(possibleTargetId, possibleTarget)) then
        begin
          continue;
        end;

        if (entity.Target = nil) then
        begin
          entity.Target := possibleTarget;
          continue;
        end;

        // Ataca o jogador com o menor nível
        // Atacar o mais proximo? Com menos HP?
        if(entity.Target.Character.CurrentScore.Level > possibleTarget.Character.CurrentScore.Level) then
        begin
          entity.Target := possibleTarget;
        end;
      end;
    end;
  end;

  if(entity.Target <> nil) then
  begin
    entity.StateMachine.ChangeState(TAIStates.Pursuit);
    exit;
  end;

  if(entity.CurrentSegmentId < 0) then
  begin
    exit;
  end;

  if(SecondsBetween(Now, entity.LastActionTime) > entity.GenerData.Segments[entity.CurrentSegmentId].WaitTime) then
  begin
    entity.StateMachine.ChangeState(TAIStates.Patrol);
  end;
end;

procedure TIdleState.OnExit(var entity : TNpc; nextState: TState<TNpc>);
begin

end;

end.
