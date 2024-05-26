unit PositionUpdateBackgroundThread;

interface

uses BaseMob, BackgroundThread, System.TimeSpan, NPC;

type TPositionUpdateBackgroundThread = class(TBackgroundThread)
  private
    procedure Interpolate(mob : TBaseMob);
    function GetCurrTime: TDateTime;

  protected
    procedure Setup; override;
    procedure Update(); override;
end;

implementation

{ TPositionUpdateBackgroundThread }
uses Classes, Util, Player, MiscData, Functions, GlobalDefs, DateUtils, SysUtils, Position;

function TPositionUpdateBackgroundThread.GetCurrTime: TDateTime;
begin
  Result := Now;
end;

procedure TPositionUpdateBackgroundThread.Interpolate(mob: TBaseMob);
var delta: single;
  currentTime: TDateTime;
begin
  currentTime := GetCurrTime;
//  if mob.clientid = 1 then
//  begin
//  writeln(datetimetostr(currentTime));
//  writeln(datetimetostr(mob.StartMoveTime));
//  writeln(floattostr(mob.EstimatedMoveTime));
//  writeln(inttostr(MilliSecondsBetween(currentTime, mob.StartMoveTime)));
//  if(mob.EstimatedMoveTime <> 0) then
//  writeln(floattostr(MilliSecondsBetween(currentTime, mob.StartMoveTime) / mob.EstimatedMoveTime));
//  end;
//  delta := MilliSecondsBetween(currentTime, mob.StartMoveTime) / mob.EstimatedMoveTime;
  if(mob.EstimatedMoveTime <> 0) then
  begin
    //delta := delta / (mob.EstimatedMoveTime*1000);
    delta := MilliSecondsBetween(currentTime, mob.StartMoveTime) / mob.EstimatedMoveTime;
  end
  else delta := 1;

  if (delta > 0.95) or ((delta > 0.50) and (mob.Character.CurrentScore.MoveSpeed >= 5)) then
  //if(delta >= 1) then
  begin
    mob.CurrentPosition := mob.FinalPosition;
    mob.IsMoving := false;
  end
  else
  begin
    mob.PreviusPosition := mob.CurrentPosition;
    mob.CurrentPosition := TPosition.Lerp(mob.InitialPosition, mob.FinalPosition, delta);
  end;

//  if TFunctions.GetEmptyMobGrid(mob.ClientId, mob.CurrentPosition) then
//  begin
//    MobGrid[mob.PreviusPosition.Y][mob.PreviusPosition.X] := 0;
//    MobGrid[mob.CurrentPosition.Y][mob.CurrentPosition.X] := mob.ClientId;
//  end;

end;

procedure TPositionUpdateBackgroundThread.Setup;
begin
  Priority := tpNormal;
  UpdateSpan := TTimeSpan.FromMilliseconds(200);
  SleepTime := TTimeSpan.FromMilliseconds(100);
end;

procedure TPositionUpdateBackgroundThread.Update();
begin
  TBaseMob.ForEach(procedure(mob : TBaseMob)
  begin
    if not(mob.IsMoving) or (mob.IsPlayer) then
      exit;
//
    Interpolate(mob);
  end);
end;

end.
