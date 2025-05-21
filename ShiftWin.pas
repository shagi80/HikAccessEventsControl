unit ShiftWin;

interface

uses Windows, Classes, Graphics, Forms, Controls, StdCtrls, TheBreaks,
  TheShift, Grids, ExtCtrls, TWebButton, TheSchedule;

type
  TfrmShift = class(TForm)
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
    procedure btnEditClick(Sender: TObject);
    procedure grGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ClickModeButton(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    function GetObject: TObject;
  private
    { Private declarations }
    BreaksList: TBreakList;
    ShiftsList: TShiftList;
    SchedulesList: TScheduleList;
    FMode: integer;
    FModify: boolean;
    procedure ShowBreaks;
    procedure ShowShifts;
    procedure ShowSchedules;
    function CanChange(NewMode: integer): boolean;
    procedure SetModify(Value: boolean);
    procedure UpdateEditButtons(Sender: TObject);
  public
    { Public declarations }
  end;

implementation


{$R *.dfm}

uses Dialogs, DateUtils, SysUtils, TheSettings, BreakEditWin;


procedure TfrmShift.FormCreate(Sender: TObject);
begin
  BreaksList := TBreakList.Create(True);
  BreaksList.LoadFromBD(Settings.GetInstance.DBFileName);
  BreaksList.SortByTitle;
  ShiftsList := TShiftList.Create(True);
  ShiftsList.LoadFromBD(Settings.GetInstance.DBFileName, BreaksList);
  ShiftsList.SortByTitle;
  SchedulesList := TScheduleList.Create(True);
  SchedulesList.LoadFromBD(Settings.GetInstance.DBFileName, ShiftsList);
  SchedulesList.SortByTitle;
  FMode := 1;
  Self.ClickModeButton(btnBreaks);
end;

procedure TfrmShift.grGridSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  UpdateEditButtons(grGrid);
end;

procedure TfrmShift.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  BreaksList.Free;
  ShiftsList.Free;
  Action := caFree;
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
  Sel := grGrid.Selection;
  Res := False;
  case FMode of
    1: begin
      if Obj = nil then Obj := TBreak.Create;
      Res := frmBreakEdit.Edit(TBreak(Obj));
      if (Res) and (Sender = btnAdd) then BreaksList.Add(TBreak(Obj));
      if Res then Self.ShowBreaks;
    end;
  end;
  grGrid.Selection := sel;
  if Res then Self.SetModify(Res);
  UpdateEditButtons(Sender);
end;

function TfrmShift.CanChange(NewMode: integer): boolean;
var
  Res: integer;
begin
  Result := True;
  if (FModify = False) or (FMode = NewMode) then Exit;
  Res := MessageDlg('', mtWarning, [mbYes, mbNo, mbCancel], 0);
  case Res of
    mrYes: Self.SaveBtnClick(Self);
    mrNo: ;
    mrCancel: Result := False;
  end;
end;

procedure TfrmShift.ClickModeButton(Sender: TObject);
var
  I: integer;
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
  for I := 0 to grGrid.RowCount - 1 do grGrid.Rows[I].Clear;
  case FMode of
    1: Self.ShowBreaks;
    2: Self.ShowShifts;
    3: Self.ShowSchedules;
  end;
  Self.SetModify(False);
  Self.UpdateEditButtons(Self);
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
    Shift.Breaks.SortByStartTime;
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
    grGrid.Cells[1, I + 1] := TimeToStr(Schedule.StartDate);
    case Schedule.ShedType of
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

procedure TfrmShift.SaveBtnClick(Sender: TObject);
begin
  //
end;


end.
