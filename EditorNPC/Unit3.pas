unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TF_Adicionais = class(TForm)
    GroupBox1: TGroupBox;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Edit3: TEdit;
    Label4: TLabel;
    Edit4: TEdit;
    Label5: TLabel;
    Edit5: TEdit;
    Edit6: TEdit;
    Label6: TLabel;
    Edit7: TEdit;
    Label7: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  F_Adicionais: TF_Adicionais;

implementation

{$R *.dfm}

uses Unit2;

procedure TF_Adicionais.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  F_Item.Edit1.Text             := Edit1.Text + ' ' + Edit2.Text + ' ' + Edit3.Text + ' ' + Edit4.Text + ' ' + Edit5.Text + ' ' + Edit6.Text + ' ' + Edit7.Text;
  F_Item.mItem.Index            := strtoint(Edit1.Text);
  F_Item.mItem.Effects[0].Index := strtoint(Edit2.Text);
  F_Item.mItem.Effects[0].Value  := strtoint(Edit3.Text);
  F_Item.mItem.Effects[1].Index   := strtoint(Edit4.Text);
  F_Item.mItem.Effects[1].Value  := strtoint(Edit5.Text);
  F_Item.mItem.Effects[2].Index   := strtoint(Edit6.Text);
  F_Item.mItem.Effects[2].Value  := strtoint(Edit7.Text);
  Action := caFree;
end;

end.
