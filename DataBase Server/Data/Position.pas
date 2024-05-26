unit Position;

interface

uses SysUtils;

type TPosition = Record
  public
    X: SmallInt;
    Y: SmallInt;

    constructor Create(x, y: SmallInt);
end;

implementation

{ TPosition }
constructor TPosition.Create(x, y: SmallInt);
begin
  self.X := x;
  self.Y := Y;
end;

end.
