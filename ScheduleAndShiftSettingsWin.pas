unit ScheduleAndShiftSettingsWin;

interface

uses Windows, Classes, Graphics, Forms, Controls, StdCtrls, TheBreaks,
  TheShift, Grids, ExtCtrls, TWebButton, TheSchedule, CHILDWIN;

type
  TfrmShift = class(TMDIChild)
    Panel1: TPanel;
    Panel2: TPanel;
    grGrid: TStringGrid;
    pnButtons: TPanel;
    btnUpdate: TWebSpeedButton;
    btnSave: TWebSpeedButton;
    btnDelete: TWebSpeedButton;
    btnEdit: TWebSpeedButton;
    btnAdd: TWebSpeedButton;
    btnSchedules: TWebSpeedButton;
    btnBreaks: TWebSpeedButton;
    btnShifts: TWebSpeedButton;
    procedure btnUpdateClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure grGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ClickModeButton(Sender: TObject);
    function GetObject: TObject;
  private
    { Private declarations }
    FMode: integer;
    FModify: boolean;
    procedure ShowBreaks;
    procedure ShowShifts;
    procedure ShowSchedules;
    function CanChange(NewMode: integer): boolean;
    procedure SetModify(Value: boolean);
    procedure UpdateEditButtons(Sender: TObject);
    procedure UpdateView;
  public
    { Public declarations }
  end;

implementation


{$R *.dfm}

uses Dialogs, DateUtils, SysUtils, TheSettings, BreakEditWin,
  ShiftEditWin, ScheduleEditWin;


procedure TfrmShift.FormCreate(Sender: TObject);
begin
  inherited;
  LoadFromBD;
  FMode := 1;
  Self.ClickModeButton(btnBreaks);
end;

procedure TfrmShift.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Self.CanChange(0) then Action := caFree;
end;

procedure TfrmShift.grGridSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  UpdateEditButtons(grGrid);
end;

procedure TfrmShift.SetModify(Value: boolean);
begin
  FModify := Value;
  btnSave.Enabled := FModify;
  btnUpdate.Enabled := FModify;
end;

function TfrmShift.GetObject: TObject;
begin
  Result := nil;
  if (grGrid.Selection.Top > 0) and (grGrid.Selection.Top < grGrid.RowCount)
    then Result := grGrid.Objects[0, grGrid.Selection.Top];
end;

procedure TfrmShift.UpdateEditButtons(Sender: TObject);
var
  Obj: TObject;
begin
  Obj := Self.GetObject;
  btnDelete.Enabled := (Obj <> nil);
  btnEdit.Enabled := (Obj <> nil);
end;

function TfrmShift.CanChange(NewMode: integer): boolean;
var
  Res: integer;
begin
  Result := True;
  if (FModify = False) or ((FMode > 0) and (FMode = NewMode)) then Exit;
  Res := MessageDlg('Сохранить изменения данных ?', mtWarning,
    [mbYes, mbNo, mbCancel], 0);
  case Res of
    mrYes: Self.btnSaveClick(Self);
    mrNo: if FMode > 0 then LoadFromBD;
    mrCancel: Result := False;
  end;
end;

{ Методы обновления формы. }

procedure TfrmShift.UpdateView;
var
  I: integer;
begin
  for I := 0 to grGrid.RowCount - 1 do grGrid.Rows[I].Clear;
  case FMode of
    1: Self.ShowBreaks;
    2: Self.ShowShifts;
    3: Self.ShowSchedules;
  end;
  Self.UpdateEditButtons(Self);
end;

procedure TfrmShift.ClickModeButton(Sender: TObject);
begin
  if not CanChange(TWebSpeedButton(Sender).Tag) then begin
    case FMode of
      1: btnBreaks.Down := True;
      2: btnShifts.Down := True;
      3: btnSchedules.Down := True;
    end;
    Exit;
  end;
  TWebSpeedButton(Sender).Down := True;
  FMode := TWebSpeedButton(Sender).Tag;
  UpdateView;
  SetModify(False);
end;

procedure TfrmShift.ShowBreaks;
var
  I: integer;
  Break: TBreak;
begin
  grGrid.ColCount := 4;
  grGrid.Cells[0, 0] := 'Название';
  grGrid.Cells[1, 0] := 'Время начала';
  grGrid.Cells[2, 0] := 'Длительность';
  grGrid.Cells[3, 0] := 'Опоздание, мин';
  grGrid.ColWidths[0] := 250;
  grGrid.ColWidths[1] := 150;
  grGrid.ColWidths[2] := 150;
  grGrid.ColWidths[3] := 100;
  if BreaksList.Count = 0 then begin
    grGrid.RowCount := 2;
    Exit;
  end;
  grGrid.RowCount := BreaksList.Count + 1;
  grGrid.Enabled := (BreaksList.Count > 0);
  for I := 0 to BreaksList.Count - 1 do begin
    Break := BreaksList.Items[I];
    grGrid.Cells[0, I + 1] := Break.Title;
    grGrid.Cells[1, I + 1] := TimeToStr(Break.StartTime);
    grGrid.Cells[2, I + 1] := TimeToStr(Break.Length);
    grGrid.Cells[3, I + 1] := IntToStr(Break.Lateness);
    grGrid.Objects[0, I + 1] := Break;
  end;
end;

procedure TfrmShift.ShowShifts;
var
  I, J: integer;
  Shift: TShift;
  Str: string;
begin
  grGrid.ColCount := 9;
  grGrid.Cells[0, 0] := 'Название';
  grGrid.Cells[1, 0] := 'Время начала';
  grGrid.Cells[2, 0] := 'Длительность';
  grGrid.Cells[3, 0] := 'Начало входа';
  grGrid.Cells[4, 0] := 'Окончание входа';
  grGrid.Cells[5, 0] := 'Начало выхода';
  grGrid.Cells[6, 0] := 'Окончание выхода';
  grGrid.Cells[7, 0] := 'Опоздание, мин';
  grGrid.Cells[8, 0] := 'Перерывы';
  grGrid.ColWidths[0] := 200;
  for I := 2 to 6 do grGrid.ColWidths[i] := 110;
  grGrid.ColWidths[7] := 100;
  grGrid.ColWidths[8] := 300;
  if ShiftsList.Count = 0 then begin
    grGrid.RowCount := 2;
    Exit;
  end;
  grGrid.RowCount := ShiftsList.Count + 1;
  grGrid.Enabled := (ShiftsList.Count > 0);
  for I := 0 to ShiftsList.Count - 1 do begin
    Shift := ShiftsList.Items[I];
    grGrid.Cells[0, I + 1] := Shift.Title;
    grGrid.Cells[1, I + 1] := TimeToStr(Shift.StartTime);
    grGrid.Cells[2, I + 1] := TimeToStr(Shift.Length);
    grGrid.Cells[3, I + 1] := TimeToStr(Shift.InStart);
    grGrid.Cells[4, I + 1] := TimeToStr(Shift.InFinish);
    grGrid.Cells[5, I + 1] := TimeToStr(Shift.OutStart);
    grGrid.Cells[6, I + 1] := TimeToStr(Shift.OutFinish);
    grGrid.Cells[7, I + 1] := TimeToStr(Shift.Lateness);
    grGrid.Cells[8, I + 1] := 'нет перерывов';
    if Shift.Breaks.Count > 0 then begin
      Str := '';
      for j := 0 to Shift.Breaks.Count - 1 do begin
       Str := Str + Shift.Breaks.Items[j].Title;
       if j < (Shift.Breaks.Count - 1) then Str := Str + ', ';
      end;
      grGrid.Cells[8, I + 1] := Str;
    end;
    grGrid.Objects[0, I + 1] := Shift;
  end
end;

procedure TfrmShift.ShowSchedules;
var
  I, J, Num: integer;
  Schedule: TSchedule;
  Str: string;
  ShiftTitles: TStringList;
begin
  grGrid.ColCount := 5;
  grGrid.Cells[0, 0] := 'Название';
  grGrid.Cells[1, 0] := 'Дата начала';
  grGrid.Cells[2, 0] := 'Тип';
  grGrid.Cells[3, 0] := 'Цикличность';
  grGrid.Cells[4, 0] := 'Смены в графике';
  grGrid.ColWidths[0] := 250;
  for I := 2 to 3 do grGrid.ColWidths[i] := 150;
  grGrid.ColWidths[4] := 400;
  if SchedulesList.Count = 0 then begin
    grGrid.RowCount := 2;
    Exit;
  end;
  grGrid.RowCount := SchedulesList.Count + 1;
  grGrid.Enabled := (SchedulesList.Count > 0);
  for I := 0 to SchedulesList.Count - 1 do begin
    Schedule := SchedulesList.Items[I];
    grGrid.Cells[0, I + 1] := Schedule.Title;
    grGrid.Cells[1, I + 1] := DateToStr(Schedule.StartDate);
    case Schedule.ScheduleType of
      stWeek: begin
        grGrid.Cells[2, I + 1] := 'недельный';
        grGrid.Cells[3, I + 1] := '---';
      end;
      stPeriod: begin
        grGrid.Cells[2, I + 1] := 'периодический';
        grGrid.Cells[3, I + 1] := IntToStr(Schedule.DayCount) + ' дн.';
      end;
    end;
    ShiftTitles := TStringList.Create;
    for Num := 0 to Schedule.DayCount - 1 do
      for j := 0 to Schedule.Day[Num].Count - 1 do
        if ShiftTitles.IndexOf(Schedule.Day[Num].Items[j].Title) < 0 then
          ShiftTitles.Add(Schedule.Day[Num].Items[j].Title);
    Str := 'смены не заданы';
    if ShiftTitles.Count > 0 then begin
      Str := '';
      for j := 0 to ShiftTitles.Count - 1 do Str := Str + ShiftTitles[j] + ', ';
      Str := Copy(Str, 1, Length(Str) - 2);
    end;
    grGrid.Cells[4, I + 1] := Str;
    ShiftTitles.Free;
    grGrid.Objects[0, I + 1] := Schedule;
  end

end;

{ Методы кнопок. }

procedure TfrmShift.btnDeleteClick(Sender: TObject);
var
  Obj: TObject;
begin
  if not (MessageDlg('Вы действительно хотите удалить этот объект ?',
    mtConfirmation, [mbYes,mbNo], 0) = mrYes) then Exit;
  Obj := Self.GetObject;
  if Obj = nil then Exit;
  case FMode of
    1: BreaksList.Extract(Obj);
    2: ShiftsList.Extract(Obj);
    3: SchedulesList.Extract(Obj);
  end;
  UpdateView;
  SetModify(True);
end;

procedure TfrmShift.btnEditClick(Sender: TObject);
var
  Obj: TObject;
  Sel: TGridRect;
  Res: boolean;
begin
  Obj := nil;
  if not(Sender = btnAdd) then begin
    Obj := Self.GetObject;
    if Obj = nil then Exit;
  end;
  Res := False;
  case FMode of
    1: if Obj = nil then begin
          Obj := TBreak.Create;
          Res := frmBreakEdit.Edit(TBreak(Obj));
          if Res then begin
            if Sender = btnAdd then BreaksList.Add(TBreak(Obj));
            BreaksList.SortByTitle;
          end else Obj.Free;
        end else Res := frmBreakEdit.Edit(TBreak(Obj));
    2: if Obj = nil then begin
          Obj := TShift.Create;
          Res := frmShiftEdit.Edit(TShift(Obj), BreaksList);
          if Res then begin
            if Sender = btnAdd then ShiftsList.Add(TShift(Obj));
            ShiftsList.SortByTitle;
          end else Obj.Free;
        end else Res := frmShiftEdit.Edit(TShift(Obj), BreaksList);
    3: if Obj = nil then begin
          Obj := TSchedule.Create;
          Res := frmScheduleEdit.Edit(TSchedule(Obj), ShiftsList);
          if Res then begin
            if Sender = btnAdd then SchedulesList.Add(TSchedule(Obj));
            SchedulesList.SortByTitle;
          end else Obj.Free;
        end else Res := frmScheduleEdit.Edit(TSchedule(Obj), ShiftsList);
  end;
  if Res then begin
    Sel := grGrid.Selection;
    SetModify(Res);
    UpdateView;
    grGrid.Selection := sel;
  end;
end;

procedure TfrmShift.btnSaveClick(Sender: TObject);
var
  Res: boolean;
begin
  Res := False;
  if not FModify then Exit;
  case FMode of
    1: Res := BreaksList.SaveToBD(Settings.GetInstance.DBFileName);
    2: Res := ShiftsList.SaveToBD(Settings.GetInstance.DBFileName);
    3: Res := SchedulesList.SaveToBD(Settings.GetInstance.DBFileName);
  end;
  SetModify(not Res);
  if not Res then
    MessageDlg('Произошла какая-то ошибка !' + chr(13)
      + 'Данные не записаны.', mtError, [mbOk], 0);
end;

procedure TfrmShift.btnUpdateClick(Sender: TObject);
begin
  LoadFromBD;
  UpdateView;
  SetModify(False);
end;

end.
