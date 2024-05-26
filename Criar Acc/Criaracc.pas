unit Criaracc;

interface

uses PlayerData, MiscData,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MongoDB,
  FireDAC.Phys.MongoDBDef, System.Rtti, System.JSON.Types, System.JSON.Readers,
  System.JSON.BSON, FireDAC.Phys.MongoDBWrapper,
  FireDAC.VCLUI.Wait, FireDAC.Comp.UI, Data.DB, FireDAC.Comp.Client,
  Rest.Json, System.JSON.Builders, PlayerDataClasses;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    FDConnection1: TFDConnection;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure Button1Click(Sender: TObject);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FConMongo: TMongoConnection;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  System.JSON.Writers, System.JSON;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  Acc: TAccountFileClass;
  MD: TMongoDocument;
  crs: IMongoCursor;
begin
  if (length(edit1.text) < 4) then
  begin
    Showmessage('Id curto demais. Deve ter pelo menos 4 digitos.');
    exit;
  end;

  if (length(edit2.Text) < 4) then
  begin
    Showmessage('Senha curta demais. Deve ter pelo menos 4 digitos.');
    exit;
  end;

  crs := FConMongo['wyd']['account'].Find().Match.Add('header.username', edit1.text).&End;
  if (crs.Next) then
  begin
    Showmessage('Usuário já está em uso.');
    exit;
  end;

  Acc := TAccountFileClass.Create;
  Acc.Header.userName:=edit1.Text;
  Acc.Header.password:=edit2.Text;
  MD := FConMongo.Env.NewDoc;
  Md.AsJSON := TJson.ObjectToJsonString(Acc);//Acc.ToJson;
  FConMongo['wyd']['account'].Insert(Md);

  Showmessage('Conta criada com sucesso!');
end;

procedure TForm1.Edit2KeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then
    button1.Click;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FConMongo := TMongoConnection(FDConnection1.CliObj);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FConMongo.Close;
  FDConnection1.Connected := False;
end;

end.
