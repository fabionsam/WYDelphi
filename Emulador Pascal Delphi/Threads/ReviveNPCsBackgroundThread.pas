unit ReviveNPCsBackgroundThread;

interface

uses BaseMob, BackgroundThread, System.TimeSpan, Log;

type TReviveNPCsBackgroundThread = class(TBackgroundThread)
  private
    function GetCurrTime() : TDateTime;
  protected
    procedure Setup; override;
    procedure Update(); override;
end;

implementation

{ TReviveNPCsBackgroundThread }
uses NPC, MiscData, Functions, GlobalDefs, System.DateUtils, System.SysUtils;

{ TReviveNPCsBackgroundThread }
function TReviveNPCsBackgroundThread.GetCurrTime: TDateTime;
begin
  Result := Now;
end;

procedure TReviveNPCsBackgroundThread.Setup;
begin
  UpdateSpan := TTimeSpan.FromSeconds(15);
  SleepTime := TTimeSpan.FromSeconds(5);
end;

procedure TReviveNPCsBackgroundThread.Update();
var minute : integer;
begin
  TNpc.ForEach(true, procedure(npc : TNpc)
  begin
    if(npc.IsDead) then
    begin
      minute := npc.GenerData.MinuteGenerate;
      if(minute >= -1) AND (Trunc(MinuteSpan(GetCurrTime(), npc.TimeKill)) >= minute) then
      begin
        if not(TFunctions.GetEmptyMobGrid(npc.ClientId, npc.Character.Last, 8)) then
        begin
          exit;
        end;
        npc.Character.Last := npc.GenerData.SpawnSegment.Position;
        npc.Character.CurrentScore := npc.Character.BaseScore;
        MobGrid[npc.Character.Last.Y][npc.Character.Last.X] := npc.ClientId;
        NPC.Revive;
      end;
    end;
  end);
end;

end.
