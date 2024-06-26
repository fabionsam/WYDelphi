unit NpcFunctions;

interface

Uses
   Windows, Messages, SysUtils, Variants, Classes, Aylin, Tiny,
   ScktComp, Packets, Player, MMSystem,
   MestreGriffo, Compounder, Shany, Agatha;

  type TNpcFunctions = class(TObject)
    public
      NpcAylin: AylinClass;
      NpcTiny : TinyClass;
      NpcMestreGriffo : MestreGriffoClass;
      NpcCompounder : CompounderClass;
      NpcShany : ShanyClass;
      NpcAgatha : AgathaClass;

      constructor Create;
      function GetIdJoia(anct : integer) : WORD;
      function GetSancId(joia : integer) : uint8;
  end;

implementation

constructor TNpcFunctions.Create;
begin
  NpcAylin := AylinClass.Create;
  NpcTiny  := TinyClass.Create;
  NpcMestreGriffo := MestreGriffoClass.Create;
end;

function TNpcFunctions.GetIdJoia(anct : integer) : WORD;
begin
	if ((anct > 4) AND (anct < 9)) then
	begin;
		result := 2436 + anct;
	end
	else
	begin
		result := 0;
	end;
end;

function TNpcFunctions.GetSancId(joia : integer) : uint8;
begin
	result := joia - 2211;
end;

end.
