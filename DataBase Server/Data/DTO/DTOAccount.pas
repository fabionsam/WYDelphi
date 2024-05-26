unit DTOAccount;

interface

uses
  PlayerData, PlayerDataClasses;

type
  TDTOAccount = class
    public
      class function AccountStructToClass(Acc : TAccountFile): TAccountFileClass; static;
  end;

implementation

uses
  ConstDefs;

{ TDTOAccount }

class function TDTOAccount.AccountStructToClass(
  Acc: TAccountFile): TAccountFileClass;
var
  i, j, k : BYTE;
begin
  Result := TAccountFileClass.Create;
  Result.Header.Username := Acc.Header.Username;
  Result.Header.PassWord := Acc.Header.Password;
  Result.Header.isActive := Acc.Header.IsActive;
  Result.Header.StorageGold := Acc.Header.StorageGold;
  Result.Header.NumericToken := Acc.Header.NumericToken;
  for I := 0 to MAX_CARGO-1 do
  begin
    Result.Header.StorageItens[i].Index := Acc.Header.StorageItens[i].Index;
    for j := 0 to 2 do
    begin
      Result.Header.StorageItens[i].Effects[j].Index := Acc.Header.StorageItens[i].Effects[j].Index;
      Result.Header.StorageItens[i].Effects[j].Value := Acc.Header.StorageItens[i].Effects[j].Value;
    end;
  end;

  for I := 0 to 3 do
  begin
    Result.Characters[i].LastAction := Acc.Characters[i].LastAction;
    Result.Characters[i].PlayerKill := Acc.Characters[i].PlayerKill;
    Result.Characters[i].CurrentKill := Acc.Characters[i].CurrentKill;
    Result.Characters[i].CP := Acc.Characters[i].CP;
    Result.Characters[i].TotalKill := Acc.Characters[i].TotalKill;
    Result.Characters[i].Fame := Acc.Characters[i].Fame;
    Result.Characters[i].CurrentCity := Byte(Acc.Characters[i].CurrentCity);
    Result.Characters[i].GemaEstelar.SetPosition(Acc.Characters[i].GemaEstelar.X, Acc.Characters[i].GemaEstelar.Y);
    Result.Characters[i].Fame := Acc.Characters[i].Fame;
    Result.Characters[i].CurrentCity := Byte(Acc.Characters[i].CurrentCity);
    Result.Characters[i].Citizenship := Integer(Acc.Characters[i].Citizenship);
    Result.Characters[i].CharacterQuests.SetQuests(Acc.Characters[i].CharacterQuests.MolarDoGargula,
                                                   Acc.Characters[i].CharacterQuests.PilulaMagica,
                                                   Acc.Characters[i].CharacterQuests.ArchDesbloq355,
                                                   Acc.Characters[i].CharacterQuests.ArchDesbloq370,
                                                   Acc.Characters[i].CharacterQuests.CristaisArch);
    Result.Characters[i].Base.Name := Acc.Characters[i].Base.Name;
    Result.Characters[i].Base.CapeInfo := Acc.Characters[i].Base.CapeInfo;
    Result.Characters[i].Base.GuildIndex := Acc.Characters[i].Base.GuildIndex;
    Result.Characters[i].Base.Merch := Acc.Characters[i].Base.Merchant;
    Result.Characters[i].Base.City := Acc.Characters[i].Base.CityId;
    Result.Characters[i].Base.ClassInfo := Acc.Characters[i].Base.ClassInfo;
    Result.Characters[i].Base.QuestInfo := Acc.Characters[i].Base.QuestInfo;
    Result.Characters[i].Base.Gold := Acc.Characters[i].Base.Gold;
    Result.Characters[i].Base.Exp := Acc.Characters[i].Base.Exp;
    Result.Characters[i].Base.Last := TPositionClass.Create(Acc.Characters[i].Base.Last.X, Acc.Characters[i].Base.Last.Y);
    Result.Characters[i].Base.Learn := Acc.Characters[i].Base.Learn;
    Result.Characters[i].Base.pStatus := Acc.Characters[i].Base.pStatus;
    Result.Characters[i].Base.pMaster := Acc.Characters[i].Base.pMaster;
    Result.Characters[i].Base.pSkill := Acc.Characters[i].Base.pSkill;
    Result.Characters[i].Base.Critical := Acc.Characters[i].Base.Critical;
    Result.Characters[i].Base.SaveMana := Acc.Characters[i].Base.SaveMana;
    Result.Characters[i].Base.GuildMemberType := Acc.Characters[i].Base.GuildMemberType;
    Result.Characters[i].Base.MagicIncrement := Acc.Characters[i].Base.MagicIncrement;
    Result.Characters[i].Base.RegenHP := Acc.Characters[i].Base.RegenMP;
    Result.Characters[i].Base.RegenMP := Acc.Characters[i].Base.RegenMP;
    Result.Characters[i].Base.AffectInfo.SlowMov := Acc.Characters[i].Base.AffectInfo.SlowMov;
    Result.Characters[i].Base.AffectInfo.DrainHP := Acc.Characters[i].Base.AffectInfo.DrainHP;
    Result.Characters[i].Base.AffectInfo.VisionDrop := Acc.Characters[i].Base.AffectInfo.VisionDrop;
    Result.Characters[i].Base.AffectInfo.Evasion := Acc.Characters[i].Base.AffectInfo.Evasion;
    Result.Characters[i].Base.AffectInfo.Snoop := Acc.Characters[i].Base.AffectInfo.Snoop;
    Result.Characters[i].Base.AffectInfo.SpeedMov := Acc.Characters[i].Base.AffectInfo.SpeedMov;
    Result.Characters[i].Base.AffectInfo.SkillDelay := Acc.Characters[i].Base.AffectInfo.SkillDelay;
    Result.Characters[i].Base.AffectInfo.Resist := Acc.Characters[i].Base.AffectInfo.Resist;

    for k := 0 to MAX_EQUIPS-1 do
    begin
      Result.Characters[i].Base.Equip[k].Index := Acc.Characters[i].Base.Equip[k].Index;
      for j := 0 to 2 do
      begin
        Result.Characters[i].Base.Equip[k].Effects[j].Index := Acc.Characters[i].Base.Equip[k].Effects[j].Index;
        Result.Characters[i].Base.Equip[k].Effects[j].Value := Acc.Characters[i].Base.Equip[k].Effects[j].Value;
      end;
    end;

    for k := 0 to MAX_INV-1 do
    begin
      Result.Characters[i].Base.Inventory[k].Index := Acc.Characters[i].Base.Inventory[k].Index;
      for j := 0 to 2 do
      begin
        Result.Characters[i].Base.Inventory[k].Effects[j].Index := Acc.Characters[i].Base.Inventory[k].Effects[j].Index;
        Result.Characters[i].Base.Inventory[k].Effects[j].Value := Acc.Characters[i].Base.Inventory[k].Effects[j].Value;
      end;
    end;

    Result.Characters[i].Base.BaseScore.Level := Acc.Characters[i].Base.BaseScore.Level;
    Result.Characters[i].Base.BaseScore.Defense := Acc.Characters[i].Base.BaseScore.Defense;
    Result.Characters[i].Base.BaseScore.Attack := Acc.Characters[i].Base.BaseScore.Attack;
    Result.Characters[i].Base.BaseScore.Merch := Acc.Characters[i].Base.BaseScore.Merchant;
    Result.Characters[i].Base.BaseScore.Direction := Acc.Characters[i].Base.BaseScore.Direction;
    Result.Characters[i].Base.BaseScore.Move := Acc.Characters[i].Base.BaseScore.MoveSpeed;
    Result.Characters[i].Base.BaseScore.Chaos := Acc.Characters[i].Base.BaseScore.ChaosRate;
    Result.Characters[i].Base.BaseScore.MaxHP := Acc.Characters[i].Base.BaseScore.MaxHP;
    Result.Characters[i].Base.BaseScore.MaxMP := Acc.Characters[i].Base.BaseScore.MaxMP;
    Result.Characters[i].Base.BaseScore.CurHP := Acc.Characters[i].Base.BaseScore.CurHP;
    Result.Characters[i].Base.BaseScore.CurMP := Acc.Characters[i].Base.BaseScore.CurMP;
    Result.Characters[i].Base.BaseScore.Str := Acc.Characters[i].Base.BaseScore.Str;
    Result.Characters[i].Base.BaseScore.Int := Acc.Characters[i].Base.BaseScore.Int;
    Result.Characters[i].Base.BaseScore.Dex := Acc.Characters[i].Base.BaseScore.Dex;
    Result.Characters[i].Base.BaseScore.Con := Acc.Characters[i].Base.BaseScore.Con;
    Result.Characters[i].Base.BaseScore.wMaster := Acc.Characters[i].Base.BaseScore.wMaster;
    Result.Characters[i].Base.BaseScore.fMaster := Acc.Characters[i].Base.BaseScore.fMaster;
    Result.Characters[i].Base.BaseScore.sMaster := Acc.Characters[i].Base.BaseScore.sMaster;
    Result.Characters[i].Base.BaseScore.tMaster := Acc.Characters[i].Base.BaseScore.tMaster;
  end;
end;

end.
