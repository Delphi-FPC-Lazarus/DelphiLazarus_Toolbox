unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, Vcl.ExtCtrls;

type
  Tfrmmain = class(TForm)
    b_strtest1: TButton;
    b_gridtest: TButton;
    b_strtest2: TButton;
    StringGrid1: TStringGrid;
    pnlgrid: TPanel;
    procedure b_strtest1Click(Sender: TObject);
    procedure b_gridtestClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure b_strtest2Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  frmmain: Tfrmmain;

implementation

{$R *.dfm}

uses toolbox_unit;

var grid:TStringgrid;

procedure Tfrmmain.FormCreate(Sender: TObject);
begin
 grid:= Tstringgrid.Create(self);
 grid.Parent:= pnlgrid;
 grid.Left:= 4;
 grid.Top:= 4;
end;

procedure Tfrmmain.b_strtest1Click(Sender: TObject);
begin
 showmessage(UpperCase2('testäüöß'));
 showmessage(LowerCase2('TestÄÜÖß'));

 showmessage(specialtrim('Test'+#13+'Test2'));
 showmessage(specialtrim('Test'+#13+'bla bla'+#13));

 showmessage(inttotimestr(34248, true));

 showmessage(pfaddatei2Name('c:\test ordner\test bla bla\testdatei - was blödes.txt'));

 showmessage(str2verzeichnisdatei('.testöäüdß-*$123.', '-'));
end;

procedure Tfrmmain.b_strtest2Click(Sender: TObject);
const datei:string='E:\Temp\mp3test\xyz.mp3';
begin
 showmessage(pfaddatei2album(datei));
 ShowMessage(pfaddatei2cover(datei, ''));
end;

procedure Tfrmmain.b_gridtestClick(Sender: TObject);
var r,c:integer;
begin
 grid.colcount:= 100;
 grid.rowcount:= 1000;
 for r:= 1 to grid.RowCount do
  for c:= 1 to grid.ColCount do
   grid.cells[c-1,r-1]:= 'Test';

 stringgrid1.colcount:= 1;
 stringgrid1.rowcount:= 1;
 for r:= 1 to stringgrid1.RowCount do
  for c:= 1 to stringgrid1.ColCount do
   stringgrid1.cells[c-1,r-1]:= 'Test';

 showmessage('1 - Speicherverbrauch prüfen!');

 clearstringgrid(@stringgrid1);
 clearstringgrid(@grid);

 showmessage('2 - Speicherverbrauch prüfen!');
end;

end.
