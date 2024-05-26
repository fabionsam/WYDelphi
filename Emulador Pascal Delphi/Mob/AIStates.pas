unit AIStates;

interface
uses IdleState, AttackState, PursuitState, PatrolState;

type TAIStates = class
  public
    class var Idle : TIdleState;
    class var Attack : TAttackState;
    class var Patrol : TPatrolState;
    class var Pursuit : TPursuitState;
    class constructor Create;
end;

implementation

{ TAIStates }
class constructor TAIStates.Create;
begin
  Idle := TIdleState.Create;
  Attack := TAttackState.Create;
  Pursuit := TPursuitState.Create;
  Patrol := TPatrolState.Create;
end;

end.
