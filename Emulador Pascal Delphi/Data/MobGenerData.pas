unit MobGenerData;

interface
uses MiscData, System.Generics.Collections;

type TMobGenerData = class(TObject)
  published
    constructor Create;

  public
  Id,
	Mode, // 0 - 3
	MinuteGenerate,// 4 - 7

	MaxNumMob, // 8 - 11

	MobCount, // 12 - 15

	MinGroup, // 16 - 19
	MaxGroup: integer;// 20 - 23

  SpawnSegment: TAISegment;     // Só vai ser usado pra definir o Spawn
  Segments : TList<TAISegment>;
  DestSegment: TAISegment;

	FightAction, // 504 - 823
	FleeAction, // 824 - 1143
	DieAction: array[0..3] of string[79]; // 1144 - 1463

  Follower,
  Leader: string;

	Formation, // 1464 - 1467
	RouteType: integer; // 1468 - 1471

  procedure AddSegmentData(segmentId: Byte); overload;
  procedure AddSegmentData(segmentId : Byte; x, y: Integer); overload;
  procedure AddSegmentData(segmentId : Byte; waitTime: Integer); overload;
  procedure AddSegmentData(segmentId : Byte; say: string); overload;
  procedure Assign(AGener : TMobGenerData);
end;
implementation

{ TMobGenerData }

procedure TMobGenerData.AddSegmentData(segmentId: Byte; x, y: Integer);
var segment: TAISegment;
begin
  AddSegmentData(segmentId);
  Dec(segmentId);

  segment := Segments[segmentId];
  if x <> -1 then
    segment.Position.X := x;
  if y <> -1 then
    segment.Position.Y := y;

  Segments[segmentId] := segment;
end;

procedure TMobGenerData.AddSegmentData(segmentId: Byte; waitTime: Integer);
var segment: TAISegment;
begin
  AddSegmentData(segmentId);
  Dec(segmentId);

  segment := Segments[segmentId];
  segment.WaitTime := waitTime;
  Segments[segmentId] := segment;
end;

procedure TMobGenerData.AddSegmentData(segmentId: Byte; say: string);
var segment: TAISegment;
begin
  AddSegmentData(segmentId);
  Dec(segmentId);

  segment := Segments[segmentId];
  segment.Say := say;
  Segments[segmentId] := segment;
end;

constructor TMobGenerData.Create;
begin
  Segments := TList<TAISegment>.Create;
end;

procedure TMobGenerData.AddSegmentData(segmentId: Byte);
var segment: TAISegment;
begin
  while segmentId > Segments.Count do
  begin
    Segments.Add(segment);
  end;
end;

procedure TMobGenerData.Assign(AGener : TMobGenerData);
begin
  Id := AGener.Id;
  Mode := AGener.Mode;
	MinuteGenerate := AGener.MinuteGenerate;
	MaxNumMob := AGener.MaxNumMob;
	MobCount := AGener.MobCount;
	MinGroup := AGener.MinGroup;
	MaxGroup := AGener.MaxGroup;
  SpawnSegment := AGener.SpawnSegment;
  DestSegment := AGener.DestSegment;
	FightAction := AGener.FightAction;
	FleeAction := AGener.FleeAction;
	DieAction := AGener.DieAction;
  Follower := AGener.Follower;
  Leader := AGener.Leader;
	Formation := AGener.Formation;
	RouteType := AGener.RouteType;
end;

end.
