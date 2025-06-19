unit MonthSchedulePresent;

interface


uses SysUtils, Classes, Graphics, Controls, ExtCtrls, ComCtrls, TheShift,
  TheSchedule, Windows, Messages, Forms;

type
  TShiftRectRecord = record
    Rct: TRect;
    Shift: TShift;
  end;

  TMonthSchedulePresent = class(TPaintBox)
  private
    FSchedule: TSchedule;
    FStartDate: TDate;
    FEndDate: TDate;
    FMinPerPixel: integer;
    FRowHeight: integer;
    FColWidth: integer;
    FShiftHeight: integer;
    FHeaderHeight: integer;
    FBufferBmp: Graphics.TBitmap;
    FShiftColor: TColor;
    FHeaderColor: TColor;
    FShiftRectRecords: array of TShiftRectRecord;
    procedure SetMonth(Value: TDate);
    procedure SetSchedule(Value: TSchedule);
    procedure SetSizes;
    procedure DrawColHeader(ACol, ARow: integer; Date: TDate);
    procedure DrawShifts(ACol, ARow: integer; Date: TDate);
    procedure PrepareBitmap;
    procedure DrawPreviosShift(ACol: integer);
    procedure DrawShift(ShiftRct: TRect; Shift: TShift);
  protected
    procedure Paint; override;
    procedure CMHintShow(var Message: TCMHintShow); message CM_HINTSHOW;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Month: TDate read FStartDate write SetMonth;
    property Schedule: TSchedule read FSchedule write SetSchedule;
  end;

implementation

uses DateUtils, Dialogs;

var
  WeekDay: array [0..6] of string = ('пн', 'вт', 'ср', 'чтв', 'птн', 'сб', 'воскр');


constructor TMonthSchedulePresent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSchedule := nil;
  FMinPerPixel := 10;
  FHeaderHeight := 40;
  FShiftHeight := 16;
  FShiftColor := clCream;
  FHeaderColor := clBtnFace;
  FBufferBmp := Graphics.TBitmap.Create;
  Self.ShowHint := True;
  Parent := nil;
  SetMonth(now);
  SetSizes;
end;

destructor TMonthSchedulePresent.Destroy;
begin
  FBufferBmp.Free;
  inherited Destroy;
end;

procedure TMonthSchedulePresent.SetMonth(Value: TDate);
begin
  Self.FStartDate := StartOfTheMonth(Value);
  Self.FEndDate := EndOfTheMonth(Value);
  if (Parent = nil) or (not Parent.HandleAllocated)then Exit;
  PrepareBitmap;
  Paint;
end;

procedure TMonthSchedulePresent.SetSchedule(Value: TSchedule);
begin
  Self.FSchedule := Value;
  SetSizes;
  if (Parent = nil) or (not Parent.HandleAllocated) then Exit;
  PrepareBitmap;
  Paint;
end;

procedure TMonthSchedulePresent.SetSizes;
var
  MaxShiftCount: integer;
begin
  MaxShiftCount := 2;
  {if Assigned(Self.FSchedule) then
    for I := 0 to FSchedule.DayCount - 1 do
      if FSchedule.Day[I].Count > MaxShiftCount then
        MaxShiftCount := FSchedule.Day[I].Count;}
  FRowHeight := FHeaderHeight + MaxShiftCount * FShiftHeight;
  Self.Height := Self.FRowHeight * 6;
  Self.FColWidth := Trunc(60 * 24 / Self.FMinPerPixel);
  Self.Width := FColWidth * 7 + 1;
  FBufferBmp.Width := Self.Width;
  FBufferBmp.Height := Self.Height;
end;

procedure TMonthSchedulePresent.Paint;
begin
  Self.Canvas.CopyRect(Self.ClientRect, Self.FBufferBmp.Canvas,
    FBufferBmp.Canvas.ClipRect);
end;

procedure TMonthSchedulePresent.DrawColHeader(ACol, ARow: integer;
  Date: TDate);
var
  Rct: TRect;
  Text: string;
  LineHeight, I: integer;
begin
  if (Date < Self.FStartDate) or (Date > Self.FEndDate) then Exit;
  LineHeight := Trunc(Self.FHeaderHeight / 2);
  with FBufferBmp do begin
    Canvas.Font.Height := LineHeight - 4;
    Rct.Top := ARow * Self.FRowHeight + 2;
    Rct.Bottom := Rct.Top + Self.FHeaderHeight;
    Rct.Left := ACol * Self.FColWidth;
    Rct.Right := Rct.Left + Self.FColWidth + 1;
    Canvas.Brush.Color := Self.FHeaderColor;
    Canvas.Rectangle(Rct);
    for I := 1 to 23 do begin
      Canvas.MoveTo(Rct.Left + Trunc(I * 60 / Self.FMinPerPixel), Rct.Bottom - 1);
      if I in [8, 12, 16] then
        Canvas.LineTo(Rct.Left + Trunc(I * 60 / Self.FMinPerPixel), Rct.Bottom - 10)
      else
        Canvas.LineTo(Rct.Left + Trunc(I * 60 / Self.FMinPerPixel), Rct.Bottom - 7)
    end;
    Rct.Bottom := Rct.Top + LineHeight;
    Text := DateToStr(Date);
    DrawText(Canvas.Handle, PAnsiChar(Text), Length(Text), Rct,
      DT_CENTER or DT_SINGLELINE or DT_VCENTER);
    OffsetRect(Rct, 0, LineHeight - 5);
    Text := WeekDay[DateUtils.DayOfTheWeek(Date) - 1];
    DrawText(Canvas.Handle, PAnsiChar(Text), Length(Text), Rct,
      DT_CENTER or DT_SINGLELINE or DT_VCENTER);
  end;
end;

procedure TMonthSchedulePresent.DrawShift(ShiftRct: TRect; Shift: TShift);
var
  Text: string;
  TextRct: TRect;
begin
  FBufferBmp.Canvas.Font.Height := ShiftRct.Bottom - ShiftRct.Top - 4;
  FBufferBmp.Canvas.Brush.Color := Self.FShiftColor;
  FBufferBmp.Canvas.Rectangle(ShiftRct);
  Text := Shift.Title;
  TextRct := ShiftRct;
  Inc(TextRct.Left, 2);
  Dec(TextRct.Right, 2);
  DrawText(FBufferBmp.Canvas.Handle, PAnsiChar(Text), Length(Text),
    TextRct, DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
  SetLength(FShiftRectRecords, High(FShiftRectRecords) + 2);
  FShiftRectRecords[High(FShiftRectRecords)].Rct := ShiftRct;
  FShiftRectRecords[High(FShiftRectRecords)].Shift := Shift;
end;

procedure TMonthSchedulePresent.DrawPreviosShift(ACol: integer);
var
  ShiftRct: TRect;
  i, DayNum, RectWdt: integer;
  Shift: TShift;
begin
  DayNum := Self.FSchedule.GetDayNumber(IncDay(Self.FStartDate, -1));
  for I := 0 to FSchedule.Day[DayNum].Count - 1 do begin
    Shift := FSchedule.Day[DayNum].Items[I];
    RectWdt := MinuteOfTheDay(Shift.StartTime) + Shift.LengthOfMinutes;
    if RectWdt > 60 * 24 then begin
      RectWdt := Trunc((RectWdt - 60 * 24) / Self.FMinPerPixel);
      ShiftRct.Left := ACol * Self.FColWidth;
      ShiftRct.Right := ShiftRct.Left + RectWdt;
      ShiftRct.Top := FHeaderHeight + 4;
      ShiftRct.Bottom := ShiftRct.Top + Self.FShiftHeight;
      DrawShift(ShiftRct, Shift);
    end;
  end;
end;

procedure TMonthSchedulePresent.DrawShifts(ACol, ARow: integer; Date: TDate);
var
  I, DayNum: integer;
  Rct, ShiftRct: TRect;
  Shift: TShift;
begin
  if (Date < Self.FStartDate) or (Date > Self.FEndDate) then Exit;
  DayNum := FSchedule.GetDayNumber(Date);
  // Прямоугольник ячейки.
  Rct.Top := ARow * FRowHeight + FHeaderHeight;
  Rct.Bottom := (ARow + 1) * Self.FRowHeight - 1;
  Rct.Left := ACol * Self.FColWidth;
  Rct.Right := Rct.Left + Self.FColWidth + 1;
  FBufferBmp.Canvas.Brush.Color := clWhite;
  // Выводим смены.
  for I := 0 to FSchedule.Day[DayNum].Count - 1 do begin
    Shift := FSchedule.Day[DayNum].Items[I];
    // Прямоугольник смены.
    ShiftRct.Left := Rct.Left + Trunc(MinuteOfTheDay(Shift.StartTime)
      / FMinPerPixel);
    ShiftRct.Right := ShiftRct.Left + Trunc(Shift.LengthOfMinutes
      / FMinPerPixel);
    ShiftRct.Top := Rct.Top + 4;
    ShiftRct.Bottom := ShiftRct.Top + Self.FShiftHeight;
    if ShiftRct.Right <= FBufferBmp.Width then begin
      // Если смена полностью помещается в строку.
      DrawShift(ShiftRct, Shift);
    end else begin
      // Если смена не помещается в строку часть ее переносится.
      DrawShift(ShiftRct, Shift);
      ShiftRct.Left := 0;
      ShiftRct.Right := ShiftRct.Right - FBufferBmp.Width;
      ShiftRct.Top := ShiftRct.Top + FRowHeight;
      ShiftRct.Bottom := ShiftRct.Top + Self.FShiftHeight;
      DrawShift(ShiftRct, Shift);
    end;
  end;
  FBufferBmp.Canvas.Brush.Color := clWhite;
end;

procedure TMonthSchedulePresent.PrepareBitmap;
var
  I, J : integer;
  Date: TDate;
begin
  if not Assigned(Self.FSchedule) then Exit;  
  SetLength(FShiftRectRecords, 0);
  FBufferBmp.Canvas.FillRect(FBufferBmp.Canvas.ClipRect);
  for I := 0 to 5 do
    for J := 0 to 6 do begin
      Date := IncDay(Self.FStartDate, (I * 7) + j
        - DayOfTheWeek(Self.FStartDate) + 1);
      if Date = FStartDate then Self.DrawPreviosShift(J);      
      Self.DrawColHeader(J, I, Date);
      Self.DrawShifts(J, I, Date);
    end;
end;

procedure TMonthSchedulePresent.CMHintShow(var Message: TCMHintShow);
var
  I, Y, X: integer;
  Pt: TPoint;
  ShiftRctRec: TShiftRectRecord;
begin
  Message.HintInfo.HintStr := '??';
  if Message.HintInfo.HintControl = Self then begin
    Pt := Message.HintInfo.HintPos;
    Pt := Self.ScreenToClient(Pt);
    Y := Pt.Y - 16;
    X := Pt.X;
    for I := 0 to High(Self.FShiftRectRecords) do begin
      ShiftRctRec := Self.FShiftRectRecords[I];
      if (X > ShiftRctRec.Rct.Left) and (X < ShiftRctRec.Rct.Right)
        and (Y > ShiftRctRec.Rct.Top) and (Y < ShiftRctRec.Rct.Bottom) then begin
          Message.HintInfo.HintStr := ShiftRctRec.Shift.Title;
        end;
    end;
  end;
  Message.Result := 0;
end;

end.
