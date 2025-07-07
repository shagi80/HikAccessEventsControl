unit AnalysisByMinPresent;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls, StdActns,
  ActnList, ToolWin, ImgList, Grids, TheAnalysisByMinute, Contnrs;

type
  TTikEvent = procedure (Sender: TObject) of object;

  TShowHours = set of byte;

  TPersonStateHandler = class(TObject)
  private
    FPersonState: TPersonMinuteState;
  public
    constructor Create(Value: TPersonMinuteState);
    property PersonState: TPersonMinuteState read FPersonState;
  end;

  TAnalysisByMinPresent = class(TStringGrid)
  private
    FAnalysis: TAnalysisByMinute;
    FTexColCount: integer;
    FMinPerPixel: integer;
    FShowHours: TShowHours;
    FTikEvent: TTikEvent;
    procedure SetDrawColWidth;
    procedure Clear;
    function CreatePersonBitmap(ARow: integer): TObject;
    function CreateHeaderBitmap: TObject;
    procedure SetAnalysis(Value: TAnalysisByMinute);
    procedure DrawColHeader(ACol: integer; Rct: TRect);
    procedure SetMinPerPixel(Value: integer);
    procedure SetShowHours;
    procedure PrepareDayBitMap(ACol, ARow: integer; var TargetBmp: Graphics.TBitmap);
    procedure WriteTotalTime(TotalDayResylt: TPersonResult; ARow: integer);
    procedure DrawDayMark(DayNum, PersonInd: integer; Rct: TRect);
  protected
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    procedure DblClick; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Analysis: TAnalysisByMinute read FAnalysis write SetAnalysis;
    property ShowHours: TShowHours write FShowHours;
    property MinPerPixel: integer read FMinPerPixel write SetMinPerPixel;
    property OnTikEvent: TTikEvent read FTikEvent write FTikEvent;
    procedure UpdateAnalys;
  end;

implementation

uses DateUtils, TheBreaks, TheSchedule, TheShift, PersonMinuteAnalysisWin;

{ TPersonStateHandler }

constructor TPersonStateHandler.Create(Value: TPersonMinuteState);
begin
  inherited Create;
  Self.FPersonState := Value;
end;

{ TAnalysisByMinPresent }

constructor TAnalysisByMinPresent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Self.FAnalysis := nil;
  Self.Ctl3D := False;
  Self.FixedCols := 1;
  Self.FTexColCount := 8;
  Self.ColCount := FTexColCount + 1;
  Self.FixedRows := 1;
  Self.RowCount := 2;
  Self.DefaultRowHeight := 24;
  Self.RowHeights[0] := 60;
  Self.DefaultColWidth := 90;
  Self.ColWidths[0] := 200;
  Self.FMinPerPixel := 10;
  self.Parent := TWinControl(AOwner);
  Self.Font.Height := 13;
end;

destructor TAnalysisByMinPresent.Destroy;
begin
  Self.Clear;
  inherited Destroy;
end;

procedure TAnalysisByMinPresent.Clear;
var
  I: integer;
begin
  for I := 0 to RowCount - 1 do
    Self.Rows[I].Clear;
end;

procedure TAnalysisByMinPresent.SetAnalysis(Value: TAnalysisByMinute);
begin
  FAnalysis := Value;
  Self.UpdateAnalys;
end;

procedure TAnalysisByMinPresent.SetMinPerPixel(Value: integer);
begin
  FMinPerPixel := Value;
  Self.SetDrawColWidth;
  Self.Repaint;
end;

{ Метод обновления данных. }

procedure TAnalysisByMinPresent.SetDrawColWidth;
var
  I: integer;
begin
  for I := FTexColCount to ColCount - 1 do
    Self.ColWidths[I] := Trunc(60 * 24 / FMinPerPixel);
end;

procedure TAnalysisByMinPresent.SetShowHours;
var
  I, J: integer;
  H: byte;
  ShiftList: TShiftList;
  Shift: TShift;
begin
  FShowHours := [];
  for I := 0 to FAnalysis.ScheduleTemplate.DayCount - 1 do begin
    ShiftList := FAnalysis.ScheduleTemplate.Day[I];
    for J := 0 to ShiftList.Count - 1 do begin
      Shift := ShiftList.Items[J];
      H := DateUtils.HourOf(Shift.StartTime);
      if not (H in FShowHours)  then FShowHours := FShowHours + [H];
      H := DateUtils.HourOf(Shift.EndTime);
      if not (H in FShowHours)  then FShowHours := FShowHours + [H];
    end;
  end;
end;

procedure TAnalysisByMinPresent.WriteTotalTime(TotalDayResylt: TPersonResult;
  ARow: integer);

  function FormatMinutes(Value: integer): string;
  var
    h, m: integer;
  begin
    h := Value div 60;
    m := Value - h * 60;
    Result := IntToStr(h) + ' ч ' + FormatFloat('00', m) + ' мин';
  end;

var
  TotalTime: integer;
begin
  Self.Cells[1, ARow] := FormatMinutes(TotalDayResylt.Schedule);
  Self.Cells[2, ARow] := FormatMinutes(TotalDayResylt.TotalWork);
  if TotalDayResylt.Overtime > 0 then
    Self.Cells[3, ARow] := FormatMinutes(TotalDayResylt.Overtime)
      else Self.Cells[3, ARow] := 'no';
  TotalTime := TotalDayResylt.TotalWork + TotalDayResylt.Overtime;
  Self.Cells[4, ARow] := FormatMinutes(TotalTime);
  if (TotalTime >= TotalDayResylt.Schedule) then
    Self.Cells[5, ARow] := 'yes' else Self.Cells[5, ARow] := 'no';
  if TotalDayResylt.LateCount = 0 then Self.Cells[6, ARow] := 'no'
    else Self.Cells[6, ARow] := IntToStr(TotalDayResylt.LateCount);
  if TotalDayResylt.Hooky = 0 then Self.Cells[7, ARow] := 'no'
    else Self.Cells[7, ARow] := FormatMinutes(TotalDayResylt.Hooky);
end;

procedure TAnalysisByMinPresent.UpdateAnalys;
var
  ARow: integer;
  PersonStateHandler: TPersonStateHandler;
begin
  Self.Enabled := False;
  Self.Clear;
  if not Assigned(FAnalysis) then  begin
    Self.RowCount := 2;
    Self.ColCount := FTexColCount + 1;
    Exit;
  end;
  if (not Assigned(FAnalysis)) or (FAnalysis.PersonCount = 0)
    or (FAnalysis.DayCount = 0) then Exit;
  Self.Enabled := True;
  Self.Cells[0, 0] := 'ФИО сотрудника';
  Self.Cells[1, 0] := 'Время по графику';
  Self.Cells[2, 0] := 'Отработанно по графику';
  Self.Cells[3, 0] := 'Отработано вне графика';
  Self.Cells[4, 0] := 'Отработанно всего';
  Self.Cells[5, 0] := 'Выполнение нормы';
  Self.Cells[6, 0] := 'Опоздания на смену';
  Self.Cells[7, 0] := 'Все прогулы и нарушения';
  Self.RowCount := FAnalysis.PersonCount + Self.FixedRows;
  Self.ColCount := FTexColCount + FAnalysis.DayCount;


  Self.SetDrawColWidth;
  Self.SetShowHours;
  Self.Objects[0, 0] := Self.CreateHeaderBitmap;
  for ARow := FixedRows to RowCount - 1 do begin
    Self.Cells[0, ARow] := FAnalysis.PersonState[ARow - FixedRows].PersonName;
    Self.Objects[0, ARow] := Self.CreatePersonBitmap(ARow);
    Self.WriteTotalTime(FAnalysis.PersonState[ARow - 1].TotalDayResult, ARow);
    PersonStateHandler := TPersonStateHandler.Create(FAnalysis.PersonState[ARow - 1]);
    Self.Objects[Self.FTexColCount, ARow] := PersonStateHandler;
    if Assigned(Self.FTikEvent) then Self.FTikEvent(Self);
  end;
  if self.Visible then Self.Repaint;
end;

{ Методы рисования. }

procedure TAnalysisByMinPresent.DrawColHeader(ACol: integer; Rct: TRect);
var
  X, FontHeight, I: integer;
  Text: string;
  HourPoint: TPoint;
begin
  Canvas.Font.Color := clBlack;
  for I := 1 to 23 do begin
    X := Trunc(60 * I / Self.FMinPerPixel) + Rct.Left;
    if I in Self.FShowHours then begin
      FontHeight := Self.Canvas.Font.Height;
      Self.Canvas.Font.Height := 10;
      Text := IntToStr(I) + ':00';
      HourPoint.X := X - Trunc(Self.Canvas.TextWidth(Text) / 2);
      HourPoint.Y := Rct.Bottom - 16 - Self.Canvas.TextHeight(Text);
      Self.Canvas.TextOut(HourPoint.X, HourPoint.Y, Text);
      Self.Canvas.Font.Height := FontHeight;
    end;
  end;
  Text := DateToStr(IncDay(FAnalysis.StartDate, ACol - Self.FTexColCount + 1));
  Inc(Rct.Top, 2);
  Rct.Bottom := Rct.Top + 18;
  DrawText(Self.Canvas.Handle, PAnsiChar(Text), Length(Text), Rct,
    DT_CENTER or DT_VCENTER or DT_SINGLELINE);
  Text := FormatDateTime('dddd', StrToDateDef(Text, 0));
  OffsetRect(Rct, 0, 13);
  DrawText(Self.Canvas.Handle, PAnsiChar(Text), Length(Text), Rct,
    DT_CENTER or DT_VCENTER or DT_SINGLELINE);
end;

function TAnalysisByMinPresent.CreateHeaderBitmap: TObject;
const
  ScheduleY = 47;
var
  DayNum, I, X: integer;
  Rct: TRect;
  HeaderBitmap: Graphics.TBitmap;

  procedure DrawLine(ScheduleX: integer; LineColor: TColor);
  begin
    HeaderBitmap.Canvas.Pen.Color := LineColor;
    HeaderBitmap.Canvas.MoveTo(ScheduleX, ScheduleY);
    HeaderBitmap.Canvas.LineTo(ScheduleX, ScheduleY + 12);
  end;

begin
  HeaderBitmap := Graphics.TBitmap.Create;
  HeaderBitmap.Width := FAnalysis.MinuteCount;
  HeaderBitmap.Height := Self.RowHeights[0];
  HeaderBitmap.Canvas.Brush.Color :=Self.FixedColor;
  HeaderBitmap.Canvas.FillRect(HeaderBitmap.Canvas.ClipRect);
  //
  for I := 0 to FAnalysis.MinuteCount - 1 do
    case FAnalysis.ScheduleState[I] of
      ssWork: DrawLine(I, rgb(119, 180, 219));
      ssEarlyToBreak, ssEarlyFromShist, ssLateFromBreak,
        ssLateToShift: DrawLine(I, rgb(154, 214, 254));
      ssBreak: DrawLine(I, rgb(214, 214, 214));
      ssInTime, ssOutTime: DrawLine(I, rgb(214, 214, 214));
    end;
  //
  Rct := HeaderBitmap.Canvas.ClipRect;
  for DayNum := 0 to Self.FAnalysis.DayCount do begin
    Rct.Left := Trunc(DayNum * 60 * 24);
    if DayNum > 0 then HeaderBitmap.Canvas.Pen.Color := clBlack
      else HeaderBitmap.Canvas.Pen.Color := clGray;
    for I := 1 to 23 do begin
      X := (60 * I + Rct.Left);
      HeaderBitmap.Canvas.MoveTo(X,  Rct.Bottom);
      if I in Self.FShowHours then
        HeaderBitmap.Canvas.LineTo(X,  Rct.Bottom - 15)
          else HeaderBitmap.Canvas.LineTo(X, Rct.Bottom - 10);
    end;
  end;
  Result := HeaderBitmap;
end;

function TAnalysisByMinPresent.CreatePersonBitmap(ARow: integer): TObject;
const
  PresenceY = 6;
  EventY = 10;
var
  Buf: Graphics.TBitmap;
  I: integer;
  PersonState: TPersonMinuteState;
  AColor: TColor;

  procedure DrawLine(X, Y, LineHeight, LineColor: TColor);
  begin
    Buf.Canvas.Pen.Color := LineColor;
    Buf.Canvas.MoveTo(X, Y);
    Buf.Canvas.LineTo(X, Y + LineHeight);
  end;

begin
  Buf := Graphics.TBitmap.Create;
  Buf.Width := FAnalysis.MinuteCount;
  Buf.Height := Self.DefaultRowHeight;
  Buf.Canvas.Brush.Color := clWhite;
  Buf.Canvas.FillRect(Buf.Canvas.ClipRect);
  for I := 0 to FAnalysis.MinuteCount - 1 do begin
    PersonState := FAnalysis.PersonState[ARow - FixedRows];
    if PersonState.StateArray[I].Presence then
      DrawLine(I, PresenceY, 3, clGray);
    AColor := clWhite;
    case PersonState.StateArray[I].EventState of
      esHooky, esEarlyFromShiftOrBreak, esLateToShift, esLateFromBreak: AColor := clRed;
      esWork: AColor := clGreen;
      esWorkOnBreak: AColor := $008AC49B;
      esOvertime: AColor := clYellow;
    end;
    DrawLine(I, EventY, 10, AColor);
  end;
  Result := Buf;
end;

procedure TAnalysisByMinPresent.DrawDayMark(DayNum, PersonInd: integer; Rct: TRect);
var
  DayResult: TDayResult;
begin
  DayResult := FAnalysis.PersonState[PersonInd].DayResult[DayNum - 1];
  if DayResult.State = dsNormal then Exit;
  Rct.Left := Rct.Right - 6;
  Rct.Bottom := Rct.top + 6;
  OffsetRect(Rct, -1, 1);
  if DayResult.State = dsHooky then Canvas.Brush.Color := clRed;
  if DayResult.State = dsOvertime then Canvas.Brush.Color := clYellow;
  Canvas.Ellipse(Rct);
end;

procedure TAnalysisByMinPresent.DrawCell(ACol, ARow: Longint; ARect: TRect;
  AState: TGridDrawState);
var
  Rct: TRect;
  DayNum: integer;
  Bmp: Graphics.TBitmap;
  Text: string;
  Flag: cardinal;
begin
  Rct := ARect;
  if (ACol >= Self.FTexColCount) and (Assigned(Self.Objects[0, ARow])) then begin
      Bmp := Graphics.TBitmap(Self.Objects[0, ARow]);
      DayNum := ACol - Self.FTexColCount + 1;
      Rct.Left := DayNum * 60 * 24;
      Rct.Top := 0;
      Rct.Right := Rct.Left + 60 *24;
      Rct.Bottom := Bmp.Height;
      Canvas.CopyRect(ARect, Bmp.Canvas, Rct);
      if (ARow = 0)then DrawColHeader(ACol, ARect);
      if (ARow > 0) then DrawDayMark(DayNum, (ARow - Self.FixedRows), ARect);
    end;
  if (ACol < Self.FTexColCount) then begin
    if ARow = 0 then Canvas.Brush.Color := Self.FixedColor
      else Canvas.Brush.Color := Self.Color;
    Canvas.FillRect(Rct);
    Canvas.Font.Color := clBlack;
    Text := Self.Cells[ACol, ARow];
    if ACol = 4 then Canvas.Font.Style := [fsBold]
      else Canvas.Font.Style := [];
    if ARow > 0 then
      case ACol of
        5: if Text = 'yes' then Canvas.Font.Color := clGreen
          else Canvas.Font.Color := clRed;
        3: if Text = 'no' then Canvas.Font.Color := clSilver
          else Canvas.Font.Color := clGreen;
        6: if Text = 'no' then Canvas.Font.Color := clSilver
          else begin
            Canvas.Font.Color := clRed;
            Text := 'да / ' + Text + ' дн';
          end;
        7: if Text = 'no' then Canvas.Font.Color := clSilver
          else Canvas.Font.Color := clRed;
      end;
    if Text = 'no' then Text := 'нет';
    if Text = 'yes' then Text := 'да';
    Flag := DT_SINGLELINE or DT_VCENTER;
    if (ACol = 0) and (ARow > 0) then Flag := Flag or DT_LEFT
      else Flag := Flag or DT_CENTER;
    if ARow = 0 then begin
      Flag := DT_WORDBREAK or DT_CENTER;
      Rct.Top := Rct.Top + 10;
    end;
    DrawText(Canvas.Handle, PAnsiChar(Text), Length(Text), Rct, Flag);
  end;
end;

{ Click }

procedure TAnalysisByMinPresent.PrepareDayBitMap(ACol, ARow: integer;
  var TargetBmp: Graphics.TBitmap);
var
  Bmp: Graphics.TBitMap;
  TargetRct, Rct: TRect;
  I: integer;
  Text: string;
  HourPoint: TPoint;
begin
  TargetBmp.Width := 60 *24;
  TargetBmp.Height := Self.DefaultRowHeight * 3;
  TargetRct := TargetBmp.Canvas.ClipRect;
  TargetRct.Bottom := Self.DefaultRowHeight;
  TargetBmp.Canvas.Brush.Color := Self.FixedColor;
  TargetBmp.Canvas.FillRect(TargetRct);
  TargetBmp.Canvas.Font.Height := 13;
  for I := 1 to 23 do begin
    if I in Self.FShowHours then TargetBmp.Canvas.Font.Style := [fsBold]
      else TargetBmp.Canvas.Font.Style := [];
    Text := IntToStr(I) + ':00';
    HourPoint.X := 60 * I - Trunc(Self.Canvas.TextWidth(Text) / 2);
    HourPoint.Y := TargetRct.Bottom - TargetBmp.Canvas.TextHeight(Text);
    TargetBmp.Canvas.TextOut(HourPoint.X, HourPoint.Y, Text);
  end;
  //
  Bmp := Graphics.TBitmap(Self.Objects[0, 0]);
  Rct.Left := (ACol - Self.FTexColCount + 1) * 60 * 24;
  Rct.Right := Rct.Left + 60 *24;
  Rct.Bottom := Bmp.Height;
  Rct.Top := Rct.Bottom - Self.DefaultRowHeight;
  TargetRct.Top := Self.DefaultRowHeight;
  TargetRct.Bottom := Self.DefaultRowHeight * 2;
  TargetBmp.Canvas.CopyRect(TargetRct, Bmp.Canvas, Rct);
  //
  Bmp := Graphics.TBitmap(Self.Objects[0, ARow]);
  TargetRct.Left := 0;
  TargetRct.Right := TargetRct.Left + 60 *24;
  TargetRct.Top := Self.DefaultRowHeight * 2;
  TargetRct.Bottom := TargetBmp.Height;
  Rct.Top := 0;
  Rct.Bottom := Bmp.Height;
  TargetBmp.Canvas.Rectangle(TargetRct);
  TargetBmp.Canvas.CopyRect(TargetRct, Bmp.Canvas, Rct);
  //
  TargetBmp.Canvas.MoveTo(0, TargetRct.Top);
  TargetBmp.Canvas.LineTo(TargetRct.Right, TargetRct.Top);
end;

procedure TAnalysisByMinPresent.DblClick;
var
  Day: TDate;
  PersonStateHandler: TPersonStateHandler;
  TargetBmp: Graphics.TBitMap;
  DayResult: TDayResult;
begin
  if (Self.Row <= 0) or (Self.Col < Self.FTexColCount)
    or (not Assigned(Self.Objects[Self.FTexColCount, Self.Row])) then Exit;
  TargetBmp := Graphics.TBitMap.Create;
  PrepareDayBitMap(Self.Col, Self.Row, TargetBmp);
  Day := IncDay(FAnalysis.StartDate, Self.Col - Self.FTexColCount + 1);
  PersonStateHandler := TPersonStateHandler(
    Self.Objects[Self.FTexColCount, Self.Row]);
  DayResult := PersonStateHandler.PersonState.DayResult[Self.Col
    - Self.FTexColCount];
  frmPersonMinuteAnalysis.ShowAnalysis(TargetBmp, Day, DayResult,
    PersonStateHandler.PersonState.PersonName,
    PersonStateHandler.PersonState.Pairs);
  TargetBmp.Free;
end;

end.
