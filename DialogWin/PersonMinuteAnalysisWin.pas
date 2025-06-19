unit PersonMinuteAnalysisWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, TWebButton, TheAnalysisByMinute, Grids,
  TheEventPairs;

type
  TfrmPersonMinuteAnalysis = class(TForm)
    pnMain: TPanel;
    ScrollBox1: TScrollBox;
    imgBmp: TImage;
    pnTop: TPanel;
    sgPairs: TStringGrid;
    pnText: TPanel;
    lbDate: TLabel;
    lbPerson: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lbScheduleTime: TLabel;
    lbTotalWorkTime: TLabel;
    lbHookyTime: TLabel;
    lbOvertime: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure WritePairs(Pairs: TEmplPairs; Date: TDate);
    procedure WriteTotalTime(ScheduleTime: integer;
      TotalTime: TEventsTotalTime);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ShowAnalysis(PersonMinuteState: TPersonMinuteState;
      AnalysisBitMap: Graphics.TBitMap; Date: TDate;
      TotalTime: TEventsTotalTime; ScheduleTime: integer);
  end;

var
  frmPersonMinuteAnalysis: TfrmPersonMinuteAnalysis;

implementation

{$R *.dfm}

uses DateUtils;

procedure TfrmPersonMinuteAnalysis.WritePairs(Pairs: TEmplPairs; Date: TDate);
var
  I, Row: integer;
begin
  for I := 1 to sgPairs.RowCount - 1 do sgPairs.Rows[I].Clear;
  sgPairs.RowCount := 2;
  Row := 1;
  for I := 0 to Pairs.Count - 1 do
    if (DateOf(Pairs.Pair[I].InTime) = Date)
      or (DateOf(Pairs.Pair[I].OutTime) = Date) then begin
        if (Row > sgPairs.RowCount - 1) then sgPairs.RowCount := Row + 1;
        if Pairs.Pair[I].InTime = 0  then sgPairs.Cells[2, Row] := '-'
          else sgPairs.Cells[0, Row] := DateTimeToStr(Pairs.Pair[I].InTime);
        if Pairs.Pair[I].OutTime = 0  then sgPairs.Cells[3, Row] := '-'
          else sgPairs.Cells[1, Row] := DateTimeToStr(Pairs.Pair[I].OutTime);
    Inc(Row);
  end;
end;

procedure TfrmPersonMinuteAnalysis.FormCreate(Sender: TObject);
begin
  sgPairs.Cells[0, 0] := '  Вход';
  sgPairs.Cells[1, 0] := '  Выход';
end;

procedure TfrmPersonMinuteAnalysis.WriteTotalTime(ScheduleTime: integer;
  TotalTime: TEventsTotalTime);

  function FormatMinutes(Value: integer): string;
  var
    h, m: integer;
  begin
    h := Value div 60;
    m := Value - h * 60;
    Result := IntToStr(h) + ' ч ' + FormatFloat('00', m) + ' мин';
  end;

var
  HookyTime, Overtime: integer;
begin
  lbScheduleTime.Caption := FormatMinutes(ScheduleTime);
  lbTotalWorkTime.Caption := FormatMinutes(TotalTime.TotalWork);
  HookyTime := TotalTime.EarlyFromShiftOrBreak
    + TotalTime.LateToShift + TotalTime.LateFromBreak + TotalTime.Hooky;
  if HookyTime = 0 then lbHookyTime.Caption := 'нет'
    else lbHookyTime.Caption := FormatMinutes(HookyTime);
  Overtime := TotalTime.TotalWork - ScheduleTime;
  if Overtime > 0 then lbOvertime.Caption := FormatMinutes(Overtime)
    else lbOvertime.Caption := 'нет';
end;

procedure TfrmPersonMinuteAnalysis.ShowAnalysis(PersonMinuteState: TPersonMinuteState;
  AnalysisBitMap: Graphics.TBitMap; Date: TDate; TotalTime: TEventsTotalTime;
  ScheduleTime: integer);
begin
  lbDate.Caption := DateToStr(Date) + ' (' + FormatDateTime('dddd', Date) + ')';
  lbPerson.Caption := PersonMinuteState.PersonName;
  imgBmp.Width := AnalysisBitMap.Width;
  imgBmp.Height := AnalysisBitMap.Height;
  imgBmp.Picture.Bitmap.Assign(AnalysisBitMap);
  WritePairs(PersonMinuteState.Pairs, DateOf(Date));
  WriteTotalTime(ScheduleTime, TotalTime);
  //
  Self.ShowModal;
end;



end.
