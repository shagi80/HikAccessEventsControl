unit PersonAnalysisPresent;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls, StdActns,
  ActnList, ToolWin, ImgList, Grids, TheAnalysisByMinute, Contnrs;

type
  TPersonAnalysisPresent = class(TStringGrid)
  private
    FAnalysis: TAnalysisByMinute;
    FWordBreak: boolean;
    FResizeColumn: boolean;
    procedure Clear;
    procedure AddDayBlockToGrid(DayNum: integer);
    procedure SetWordBreak(Value: boolean);
    procedure SetResizeColumn(Value: boolean);
    procedure SetDefColumnSize;
  protected
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    procedure DblClick; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Analysis: TAnalysisByMinute read FAnalysis write FAnalysis;
    property WordBreak: boolean read FWordBreak write SetWordBreak;
    property ResizeColumn: boolean read FResizeColumn write SetResizeColumn;
    procedure UpdateAnalys;
    procedure Resize; override;
  end;

implementation

uses TheShift, TheEventPairs, DateUtils;

constructor TPersonAnalysisPresent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Self.DoubleBuffered := True;
  FAnalysis := nil;
  FWordBreak := True;
  Self.Ctl3D := False;
  Self.FixedCols := 0;
  Self.Options := Self.Options + [goColSizing];
  Self.Options := Self.Options - [goHorzLine];
  Self.Cells[0, 0] := 'Дата';
  Self.Cells[1, 0] := 'Смена';
  Self.Cells[2, 0] := 'Отработанное время';
  Self.Cells[3, 0] := 'Замечания';
  Self.Cells[4, 0] := 'События входа и выхода';
  SetDefColumnSize;
end;

destructor TPersonAnalysisPresent.Destroy;
begin
  Self.Clear;
  inherited Destroy;
end;

procedure TPersonAnalysisPresent.SetDefColumnSize;
begin
  Self.ColWidths[0] := 80;
  Self.ColWidths[1] := 250;
  Self.ColWidths[2] := 250;
  Self.ColWidths[3] := 250;
  Self.ColWidths[4] := 250;
end;

procedure TPersonAnalysisPresent.SetWordBreak(Value: boolean);
var
  I: integer;
begin
  if not Value then
    for I := 1 to Self.RowCount - 1 do
      if RowHeights[I] > DefaultRowHeight then
        RowHeights[I] := DefaultRowHeight;
  Self.FWordBreak := Value;
  Self.Repaint;
end;

procedure TPersonAnalysisPresent.SetResizeColumn(Value: boolean);
begin
  Self.FResizeColumn := Value;
  if Value then begin
    Self.Options := Self.Options + [goColSizing];
    Self.Resize;
  end else begin
    Self.Options := Self.Options + [goColSizing];
    SetDefColumnSize;
  end;
end;

//

procedure TPersonAnalysisPresent.Resize;
begin
  inherited;
  if not FResizeColumn then Exit;
  Self.ColWidths[1] := trunc(Self.ClientWidth * 0.23);
  Self.ColWidths[2] := Self.ColWidths[1];
  Self.ColWidths[3] := Self.ColWidths[1];
  Self.ColWidths[4] := Self.ColWidths[1];
  Self.ColWidths[0] := Self.ClientWidth - Self.ColWidths[1]
    - Self.ColWidths[2] - Self.ColWidths[3] - Self.ColWidths[4] - 5;
end;

procedure TPersonAnalysisPresent.Clear;
var
  I: integer;
begin
  for I := 1 to Self.RowCount - 1 do Self.Rows[I].Clear;
  Self.RowCount := 2;
end;

procedure TPersonAnalysisPresent.UpdateAnalys;
var
  I: integer;
begin
  Self.Clear;
  if not(Assigned(FAnalysis)) then Exit;
  for I := 1 to FAnalysis.DayCnt - 1 do AddDayBlockToGrid(I);
end;

procedure TPersonAnalysisPresent.AddDayBlockToGrid(DayNum: integer);

  function FormatMinutes(Value: integer): string;
  var
    h, m: integer;
  begin
    h := Value div 60;
    m := Value - h * 60;
    Result := IntToStr(h) + ' ч ' + FormatFloat('00', m) + ' мин';
  end;

  procedure SetText(ACol, ARow: integer; Text: string;
    FontColor: TColor = clBlack);
  begin
    if (Length(Text) = 0) then Exit;
    if (Length(Text) > 0) and (ACol <> 4) then Text := Text + chr(13);
    Self.Cells[ACol, ARow] := Text;
    if ACol > 0 then Self.Objects[ACol, ARow] := TObject(FontColor);
    if ACol = 0 then Self.Objects[ACol, ARow] := TObject(DayNum);
  end;

var
  ADate: TDate;
  PersonState: TPersonMinuteState;
  DayResult: TDayResult;
  ARow, I: integer;
  ShiftList: TShiftList;
  Pair: TOnePair;
  Text: string;
  AColor: TColor;
begin
  if Length(Self.Cells[0, 1]) = 0 then ARow := 1
    else begin
      Self.RowCount := Self.RowCount + 1;
      ARow := Self.RowCount - 1;
    end;
  PersonState := FAnalysis.PersonState[0];
  DayResult := PersonState.DayResult[DayNum - 1];
  // Дата и день недели
  ADate := IncDay(FAnalysis.StartDate, DayNum);
  Text := DateToStr(ADate) + chr(13) + FormatDateTime('dddd', ADate);
  SetText(0, ARow, Text);
  // Смены и часы по графику
  Text := '';
  if DayResult.Schedule > 0 then begin
    ShiftList := FAnalysis.GetDayShifts(ADate);
    if ShiftList.Count > 0 then begin
      Self.RowCount := Self.RowCount + ShiftList.Count - 1;
      for I := 0 to ShiftList.Count - 1 do
        Text := Text + ShiftList.Items[I].Title + chr(13);
    end else Text :=  'Окончание ночной смены' + chr(13);
    Text := Text + 'По графику: ' + FormatMinutes(DayResult.Schedule);
    SetText(1, ARow, Text);
  end else SetText(1, ARow, 'выходной', clGray);
  // Отработанное время
  if ((DayResult.TotalWork + DayResult.Overtime) = 0)
    and (DayResult.Schedule > 0) then begin
      SetText(2, ARow, 'прогул', clRed);
      Exit;
    end;
  Text := '';
  AColor := clBlack;
  if DayResult.TotalWork > 0 then
    Text := 'Отработанно по графику: ' + FormatMinutes(DayResult.TotalWork);
  if DayResult.Overtime > 0 then begin
    if Length(Text) > 0 then Text := Text + chr(13);
    Text := Text + 'Отработанно вне графика: ' + FormatMinutes(DayResult.Overtime);
  end;
  if (DayResult.TotalWork + DayResult.Overtime) > 0 then 
    Text := Text +chr (13) +'Отработанно всего: ' + FormatMinutes(
      DayResult.TotalWork + DayResult.Overtime);
  if DayResult.Schedule > 0 then
    if (DayResult.TotalWork + DayResult.Overtime)>= DayResult.Schedule then begin
      Text := Text + chr(13) + 'Норма выполнена';
      AColor := clGreen;
    end else begin
      Text := Text + chr(13) + 'Норма НЕ выполнена';
      AColor := clRed;
    end;
  SetText(2, ARow, Text, AColor);
  // Опоздания и наруления
  Text := '';
  AColor := clRed;
  if (DayResult.Hooky = 0) and (DayResult.Schedule > 0) then begin
    AColor := clGreen;
    Text := 'нет';
  end;
  if DayResult.HookyComps and (DayResult.Hooky = 0) then begin
      AColor := clGreen;
      Text :=  'Все нарушения компенсированы';
    end else begin
      if DayResult.LateToShift > 0 then
        Text :=  'Опоздание на смену';
      if DayResult.Hooky > 0 then begin
        if Length(Text) > 0 then Text := Text + chr(13);
        Text := Text + 'Всего нарушкеий: '
          + FormatMinutes(DayResult.Hooky);
      end;
      if DayResult.HookyComps and (DayResult.Hooky > 0) then
        Text := Text + ' (частично компенсированы)';
    end;
  SetText(3, ARow, Text, AColor);
  // События
  Text := '';
  for I := 0 to PersonState.Pairs.Count - 1 do begin
    Pair := PersonState.Pairs.Pair[I];
    if DateOf(Pair.InTime) <> DateOf(ADate) then Continue;
    case Pair.State of
      psNormal: Text := Text + 'Вход и выход: '
        + FormatDateTime('hh:mm', Pair.InTime) + ' - '
        + FormatDateTime('hh:mm', Pair.OutTime) + chr(13);
      psNotIn: Text := Text + 'Нет входа, выход '
        + FormatDateTime('hh:mm', Pair.OutTime) + chr(13);
      psNotOut: Text := Text + 'Вход ' + FormatDateTime('hh:mm',
        Pair.InTime) + ', нет выхода.' + chr(13);
    end;
    SetText(4, ARow, Text);
  end;
end;

procedure TPersonAnalysisPresent.DrawCell(ACol, ARow: Longint; ARect: TRect;
  AState: TGridDrawState);
var
  DayNum, ARowHeight: integer;
  AColor, AFontColor: TColor;
  Rct: TRect;
  Text: string;
  Flag: cardinal;
begin
  if ARow = 0 then begin
    Rct := ARect;
    Self.Canvas.Brush.Color := clBtnFace;
    Self.Canvas.FillRect(Rct);
    Self.Canvas.Font.Color := clBlack;
    Text := Self.Cells[ACol, ARow];
    DrawText(Self.Canvas.Handle, PAnsiChar(Text),
      Length(Text), Rct, DT_CENTER or DT_SINGLELINE or DT_VCENTER);
    Exit;
  end;
  DayNum := 0;
  AColor := clWhite;
  AFontColor := clBlack;
  if Assigned(Self.Objects[0, ARow]) then
    DayNum := Integer(Self.Objects[0, ARow]);
  if (ACol > 0) and (Assigned(Self.Objects[ACol, ARow])) then
    AFontColor := Integer(Self.Objects[ACol, ARow]);
  if not (DayNum mod 2 = 0) then AColor := clBtnFace;
  Self.Canvas.Font.Color := AFontColor;
  Rct := ARect;
  Self.Canvas.Brush.Color := AColor;
  Self.Canvas.FillRect(Rct);
  Text := Self.Cells[ACol, ARow];
  if Length(Text) > 0 then begin
    Flag := DT_LEFT;
    if Self.WordBreak then Flag := DT_LEFT or DT_WORDBREAK;
    ARowHeight := DrawText(Self.Canvas.Handle, PAnsiChar(Text),
      Length(Text), Rct, Flag);
    if (Self.FWordBreak) and (ARowHeight > Self.RowHeights[ARow]) then
      Self.RowHeights[ARow] := ARowHeight;
  end;

end;

procedure TPersonAnalysisPresent.DblClick;
begin
  //
end;

end.
