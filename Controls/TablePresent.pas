unit TablePresent;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls, StdActns,
  ActnList, ToolWin, ImgList, Grids, TheAnalysisByMinute, Contnrs;

type
  //TTikEvent = procedure (Sender: TObject) of object;

  //TShowHours = set of byte;

  TPersonStateHandler = class(TObject)
  private
    FPersonState: TPersonMinuteState;
  public
    constructor Create(Value: TPersonMinuteState);
    property PersonState: TPersonMinuteState read FPersonState;
  end;

  TTablePresent = class(TStringGrid)
  private
    FAnalysis: TAnalysisByMinute;
    FResultCol: integer;
    procedure Clear;
    procedure SetAnalysis(Value: TAnalysisByMinute);
    procedure DarwHeader(ACol: integer; ARect: TRect);
    procedure DrawDayMark(DayResult: TDayResult; ARect: TRect);
    function GetLastDayCol: integer;
  protected
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    procedure DblClick; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Analysis: TAnalysisByMinute read FAnalysis write SetAnalysis;
    property LastDayCol: integer read GetLastDayCol;
    function GetDayTotalTime(DayResult: TDayResult): integer;
    function GetPersonTotalTime(PersonResult: TPersonResult): integer;
    function FormatMinutes(Value: integer): string;
    procedure UpdateAnalys;
  end;

implementation

uses DateUtils, PrintWin, PersonMinuteAnalysisWin;

{ TPersonStateHandler }

constructor TPersonStateHandler.Create(Value: TPersonMinuteState);
begin
  inherited Create;
  Self.FPersonState := Value;
end;

{ TAnalysisByMinPresent }

constructor TTablePresent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Self.FAnalysis := nil;
  Self.Ctl3D := False;
  Self.FixedCols := 1;
  Self.ColCount := FixedCols + 1;
  Self.FixedRows := 1;
  Self.RowCount := 2;
  Self.DefaultRowHeight := 24;
  Self.RowHeights[0] := 34;
  Self.DefaultColWidth := 60;
  Self.ColWidths[0] := 200;
  Self.FResultCol := 3;
  Self.Font.Height := 13;
  Self.Font.Color := clBlack;
end;

destructor TTablePresent.Destroy;
begin
  Self.Clear;
  inherited Destroy;
end;

procedure TTablePresent.Clear;
var
  I: integer;
begin
  for I := 0 to RowCount - 1 do
    Self.Rows[I].Clear;
end;

procedure TTablePresent.SetAnalysis(Value: TAnalysisByMinute);
begin
  FAnalysis := Value;
  Self.UpdateAnalys;
end;

function TTablePresent.GetLastDayCol: integer;
begin
  Result := Self.ColCount - Self.FResultCol - 1;
end;

function TTablePresent.GetDayTotalTime(DayResult: TDayResult): integer;
begin
  Result := DayResult.TotalWork + DayResult.Overtime;
end;

function TTablePresent.GetPersonTotalTime(PersonResult: TPersonResult): integer;
begin
  Result := PersonResult.TotalWork + PersonResult.Overtime;
end;

{ Метод обновления данных. }

procedure TTablePresent.UpdateAnalys;
var
  ARow, ACol: integer;
  PersonStateHandler: TPersonStateHandler;
begin
  Self.Enabled := False;
  Self.Clear;
  if not Assigned(FAnalysis) then  begin
    Self.RowCount := 2;
    Self.ColCount := Self.FixedCols + 1;
    Exit;
  end;
  if (not Assigned(FAnalysis)) or (FAnalysis.PersonCount = 0)
    or (FAnalysis.DayCnt = 0) then Exit;
  Self.Enabled := True;
  // Устанавливаем размеры таблицы.
  Self.ColCount := Self.FixedCols + FAnalysis.DayCnt + (FResultCol - 1);
  Self.RowCount := FAnalysis.PersonCount + Self.FixedRows;
  // Устанавливаем ширину колонок
  for ACol := FixedCols to ColCount - 1 - FResultCol do
    Self.ColWidths[ACol] := 60;
  Self.ColWidths[Self.ColCount - 3] := 80;
  Self.ColWidths[Self.ColCount - 2] := 100;
  Self.ColWidths[Self.ColCount - 1] := 100;
  // Записывае  данные строк табеля в обхекты.
  for ARow := FixedRows to RowCount - 1 do begin
    PersonStateHandler := TPersonStateHandler.Create(FAnalysis.PersonState[ARow - 1]);
    Self.Objects[0, ARow] := PersonStateHandler;
  end;
  if self.Visible then Self.Repaint;
end;

{ Методы рисования }

function TTablePresent.FormatMinutes(Value: integer): string;
var
  h, m: integer;
begin
  h := Value div 60;
  m := Value - h * 60;
  Result := IntToStr(h) + ':' + FormatFloat('00', m);
end;

procedure TTablePresent.DarwHeader(ACol: integer; ARect: TRect);
var
  Date: TDate;
  Text: string;
  Rct: TRect;
begin
  Self.Canvas.FillRect(ARect);
  Rct := ARect;
  Inc(Rct.Top, 2);
  if (ACol > 0) and (ACol < Self.ColCount - FResultCol) then begin
    Date := IncDay(Self.FAnalysis.StartDate, ACol);
    Text := IntToStr(DayOf(Date)) + chr(13) + FormatDateTime('ddd', Date);
    Canvas.Font.Color := clBlack;
    if DayOfTheWeek(Date) in [6, 7] then Canvas.Font.Color := clRed;
    DrawText(Self.Canvas.Handle, PAnsiChar(Text), Length(Text), Rct,
      DT_CENTER);
  end else begin
    Text := '???';
    if ACol = 0 then Text := 'ФИО сотрудинка';
    if ACol = ColCount - 3 then Text := 'Итого смен' + chr(13)
      + ' факт';
    if ACol = ColCount - 2 then Text := 'Итого часов' + chr(13)
      + ' норма / факт';
    if ACol = ColCount - 1 then Text := 'Опоздания' + chr(13)
      + ' на смену';
    DrawText(Self.Canvas.Handle, PAnsiChar(Text), Length(Text), Rct,
      DT_CENTER or DT_WORDBREAK);
  end;
end;

procedure TTablePresent.DrawDayMark(DayResult: TDayResult; ARect: TRect);
var
  BufColor: TColor;
  BufWidth, Border: integer;
  Text: string;
begin
  if DayResult.State in [dsNormal, dsRest] then Exit;
  if DayResult.State = dsFullHooky then begin
    Canvas.Brush.Color := rgb(255, 160, 122);
    Canvas.Font.Color := clBlack;
    Canvas.Rectangle(ARect);
    Text := 'HH';
    DrawText(Canvas.Handle, PAnsiChar(Text), Length(Text), ARect,
      DT_CENTER or DT_SINGLELINE or DT_VCENTER);
    Exit;
  end;
  if DayResult.State = dsSmallTime then begin
    //Border := Trunc(200 / Self.FMinPerPixel);
    Border := 10;
    Inc(ARect.Left, Border);
    Inc(ARect.Top,  Trunc(Border / 4));
    Dec(ARect.Right, Border);
    Dec(ARect.Bottom, Trunc(Border / 4));
    BufColor := Canvas.Pen.Color;
    Canvas.Pen.Color := rgb(255, 160, 122);
    BufWidth := Canvas.Pen.Width;
    Canvas.Pen.Width :=3;
    {Canvas.MoveTo(ARect.Left, ARect.Top);
    Canvas.LineTo(ARect.Right, ARect.Bottom); }
    Canvas.MoveTo(ARect.Left, ARect.Bottom);
    Canvas.LineTo(ARect.Right, ARect.Top);
    Canvas.Pen.Color := BufColor;
    Canvas.Pen.Width := BufWidth;
    Exit;
  end;
  ARect.Left := ARect.Right - 8;
  ARect.Bottom := ARect.top + 8;
  OffsetRect(ARect, -1, 1);
  if DayResult.State = dsHooky then Canvas.Brush.Color := clRed;
  if DayResult.State = dsOvertime then Canvas.Brush.Color := clYellow;
  Canvas.Ellipse(ARect);
end;

procedure TTablePresent.DrawCell(ACol, ARow: Longint; ARect: TRect;
  AState: TGridDrawState);
var
  PersonStateHandler: TPersonStateHandler;
  DayResult: TDayResult;
  Rct: TRect;
  TotalTime, RED_FILL: integer;
begin
  inherited DrawCell(ACol, ARow, ARect, AState);
  RED_FILL := rgb(255, 160, 122);
  // Заголовок таблицы.
  if ARow = 0 then DarwHeader(ACol, ARect);
  // Строки табеля.
  if ARow > 0 then begin
    if Self.Objects[0, ARow] = nil then Exit;
    Canvas.Brush.Color := clWhite;
    Canvas.Font.Color := clBlack;
    Canvas.Font.Style := [];
    Canvas.FillRect(ARect);
    Rct := ARect;
    Inc(Rct.Top, 2);
    Inc(Rct.Left, 2);
    PersonStateHandler := TPersonStateHandler(Self.Objects[0, ARow]);
    // Заголовок строки - ФИО сотрудника.
    if ACol = 0 then begin
      Text := PersonStateHandler.PersonState.PersonName;
      DrawText(Canvas.Handle ,PAnsiChar(Text), Length(Text), Rct,
        DT_LEFT or DT_SINGLELINE or DT_VCENTER);
    end;
    // Ячейки табеля.
    if (ACol > 0) and (ACol < ColCount - FResultCol) then begin
      DayResult := PersonStateHandler.PersonState.DayResult[ACol - 1];
      TotalTime := Self.GetDayTotalTime(DayResult);
      Text := '';
      if (TotalTime > 0) then begin
        Text := FormatMinutes(TotalTime);
        DrawText(Canvas.Handle ,PAnsiChar(Text), Length(Text), Rct,
          DT_CENTER or DT_SINGLELINE or DT_VCENTER);
        DrawDayMark(DayResult, ARect);
      end;
      if (TotalTime = 0) and (DayResult.Schedule > 0) then begin
        Text := 'НН';
        Canvas.Brush.Color := RED_FILL;
        Canvas.FillRect(ARect);
        Canvas.Font.Style := [fsBold];
        DrawText(Canvas.Handle ,PAnsiChar(Text), Length(Text), Rct,
          DT_CENTER or DT_SINGLELINE or DT_VCENTER);
      end;
    end;
    // Ячейка итогов.
    if (ACol = ColCount - 3) then begin
      Text := IntToStr(PersonStateHandler.PersonState.TotalDayResult.DayCount);
      DrawText(Canvas.Handle ,PAnsiChar(Text), Length(Text), Rct,
        DT_CENTER or DT_SINGLELINE or DT_VCENTER);
    end;
    if (ACol = ColCount - 2) then begin
      TotalTime := Self.GetPersonTotalTime(PersonStateHandler.PersonState.TotalDayResult);
      Text := FormatMinutes(PersonStateHandler.PersonState.TotalDayResult.Schedule)
        + ' / ' + FormatMinutes(TotalTime);
      if TotalTime < PersonStateHandler.PersonState.TotalDayResult.Schedule then
        Canvas.Font.Color := clRed;
      DrawText(Canvas.Handle ,PAnsiChar(Text), Length(Text), Rct,
        DT_CENTER or DT_SINGLELINE or DT_VCENTER);
    end;
    if (ACol = ColCount - 1) then begin
      TotalTime := PersonStateHandler.PersonState.TotalDayResult.LateCount;
      if TotalTime > 0 then begin
        Text := 'да, ' + IntToStr(TotalTime) + ' дней';
        Canvas.Font.Color := clRed;
      end else begin
        Canvas.Font.Color := clSilver;
        Text := 'нет';
      end;
      DrawText(Canvas.Handle ,PAnsiChar(Text), Length(Text), Rct,
        DT_CENTER or DT_SINGLELINE or DT_VCENTER);
    end;
  end;

end;

{ Click }

procedure TTablePresent.DblClick;
var
  Day: TDate;
  PersonStateHandler: TPersonStateHandler;
  DayResult: TDayResult;
begin
  if (Self.Row <= 0) or (Self.Col >= ColCount - FResultCol)
    or (not Assigned(Self.Objects[0, Self.Row])) then Exit;
  Day := IncDay(FAnalysis.StartDate, Self.Col);
  PersonStateHandler := TPersonStateHandler(Self.Objects[0, Self.Row]);
  DayResult := PersonStateHandler.PersonState.DayResult[Self.Col - 1];
  frmPersonMinuteAnalysis.ShowAnalysis(nil, Day, DayResult,
    PersonStateHandler.PersonState.PersonName,
    PersonStateHandler.PersonState.Pairs);
end;


end.
