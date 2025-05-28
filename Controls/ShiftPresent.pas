unit ShiftPresent;

interface

uses SysUtils, Classes, Graphics, Controls, ExtCtrls, ComCtrls, TheShift;

type
  TShiftPresent = class(TPaintBox)
  private
    FShift: TShift;
    FScale: real;
    FFormat: string;
    FEndTime: TTime;
    FTextHeight: integer;
    FRealWidth: integer;
    const ImgSize = 50;
    procedure SetWidth;
    procedure SetShift(Shift: TShift);
    procedure SetScale(Scale: real);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Shift: TShift read FShift write SetShift;
    property Scale: real read FScale write SetScale;
  end;


implementation

uses DateUtils, TheBreaks, Dialogs, Windows;

constructor TShiftPresent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FShift := nil;
  FFormat := 'hh:mm';
  FTextHeight := 14;
  FScale := 1;
  Self.Height := Self.FTextHeight + Self.ImgSize;
  Self.Width := Self.ImgSize * 2 + 60;
end;

procedure TShiftPresent.SetWidth;

  function CalculateRealWidth(Scale: real): integer;
  begin
    Result := 0;
    if (not FShift.IncorrectIn) and (FShift.InStart < FShift.StartTime) then
      Result := Result + MinutesBetween(FShift.InStart, FShift.StartTime);
    if (not FShift.IncorrectOut) and
      (MinuteOfTheDay(Shift.OutFinish) > MinuteOfTheDay(FEndTime)) then
        Result := Result + (MinuteOfTheDay(Shift.OutFinish)
          - MinuteOfTheDay(FEndTime));
    Result := Self.ImgSize * 2 + trunc(Scale *(FShift.LengthOfMinutes
      + Result));
  end;

begin
  if Self.Align in [alClient, alTop, alBottom] then begin
    FRealWidth := CalculateRealWidth(1);
    if FRealWidth > Self.ClientWidth then begin
      FScale := Self.ClientWidth / FRealWidth * 0.9;
      FRealWidth := CalculateRealWidth(FScale);
    end else FScale := 1;
  end else begin
    FRealWidth := CalculateRealWidth(FScale);;
    Self.Width := FRealWidth ;
  end;
end;

procedure TShiftPresent.SetShift(Shift: TShift);
begin
  Self.FShift := Shift;
  Self.Paint;
end;

procedure TShiftPresent.SetScale(Scale: real);
begin
  if FScale > Scale then FTextHeight := FTextHeight - 1
    else FTextHeight := FTextHeight + 1;
  FScale := Scale;
  Self.Height := FTextHeight + Self.ImgSize;
  if Shift = nil then Exit;
  Self.Paint;
end;

procedure TShiftPresent.Paint;
var
  Bmp: Graphics.TBitMap;
  Wdth, X, X0, Y0, I: integer;
  Break: TBreak;
  Text: string;
  Rct: TRect;

  procedure TimeOut(X, Y: integer; Time: TTime);
  var
    Text: string;
  begin
    Text := FormatDateTime(Self.FFormat, Time);
    Wdth := Canvas.TextWidth(Text);
    Canvas.TextOut(X - trunc(Wdth / 2), Y, Text);
  end;

begin
  inherited Paint;

  { Изображения входа и выхода. }
  FEndTime := IncMinute(FShift.StartTime, FShift.LengthOfMinutes);
  Self.SetWidth;
  Self.Canvas.Font.Height := Self.FTextHeight;
  Self.Canvas.Brush.Color := clWhite;
  Self.Canvas.FillRect(Self.ClientRect);
  Bmp := Graphics.TBitMap.Create;
  Bmp.LoadFromResourceName(HInstance, 'PERSON_ENTER');
  Self.Canvas.CopyRect(Rect(0, 0, ImgSize, ImgSize),
    Bmp.Canvas, Bmp.Canvas.ClipRect);
  Bmp.LoadFromResourceName(HInstance, 'PERSON_ENTER');
  Self.Canvas.CopyRect(Rect(FRealWidth - ImgSize, 0, FRealWidth, ImgSize),
    Bmp.Canvas, Bmp.Canvas.ClipRect);
  Bmp.Free;

  { Период в хода и выхода. }
  Canvas.Pen.Width := 3;
  Canvas.Pen.Color := clGreen;
  if not FShift.IncorrectIn then begin
      Y0 := ImgSize - Canvas.Pen.Width - 1;
      X := ImgSize;
      TimeOut(X, ImgSize, FShift.InStart);
      Canvas.MoveTo(X + 2, Y0);
      X := X + trunc(MinutesBetween(FShift.InStart, FShift.InFinish) * FScale);
      Canvas.LineTo(X, Y0);
      TimeOut(X, ImgSize, FShift.InFinish);
    end;
  if not FShift.IncorrectOut then begin
      Y0 := ImgSize - Canvas.Pen.Width - 1;
      X := FRealWidth - Self.ImgSize;
      TimeOut(X, ImgSize, FShift.OutFinish);
      Canvas.MoveTo(X - 2, Y0);
      X := X - trunc(MinutesBetween(FShift.OutStart, FShift.OutFinish) * FScale);
      Canvas.LineTo(X, Y0);
      TimeOut(X, ImgSize, FShift.OutStart);
    end;

  { Шкала времени. }
  Canvas.Pen.Width := 1;
  Canvas.Pen.Color := clSilver;
  if not FShift.IncorrectIn then
      X0 := ImgSize + trunc(FScale * MinutesBetween(FShift.InStart,
        FShift.StartTime))
  else X0 := ImgSize;
  Y0 := FTextHeight + 3;
  Canvas.MoveTo(X0, Y0);
  X := X0 + trunc(FScale * FShift.LengthOfMinutes);
  Canvas.LineTo(X, Y0);
  I := 0;
  while I <= FShift.LengthOfMinutes do begin
    X := X0 + trunc(I * FScale);
    Canvas.MoveTo(X, Y0);
    if I mod 60 = 0 then begin
        Canvas.LineTo(X, Y0 + 20);
        TimeOut(X, 0, IncMinute(FShift.StartTime, I));
      end else if I mod 30 = 0 then Canvas.LineTo(X, Y0 + 15)
        else Canvas.LineTo(X, Y0 + 10);
    Inc(I, 15);
  end;

  { Перерывы }
  Canvas.Pen.Width := 3;
  Canvas.Pen.Color := clRed;
  if not FShift.IncorrectBreaks then
    for I := 0 to FShift.Breaks.Count - 1 do begin
      Break := FShift.Breaks[I];
      if MinuteOfTheDay(Break.StartTime) > MinuteOfTheDay(FShift.StartTime) then
        X := X0 + trunc(FScale * MinutesBetween(FShift.StartTime,
          Break.StartTime))
      else
        X := X0 + trunc(FScale * FShift.LengthOfMinutes)
          - trunc(FScale * (MinuteOfTheDay(Self.FEndTime)
          - MinuteOfTheDay(Break.StartTime)));
      Canvas.MoveTo(X, Y0);
      Canvas.LineTo(X + trunc(FScale * Break.LengthOfMinutes), Y0);
      X := X + trunc(trunc(FScale * Break.LengthOfMinutes) / 2);
      Wdth := Canvas.TextWidth(Break.Title);
      Canvas.TextOut(trunc(X - Wdth / 2), Y0 + Canvas.Pen.Width + 1, Break.Title);
    end;

  { Сообщение об ошибке. }
  if FShift.Incorrect then begin
      Canvas.Font.Color := clRed;
      Rct := Canvas.ClipRect;
      Text := 'Ошибки в задании параметров времени или перерывов !';
      DrawText(Canvas.Handle, PAnsiChar(Text), Length(Text), Rct,
        DT_CENTER or DT_VCENTER or DT_SINGLELINE);
    end;
end;


end.
