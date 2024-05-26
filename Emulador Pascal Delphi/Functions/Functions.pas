unit Functions;

interface

uses Classes, StrUtils, SysUtils, Windows, MiscData, PlayerData, BaseMob, Player, Math,
    Packets, Position, System.Threading, Variants;

type TTipoPacote = (Enviado, Recebido);
type TPacketFile = packed record
  Bytes: Array[0..3000] of byte;
end;

type TFunctions = class
  public
    class function FreeClientId() : WORD; static;

    class function IsNumeric(str : string; out Value: Integer) : Boolean; overload; static;
    class function IsNumeric(str : string; out Value: short) : Boolean; overload; static;
    class function IsNumeric(str: string): Boolean; overload; static;

    class function IsLetter(text: string): Boolean; static;
    class function Clock() : Cardinal; static;
    class function CharArrayToString(chars : array of AnsiChar) : string; static;
    class function FindFreePartyId: WORD; static;
    class function CompareCharOwner(const player : TPlayer; characterName : string) : Boolean; static;

    class function GetRoute(pos: TPosition; var dest: TPosition; var route : array of AnsiChar; distance: Byte) : Integer;

    class function GetStartXY(var player : TPlayer; charId : Byte) : TPosition; overload; static;
    class function GetStartXY(var player : TPlayer) : TPosition; overload; static;
    class function GetStartXY(cityId : TCity) : TPosition; overload; static;

    class function GetEmptyMobGrid(index: WORD; var pos : TPosition; radius: WORD = 6): Boolean; overload; static;
    class function GetEmptyMobGrid(index: WORD; var posX: SmallInt; var posY: SmallInt; radius: WORD = 6) : Boolean; overload; static;

    class function GetEmptyItemGrid(index: WORD; var pos : TPosition): Boolean; overload; static;
    class function GetEmptyItemGrid(index: WORD; var posX: SmallInt; var posY: SmallInt) : Boolean; overload; static;

    class function GetRandomEmptyMobGrid(index: WORD; var pos : TPosition; radius: WORD = 6; chances: Word = 3) : Boolean; overload; static;
    class function GetRandomEmptyMobGrid(index: WORD; var posX: SmallInt; var posY: SmallInt; radius: WORD = 6; chances: Word = 3) : Boolean; overload; static;

    class function GetFreeMob() : WORD; static;

    class function Rand(num: integer = 0) : integer; overload; static;
    class function Rand(num, num2: integer) : integer; overload; static;

    class procedure ClearArea(pos1, pos2: TPosition); static;

    class function UpdateWorld(index: Integer; var pos: TPosition; flag: Byte): Boolean;
    class function GetAction(mob: TBaseMob; pos: TPosition; actionType: Byte): TMovementPacket;

    class procedure SendWorldMessage(str: AnsiString);

    class function TrocaCaracterEspecial(aTexto: string; aLimExt: boolean): string; static;
    class procedure StringToAnsiChar(aTexto : string; var aReceptor : Array of AnsiChar); static;

    class function GetCurrTime: TDateTime; inline;

    class procedure SavePacket(tipo: TTipoPacote; packet: Pointer);

    class function CheckItensTrade(player : TPlayer; transfer: Boolean): boolean;

end;

implementation
{ TFunctions }

uses GlobalDefs, ConstDefs, Log, NPC, PacketsDbServer, ItemFunctions;

class function TFunctions.GetCurrTime: TDateTime;
begin
  Result := Now;
end;

class function TFunctions.FindFreePartyId(): WORD;
var
  resultado : Variant;
begin
  resultado := TParallel.For(1 , MAX_CONNECTIONS, procedure(i : Integer; loopState : TParallel.TLoopState)
  begin
    if (Parties[i].Leader = 0) then
    begin
      loopState.break;
    end;
  end).LowestBreakIteration;

  if (VarIsNull(resultado)) then
    result := 751
  else
    result := resultado;
end;

class function TFunctions.FreeClientId: WORD;
var i: WORD;
begin
  result := 0;

  if(TPlayer.InstantiatedPlayers + 1 > MAX_CONNECTIONS) then
    exit;

  for i := 1 to (MAX_CONNECTIONS - 1) do
  begin
    if not(Assigned(TPlayer.Players[i])) then
    begin
      result := i;
      exit;
    end;
  end;
end;

class function TFunctions.IsNumeric(str: string; out Value: short): Boolean;
var
  E: Integer;
begin
  Val(str, Value, E);
  Result := E = 0;
end;

class function TFunctions.IsNumeric(str: string; out Value: Integer): Boolean;
var
  E: Integer;
begin
  Val(str, Value, E);
  Result := E = 0;
end;

class function TFunctions.IsNumeric(str: string): Boolean;
var
  E: Integer;
  Value: Integer;
begin
  Val(str, Value, E);
  Result := E = 0;
end;

class function TFunctions.Rand(num, num2: integer): integer;
begin
  Result := RandomRange(num, num2);
  Randomize;
end;

class function TFunctions.Rand(num: integer = 0): integer;
begin
  Randomize;
  if(num = 0) then
  begin
    result := Trunc(Random);
    exit;
  end;
  result := Random(num);
end;

class procedure TFunctions.SavePacket(tipo: TTipoPacote; packet: Pointer);
var
  f: File of TPacketFile;
  packetFile: TPacketFile;
  local : string;
begin
  ZeroMemory(@packetFile, sizeof(TPacketFile));
  Move(packet, packetFile.Bytes[0], TPacketHeader(packet^).Size);

  local := CurrentDir + '\Pacotes\' + IfThen(tipo = Enviado, 'Enviados', 'Recebidos');
  if not (DirectoryExists(local)) then
    ForceDirectories(local);

  AssignFile(f, local + Format('\0x%x', [TPacketHeader(packet^).Code]) + '_' + FormatDateTime('ddmmyyyy_hhnnsszz', now) + '.pckt');
  ReWrite(f);
  Write(f, packetFile);
  CloseFile(f);
end;

class procedure TFunctions.SendWorldMessage(str: AnsiString);
var player: TPlayer;
begin
  for player in TPlayer.Players do
  begin
    player.SendClientMessage(str);
  end;
end;

class function TFunctions.UpdateWorld(index: Integer; var pos: TPosition; flag: Byte): Boolean;
var mob: TBaseMob;
begin
  Result := false;
	if flag = WORLD_MOB then
	begin
    if not TBaseMob.GetMob(index, mob) then
      exit;

		Result := GetEmptyMobGrid(index, pos);
		if Result then
		begin
			MobGrid[mob.CurrentPosition.Y][mob.CurrentPosition.X] := 0;
			MobGrid[pos.Y][pos.X] := index;
    end;
    exit;
  end
	else if flag = WORLD_ITEM then
  begin
		if (Index >= MAX_INITITEM_LIST) OR (Index < 0) then
    begin
      exit;
    end;

		Result := GetEmptyItemGrid(Index, pos);
		if Result then
		begin
			ItemGrid[pos.Y][pos.X] := Index;
    end;
	  exit;
  end;
end;

class function TFunctions.IsLetter(text: string): boolean;
const ALPHA_CHARS = ['a'..'z', 'A'..'Z'];
begin
  if(Length(text) > 0) AND (text[1] in ALPHA_CHARS) then begin
    Result := true;
    exit;
  end;
  result := false;
end;

class function TFunctions.CharArrayToString(chars: array of AnsiChar): string;
begin
  if (Length(chars) > 0) then
    SetString(Result, PAnsiChar(@chars[0]), Length(chars))
  else
    Result := '';

  Result := Trim(Result);
end;

class procedure TFunctions.ClearArea(pos1, pos2: TPosition);
begin
  TParallel.For(pos1.X, pos2.X,
  Procedure(x : Integer)
  begin
    TParallel.For(pos1.Y, pos2.Y,
    Procedure(y : Integer)
    var
      mob: TBaseMob;
      p: TPosition;
    begin
      p.Create(x, y);

      if not(TBaseMob.GetMob(p, mob)) then exit;

      if(mob.IsPlayer) then
        p := GetStartXY(TPlayer.Players[mob.ClientId]);
      mob.Teleport(p);
//      FreeAndNil(p);
    end);
  end);
end;

class function TFunctions.Clock() : Cardinal;
begin
  result := GetTickCount();
end;

class function TFunctions.CompareCharOwner(const player: TPlayer; characterName: string): Boolean;
var
  i : Byte;
begin
  Result := False;
  for I := 0 to 3 do
  begin
     Result := AnsiCompareStr(player.Account.Characters[i].Base.Name, characterName) = 0;
     if (Result) then
      break;
  end;
end;

class function TFunctions.GetFreeMob() : WORD;
var i:WORD;
begin
  result := 0;
  for i := 1001 to 30000 do
  begin
    if not(Assigned(TNPC.NPCs[i])) then
    begin
      result := i;
      break;
    end;
  end;
end;

class function TFunctions.GetRandomEmptyMobGrid(index: WORD; var pos: TPosition;
  radius: WORD; chances: Word): Boolean;
begin
  Result := GetRandomEmptyMobGrid(index, pos.X, pos.Y, radius, chances);
end;

class function TFunctions.GetRandomEmptyMobGrid(index: WORD; var posX,
  posY: SmallInt; radius: WORD; chances: Word): Boolean;
var nY, nX: integer;
  r: Byte;
  w,t,x,y: Integer;
begin
  if(posX < 0) or (posX >= 4096) or (posY < 0) or (posY >= 4096) then
  begin
    result := false;
    exit;
  end;

  if(MobGrid[posY][posX] = Index) OR (MobGrid[posY][posX] = 0) then
  begin
    if(HeightGrid.p[posY][posX] <> 127)then
    begin
      result := true;
      exit;
    end;
  end;

  for r := 1 to chances do
  begin
    x := r * Round(Sqrt(Random(radius)));
    y := 2 * Round(Pi * Random(radius));

    nX := posX + x;
    nY := posY + y;

    if(MobGrid[nY][nX] = 0) then
    begin
      if(HeightGrid.p[nY][nX] <> 127) then
      begin
        posX := nX;
        posY := nY;
        result := true;
        exit;
      end;
    end;
  end;
  result := false;
end;

class function TFunctions.GetEmptyMobGrid(index: WORD; var pos: TPosition; radius: WORD = 6): Boolean;
begin
  Result := GetEmptyMobGrid(index, pos.X, pos.Y, radius);
end;

class function TFunctions.GetAction(mob: TBaseMob; pos: TPosition; actionType: Byte): TMovementPacket;
var
  i : Byte;
begin
  ZeroMemory(@Result, SizeOf(TMovementPacket));

  Result.Header.Size := sizeof(TMovementPacket);
  Result.Header.Code := $366;
  Result.Header.Index := mob.Clientid;

	Result.Speed := mob.Character.CurrentScore.MoveSpeed;
  Result.Destination := pos;
  Result.Source := mob.Character.Last;

	Result.MoveType := actionType;

  if (actionType = MOVE_NORMAL) then
    mob.Character.CurrentScore.Direction := GetRoute(mob.CurrentPosition, Result.Destination, Result.Route, mob.CurrentPosition.WYDDistance(pos));
end;

class function TFunctions.GetEmptyItemGrid(index: WORD; var pos: TPosition): Boolean;
begin
  Result := GetEmptyItemGrid(index, pos.X, pos.Y);
end;

class function TFunctions.GetEmptyItemGrid(index: WORD; var posX, posY: SmallInt): Boolean;
var nY, nX: integer;
begin
  if(posX < 0) or (posX >= 4096) or (posY < 0) or (posY >= 4096) then
  begin
    Logger.Write('GetEmptyItemGrid: Posição fora do limite permitido X:' + IntToStr(posX) + '-Y:' + IntToStr(posY), TLogType.Warnings);
    result := false;
    exit;
  end;

  if(ItemGrid[posY][posX] = Index) then
  begin
    result := true;
    exit;
  end;

  if (ItemGrid[posY][posX] = 0) then
  begin
    if(HeightGrid.p[posY][posX] <> 127)then
    begin
      result := true;
      exit;
    end;
  end;

  for nY := posY - 1 to posY + 1 do
  begin
    for nX := posX - 1 to posX + 1 do
    begin
      if(ItemGrid[nY][nX] = 0)then
      begin
        if(HeightGrid.p[nY][nX] <> 127)then
        begin
          posX := nX;
          posY := nY;
          result := true;
          exit;
        end;
      end;
    end;
  end;
  result := false;
end;

class function TFunctions.GetEmptyMobGrid(index: WORD; var posX: SmallInt; var posY: SmallInt; radius: WORD = 6) : Boolean;
var nY, nX: integer;
  r: Byte;
  neighbor: TPosition;
begin
  if(posX < 0) or (posX >= 4096) or (posY < 0) or (posY >= 4096) then
  begin
    Logger.Write('GetEmptyMobGrid: Posição fora do limite permitido X:' + IntToStr(posX) + '-Y:' + IntToStr(posY), TLogType.Warnings);
    result := false;
    exit;
  end;

  if(MobGrid[posY][posX] = Index) OR (MobGrid[posY][posX] = 0) then
  begin
    if(HeightGrid.p[posY][posX] <> 127)then
    begin
      result := true;
      exit;
    end;
  end;

  for r := 1 to radius do
  begin
    for neighbor in Neighbors do
    begin
      nX := posX + (neighbor.X * r);
      nY := posY + (neighbor.Y * r);

      if(MobGrid[nY][nX] = 0)then
      begin
        if(HeightGrid.p[nY][nX] <> 127)then
        begin
          posX := nX;
          posY := nY;
          result := true;
          exit;
        end;
      end;
    end;
  end;
  result := false;
//  Logger.Write('MobAction: Sem nenhum espaço livre para movimento.', TLogType.Warnings);
end;

class function TFunctions.GetStartXY(cityId: TCity): TPosition;
begin
  case(cityId) of
    TCity.Armia: //armia
    begin
      Result.X := 2100;
      Result.Y := 2100;
      end;
    TCity.Azram:
    begin
      Result.X := 2507;
      Result.Y := 1715;
      end;
    TCity.Erion:
    begin
      Result.X := 2461;
      Result.Y := 1997;
      end;
    TCity.Karden:
    begin
      Result.X := 3645;
      Result.Y := 3130;
    end;
	end;
end;

class function TFunctions.GetStartXY(var player : TPlayer; charId : Byte) : TPosition;
begin
  if(player.Account.Characters[charId].Base.BaseScore.Level < 35) then
  begin
    Result.X := 2112;
    Result.Y := 2041;
    player.Account.Characters[charId].CurrentCity := TCity.Armia;
    exit;
  end;
  Result := GetStartXY(player.Account.Characters[charId].CurrentCity);
end;

class function TFunctions.GetStartXY(var player : TPlayer) : TPosition;
begin
  if(player.Character.BaseScore.Level < 35) then
  begin
    Result.X := 2112;
    Result.Y := 2041;
    player.PlayerCharacter.CurrentCity := TCity.Armia;
    exit;
  end;
  Result := GetStartXY(player.PLayerCharacter.CurrentCity);
end;

class function TFunctions.TrocaCaracterEspecial(aTexto : string; aLimExt : boolean) : string;
const
  //Lista de caracteres especiais
  xCarEsp: array[1..38] of String = ('á', 'à', 'ã', 'â', 'ä','Á', 'À', 'Ã', 'Â', 'Ä',
                                     'é', 'è','É', 'È','í', 'ì','Í', 'Ì',
                                     'ó', 'ò', 'ö','õ', 'ô','Ó', 'Ò', 'Ö', 'Õ', 'Ô',
                                     'ú', 'ù', 'ü','Ú','Ù', 'Ü','ç','Ç','ñ','Ñ');
  //Lista de caracteres para troca
  xCarTro: array[1..38] of String = ('a', 'a', 'a', 'a', 'a','A', 'A', 'A', 'A', 'A',
                                     'e', 'e','E', 'E','i', 'i','I', 'I',
                                     'o', 'o', 'o','o', 'o','O', 'O', 'O', 'O', 'O',
                                     'u', 'u', 'u','u','u', 'u','c','C','n', 'N');
  //Lista de Caracteres Extras
  xCarExt: array[1..47] of string = ('<','>','!','@','#','$','%','¨','&','*',
                                     '(',')','+','=','{','}','[',']','?',
                                     ';',':',',','|','*','"','~','^','´','`',
                                     '¨','æ','Æ','ø','£','Ø','ƒ','ª','º','¿',
                                     '®','½','¼','ß','µ','þ','ý','Ý');
var
  xTexto : string;
  i : Integer;
begin
   xTexto := aTexto;
   for i:=1 to 38 do
     xTexto := StringReplace(xTexto, xCarEsp[i], xCarTro[i], [rfreplaceall]);
   //De acordo com o parâmetro aLimExt, elimina caracteres extras.
   if (aLimExt) then
     for i:=1 to 47 do
       xTexto := StringReplace(xTexto, xCarExt[i], '', [rfreplaceall]);
   Result := xTexto;
end;

class procedure TFunctions.StringToAnsiChar(aTexto : string; var aReceptor : Array of AnsiChar);
var
  i : Word;
begin
  ZeroMemory(@aReceptor, sizeof(aReceptor));
  for i := Low(aTexto) to High(aTexto) do
    aReceptor[i-1] := AnsiChar(aTexto[i]);
end;

class function TFunctions.GetRoute(pos: TPosition; var dest: TPosition; var route : array of AnsiChar; distance: Byte) : Integer;
var
  i : SmallInt;
  n, ne, e, se, s, sw, w, nw, cul : Word;
  p : PByte;
  auxp, lastx, lasty : Integer;
begin
	FillChar(route, MAX_ROUTE, 0);

  lastx := pos.X;
  lasty := pos.Y;

  p := @HeightGrid.p[0];
  auxp := Integer(p);

  i := 0;
	while (i < distance) and (i < MAX_ROUTE-1) do
	begin
		if (pos.x - HEIGHTPOSX < 1) or (pos.y - HEIGHTPOSY < 1) or ((pos.x - HEIGHTPOSX) > (HEIGHTWIDTH - 2)) or ((pos.y - HEIGHTPOSY) > (HEIGHTHEIGHT - 2)) then
		begin
			Route[i] := '0';
      inc(i);
			break;
		end;

    cul := PByte(auxp+((pos.y - HEIGHTPOSY) * HEIGHTWIDTH + pos.x - HEIGHTPOSX))^;

		 n  := PByte(auxp+((pos.y - HEIGHTPOSY - 1) * HEIGHTWIDTH + pos.x - HEIGHTPOSX))^;
		 ne := PByte(auxp+((pos.y - HEIGHTPOSY - 1) * HEIGHTWIDTH + pos.x - HEIGHTPOSX + 1))^;
		 e  := PByte(auxp+((pos.y - HEIGHTPOSY    ) * HEIGHTWIDTH + pos.x - HEIGHTPOSX + 1))^;
		 se := PByte(auxp+((pos.y - HEIGHTPOSY + 1) * HEIGHTWIDTH + pos.x - HEIGHTPOSX + 1))^;
		 s  := PByte(auxp+((pos.y - HEIGHTPOSY + 1) * HEIGHTWIDTH + pos.x - HEIGHTPOSX    ))^;
		 sw := PByte(auxp+((pos.y - HEIGHTPOSY + 1) * HEIGHTWIDTH + pos.x - HEIGHTPOSX - 1))^;
		 w  := PByte(auxp+((pos.y - HEIGHTPOSY    ) * HEIGHTWIDTH + pos.x - HEIGHTPOSX - 1))^;
		 nw := PByte(auxp+((pos.y - HEIGHTPOSY - 1) * HEIGHTWIDTH + pos.x - HEIGHTPOSX - 1))^;

		 if(dest.x = pos.x) and (dest.y = pos.y) then
		 begin
			 Route[i] := '0';
       inc(i);
			 break;
		 end;

		 if(dest.x = pos.x) and (dest.y < pos.y) and (n < cul + MH) and (n > cul - MH) then
		 begin
			 Route[i] := '2';
			 dec(pos.y);
       inc(i);

			 continue;
		 end;

		 if(dest.x > pos.x) and (dest.y < pos.y) and (ne < cul + MH) and (ne > cul - MH) then
		 begin
			 Route[i] := '3';

			 inc(pos.x);
			 dec(pos.y);
       inc(i);

			 continue;
		 end;

		 if(dest.x > pos.x) and (dest.y = pos.y) and (e < cul + MH) and (e > cul - MH) then
		 begin
			 Route[i] := '6';

			 inc(pos.x);
       inc(i);

			 continue;
		 end;

		 if(dest.x > pos.x) and (dest.y > pos.y) and (se < cul + MH) and (se > cul - MH) then
		 begin
			 Route[i] := '9';

			 inc(pos.x);
			 inc(pos.y);
       inc(i);

			 continue;
		 end;

		 if(dest.x = pos.x) and (dest.y > pos.y) and (s < cul + MH) and (s > cul - MH) then
		 begin
			 Route[i] := '8';

			 inc(pos.y);
       inc(i);

			 continue;
		 end;

		 if(dest.x < pos.x) and (dest.y > pos.y) and (sw < cul + MH) and (sw > cul - MH) then
		 begin
			 Route[i] := '7';

			 dec(pos.x);
			 inc(pos.y);
       inc(i);

			 continue;
		 end;

		 if(dest.x < pos.x) and (dest.y = pos.y) and (w < cul + MH) and (w > cul - MH) then
		 begin
			 Route[i] := '4';

			 dec(pos.x);
       inc(i);

			 continue;
		 end;

		 if(dest.x < pos.x) and (dest.y < pos.y) and (nw < cul + MH) and (nw > cul - MH) then
		 begin
			 Route[i] := '1';

			 dec(pos.x);
			 dec(pos.y);
       inc(i);

			 continue;
		 end;

		 if(dest.x > pos.x) and (dest.y < pos.y) and (e < cul + MH) and (e > cul - MH) then
		 begin
			 Route[i] := '6';

			 inc(pos.x);
       inc(i);

			 continue;
		 end;

		 if(dest.x > pos.x) and (dest.y < pos.y) and (n < cul + MH) and (n > cul - MH) then
		 begin
			 Route[i] := '2';

			 dec(pos.y);
       inc(i);

			 continue;
		 end;

		 if(dest.x > pos.x) and (dest.y > pos.y) and (e < cul + MH) and (e > cul - MH) then
		 begin
			 Route[i] := '6';

			 inc(pos.x);
       inc(i);

			 continue;
		 end;

		 if(dest.x > pos.x) and (dest.y > pos.y) and (s < cul + MH) and (s > cul - MH) then
		 begin
			 Route[i] := '8';

			 inc(pos.y);
       inc(i);

			 continue;
		 end;

		 if(dest.x < pos.x) and (dest.y > pos.y) and (w < cul + MH) and (w > cul - MH) then
		 begin
			 Route[i] := '4';

			 dec(pos.x);
       inc(i);

			 continue;
		 end;

		 if(dest.x < pos.x) and (dest.y > pos.y) and (s < cul + MH) and (s > cul - MH) then
		 begin
			 Route[i] := '8';

			 inc(pos.y);
       inc(i);

			 continue;
		 end;

		 if(dest.x < pos.x) and (dest.y < pos.y) and (w < cul + MH) and (w > cul - MH) then
		 begin
			 Route[i] := '4';

			 dec(pos.x);
       inc(i);

			 continue;
		 end;

		 if(dest.x < pos.x) and (dest.y < pos.y) and (n < cul + MH) and (n > cul - MH) then
		 begin
			 Route[i] := '2';

			 dec(pos.y);
       inc(i);

			 continue;
		 end;

		 if(dest.x = pos.x + 1) or (dest.y = pos.y + 1) or (dest.x = pos.x - 1) or (dest.y = pos.y - 1) then
		 begin
			 Route[i] := '0';
       inc(i);
			 break;
		 end;

		 if(dest.x = pos.x) and (dest.y > pos.y) and (se < cul + MH) and (se > cul - MH) then
		 begin
			 Route[i] := '9';

			 inc(pos.x);
			 inc(pos.y);
       inc(i);

			 continue;
		 end;

		 if(dest.x = pos.x) and (dest.y > pos.y) and (sw < cul + MH) and (sw > cul - MH) then
		 begin
			 Route[i] := '7';

			 dec(pos.x);
			 inc(pos.y);
       inc(i);

			 continue;
		 end;

		 if(dest.x = pos.x) and (dest.y < pos.y) and (ne < cul + MH) and (ne > cul - MH) then
		 begin
			 Route[i] := '3';

			 inc(pos.x);
			 dec(pos.y);
       inc(i);

			 continue;
		 end;

		 if(dest.x = pos.x) and (dest.y < pos.y) and (nw < cul + MH) and (nw > cul - MH) then
		 begin
			 Route[i] := '1';

			 dec(pos.x);
			 dec(pos.y);
       inc(i);

			 continue;
		 end;

		 if(dest.x < pos.x) and (dest.y = pos.y) and (sw < cul + MH) and (sw > cul - MH) then
		 begin
			 Route[i] := '7';

			 dec(pos.x);
			 inc(pos.y);
       inc(i);

			 continue;
		 end;

		 if(dest.x < pos.x) and (dest.y = pos.y) and (nw < cul + MH) and (nw > cul - MH) then
		 begin
			 Route[i] := '1';

			 dec(pos.x);
			 dec(pos.y);
       inc(i);

			 continue;
		 end;

		 if(dest.x > pos.x) and (dest.y = pos.y) and (se < cul + MH) and (se > cul - MH) then
		 begin
			 Route[i] := '9';

			 inc(pos.x);
			 inc(pos.y);
       inc(i);

			 continue;
		 end;

		 if(dest.x > pos.x) and (dest.y = pos.y) and (ne < cul + MH) and (ne > cul - MH) then
		 begin
			 Route[i] := '3';

			 inc(pos.x);
			 dec(pos.y);
       inc(i);

			 continue;
		 end;

		 Route[i] := '0';
     inc(i);
		 break;
	end;

  Finalize(p);

	if(lastx = pos.x) and (lasty = pos.y) then
  begin
		result := 0;
    exit;
  end;

	dest.x := pos.x;
	dest.y := pos.y;

  Result := IfThen(i > 0, StrToInt(Route[i-1]), 0);
end;

class function TFunctions.CheckItensTrade(player: TPlayer; transfer: Boolean): boolean;
var i, j, otherClientId: WORD;
  otherPlayer : TPlayer;
  availableSlots: integer;
  qitem: BYTE;
  slot: BYTE;
begin
  Result := False;
	otherClientId := player.PlayerCharacter.Trade.OtherClientid;
  TPlayer.GetPlayer(otherClientId, otherPlayer);

	qitem := 0;
  for i := 0 to 14 do
    if(otherPlayer.PlayerCharacter.Trade.Itens[i].Index <> 0)then
      inc(qitem);

  availableSlots := 0;
	if(qitem <= 0)then
  begin
		result := true;
    exit;
  end;

  for j := 0 to MAX_INV-1 do
  begin
    if(player.PlayerCharacter.Base.Inventory[j].Index = 0) then
    begin
      inc(availableSlots);
      if(availableSlots >= qitem) then
      begin
        result := True;
        break;
      end;
    end;
  end;

	if result AND transfer then
  begin
    for i := 0 to qitem do
    begin
      slot := otherPlayer.PlayerCharacter.Trade.TradeItemSlot[i];
      TItemFunctions.PutItem(player, otherPlayer.PlayerCharacter.Trade.Itens[i]);
      TItemFunctions.DeleteItemSlot(otherPlayer, slot);
    end;
  end;
end;

end.

