unit BMBuffs;

interface

Uses PlayerData, BaseMob, MiscData, ItemFunctions, Log,
   Windows, Messages, SysUtils, Variants, Classes, DateUtils,
   ScktComp, Packets, Player, MMSystem,
   Generics.Collections, Functions;

  type TBMBuffs = class(TObject)
  published
    procedure ChangeFace(var attacker, target : TBaseMob; skillId, face, vdiv, master : Byte);
    procedure Lobisomem(var attacker, target : TBaseMob; skillId : Byte);
    procedure Astaroth(var attacker, target: TBaseMob; skillId: Byte);
    procedure Eden(var attacker, target: TBaseMob; skillId: Byte);
    procedure HomemUrso(var attacker, target: TBaseMob; skillId: Byte);
    procedure Tita(var attacker, target: TBaseMob; skillId: Byte);
  end;

implementation

Uses GlobalDefs;

var Affects : TAffect;

procedure TBMBuffs.ChangeFace(var attacker, target : TBaseMob; skillId, face, vdiv, master : Byte);
var sanc : BYTE;
begin
  Affects.Index  := 16;
  Affects.Master := master;
  Affects.Value  := attacker.Character.CurrentScore.tMaster;
  Affects.Time   := ((SkillsData[skillId].AffectTime div 2) + (attacker.Character.CurrentScore.tMaster div 5));

  if (target.Character.Equip[0].Effects[2].Value = 0) then
    target.Character.Equip[0].Effects[2].Value := target.Character.Equip[0].Index;

  target.Character.Equip[0].Index := face;

  sanc := (target.Character.CurrentScore.tMaster div vdiv);
  if(sanc > 9)then
    sanc := 9;

  target.Character.Equip[0].Effects[0].Index := 43;
  target.Character.Equip[0].Effects[0].Value := sanc;

  target.AddAffect(Affects);
  target.SendEquipItems();
  target.SendAffects();
  target.SendScore();
end;

procedure TBMBuffs.Lobisomem(var attacker, target : TBaseMob; skillId : Byte);
begin
  ChangeFace(attacker, target, skillId, 22, 25, 1);
end;

procedure TBMBuffs.HomemUrso(var attacker, target : TBaseMob; skillId : Byte);
begin
  ChangeFace(attacker, target, skillId, 23, 25, 2);
end;

procedure TBMBuffs.Astaroth(var attacker, target : TBaseMob; skillId : Byte);
begin
  ChangeFace(attacker, target, skillId, 24, 25, 3);
end;

procedure TBMBuffs.Tita(var attacker, target : TBaseMob; skillId : Byte);
begin
  ChangeFace(attacker, target, skillId, 25, 25, 4);
end;

procedure TBMBuffs.Eden(var attacker, target : TBaseMob; skillId : Byte);
begin
  ChangeFace(attacker, target, skillId, 32, 25, 5);
end;

end.
