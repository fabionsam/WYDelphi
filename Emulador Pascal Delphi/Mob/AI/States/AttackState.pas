unit AttackState;

interface
uses State, NPC, BaseMob;

type TAttackState = class(TState<TNpc>)
  private
    function SelectSkill(var entity: TNpc; target: TBaseMob): ShortInt;
  public
    procedure OnEnter(var entity : TNpc; previousState: TState<TNpc>); override;
    procedure OnExecute(var entity : TNpc); override;
    procedure OnExit(var entity : TNpc; nextState: TState<TNpc>); override;
end;

implementation
uses Math, AIStates, SysUtils, DateUtils, Functions, GlobalDefs, Log;

procedure TAttackState.OnEnter(var entity : TNpc; previousState: TState<TNpc>);
begin
  if (TFunctions.GetCurrTime() >= IncMillisecond(entity.LastAtackTime, Trunc((100 / entity.AttackSpeed) * 1000))) then
  begin
    entity.SendDamage(entity.Target, SelectSkill(entity, entity.Target));
    entity.LastAtackTime := Now;
    entity.StateMachine.ChangeState(TAIStates.Pursuit);
  end;
end;

procedure TAttackState.OnExecute(var entity : TNpc);
begin
  entity.StateMachine.ChangeState(TAIStates.Pursuit);
end;

procedure TAttackState.OnExit(var entity : TNpc; nextState: TState<TNpc>);
begin

end;

function TAttackState.SelectSkill(var entity: TNpc; target: TBaseMob): ShortInt;
begin
  result := 0;
  RandomRange(0, entity.LearnedSkills.Count);
  //result := entity.LearnedSkills[]
end;

end.
