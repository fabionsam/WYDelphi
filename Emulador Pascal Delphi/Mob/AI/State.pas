unit State;

interface

type TState<T> = class abstract
  public
    procedure OnEnter(var entity : T; previousState: TState<T>); virtual; abstract;
    procedure OnExecute(var entity : T); virtual; abstract;
    procedure OnExit(var entity : T; nextState: TState<T>); virtual; abstract;
end;

implementation


end.
