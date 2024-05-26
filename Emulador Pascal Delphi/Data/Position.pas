unit Position;

interface

uses SysUtils;

type TPosition = packed Record
  public
    X: SmallInt;
    Y: SmallInt;

    constructor Create(x, y: SmallInt);

    function InView(pos : TPosition) : boolean;
    function WYDDistance(const pos: TPosition) : WORD;
    function Distance(const pos : TPosition) : Single;
    function InRange(const pos : TPosition; range : WORD) : Boolean;
    procedure ForEach(range: Byte; proc: TProc<TPosition>); overload;
    procedure ForEach(range: Byte; basePointer : Pointer; proc: TProc<Pointer, TPosition>); overload;
    procedure ForEach(range: Byte; id : Word; proc: TProc<Word, TPosition>); overload;

    function magnitude: WORD;
    function normalized: TPosition;
    function IsValid: boolean;
    function PvPAreaType : Integer;

    class function Forward: TPosition; static;
    class function Rigth: TPosition; static;

    class function Lerp(const start, dest: TPosition; time: Single): TPosition; static;
    class function Qerp(const start, dest: TPosition; time: Single; inverse: Boolean = false): TPosition; static;
//    class function Cerp(const start, dest: TPosition; time: Single): TPosition; static;

    class operator Equal(pos1, pos2 : TPosition): Boolean;
    class operator NotEqual(pos1, pos2 : TPosition): Boolean;
    class operator Add(pos1, pos2 : TPosition) : TPosition;
    class operator Subtract(pos1, pos2 : TPosition) : TPosition;
    class operator Multiply(pos1 : TPosition; val: WORD): TPosition;
    class operator Multiply(pos1 : TPosition; val: Single): TPosition;
end;

implementation
uses Math, ConstDefs, Util;

var DistanceTable: array[0..7] of array[0..7] of Integer =
    (	(0,1,2,3,4,5,6,7),
      (1,1,2,3,4,5,6,7),
      (2,2,3,4,4,5,6,7),
      (3,3,4,4,5,5,6,7),
      (4,4,4,5,5,5,6,7),
      (5,5,5,5,5,6,6,7),
      (6,6,6,6,6,6,7,7),
      (7,7,7,7,7,7,7,7));

{ TPosition }
constructor TPosition.Create(x, y: SmallInt);
begin
  self.X := x;
  self.Y := Y;
end;

function TPosition.InView(pos : TPosition) : Boolean;
begin
	if (self.X < pos.X - VIEWGRIDX) or (self.X > pos.X + VIEWGRIDX) or
		 (self.Y < pos.Y - VIEWGRIDY) or (self.Y > pos.Y + VIEWGRIDY) then
		result := false
  else
	  result := true;
end;


function TPosition.WYDDistance(const pos: TPosition): WORD;
var local1, local2 : WORD;
  x1, x2, y1, y2 : WORD;
begin
  x1 := X;
  x2 := pos.X;
  y1 := Y;
  y2 := pos.Y;

	if(x1 > x2) then
		local1 := x1 - x2
	else
		local1 := x2 - x1;

	if(y1 > y2) then
		local2 := y1 - y2
	else
		local2 := y2 - y1;

	if(local1 <= 7) AND (local1 <= 7) then
  begin
		result := DistanceTable[local2][local1]; // array com distâncias
    exit;
  end;

	if(local1 > local2) then
		result := local1 + 1
  else
	  result := local2 + 1;
end;

function TPosition.Distance(const pos: TPosition): Single;
var dif: TPosition;
begin
  dif := self - pos;

  Result := Sqrt(dif.X * dif.X + dif.Y * dif.Y);
end;


function TPosition.InRange(const pos : TPosition; range: WORD): Boolean;
var dist : Single;
begin
  dist := Distance(pos);
  Result := IfThen(dist <= range);
end;

procedure TPosition.ForEach(range: Byte; proc: TProc<TPosition>);
var
  x, y: WORD;
begin
  for x := self.X - range to self.X + range do
  begin
    for y := self.Y - range to self.Y + range do
    begin
      if (x > 4096) or (x <= 0) or (y > 4096) or (y <= 0) then
        continue;

      proc(TPosition.Create(x,y));
    end;
  end;
end;

procedure TPosition.ForEach(range: Byte; basePointer : Pointer; proc: TProc<Pointer, TPosition>);
var
  x, y: WORD;
begin
  for x := self.X - range to self.X + range do
  begin
    for y := self.Y - range to self.Y + range do
    begin
      if (x > 4096) or (x <= 0) or (y > 4096) or (y <= 0) then
        continue;

      proc(basePointer, TPosition.Create(x,y));
    end;
  end;
end;

procedure TPosition.ForEach(range: Byte; id: Word; proc: TProc<Word, TPosition>);
var
  x, y: WORD;
begin
  for x := self.X - range to self.X + range do
  begin
    for y := self.Y - range to self.Y + range do
    begin
      if (x > 4096) or (x <= 0) or (y > 4096) or (y <= 0) then
        continue;

      proc(id, TPosition.Create(x,y));
    end;
  end;

end;

class function TPosition.Forward: TPosition;
begin
  Result.X := 0;
  Result.Y := -1;
end;
class function TPosition.Rigth: TPosition;
begin
  Result.X := -1;
  Result.Y := 0;
end;

function TPosition.IsValid: boolean;
begin
  Result := true;
  if(self.X > 4096) or (self.Y > 4096) or (self.X <= 0) or (self.Y <= 0) then
    Result := false;
end;

class function TPosition.Lerp(const start, dest: TPosition; time: Single): TPosition;
begin
  Result :=  start + ((dest - start) * time);
  //Result := dest * time + start * (1 - time);
  //Result := start + (dest - start) * time;
end;

class function TPosition.Qerp(const start, dest: TPosition; time: Single; inverse: Boolean = false): TPosition;
var quad: Single;
begin
  quad := IfThen(inverse, (2 - time), time);
  Result := start + (dest - start) * time * quad;
end;

function TPosition.magnitude: WORD;
begin
  Result := Round(Sqrt(self.X * self.X + self.Y * self.Y));
end;

function TPosition.normalized: TPosition;
var mag : WORD;
begin
  mag := self.magnitude;
  Result.X := self.X div mag;
  Result.Y := self.Y div mag;
end;

class operator TPosition.Equal(pos1, pos2: TPosition): Boolean;
begin
  Result := false;
  if (pos1.X = pos2.X) AND (pos1.Y = pos2.Y) then
    Result := true;
end;
class operator TPosition.NotEqual(pos1, pos2: TPosition): Boolean;
begin
  Result := not(pos1 = pos2);
end;

function TPosition.PvPAreaType: Integer;
begin
	////MENOS CP / COM FRAG
	if (X >= 3330) AND (Y >= 1026) AND (X <= 3600) AND (Y <= 1660) then Result := 2 //Area das Pistas de Runas
	else if (X >= 2176) AND (Y >= 1150) AND (X <= 2304) AND (Y <= 1534) then Result := 2 //Area Campo Azran Quest Imp
	else if (X >= 2446) AND (Y >= 1850) AND (X <= 2546) AND (Y <= 1920) then Result := 2 //Area Torre Erion 02
	else if (X >= 1678) AND (Y >= 1550) AND (X <= 1776) AND (Y <= 1906) then Result := 2 //Area de Reinos
	else if (X >= 1150) AND (Y >= 1676) AND (X <= 1678) AND (Y <= 1920) then Result := 2 //Area caça Noatun
	else if (X >= 3456) AND (Y >= 2688) AND (X <= 3966) AND (Y <= 3083) then Result := 2 //Area caça Gelo
	else if (X >= 3582) AND (Y >= 3456) AND (X <= 3968) AND (Y <= 3710) then Result := 2 //Area Lan House

	////SEM CP / SEM FRAG
	else if (X >= 2602) AND (Y >= 1702) AND (X <= 2652) AND (Y <= 1750) then Result := 1 //Area Coliseu Azran
	else if (X >= 2560) AND (Y >= 1682) AND (X <= 2584) AND (Y <= 1716) then Result := 1 //Area PVP Azran
	else if (X >= 2122) AND (Y >= 2140) AND (X <= 2148) AND (Y <= 2156) then Result := 1 //Area PVP Armia
	else if (X >= 136) AND (Y >= 4002) AND (X <= 200) AND (Y <= 4088) then Result := 1 //Area Duelo

	////SEM CP / COM FRAG
	else if (X >= 2174) AND (Y >= 3838) AND (X <= 2560) AND (Y <= 4096) then Result := 3 //Area Kefra
	else if (X >= 1076) AND (Y >= 1678) AND (X <= 1150) AND (Y <= 1778) then Result := 3 //Area Castelo Noatun
	else if (X >= 1038) AND (Y >= 1678) AND (X <= 1076) AND (Y <= 1702) then Result := 3 //Area Castelo Noatun Altar
	else if (X >= 2498) AND (Y >= 1868) AND (X <= 2516) AND (Y <= 1896) then Result := 3 //Area Torre Erion 01
	else if (X >= 130) AND (Y >= 140) AND (X <= 248) AND (Y <= 240) then Result := 3 //Area Guerra entre Guildas
	else Result := 0;
end;

class operator TPosition.Add(pos1, pos2: TPosition): TPosition;
begin
  Result.X := pos1.X + pos2.X;
  Result.Y := pos1.Y + pos2.Y;
end;
class operator TPosition.Subtract(pos1, pos2: TPosition): TPosition;
begin
  Result.X := pos1.X - pos2.X;
  Result.Y := pos1.Y - pos2.Y;
end;
class operator TPosition.Multiply(pos1 : TPosition; val: WORD): TPosition;
begin
  Result.X := pos1.X * val;
  Result.Y := pos1.Y * val;
end;
class operator TPosition.Multiply(pos1: TPosition; val: Single): TPosition;
begin
  Result.X := Ceil(pos1.X * val);
  Result.Y := Ceil(pos1.Y * val);
end;

end.
