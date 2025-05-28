unit ScheduleTemplatePresent;

interface


uses SysUtils, Classes, Graphics, Controls, ExtCtrls, ComCtrls, TheShift,
  TheSchedule, Dialogs, StdCtrls, Forms, Windows, Buttons;

type
  TOnClickDeleteButton = procedure (DayNum: integer; Shift: TShift) of object;

  TOnClickAddButton = procedure (DayNum: integer) of object;

  TScheduleShiftPresent = class(TPanel)
  private
    FShift: TShift;
    FShowDeleteBtn: boolean;
    FDelBtn: TSpeedButton;
    procedure SetSize;
    procedure SetShift(Shift: TShift);
    procedure ClickDeleteButton(Sender: TObject);
    procedure SetDayNum(Value: integer);
    function GetDayNum: integer;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Shift: TShift read FShift write SetShift;
    property DayNum: integer read GetDayNum write SetDayNum;
    procedure UpdateShift;
  end;

  TScheduleTemplatePresent = class(TPanel)
  private
    FSchedule: TSchedule;
    FMinPerPixel: integer;
    FHeaderHeight: integer;
    FLineHeight: integer;
    FGridColor: TColor;
    FHeaderColor: TColor;
    FDayWidth: integer;
    FOnClickAddButton: TOnClickAddButton;
    FOnClickDeleteButton: TOnClickDeleteButton;
    procedure SetSize;
    procedure SetSchedule(Schedule: TSchedule);
    procedure AddButton(DayNum: integer);
    procedure ClickAddButton(Sender: TObject);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Resize; override;
    procedure UpdateSchedule;
    //procedure AddShift(DayNum: integer; Shift: TShift);
    procedure DelShift(Shift: TShift);
    property Schedule: TSchedule read FSchedule write SetSchedule;
    property MinPerPixel: integer read FMinPerPixel write FMinPerPixel;
    property LineHeight: integer read FLineHeight write FLineHeight;
    property OnClickAddButton: TOnClickAddButton read FOnClickAddButton
      write FOnClickAddButton;
    property OnClickDeleteButton: TOnClickDeleteButton read FOnClickDeleteButton
      write FOnClickDeleteButton;
  end;


implementation

uses DateUtils;

var
  WeekDay: array [0..6] of string = ('пн', 'вт', 'ср', 'чтв', 'птн', 'сб', 'воскр');


{ TScheduleShiftPresent }

constructor TScheduleShiftPresent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Self.DoubleBuffered := True;
  Color := clCream;
  FShift := nil;
  Self.ShowHint := True;
  FDelBtn := TSpeedButton.Create(Self);
  FDelBtn.Flat := True;
  FDelBtn.Caption := 'x';
  FDelBtn.Font.Size := 8;
  FDelBtn.Font.Style := [fsBold];
  FDelBtn.Font.Color := clRed;
  FDelBtn.Width := 11;
  FDelBtn.Height := 10;
  FDelBtn.Top := 1;
  FDelBtn.Left := Self.Width - FDelBtn.Width - 2;
  FDelBtn.OnClick := Self.ClickDeleteButton;
  Self.InsertControl(FDelBtn);
  FShowDeleteBtn := True;
end;

destructor TScheduleShiftPresent.Destroy;
begin
  FDelBtn.Free;
  inherited Destroy;
end;

procedure TScheduleShiftPresent.SetSize;
begin
  Self.Width := Trunc(FShift.LengthOfMinutes /
    TScheduleTemplatePresent(Owner).FMinPerPixel);
end;

procedure TScheduleShiftPresent.SetDayNum(Value: integer);
begin
  Self.FDelBtn.Tag := Value;
end;

function TScheduleShiftPresent.GetDayNum: integer;
begin
  Result := Self.FDelBtn.Tag;
end;

procedure TScheduleShiftPresent.UpdateShift;
begin
  if FShift = nil then Exit;
  Self.SetSize;
  FDelBtn.Left := Self.Width - FDelBtn.Width - 2;
  FDelBtn.Visible := Self.FShowDeleteBtn;
end;

procedure TScheduleShiftPresent.SetShift(Shift: TShift);
begin
  FShift := SHift;
  Self.Hint := FShift.Title;
  Self.UpdateShift;
end;

procedure TScheduleShiftPresent.Paint;
var
  Rct: TRect;
  Text: string;
  Flag: cardinal;
begin
  if FShift = nil then begin
    inherited Paint;
    Exit;
  end;
  Rct := Self.ClientRect;
  Canvas.Brush.Color := Color;
  Canvas.Font := Font;
  Canvas.Rectangle(Rct);
  Text := FShift.Title;
  Inc(Rct.Top, 2);
  Inc(Rct.Left, 2);
  Dec(Rct.Bottom, 1);
  if Self.FShowDeleteBtn then Dec(Rct.Right, FDelBtn.Width + 4)
    else Dec(Rct.Right, 2);
  if (Self.Height - 4) >= (Canvas.TextHeight(Text) * 2) then
    Flag := DT_LEFT or DT_WORDBREAK
  else
    Flag := DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS;
  DrawText(Canvas.Handle, PAnsiChar(Text), Length(Text), Rct, Flag);
end;

procedure TScheduleShiftPresent.ClickDeleteButton(Sender: TObject);
begin
  if Assigned(TScheduleTemplatePresent(Owner).FOnClickDeleteButton) then
    TScheduleTemplatePresent(Owner).FOnClickDeleteButton(
      TSpeedButton(Sender).Tag, Self.FShift);
end;


{ TScheduleTemplatePresent }

constructor TScheduleTemplatePresent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Color := clWhite;
  FSchedule := nil;
  FMinPerPixel := 10;
  FHeaderHeight := 40;
  FLineHeight := 16;
  FGridColor := clGray;
  FHeaderColor := clBtnFace;
end;

destructor TScheduleTemplatePresent.Destroy;
begin
  while (Self.ControlCount > 0) do Self.Controls[0].Free;
  inherited Destroy;
end;

procedure TScheduleTemplatePresent.SetSchedule(Schedule: TSchedule);
begin
  FSchedule := Schedule;
  Self.UpdateSchedule;
end;

procedure TScheduleTemplatePresent.SetSize;
var
  LastShift: TShift;
  Wdt: integer;
begin
  if FSchedule = nil then Exit;
  Wdt := 0;
  if Self.Align in [alClient, alTop, alBottom] then
    FMinPerPixel := Trunc((FSchedule.DayCount * 60 * 24) / Self.Width)
  else begin
    Wdt := Trunc((FSchedule.DayCount * 60 * 24) / FMinPerPixel) + 2;
    if (FSchedule.DayCount > 0)
      and(FSchedule.Day[FSchedule.DayCount - 1].Count > 0) then begin
        LastShift := FSchedule.Day[FSchedule.DayCount - 1].Last;
        if (LastShift <> nil) and (DayOf(LastShift.StartTime)
          < DayOf(LastShift.EndTime)) then
            Wdt := Wdt + Trunc(MinuteOfTheDay(LastShift.EndTime)
              / FMinPerPixel);
    end;
  end;
  FDayWidth := Trunc(60 * 24 / FMinPerPixel);
  Self.Width := Wdt;
  {if Self.Align in [alLeft, alRight] then
    FLineHeight := Trunc((Self.Height - FHeaderHeight)
      / FSchedule.MaxShiftCount * 3)
  else}
  Self.Height := FSchedule.MaxShiftCount * FLineHeight + FHeaderHeight + 4;
end;

procedure TScheduleTemplatePresent.Resize;
begin
  inherited Resize;
  Self.SetSize;
end;

procedure TScheduleTemplatePresent.UpdateSchedule;
var
  I, j: integer;
  ShiftPres: TScheduleShiftPresent;
begin
  while (Self.ControlCount > 0) do Self.Controls[0].Free;
  if FSchedule = nil then Exit;
  Self.SetSize;
  for I := 0 to FSchedule.DayCount - 1 do begin
    Self.AddButton(I);
    for J := 0 to FSchedule.Day[I].Count - 1 do begin
      ShiftPres := TScheduleShiftPresent.Create(Self);
      ShiftPres.Shift := FSchedule.Day[I].Items[J];
      ShiftPres.DayNum := I;
      ShiftPres.Height := FLineHeight;
      ShiftPres.Left := Self.FDayWidth * I
        + Trunc(MinuteOfTheDay(ShiftPres.Shift.StartTime) / FMinPerPixel);
      ShiftPres.Top := Self.FHeaderHeight + FLineHeight * j;
      Self.InsertControl(ShiftPres);
    end;
  end;
  Self.Paint;
end;


procedure TScheduleTemplatePresent.Paint;
var
  Rct: TRect;
  I, J, RealWidth: integer;
  Text: string;
begin
  if FSchedule = nil then begin
    inherited Paint;
    Exit;
  end;
  Rct := Self.ClientRect;
  Canvas.Brush.Color := Color;
  Canvas.Font := Font;
  Canvas.FillRect(Rct);
  RealWidth := 0;
  for I := 0 to FSchedule.DayCount - 1 do begin
    Canvas.Pen.Color := Self.FGridColor;
    Canvas.MoveTo(I * FDayWidth, 0);
    Canvas.LineTo(I * FDayWidth, Self.Height);
    for J := 1 to 23 do begin
      Canvas.MoveTo(I * FDayWidth + J * Trunc(60 / FMinPerPixel),
        FHeaderHeight - 2);
      Canvas.LineTo(I * FDayWidth + J * Trunc(60 / FMinPerPixel),
        FHeaderHeight - 10);
    end;
    Rct := Rect(I * FDayWidth, 0, (I + 1) * FDayWidth, FHeaderHeight - 12);
    if I < (FSchedule.DayCount - 1) then Inc(Rct.Right, 1);
    Canvas.Pen.Color := clBlack;
    Canvas.Brush.Color := Self.FHeaderColor;
    Canvas.Rectangle(Rct);
    if I = (FSchedule.DayCount - 1) then RealWidth := Rct.Right;
    Dec(Rct.Right, 20);
    if FSchedule.ScheduleType = stPeriod then Text := IntToStr(I + 1) + ' день'
      else Text := WeekDay[I];
    DrawText(Canvas.Handle, PAnsiChar(Text), Length(Text), Rct,
      DT_CENTER or DT_VCENTER or DT_SINGLELINE);
  end;
  Canvas.Pen.Color := Self.FGridColor;
  Canvas.MoveTo(RealWidth - 1, FHeaderHeight - 12);
  Canvas.LineTo(RealWidth - 1, Self.Height);
  Canvas.MoveTo(0, FHeaderHeight - 10);
  Canvas.LineTo(RealWidth, FHeaderHeight - 10);
end;


procedure TScheduleTemplatePresent.ClickAddButton(Sender: TObject);
begin
  if Assigned(Self.FOnClickAddButton) then
    Self.FOnClickAddButton(TSpeedButton(Sender).Tag);
end;

procedure TScheduleTemplatePresent.AddButton(DayNum: integer);
var
  AddBtn: TSpeedButton;
begin
  Self.SetSize;
  AddBtn := TSpeedButton.Create(Self);
  AddBtn.Flat := True;
  AddBtn.Caption := '+';
  AddBtn.Font.Size := 12;
  AddBtn.Font.Style := [fsBold];
  AddBtn.Font.Color := clNavy;
  AddBtn.Tag := DayNum;
  AddBtn.Top := 2;
  AddBtn.Left := (DayNum + 1) * Self.FDayWidth - AddBtn.Width - 2;
  AddBtn.OnClick := Self.ClickAddButton;
  Self.InsertControl(AddBtn);
end;

procedure TScheduleTemplatePresent.DelShift(Shift: TShift);
var
  I: integer;
begin
  for I := 0 to ControlCount - 1 do
    if (Controls[i] is TScheduleShiftPresent)
      and (TScheduleShiftPresent(Controls[i]).Shift = Shift) then begin
        Controls[i].Free;
    end;
end;


end.
