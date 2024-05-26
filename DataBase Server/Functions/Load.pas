unit Load;

interface

type TLoad = class
  public
    class function CarregarConfiguracoes(): Boolean; static;
end;

implementation

uses
  Log, GlobalDefs, IniFiles;

{ TLoad }

class function TLoad.CarregarConfiguracoes: Boolean;
var
  iniFile : TIniFile;
begin
  Result := False;
  iniFile := TIniFile.Create(CurrentDir + '\Configuracoes.ini');

  if (not iniFile.SectionExists('DataBaseServer')) then
  begin
    iniFile.WriteInteger('DataBaseServer', 'Porta', 0);
  end;

  ConfiguracoesDbServer.Porta := iniFile.ReadInteger('DataBaseServer', 'Porta', 0);
  if (ConfiguracoesDbServer.Porta = 0) then
  begin
    Logger.Write('Seção [DataBaseServer] no arquivo Configuracoes.ini não configurada.', TLogType.Warnings);
    exit;
  end;

  Result := True;
end;

end.
