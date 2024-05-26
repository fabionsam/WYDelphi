unit FiniteStateMachine;

interface
uses Generics.Collections, State;

type TStateMachine<T> = class
  private

  public
    GlobalState : TState<T>;
    CurrentState : TState<T>;
    PreviousState : TState<T>;

    constructor Create(var owner : T; initialState: TState<T>);
    procedure Update();
    procedure ChangeState(newState : TState<T>);
    procedure RevertToPreviousState();

  private
    Owner : T;
end;

implementation
{ TStateMachine<T> }

procedure TStateMachine<T>.ChangeState(newState: TState<T>);
begin
  PreviousState := CurrentState;
  if (CurrentState <> nil) then
    CurrentState.OnExit(Owner, newState);

  CurrentState := newState;
  if (CurrentState <> nil) then
    CurrentState.OnEnter(Owner, PreviousState);
end;

constructor TStateMachine<T>.Create(var owner: T; initialState: TState<T>);
begin
  self.Owner := owner;
  GlobalState := nil;
  ChangeState(initialState);
end;

procedure TStateMachine<T>.RevertToPreviousState;
begin
  if (PreviousState <> nil) then
    ChangeState(PreviousState);
end;

procedure TStateMachine<T>.Update;
begin
  if (GlobalState <> nil) then
    GlobalState.OnExecute(Owner);
  if (CurrentState <> nil) then
    CurrentState.OnExecute(Owner);
end;

end.
