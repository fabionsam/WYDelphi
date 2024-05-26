program Acc;

uses
  Forms,
  Criaracc in 'Criaracc.pas' {Form1},
  MiscData in '..\Emulador Pascal Delphi\Data\MiscData.pas',
  PlayerData in '..\Emulador Pascal Delphi\Data\PlayerData.pas',
  Packets in '..\Emulador Pascal Delphi\Data\Packets.pas',
  Util in '..\Emulador Pascal Delphi\Functions\Util.pas',
  PlayerDataClasses in '..\Emulador Pascal Delphi\Data\PlayerDataClasses.pas',
  Position in '..\DataBase Server\Data\Position.pas',
  ConstDefs in '..\Emulador Pascal Delphi\Data\ConstDefs.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
