unit U_Principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient, Vcl.StdCtrls, players,
  Vcl.Grids, Vcl.DBGrids;

type
  TF_Principal = class(TForm)
    Button1: TButton;
    cdsItemList: TClientDataSet;
    cdsItemListNome: TStringField;
    cdsItemListMesh: TIntegerField;
    cdsItemListSubMesh: TIntegerField;
    cdsItemListUnknow: TIntegerField;
    cdsItemListLevel: TIntegerField;
    cdsItemListSTR: TIntegerField;
    cdsItemListINT: TIntegerField;
    cdsItemListDEX: TIntegerField;
    cdsItemListCON: TIntegerField;
    cdsItemListEffect1: TIntegerField;
    cdsItemListvEffect1: TIntegerField;
    cdsItemListEffect2: TIntegerField;
    cdsItemListvEffect2: TIntegerField;
    cdsItemListEffect3: TIntegerField;
    cdsItemListvEffect3: TIntegerField;
    cdsItemListEffect4: TIntegerField;
    cdsItemListvEffect4: TIntegerField;
    cdsItemListEffect5: TIntegerField;
    cdsItemListvEffect5: TIntegerField;
    cdsItemListEffect6: TIntegerField;
    cdsItemListvEffect6: TIntegerField;
    cdsItemListEffect7: TIntegerField;
    cdsItemListvEffect7: TIntegerField;
    cdsItemListEffect8: TIntegerField;
    cdsItemListvEffect8: TIntegerField;
    cdsItemListEffect9: TIntegerField;
    cdsItemListvEffect9: TIntegerField;
    cdsItemListEffect10: TIntegerField;
    cdsItemListvEffect10: TIntegerField;
    cdsItemListEffect11: TIntegerField;
    cdsItemListvEffect11: TIntegerField;
    cdsItemListEffect12: TIntegerField;
    cdsItemListvEffect12: TIntegerField;
    cdsItemListPrice: TIntegerField;
    cdsItemListUnique: TIntegerField;
    cdsItemListPos: TIntegerField;
    cdsItemListExtreme: TIntegerField;
    cdsItemListGrade: TIntegerField;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    cdsItemListID: TIntegerField;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure Edit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


var
  F_Principal: TF_Principal;  ItemList: array of st_ItemListConvert; Busca: string;

implementation

{$R *.dfm}

procedure TF_Principal.Button1Click(Sender: TObject);
var f: TFileStream;
buffer: array of BYTE;
local: string;
I,j, size: Integer;
begin

  local:=getcurrentdir+'\ItemList.bin';

  if not(FileExists(local)) then
  begin
    showmessage('Arquivo não encontrado. Coloque o ItemList.bin na mesma pasta que o Leitor de ItemList.');
    exit;
  end;

  F := TFileStream.Create(local, fmOpenRead);
  size := F.Size;
  SetLength(buffer,size);
  F.Read(buffer[0],size);
  F.Free;

  for I := 0 to size do
  begin
    buffer[i] := $5A xor buffer[i];
  end;

  setlength(itemlist, Round(size/140));
  Move(buffer[0], itemlist[0], size);

  cdsItemList.CreateDataSet;
  for I := 0 to Round(size/140) do
  begin
    with cdsItemList do
    begin
      Append;
      FieldByName('ID').AsInteger := i;
      FieldByName('Nome').AsString := ItemList[i].Name;
      FieldByName('Mesh').AsInteger := ItemList[i].Mesh;
      FieldByName('SubMesh').AsInteger := ItemList[i].SubMesh;
      FieldByName('Unknow').AsInteger := ItemList[i].Unknow;
      FieldByName('Level').AsInteger := ItemList[i].Level;
      FieldByName('STR').AsInteger := ItemList[i].STR;
      FieldByName('INT').AsInteger := ItemList[i].INT;
      FieldByName('DEX').AsInteger := ItemList[i].DEX;
      FieldByName('CON').AsInteger := ItemList[i].CON;
      for j := 0 to 11 do
      begin
        FieldByName('Effect'+inttostr(j+1)).AsInteger  := ItemList[i].Effect[j].index;
        FieldByName('vEffect'+inttostr(j+1)).AsInteger := ItemList[i].Effect[j].value;
      end;
      FieldByName('Price').AsInteger := ItemList[i].Price;
      FieldByName('Unique').AsInteger := ItemList[i].Unique;
      FieldByName('Pos').AsInteger := ItemList[i].Pos;
      FieldByName('Extreme').AsInteger := ItemList[i].Extreme;
      FieldByName('Grade').AsInteger := ItemList[i].Grade;
      Post;
    end;
  end;
  cdsItemList.Filtered := False;
  cdsItemList.Filter := 'Nome <> '+QuotedStr('');
  cdsItemList.Filtered := True;
end;

procedure TF_Principal.DBGrid1CellClick(Column: TColumn);
begin
  Busca := Column.Title.Caption;
end;

procedure TF_Principal.Edit1Change(Sender: TObject);
begin
  cdsItemList.Filtered := False;
  cdsItemList.FilterOptions := [foCaseInsensitive];
  if Busca = 'Nome' then
    cdsItemList.Filter := Busca + ' LIKE ''%' + Edit1.Text + '%'''
  else
    cdsItemList.Filter := Busca + ' = ' + inttostr(strtointdef(Edit1.Text,0));
    cdsItemList.Filtered := True;

  if Edit1.Text = '' then
  begin
    cdsItemList.Filtered := False;
    cdsItemList.Filter := 'Nome <> '+QuotedStr('');
    cdsItemList.Filtered := True;
  end;
end;

procedure TF_Principal.FormCreate(Sender: TObject);
begin
  Busca := 'Nome';
  Button1.Click;
  Edit1.Enabled := True;
end;

end.
