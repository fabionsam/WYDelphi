unit U_DMDataBase;

interface

uses
  System.SysUtils, System.Classes, FireDAC.UI.Intf, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.MongoDB, FireDAC.Phys.MongoDBDef, System.Rtti, System.JSON.Types,
  System.JSON.Readers, System.JSON.BSON, System.JSON.Builders,
  FireDAC.Phys.MongoDBWrapper, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.UI,
  PlayerDataClasses, REST.Json;

type
  TDMDataBase = class(TDataModule)
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDConnection: TFDConnection;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    FConMongo: TMongoConnection;
    procedure UpdateAccount(Account : TAccountFileClass; accountId : String);
    procedure UpdateActive(Active: Boolean); overload;
    procedure UpdateActive(Active: Boolean; serverId : Byte); overload;
    procedure UpdateActive(Active: Boolean; accountId : String; serverId : Byte); overload;
    function CharacterNameInUse(Name: String): Boolean;
  end;

var
  DMDataBase: TDMDataBase;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDMDataBase.DataModuleCreate(Sender: TObject);
begin
  FDConnection.Connected := True;
  FConMongo := TMongoConnection(FDConnection.CliObj);
end;

procedure TDMDataBase.UpdateAccount(Account : TAccountFileClass; accountId : String);
var
  MongoUpd : TMongoUpdate;
begin
  MongoUpd := TMongoUpdate.Create(FConMongo.Env);
  MongoUpd.Match().Add('_id', TJsonOId.Create(accountId));
  MongoUpd.Modify().&Set(TJson.ObjectToJsonString(Account)).&End;
  FConMongo['wyd']['account'].Update(MongoUpd);
  MongoUpd.Free;
end;

procedure TDMDataBase.UpdateActive(Active: Boolean);
var
  MongoUpd : TMongoUpdate;
begin
  MongoUpd := TMongoUpdate.Create(FConMongo.Env);
  MongoUpd.Match(); //obtendo todos os registros
  MongoUpd.Modify().&Set().Field('header.isActive', Active).&End;
  FConMongo['wyd']['account'].Update(MongoUpd);
  MongoUpd.Free;
end;

procedure TDMDataBase.UpdateActive(Active: Boolean; serverId : Byte);
var
  MongoUpd : TMongoUpdate;
begin
  MongoUpd := TMongoUpdate.Create(FConMongo.Env);
  MongoUpd.Match().Add('header.serverIdActive', serverId);
  MongoUpd.Modify().&Set().Field('header.isActive', Active).&End;
  FConMongo['wyd']['account'].Update(MongoUpd);
  MongoUpd.Free;
end;

procedure TDMDataBase.UpdateActive(Active: Boolean; accountId : String; serverId : Byte);
var
  MongoUpd : TMongoUpdate;
begin
  MongoUpd := TMongoUpdate.Create(FConMongo.Env);
  MongoUpd.Match().Add('_id', TJsonOId.Create(accountId));
  MongoUpd.Modify().&Set().Field('header.isActive', Active).Field('header.serverIdActive', serverId).&End;
  FConMongo['wyd']['account'].Update(MongoUpd);
  MongoUpd.Free;
end;

function TDMDataBase.CharacterNameInUse(Name: String): Boolean;
var
  crs: IMongoCursor;
begin
  crs := FConMongo['wyd']['account'].Find().Match('{ "characters": { $elemMatch: {"base.name": "'+Name+'" } } }').&End;
  Result := crs.Next;
end;

end.
