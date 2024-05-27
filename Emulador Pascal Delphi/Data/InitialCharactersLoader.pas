unit InitialCharactersLoader;

interface

uses Windows, PlayerData, MiscData;

type TInitialCharactersLoader = class
    class procedure Load(); static;
  end;

var
  InitialCharacters: array[0..3] of TCharacter;

implementation

{ TInitialCharacters }

class procedure TInitialCharactersLoader.Load;
begin
  // TK
  ZeroMemory(@InitialCharacters[0], 4 * sizeof(TCharacter));
  InitialCharacters[0].ClassInfo:=0;
  InitialCharacters[0].Merchant:=1;
  InitialCharacters[0].BaseScore.Level:=0;
  InitialCharacters[0].Equip[0].Index:=1;
  InitialCharacters[0].BaseScore.Str:=8;
  InitialCharacters[0].BaseScore.Int:=4;
  InitialCharacters[0].BaseScore.Dex:=7;
  InitialCharacters[0].BaseScore.Con:=6;
  InitialCharacters[0].pSkill:=0;
  InitialCharacters[0].BaseScore.CurHP:=80;
  InitialCharacters[0].BaseScore.MaxHP:=80;
  InitialCharacters[0].BaseScore.Defense:=10;
  InitialCharacters[0].BaseScore.CurMP:=45;
  InitialCharacters[0].BaseScore.MaxMP:=45;
  InitialCharacters[0].BaseScore.Attack:=10;
  InitialCharacters[0].CurrentScore.CurHP:=80;
  InitialCharacters[0].CurrentScore.MaxHP:=80;
  InitialCharacters[0].RegenHP:=8;
  InitialCharacters[0].CurrentScore.CurMP:=45;
  InitialCharacters[0].CurrentScore.MaxMP:=45;
  InitialCharacters[0].RegenMP:=8;
  InitialCharacters[0].Equip[1].Index:=1106;
  InitialCharacters[0].Equip[2].Index:=1118;
  InitialCharacters[0].Equip[3].Index:=1130;
  InitialCharacters[0].Equip[4].Index:=1142;
  InitialCharacters[0].Equip[5].Index:=1154;
  InitialCharacters[0].Equip[byte(TEquipSlot.LWeapon)].Index := 861;
  InitialCharacters[0].Gold:=1000;
  InitialCharacters[0].BaseScore.MoveSpeed := 1;

  //InitialCharacters[0].Equip[0].Effects[1].Index:=98;
  //InitialCharacters[0].Equip[0].Effects[1].Value:=1;
  FillChar(InitialCharacters[0].SkillBar1[0], 4, 255);
  FillChar(InitialCharacters[0].SkillBar2[0], 16, 255);

  //FM
  InitialCharacters[1].ClassInfo:=1;
  InitialCharacters[1].Merchant:=11;
  InitialCharacters[1].BaseScore.Level:=0;
  InitialCharacters[1].Equip[0].Index:=11;
  InitialCharacters[1].BaseScore.Str:=5;
  InitialCharacters[1].BaseScore.Int:=8;
  InitialCharacters[1].BaseScore.Dex:=5;
  InitialCharacters[1].BaseScore.Con:=5;
  InitialCharacters[1].pSkill:=0;
  InitialCharacters[1].BaseScore.CurHP:=60;
  InitialCharacters[1].BaseScore.MaxHP:=60;
  InitialCharacters[1].BaseScore.Defense:=10;
  InitialCharacters[1].BaseScore.CurMP:=65;
  InitialCharacters[1].BaseScore.MaxMP:=65;
  InitialCharacters[1].BaseScore.Attack:=10;
  InitialCharacters[1].CurrentScore.CurHP:=60;
  InitialCharacters[1].CurrentScore.MaxHP:=60;
  InitialCharacters[1].RegenHP:=8;
  InitialCharacters[1].CurrentScore.CurMP:=65;
  InitialCharacters[1].CurrentScore.MaxMP:=65;
  InitialCharacters[1].RegenMP:=8;
  InitialCharacters[1].Equip[1].Index:=1256;
  InitialCharacters[1].Equip[2].Index:=1268;
  InitialCharacters[1].Equip[3].Index:=1280;
  InitialCharacters[1].Equip[4].Index:=1292;
  InitialCharacters[1].Equip[5].Index:=1304;
  InitialCharacters[1].Equip[byte(TEquipSlot.LWeapon)].Index := 891;
  InitialCharacters[1].Gold:=1000;
  InitialCharacters[1].BaseScore.MoveSpeed := 1;
  //InitialCharacters[1].Equip[0].Effects[1].Index:=98;
  //InitialCharacters[1].Equip[0].Effects[1].Value:=1;
  FillChar(InitialCharacters[1].SkillBar1[0], 4, 255);
  FillChar(InitialCharacters[1].SkillBar2[0],16, 255);

  //BM
  InitialCharacters[2].ClassInfo:=2;
  InitialCharacters[2].Merchant:=21;
  InitialCharacters[2].BaseScore.Level:=0;
  InitialCharacters[2].Equip[0].Index:=21;
  InitialCharacters[2].BaseScore.Str:=6;
  InitialCharacters[2].BaseScore.Int:=6;
  InitialCharacters[2].BaseScore.Dex:=9;
  InitialCharacters[2].BaseScore.Con:=5;
  InitialCharacters[2].pSkill:=0;
  InitialCharacters[2].BaseScore.CurHP:=70;
  InitialCharacters[2].BaseScore.MaxHP:=70;
  InitialCharacters[2].BaseScore.Defense:=10;
  InitialCharacters[2].BaseScore.CurMP:=55;
  InitialCharacters[2].BaseScore.MaxMP:=55;
  InitialCharacters[2].BaseScore.Attack:=10;
  InitialCharacters[2].CurrentScore.CurHP:=70;
  InitialCharacters[2].CurrentScore.MaxHP:=70;
  InitialCharacters[2].RegenHP:=8;
  InitialCharacters[2].CurrentScore.CurMP:=55;
  InitialCharacters[2].CurrentScore.MaxMP:=55;
  InitialCharacters[2].RegenMP:=8;
  InitialCharacters[2].Equip[1].Index:=1418;
  InitialCharacters[2].Equip[2].Index:=1421;
  InitialCharacters[2].Equip[3].Index:=1424;
  InitialCharacters[2].Equip[4].Index:=1427;
  InitialCharacters[2].Equip[5].Index:=1430;
  InitialCharacters[2].Equip[byte(TEquipSlot.LWeapon)].Index := 861;
  InitialCharacters[2].Gold:=1000;
  InitialCharacters[2].BaseScore.MoveSpeed := 1;
  //InitialCharacters[2].Equip[0].Effects[1].Index:=98;
  //InitialCharacters[2].Equip[0].Effects[1].Value:=1;
  FillChar(InitialCharacters[2].SkillBar1[0], 4, 255);
  FillChar(InitialCharacters[2].SkillBar2[0],16, 255);

  //HT
  InitialCharacters[3].ClassInfo:=3;
  InitialCharacters[3].Merchant:=31;
  InitialCharacters[3].BaseScore.Level:=0;
  InitialCharacters[3].Equip[0].Index:=31;
  InitialCharacters[3].BaseScore.Str:=8;
  InitialCharacters[3].BaseScore.Int:=9;
  InitialCharacters[3].BaseScore.Dex:=13;
  InitialCharacters[3].BaseScore.Con:=6;
  InitialCharacters[3].pSkill:=0;
  InitialCharacters[3].BaseScore.CurHP:=75;
  InitialCharacters[3].BaseScore.MaxHP:=75;
  InitialCharacters[3].BaseScore.Defense:=10;
  InitialCharacters[3].BaseScore.CurMP:=60;
  InitialCharacters[3].BaseScore.MaxMP:=60;
  InitialCharacters[3].BaseScore.Attack:=10;
  InitialCharacters[3].CurrentScore.CurHP:=75;
  InitialCharacters[3].CurrentScore.MaxHP:=75;
  InitialCharacters[3].RegenHP:=8;
  InitialCharacters[3].CurrentScore.CurMP:=50;
  InitialCharacters[3].CurrentScore.MaxMP:=50;
  InitialCharacters[3].RegenMP:=8;
  InitialCharacters[3].Equip[1].Index:=1567;
  InitialCharacters[3].Equip[2].Index:=1571;
  InitialCharacters[3].Equip[3].Index:=1574;
  InitialCharacters[3].Equip[4].Index:=1577;
  InitialCharacters[3].Equip[5].Index:=1580;
  InitialCharacters[3].Equip[byte(TEquipSlot.LWeapon)].Index := 816;
  InitialCharacters[3].Gold:=1000;
  InitialCharacters[3].BaseScore.MoveSpeed := 1;
  //InitialCharacters[3].Equip[0].Effects[1].Index:=98;
  //InitialCharacters[3].Equip[0].Effects[1].Value:=1;
  FillChar(InitialCharacters[3].SkillBar1[0], 4, 255);
  FillChar(InitialCharacters[3].SkillBar2[0],16, 255);
end;

end.
