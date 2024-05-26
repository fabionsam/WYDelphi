unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, DB,

  PlayerData, MiscData;

type
  TF_Item = class(TForm)
    Edit1: TEdit;
    DBGrid1: TDBGrid;
    procedure Edit1Change(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    mItem: TItem;
  end;

var
  F_Item: TF_Item; Busca: string;

implementation

Uses Unit1, Unit3;

{$R *.dfm}

procedure TF_Item.DBGrid1CellClick(Column: TColumn);
begin
  Busca := Column.Title.Caption;
end;

procedure TF_Item.DBGrid1DblClick(Sender: TObject);
begin
  try
    Application.CreateForm(TF_Adicionais, F_Adicionais);
    F_Adicionais.Edit1.Text := Form1.cdsItems.FieldByName('ID').AsString;
    F_Adicionais.ShowModal;
    F_Adicionais.Release;
  except
    showmessage('Erro ao criar form adicionais');
  end;
end;

procedure TF_Item.Edit1Change(Sender: TObject);
begin
  Form1.cdsItems.Filtered := False;
  Form1.cdsItems.FilterOptions := [foCaseInsensitive];
  if Busca = 'Nome' then
    Form1.cdsItems.Filter := Busca + ' LIKE ''%' + Edit1.Text + '%'''
  else
    Form1.cdsItems.Filter := Busca + ' = ' + inttostr(strtointdef(Edit1.Text,0));
  Form1.cdsItems.Filtered := True;

  if Edit1.Text = '' then
    Form1.cdsItems.Filtered := False;
end;

procedure TF_Item.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TF_Item.FormCreate(Sender: TObject);
begin
  Busca := 'Nome';
end;

end.
