program NPCEditor;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {F_Item},
  Unit3 in 'Unit3.pas' {F_Adicionais},
  Unit4 in 'Unit4.pas' {F_Conversor},
  MiscData in '..\Emulador Pascal Delphi\Data\MiscData.pas',
  PlayerData in '..\Emulador Pascal Delphi\Data\PlayerData.pas',
  PlayerDataClasses in '..\Emulador Pascal Delphi\Data\PlayerDataClasses.pas',
  Position in '..\Emulador Pascal Delphi\Data\Position.pas',
  ConstDefs in '..\Emulador Pascal Delphi\Data\ConstDefs.pas',
  Util in '..\Emulador Pascal Delphi\Functions\Util.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TF_Item, F_Item);
  Application.CreateForm(TF_Adicionais, F_Adicionais);
  Application.CreateForm(TF_Conversor, F_Conversor);
  Application.Run;
end.
