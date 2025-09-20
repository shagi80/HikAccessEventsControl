unit PersonMinuteAnalysisWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, TWebButton, TheAnalysisByMinute, Grids,
  TheEventPairs, TheSchedule;

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
    Label5: TLabel;
    lbWorkToReport: TLabel;
    Label6: TLabel;
    lbLateToShift: TLabel;
    lbDayState: TLabel;
    Label8: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure WritePairs(Pairs: TEmplPairs; Date: TDate);
    procedure WriteTotalTime;
    function GetDayStateText(State: TDayResultState): string;
  private
    { Private declarations }
    FDayResult: TDayResult;
  public
    { Public declarations }
    procedure ShowAnalysis(AnalysisBitMap: Graphics.TBitMap; Date: TDate;
      DayResult: TDayResult; PersonName: string; Pairs: TEmplPairs);
  end;

var
  frmPersonMinuteAnalysis: TfrmPersonMinuteAnalysis;

implementation

{$R *.dfm}

uses DateUtils;

function TfrmPersonMinuteAnalysis.GetDayStateText(State: TDayResultState): string;
begin
  case State of
    dsNormal: Result := 'Норма';
    dsHooky: Result := 'Нарушения';
    dsOvertime: Result := 'Переработка';
    dsSmallTime: Result := 'Недостаточно времени';
    dsFullHooky: Result := 'Прогул';
    dsRest: Result := 'Выходной';
  end;
end;

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

procedure TfrmPersonMinuteAnalysis.WriteTotalTime;

  function FormatMinutes(Value: integer): string;
  var
    h, m: integer;
  begin
    h := Value div 60;
    m := Value - h * 60;
    Result := IntToStr(h) + ' ч ' + FormatFloat('00', m) + ' мин';
  end;

begin
  lbDayState.Caption := Self.GetDayStateText(FDayResult.State);
  lbScheduleTime.Caption := FormatMinutes(FDayResult.Schedule);
  lbTotalWorkTime.Caption := FormatMinutes(FDayResult.Present);
  lbWorkToReport.Caption := FormatMinutes(FDayResult.TotalWork);
  //
  lbOvertime.Font.Color := clGray;
  if FDayResult.Overtime = 0 then lbOvertime.Caption := 'нет'
    else begin
      lbOvertime.Font.Color := clGreen;
      lbOvertime.Caption := FormatMinutes(FDayResult.Overtime);
    end;
  // Если все компенсировано
  if (FDayResult.HookyComps) and (FDayResult.Hooky = 0) then begin
    lbHookyTime.Font.Color := clGray;
    lbLateToShift.Font.Color := clGray;
    lbHookyTime.Caption := 'компенсировано полностью';
    lbLateToShift.Caption := 'компенсировано полностью';
    Exit;
  end;
  // Если прогул
  if (FDayResult.Schedule > 0)
    and (FDayResult.TotalWork = 0)
    and (FDayResult.Overtime = 0) then begin
      lbLateToShift.Font.Color := clRed;
      lbHookyTime.Font.Color := clRed;
      lbLateToShift.Caption := 'прогул';
      lbHookyTime.Caption := 'прогул';
      Exit;
  end;
  //
  if FDayResult.LateToShift = 0 then begin
    lbLateToShift.Font.Color := clGray;
    lbLateToShift.Caption := 'нет';
  end else begin
    lbLateToShift.Font.Color := clRed;
    lbLateToShift.Caption := 'да';
  end;
  if FDayResult.Hooky = 0 then begin
    lbHookyTime.Font.Color := clGray;
    lbHookyTime.Caption := 'нет'
  end else begin
    lbHookyTime.Font.Color := clRed;
    lbHookyTime.Caption := FormatMinutes(FDayResult.Hooky);
    if FDayResult.HookyComps then lbHookyTime.Caption :=
      lbHookyTime.Caption + ' (часть компнсирована)';
  end;
end;


procedure TfrmPersonMinuteAnalysis.ShowAnalysis(AnalysisBitMap: Graphics.TBitMap;
  Date: TDate; DayResult: TDayResult; PersonName: string; Pairs: TEmplPairs);
begin
  FDayResult := DayResult;
  lbDate.Caption := DateToStr(Date) + ' (' + FormatDateTime('dddd', Date) + ')';
  lbPerson.Caption := PersonName;
  if Assigned(AnalysisBitMap) then begin
    imgBmp.Width := AnalysisBitMap.Width;
    imgBmp.Height := AnalysisBitMap.Height;
    imgBmp.Picture.Bitmap.Assign(AnalysisBitMap);
    pnMain.Visible := True;
    Self.Height := 400;
  end else begin
    pnMain.Visible := False;
    Self.Height := 280;
  end;
  WritePairs(Pairs, DateOf(Date));
  WriteTotalTime;
  //
  Self.ShowModal;
end;


end.
