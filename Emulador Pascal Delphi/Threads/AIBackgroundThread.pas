unit AIBackgroundThread;

interface
uses BackgroundThread, System.TimeSpan, Classes, System.SyncObjs;

type TAIBackgroundThread = class(TBackgroundThread)
  protected
    procedure Setup; override;
    procedure Update(); override;
end;


implementation

uses NPC, DateUtils, SysUtils, Position, Math, Functions;

{ TAIBackgroundThread }
procedure TAIBackgroundThread.Setup;
begin
  Priority := tpHigher;
  UpdateSpan := TTimeSpan.FromSeconds(0.1);
  SleepTime := TTimeSpan.FromSeconds(1);
end;

procedure TAIBackgroundThread.Update();
begin
  TNpc.ForEach(true, procedure(npc: TNpc)
  begin
    if(npc.IsDead) OR (npc.VisibleMobs.Count = 0) then
      exit;
    npc.StateMachine.Update;
  end);
end;


end.
