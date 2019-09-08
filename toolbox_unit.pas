{ Toolbox - allgemein

  08/2012 XE2 kompatibel
  02/2016 XE10 x64 Test
  xx/xxxx FPC Ubuntu

  --------------------------------------------------------------------
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.

  THE SOFTWARE IS PROVIDED "AS IS" AND WITHOUT WARRANTY

  Author: Peter Lorenz
  Is that code useful for you? Donate!
  Paypal webmaster@peter-ebe.de
  --------------------------------------------------------------------

}

{$WARN SYMBOL_PLATFORM OFF}
{$I ..\share_settings.inc}
unit toolbox_unit;

interface

uses
{$IFNDEF UNIX}Windows, {$ENDIF}
{$IFDEF FPC}LCLIntf, LCLType, LMessages, {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  grids;

{ =========================================================================== }

function UpperCase2(const S: string): string;
function LowerCase2(const S: string): string;

function specialtrim(const S: string): string;

procedure zeilezerlegen(input: string; var ausgabe: array of string);

function inttotimestr(zeitwert: integer; istinms: boolean): string;
Function pfaddatei2Name(const pfaddatei: string): string;

function str2verzeichnisdatei(eingabe: string; ersatzzeichen: char): string;

{ =========================================================================== }

function FilePath2path(const filepath: string): string;
function FilePath2file(const filepath: string): string;

{ =========================================================================== }

function pfaddatei2album(const datei: string): string;
function pfaddatei2cover(const datei: string; coveroptdateiname: string): string;

{ =========================================================================== }

type
  Pstringgrid = ^TStringgrid;
procedure clearstringgrid(grid: Pstringgrid; optclearcc: integer = 0);

{ =========================================================================== }

implementation

// uses os_api_unit;

{$IFDEF UNIX}

const
  Delimiter = '/';
{$ELSE}

const
  Delimiter = '\';
{$ENDIF}
  { =========================================================================== }

function LowerCase2(const S: string): string;
var
  Ch: char;
  L: integer;
  Source, Dest: PChar;
begin
  // Kopie der Systemfunktion Lowercase(), nur um Umlaute erweitert
  L := Length(S);
  SetLength(Result, L);
  Source := Pointer(S);
  Dest := Pointer(Result);
  while L <> 0 do
  begin
    Ch := Source^;
{$IFDEF FPC}
    case Ch of
      'A' .. 'Z':
        inc(Ch, 32);
    end;
    if Ch = 'Ö' then
      Ch := char('ö');
    if Ch = 'Ü' then
      Ch := char('ü');
    if Ch = 'Ä' then
      Ch := char('ä');
{$ELSE}
    case Ch of
      'A' .. 'Z':
        inc(Ch, 32);
      'Ö':
        Ch := 'ö';
      'Ü':
        Ch := 'ü';
      'Ä':
        Ch := 'ä';
    end;
{$ENDIF}
    Dest^ := Ch;
    inc(Source);
    inc(Dest);
    Dec(L);
  end;
end;

function UpperCase2(const S: string): string;
var
  Ch: char;
  L: integer;
  Source, Dest: PChar;
begin
  // Kopie der Systemfunktion Uppercase(), nur um Umlaute erweitert
  L := Length(S);
  SetLength(Result, L);
  Source := Pointer(S);
  Dest := Pointer(Result);
  while L <> 0 do
  begin
    Ch := Source^;
{$IFDEF FPC}
    case Ch of
      'A' .. 'Z':
        inc(Ch, 32);
    end;
    if Ch = 'ö' then
      Ch := char('Ö');
    if Ch = 'ü' then
      Ch := char('Ü');
    if Ch = 'ä' then
      Ch := char('Ä');
{$ELSE}
    case Ch of
      'a' .. 'z':
        Dec(Ch, 32);
      'ö':
        Ch := 'Ö';
      'ü':
        Ch := 'Ü';
      'ä':
        Ch := 'Ä';
    end;
{$ENDIF}
    Dest^ := Ch;
    inc(Source);
    inc(Dest);
    Dec(L);
  end;
end;

function specialtrim(const S: string): string;
var
  i: integer;
  zeile: string;
begin
  Result := '';
  zeile := S;
  i := Length(zeile);

  if i = 0 then
    exit; { falls Zeile leer }

  repeat
    If ord(zeile[i]) < 32 then
      zeile[i] := ' ';

    Dec(i);
  until (i = 0) or (ord(zeile[i]) > 32);
  Result := trim(zeile);
end;

procedure zeilezerlegen(input: string; var ausgabe: array of string);
var
  i, S, nr: integer;
begin
  { zerlegen eines Strings in Teilstrings }
  input := UpperCase2(trim(input));

  S := 1;
  nr := 0;
  for i := 1 to Length(input) do
  begin
    case S of
      1:
        begin
          { warte auf Leerzeichen }
          if input[i] <> ' ' then
            ausgabe[nr] := ausgabe[nr] + input[i]
          else
            inc(S);
        end;
      2:
        begin
          { Warte auf ein Zeichen <> Leerzeichen }
          if input[i] <> ' ' then
          begin
            S := 1;
            inc(nr);
            ausgabe[nr] := ausgabe[nr] + input[i];
          end;
        end;
    end; { of case }
  end; { next i }

  { damit das Ende erkannt wird }
  inc(nr);
  ausgabe[nr] := '';
end;

function inttotimestr(zeitwert: integer; istinms: boolean): string;

  function int2(intwert: integer): string;
  var
    wertstr: string;
  begin
    Result := '--';
    wertstr := inttostr(intwert);
    if Length(wertstr) < 2 then
      wertstr := '0' + wertstr;
    Result := wertstr;
  end;

var
  h, m, S, s100: integer;
  h_, m_, s_, s100_: string;

  wertsec: integer;
begin
  { umwandeln in hh:mm:ss:xx (xx=hunderstel) }
  Result := '';
  h := 0;
  m := 0;
  S := 0;
  s100 := 0;

  if zeitwert > 0 then
  begin
    { prüfen ob übergebener Wert in ms ist }
    if istinms = true then
    begin
      { umrechnen in sec }
      wertsec := trunc(zeitwert / 1000);

      { tausenstel als hundertstel ausgeben }
      s100 := trunc((zeitwert - wertsec * 1000) / 10);
    end
    else
    begin
      { schon in sec }
      s100 := 0;
      wertsec := zeitwert;
    end;

    { Stunden, Minuten, Sekunden }
    while wertsec >= 3600 do
    begin
      inc(h);
      wertsec := wertsec - 3600;
    end;

    while wertsec >= 60 do
    begin
      inc(m);
      wertsec := wertsec - 60;
    end;

    S := wertsec;
  end;

  { Ausgabestring zusammensetzen }
  h_ := int2(h);
  m_ := int2(m);
  s_ := int2(S);
  s100_ := int2(s100);
  Result := h_ + ':' + m_ + ':' + s_ + ':' + s100_;
end;

Function pfaddatei2Name(const pfaddatei: string): string;
var
  sneu: string;
begin
  Result := pfaddatei;
  if StrRScan(PChar(pfaddatei), Delimiter) <> nil then
    sneu := ExtractFileName(pfaddatei)
  else
    sneu := pfaddatei;
  if StrRScan(PChar(sneu), '.') <> nil then
    sneu := ChangeFileExt(sneu, '');
  Result := sneu;
end;

function str2verzeichnisdatei(eingabe: string; ersatzzeichen: char): string;
const
  charfilter = ['/', '\', ':', '*', '?', '"', '<', '>', '|'];
  // unzulässige Zeichen wie von Explorer angezeigt
var
  i: integer;
  pfaddateiname: string;
begin
  Result := eingabe;
  eingabe := trim(eingabe);

  if Length(eingabe) > 0 then
  begin
    pfaddateiname := '';

    // erst mal nur alle Zeichen > #32 übernehmen
    for i := 1 to Length(eingabe) do
    // zstring ist unicodestring, zstr[x] ist char/widechar, filter funktioniert auf diese Weise#
    begin
      if (eingabe[i] >= #32) then
        pfaddateiname := pfaddateiname + eingabe[i];
    end;
    pfaddateiname := trim(pfaddateiname);

    // Filter für nicht zulässige Zeichen -> ersetzen durch space
    for i := 1 to Length(pfaddateiname) do
    begin
      if charinset(pfaddateiname[i], charfilter) then
        pfaddateiname[i] := ersatzzeichen;
    end;

    // '.' am Anfang und Ende entfernen da problematisch -> ersetzen durch space
    if Length(pfaddateiname) > 0 then
    begin
      if pfaddateiname[1] = '.' then
        pfaddateiname[1] := ersatzzeichen;
      if pfaddateiname[Length(pfaddateiname)] = '.' then
        pfaddateiname[Length(pfaddateiname)] := ersatzzeichen;
      pfaddateiname := trim(pfaddateiname);
    end;

    Result := trim(pfaddateiname);
  end;
end;

{ =========================================================================== }

function FilePath2path(const filepath: string): string;
var
  path: string;
begin
  Result := '';
  { Pfad aus Dateiname+Pfad - ACHTUNG: Ohne Delimiter am Ende! }
  path := ExtractFilePath(filepath);
  if Length(path) > 0 then
    if path[Length(path)] = Delimiter then
      path[Length(path)] := ' ';
  Result := trim(path);
end;

function FilePath2file(const filepath: string): string;
begin
  Result := trim(ExtractFileName(filepath));
end;

{ =========================================================================== }

function pfaddatei2cover(const datei: string; coveroptdateiname: string): string;

  function findecover(pfad: string): string;
  var
    sr: Tsearchrec;
    i, res: integer;
    such, tmpstr: string;
    flag: boolean;
  begin
    Result := '';
    coveroptdateiname := trim(coveroptdateiname);

    flag := false;
    for i := 1 to 3 do { 2 versuche - bmp und jpg }
    begin
      if Length(coveroptdateiname) < 1 then
      begin
        case i of
          1:
            such := '*.png';
          2:
            such := '*.jpg';
          3:
            such := '*.bmp';
        end;
      end
      else
      begin
        such := coveroptdateiname;
      end;

      { versuche die datei zu finden }
      if Length(pfad) < 1 then
        exit;
      pfad := IncludeTrailingPathDelimiter(pfad);
      try
        res := findfirst(pfad + such, faanyfile, sr);
        if res = 0 then
        begin
          tmpstr := pfad + sr.Name;
          if (sr.size > 0) and (fileexists(tmpstr) = true) then
          begin
            Result := tmpstr;
            flag := true;
          end;
        end;
      finally
        findclose(sr);
      end;

      { wenn gefunden dann raus }
      if flag = true then
        exit;
    end; { next i - nächster versuch }

  end;

var
  atmpstr, dateipfad, coverdatei: string;
  i: integer;
begin
  { mögliches Cover in Verz. finden }
  Result := '';

  { suche in Pfad der Datei }
  coverdatei := trim(findecover(FilePath2path(datei)));

  { ggf. noch eins darunter wenn kriterien passen }
  if Length(coverdatei) < 1 then
  begin
    { pfad extrahieren }
    dateipfad := FilePath2path(datei);
    if Length(dateipfad) > 0 then
      if dateipfad[Length(dateipfad)] = Delimiter then
        dateipfad[Length(dateipfad)] := ' ';
    dateipfad := trim(dateipfad);

    { letztes Verzeichnis extrahieren }
    atmpstr := StrRScan(PChar(dateipfad), Delimiter);
    if Length(atmpstr) > 0 then
      atmpstr[1] := ' ';
    atmpstr := trim(atmpstr);

    while Length(atmpstr) < 4 do
      atmpstr := atmpstr + ' '; { crash-schutz }

    if (UpperCase2(atmpstr[1] + atmpstr[2]) = 'CD') or
      (UpperCase2(atmpstr[1] + atmpstr[2] + atmpstr[3] + atmpstr[4]) = 'DISK')
      or (UpperCase2(atmpstr[1] + atmpstr[2] + atmpstr[3] + atmpstr[4]) = 'DISC')
    then
    begin
      { gehe einen Pfad zurück -> vorletzte Ebene }
      atmpstr := '';
      for i := 1 to Length(dateipfad) -
        Length(StrRScan(PChar(dateipfad), Delimiter)) do
        atmpstr := atmpstr + dateipfad[i];
      coverdatei := trim(findecover(atmpstr));
    end; { of suche eins darunter }

  end; { of coverdatei nicht ium pfad }

  { zurückübergeben }
  Result := coverdatei;
end;

function pfaddatei2album(const datei: string): string;
var
  dateipfad: string;
  atmpstr: string;
  i: integer;
begin
  { möglichen Albennamen aus Verz. extrahieren }
  Result := '';

  { pfad extrahieren }
  dateipfad := FilePath2path(datei);
  if Length(dateipfad) > 0 then
    if dateipfad[Length(dateipfad)] = Delimiter then
      dateipfad[Length(dateipfad)] := ' ';
  dateipfad := trim(dateipfad);

  { letztes Verzeichnis extrahieren }
  atmpstr := StrRScan(PChar(dateipfad), Delimiter);
  if Length(atmpstr) > 0 then
    atmpstr[1] := ' ';
  atmpstr := trim(atmpstr);

  while Length(atmpstr) < 4 do
    atmpstr := atmpstr + ' '; { crash-schutz }

  if (UpperCase2(atmpstr[1] + atmpstr[2]) = 'CD') or
    (UpperCase2(atmpstr[1] + atmpstr[2] + atmpstr[3] + atmpstr[4]) = 'DISK') or
    (UpperCase2(atmpstr[1] + atmpstr[2] + atmpstr[3] + atmpstr[4]) = 'DISC')
  then
  begin
    { gehe einen Pfad zurück -> vorletzte Ebene }
    atmpstr := '';
    for i := 1 to Length(dateipfad) -
      Length(StrRScan(PChar(dateipfad), Delimiter)) do
      atmpstr := atmpstr + dateipfad[i];
    atmpstr := StrRScan(PChar(atmpstr), Delimiter);
    if Length(atmpstr) > 0 then
      atmpstr[1] := ' ';
    atmpstr := trim(atmpstr);
  end;

  atmpstr := trim(atmpstr); { wichtig: Leerzeichen wieder weg }
  Result := atmpstr;
end;

{ =========================================================================== }

procedure clearstringgrid(grid: Pstringgrid; optclearcc: integer = 0);
var
  c, cc: integer;
begin
  { Diese Funktion löscht die Inhalte eines Stringgrids,
    falls Komponente nicht visuell die Instanz
    Achtung: Stringgrid nicht für große Datenmengen verwenden!
  }

  if (grid^.Parent = nil) then
  begin
    { Instanz vollständig auflösen und neu erzeugen }
    FreeAndNil(grid^);
    grid^ := TStringgrid.create(nil);
    grid^.ColCount := 1;
    grid^.RowCount := 1;
  end
  else
  begin
    { nur Inhalte killen }
    cc := grid^.ColCount;
    if optclearcc > 0 then
      cc := optclearcc;
    for c := 1 to cc do
      grid^.Cols[c - 1].clear;

    // grid^.ColCount:= grid^.FixedCols+1;
    grid^.RowCount := grid^.FixedRows + 1;
  end;

end;

end.
