unit PersonEventsWin;

interface

uses Windows, Classes, Graphics, Forms, Controls, StdCtrls, TWebButton,
  ComCtrls, ExtCtrls, Grids, Buttons, CHILDWIN, TheDivisions,
  TheAnalysisByMinute, TheAnalysisByMinuteThread, ThePersons;

type
  TfrmPervonEvents = class(TMDIChild)
    pnMain: TPanel;
    Panel2: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    btnCurrentMonth: TWebSpeedButton;
    btnUpdate: TWebSpeedButton;
    btnPreviosMonth: TWebSpeedButton;
    cbDivision: TComboBox;
    dtpEndDate: TDateTimePicker;
    dtpStartDate: TDateTimePicker;
    tbScale: TTrackBar;
    pnPerson: TPanel;
    Splitter1: TSplitter;
    Label1: TLabel;
    lbPerson: TListBox;
    pnData: TPanel;
    Panel3: TPanel;
    lbOvertime: TLabel;
    Panel1: TPanel;
    lbMessage: TLabel;
    btnClose: TWebSpeedButton;
    btnPrint: TWebSpeedButton;
    sgResult: TStringGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbDivisionChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure btnPreviosMonthClick(Sender: TObject);
    procedure btnCurrentMonthClick(Sender: TObject);
    procedure Analysis(Sender: TObject);
  private
    { Private declarations }
    FAnalysis: TAnalysisByMinute;
    FThread: TAnalysisByMinuteThread;
    procedure UpdateDivisionList(CurDivision: TDivision);
    function UpdatePersonList(CurDivision: TDivision;
      CurPerson: TPerson): integer;
    procedure EndAnalysis(Result: boolean);
    procedure AddDayBlockToGrid(DayNum: integer);
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses  TheSettings, SysUtils, DateUtils, TheEventPairs, Dialogs, TheShift;

procedure TfrmPervonEvents.FormCreate(Sender: TObject);
begin
  inherited;
  FAnalysis := TAnalysisByMinute.Create;
  Self.dtpStartDate.Date := StartOfTheMonth(now);
  Self.dtpEndDate.Date := now;
  Self.DoubleBuffered := True;
  Self.LoadFromBD;
  UpdateDivisionList(nil);
  cbDivisionChange(Self);
end;

procedure TfrmPervonEvents.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FAnalysis.Free;
  inherited;
end;


procedure TfrmPervonEvents.UpdateDivisionList(CurDivision: TDivision);

  procedure AddChildDivision(Level: integer; ParentDivision: TDivision);
  var
    J, I: integer;
    Text: string;
    Division: TDivision;
  begin
    for J := 0 to DivisionsList.Count - 1 do begin
      Division := DivisionsList.Items[J];
      if Division.ParentDivision = ParentDivision then begin
        Text := ' - ' + Division.Title;
        for I := 0 to Level - 1 do Text := '   ' + Text;
        cbDivision.AddItem(Text, Division);
        AddChildDivision(Level + 1, Division);
      end;
    end;
  end;

var
  I: integer;
  Division: TDivision;
begin
  cbDivision.Clear;
  Division := DivisionsList.Items['parent'];
  if not Assigned(Division) then Exit;
  cbDivision.AddItem(Division.Title,  TObject(Division));
  AddChildDivision(1, Division);
  cbDivision.ItemIndex := 0;
  if Assigned(CurDivision) then
    for I := 0 to cbDivision.Items.Count - 1 do
      if cbDivision.Items.Objects[I] = CurDivision then begin
        cbDivision.ItemIndex := I;
        Break;
      end;
end;

function  TfrmPervonEvents.UpdatePersonList(CurDivision: TDivision;
  CurPerson: TPerson): integer;
var
  I: integer;
  Person: TPerson;
begin
  lbPerson.Clear;
  if not Assigned(CurDivision) then Exit;
  for I := 0 to PersonsList.Count - 1 do begin
    Person := PersonsList.Items[I];
    if (CurDivision.ParentDivision = nil) or (Person.Division = CurDivision) then
      lbPerson.AddItem(Person.Name, Person);
  end;
  Result := lbPerson.Items.Count;
  if Assigned(CurPerson) then
    for I := 0 to lbPerson.Items.Count - 1 do
      if lbPerson.Items.Objects[I] = CurPerson then begin
        lbPerson.ItemIndex := I;
        Break;
      end;
end;

procedure TfrmPervonEvents.cbDivisionChange(Sender: TObject);
var
  Division: TDivision;
  Str: string;
begin
  inherited;
  lbPerson.Visible := False;
  if cbDivision.ItemIndex < 0 then begin
    lbMessage.Font.Color := clRed;
    lbMessage.Caption := 'Подразделение не выбрано';
    Exit;
  end;
  Division := TDivision(cbDivision.Items.Objects[cbDivision.ItemIndex]);
  if not Assigned(Division.Schedule) then begin
    lbMessage.Font.Color := clRed;
    lbMessage.Caption := Format('Для подразделения "%s" не задан график',
      [Division.Title]);
    Exit;
  end;
  //
  if UpdatePersonList(Division, nil) = 0 then begin
    lbMessage.Font.Color := clRed;
    lbMessage.Caption := Format('В подразделении "%s" нет сотрудников',
      [Division.Title]);
    Exit;
  end;
  lbPerson.Visible := True;
  //
  lbMessage.Font.Color := clNavy;
  lbMessage.Caption := Format('Подразделение "%s". График "%s"',
      [Division.Title, Division.Schedule.Title]);
  Self.ChangeTitle(Division.Title + ' c ' + DateToStr(dtpStartDate.Date)
        + ' по ' + DateToStr(dtpEndDate.Date));
  Str := 'Переработка не учитывается.';
  if Division.Schedule.CanOvertime then begin
    if Division.Schedule.OvertimeMin = 0 then
      Str := 'Учитывается любая переработка.'
        else Str := 'Учитывается переработка более '
          + IntToStr(Division.Schedule.OvertimeMin) + ' минут.';
      if Division.Schedule.UseOvertimeForHooky then Str := Str
        + ' Переработка компенсирует опоздания.';
  end;
  if Division.Schedule.CanWorkToBreak then
    Str := Str + ' Разрешено работать в перерывы.';
  lbOvertime.Caption := Str;
end;

procedure TfrmPervonEvents.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmPervonEvents.btnPreviosMonthClick(Sender: TObject);
begin
  Self.dtpStartDate.Date := StartOfTheMonth(IncDay(StartOfTheMonth(now), -1));
  Self.dtpEndDate.Date := DateUtils.EndOfTheMonth(dtpStartDate.Date);
  Analysis(Self);
end;

procedure TfrmPervonEvents.btnUpdateClick(Sender: TObject);
var
  SelectDivision: TDivision;
  SelectPerson: TPerson;
  SelectDivGUID, SelectPersGUID: TGUID;
begin
  if (cbDivision.ItemIndex < 0) then Exit;
  //
  SelectDivision := TDivision(cbDivision.Items.Objects[cbDivision.ItemIndex]);
  SelectDivGUID := SelectDivision.GUID;
  if (lbPerson.ItemIndex >= 0) then begin
    SelectPerson := TPerson(lbPerson.Items.Objects[lbPerson.ItemIndex]);
    SelectPersGUID := SelectPerson.GUID;
  end;
  //
  Self.LoadFromBD;
  //
  if (lbPerson.ItemIndex < 0) then
      UpdatePersonList(SelectDivision, SelectPerson)
    else begin
      SelectDivision := DivisionsList.Items[SelectDivGUID];
      UpdateDivisionList(SelectDivision);
      SelectPerson := PersonsList.Items[SelectPersGUID];
      UpdatePersonList(SelectDivision, SelectPerson);
    end;
  Analysis(Self);
end;

procedure TfrmPervonEvents.btnCurrentMonthClick(Sender: TObject);
begin
  Self.dtpStartDate.Date := StartOfTheMonth(now);
  Self.dtpEndDate.Date := now;
  Analysis(Self);
end;



procedure TfrmPervonEvents.Analysis(Sender: TObject);
var
  Person: TPerson;
  PersonList: TStringList;
  Division: TDivision;
  ADate: TDate;
begin
  sgResult.Visible := False;
  if not Self.lbPerson.Visible then Exit;
  if lbPerson.ItemIndex < 0 then begin
    lbMessage.Font.Color := clRed;
    lbMessage.Caption := 'Сотрудник не выбран !';
    lbOvertime.Visible := False;
    Exit;
  end;
  Person := TPerson(lbPerson.Items.Objects[lbPerson.ItemIndex]);
  //Division := TDivision(cbDivision.Items.Objects[cbDivision.ItemIndex]);
  Division := Person.Division;
  if (not Assigned(Person)) or (not Assigned(Division)) then Exit;

  PersonList := TStringList.Create;
  PersonList.Add(Person.PersonId + '=' + Person.Name);
  Self.ChangeTitle(Person.Name + ' c ' + DateToStr(dtpStartDate.Date)
        + ' по ' + DateToStr(dtpEndDate.Date));


  PersonList := TStringList.Create;
  PersonList.Add(Person.PersonId + '=' + Person.Name);
  FAnalysis.SetParametrs(PersonList, Division.Schedule,
    dtpStartDate.Date, dtpEndDate.Date, HolydaysList);

  EndAnalysis(FAnalysis.Analysis);


  {FThread := TAnalysisByMinuteThread.Create(True);
  FThread.FreeOnTerminate := True;
  FThread.Analysis := Self.FAnalysisByMinute;
  FThread.Present := nil;
  FThread.OnAnalysisEnd := Self.EndAnalysis;
  FThread.Resume;}
end;

procedure TfrmPervonEvents.EndAnalysis(Result: boolean);
var
  I: integer;
begin
  if not Result then begin
      lbMessage.Font.Color := clRed;
      lbMessage.Caption := 'Ошибка при выполнении анализа !';
      Exit;
    end;

  for I := 1 to sgResult.RowCount - 1 do sgResult.Rows[I].Clear;
  sgResult.RowCount := 2;
  for I := 1 to FAnalysis.DayCnt - 1 do AddDayBlockToGrid(I);
  sgResult.Visible := True;
end;

procedure TfrmPervonEvents.AddDayBlockToGrid(DayNum: integer);

  procedure SetNextRow(var ARow: integer);
  begin
    Inc(ARow);
    if ARow = sgResult.RowCount then
      sgResult.RowCount := sgResult.RowCount + 1;
  end;

  function FormatMinutes(Value: integer): string;
  var
    h, m: integer;
  begin
    h := Value div 60;
    m := Value - h * 60;
    Result := IntToStr(h) + ' ч ' + FormatFloat('00', m) + ' мин';
  end;

var
  ADate: TDate;
  PersonState: TPersonMinuteState;
  DayResult: TDayResult;
  ARow, FirstRow, I: integer;
  ShiftList: TShiftList;
  Pair: TOnePair;
  Text: string;
begin
  if Length(sgResult.Cells[0, 1]) = 0 then ARow := 1
    else begin
      sgResult.RowCount := sgResult.RowCount + 1;
      ARow := sgResult.RowCount - 1;
    end;
  PersonState := FAnalysis.PersonState[0];
  DayResult := PersonState.DayResult[DayNum - 1];
  //
  ADate := IncDay(FAnalysis.StartDate, DayNum);
  sgResult.Cells[0, ARow] := DateToStr(ADate);
  FirstRow := ARow;
  //
  ShiftList := FAnalysis.GetDayShifts(ADate);
  if ShiftList.Count > 0 then begin
    sgResult.RowCount := sgResult.RowCount + ShiftList.Count;
    for I := 0 to ShiftList.Count - 1 do begin
      sgResult.Cells[1, ARow] := ShiftList.Items[I].Title;
      Inc(ARow);
    end;
    sgResult.Cells[1, ARow] := 'Должно быть по графику: '
      + FormatMinutes(DayResult.Schedule);
  end else sgResult.Cells[1, ARow] := 'выходной';
  //
  ARow := FirstRow;
  if ((DayResult.TotalWork + DayResult.Overtime) = 0)
    and (DayResult.Schedule > 0) then begin
      sgResult.Cells[2, ARow] := 'прогул';
      Exit;
    end;
  if DayResult.TotalWork > 0 then begin
    sgResult.Cells[2, ARow] := 'Отработанно по графику: '
      + FormatMinutes(DayResult.TotalWork);
    SetNextRow(ARow);
  end;
  if DayResult.Overtime > 0 then begin
    sgResult.Cells[2, ARow] := 'Отработанно вне графика: '
      + FormatMinutes(DayResult.Overtime);
    SetNextRow(ARow);
  end;
  if (DayResult.TotalWork + DayResult.Overtime) > 0 then
    sgResult.Cells[2, ARow] := 'Отработанно всего: ' + FormatMinutes(
      DayResult.TotalWork + DayResult.Overtime);
  //
  ARow := FirstRow;
  if (DayResult.Hooky = 0) and (DayResult.Schedule > 0) then
    sgResult.Cells[3, ARow] := 'нет';
  if DayResult.HookyComps and (DayResult.Hooky = 0) then
      sgResult.Cells[3, ARow] := 'Все нарушения компенсированы'
    else begin
      if DayResult.LateToShift > 0 then begin
        sgResult.Cells[3, ARow] := 'Опоздание на смену';
        SetNextRow(ARow);
      end;
      if DayResult.Hooky > 0 then
        sgResult.Cells[3, ARow] := 'Всего нарушкеий: ' + FormatMinutes(DayResult.Hooky);
      if DayResult.HookyComps and (DayResult.Hooky > 0) then begin
        SetNextRow(ARow);
        sgResult.Cells[3, ARow] := '(частично компенсированы)';
      end;
    end;
  //
  ARow := FirstRow;
  for I := 0 to PersonState.Pairs.Count - 1 do begin
    Pair := PersonState.Pairs.Pair[I];
    if DateOf(Pair.InTime) <> DateOf(ADate) then Continue;

    case Pair.State of
      psNormal: Text := 'Вход и выход: '
        + FormatDateTime('hh:mm', Pair.InTime) + ' - '
        + FormatDateTime('hh:mm', Pair.OutTime);
      psNotIn: Text := 'Нет входа, выход '
        + FormatDateTime('hh:mm', Pair.OutTime);
      psNotOut: Text := 'Вход ' + FormatDateTime('hh:mm', Pair.InTime)
        + ', нет выхода.';
    end;
    sgResult.Cells[4, ARow] := Text;
    if I < PersonState.Pairs.Count - 1 then SetNextRow(ARow);
  end;

end;


end.
