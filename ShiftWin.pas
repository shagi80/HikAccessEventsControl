unit ShiftWin;

interface

uses Windows, Classes, Graphics, Forms, Controls, StdCtrls, TheBreaks,
  TheShift, Grids;

type
  TfrmShift = class(TForm)
    grBreaks: TStringGrid;
    grShifts: TStringGrid;
    Button1: TButton;
    Edit1: TEdit;
    Button2: TButton;
    Button3: TButton;
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    BreaksList: TBreakList;
    ShiftsList: TShiftList;
  public
    { Public declarations }
    procedure LoadFromBase(DBFileName: string);
  end;

implementation


{$R *.dfm}

uses Dialogs, DateUtils, SysUtils, TheSettings;

procedure TfrmShift.FormCreate(Sender: TObject);
begin
  BreaksList := TBreakList.Create(True);
  ShiftsList := TShiftList.Create(True);
end;

procedure TfrmShift.LoadFromBase(DBFileName: string);
var
  I, j: integer;
  Break: TBreak;
  Shift: TShift;
  Str: string;
begin
  BreaksList.Clear;
  ShiftsList.Clear;

  grBreaks.RowCount := 2;
  grBreaks.Rows[1].Clear;
  BreaksList.LoadFromBD(DBFileName);
  grBreaks.RowCount := BreaksList.Count + 1;
  for I := 0 to BreaksList.Count - 1 do begin
    Break := BreaksList.Items[i];
    grBreaks.Cells[0, i + 1] := GUIDToString(Break.GUID);
    grBreaks.Cells[1, i + 1] := Break.Title;
    grBreaks.Cells[2, i + 1] := TimeToStr(Break.StartTime);
    grBreaks.Cells[3, i + 1] := TimeToStr(Break.Length);
  end;

  grShifts.RowCount := 2;
  grShifts.Rows[1].Clear;
  ShiftsList.LoadFromBD(DBFileName, BreaksList);
  grShifts.RowCount := ShiftsList.Count + 1;
  for I := 0 to ShiftsList.Count - 1 do begin
    Shift := ShiftsList.Items[i];
    grShifts.Cells[0, i + 1] := GUIDToString(Shift.GUID);
    grShifts.Cells[1, i + 1] := Shift.Title;
    if Shift.Breaks.Count > 0 then begin
      str := '';
      for j := 0 to Shift.Breaks.Count - 1 do
       str := str + Shift.Breaks.Items[j].Title + ' - ';
      grShifts.Cells[2, i + 1] := str;
    end;

  end;
end;


procedure TfrmShift.Button1Click(Sender: TObject);
var
  GUID: TGUID;
begin
  CreateGUID(GUID);
  Edit1.Text := GuidToString(GUID);
end;

procedure TfrmShift.Button2Click(Sender: TObject);
begin
  Self.LoadFromBase(Settings.GetInstance.DBFileName);
end;

procedure TfrmShift.Button3Click(Sender: TObject);
begin
  ShowMessage(TimeToStr(now) + chr(13)
    + FloatToStr(Timeof(now)));
end;

procedure TfrmShift.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  BreaksList.Free;
  ShiftsList.Free;
  Action := caFree;
end;

end.
