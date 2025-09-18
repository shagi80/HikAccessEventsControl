unit PersonEventsWin;

interface

uses Windows, Classes, Graphics, Forms, Controls, StdCtrls, TWebButton,
  ComCtrls, ExtCtrls, Grids, Buttons, CHILDWIN, TheDivisions,
  TheAnalysisByMinute, TheAnalysisByMinuteThread, ThePersons,
  PersonAnalysisPresent;

type
  TfrmPervonEvents = class(TMDIChild)
    pnMain: TPanel;
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
    pnTop: TPanel;
    lbOvertime: TLabel;
    Panel1: TPanel;
    lbMessage: TLabel;
    btnClose: TWebSpeedButton;
    btnPrint: TWebSpeedButton;
    Panel4: TPanel;
    pnTotalResult: TGridPanel;
    Label2: TLabel;
    lbTotalSchedule: TLabel;
    lbTotalWorkCaption: TLabel;
    lbTotalWork: TLabel;
    Label10: TLabel;
    lbTotalWorkToSchedule: TLabel;
    Label12: TLabel;
    lbLateToShift: TLabel;
    Label14: TLabel;
    lbTotalOvertime: TLabel;
    Label16: TLabel;
    lbTotalHooky: TLabel;
    pnLeft: TPanel;
    cbResizeColumn: TCheckBox;
    cbWordBreak: TCheckBox;
    procedure btnPrintClick(Sender: TObject);
    procedure cbResizeColumnClick(Sender: TObject);
    procedure cbWordBreakClick(Sender: TObject);
    procedure lbPersonClick(Sender: TObject);
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
    FResultGrid: TPersonAnalysisPresent;
    procedure UpdateDivisionList(CurDivision: TDivision);
    function UpdatePersonList(CurDivision: TDivision;
      CurPerson: TPerson): integer;
    procedure EndAnalysis(Result: boolean);
    procedure WriteTotalTime(TotalDayResylt: TPersonResult);
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses  TheSettings, SysUtils, DateUtils, TheEventPairs, Dialogs, TheShift,
  PrintWin;

procedure TfrmPervonEvents.FormCreate(Sender: TObject);
begin
  inherited;
  FAnalysis := TAnalysisByMinute.Create;
  FResultGrid := TPersonAnalysisPresent.Create(pnData);
  FResultGrid.Visible := False;
  FResultGrid.Align := alClient;
  FResultGrid.Analysis := FAnalysis;
  FResultGrid.Parent := pnData;
  cbWordBreak.Checked := FResultGrid.WordBreak;
  cbResizeColumn.Checked := FresultGrid.ResizeColumn;
  Self.dtpStartDate.Date := StartOfTheMonth(now);
  Self.dtpEndDate.Date := now;
  Self.DoubleBuffered := True;
  Self.LoadFromBD;
  UpdateDivisionList(nil);
  cbDivisionChange(Self);
end;

procedure TfrmPervonEvents.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FResultGrid.Free;
  FAnalysis.Free;
  inherited;
end;

{ События контролов. }

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
  Result := 0;
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
begin
  lbPerson.Visible := False;
  FResultGrid.Visible := False;
  pnTotalResult.Visible := False;
  lbOvertime.Visible := False;
  btnPrint.Enabled := False;
  lbMessage.Font.Color := clNavy;
  lbMessage.Caption := 'Выберите сотрудника ...';
  if cbDivision.ItemIndex < 0 then begin
    lbMessage.Font.Color := clRed;
    lbMessage.Caption := 'Подразделение не выбрано';
    Exit;
  end;
  Division := TDivision(cbDivision.Items.Objects[cbDivision.ItemIndex]);
  if UpdatePersonList(Division, nil) = 0 then begin
    lbMessage.Font.Color := clRed;
    lbMessage.Caption := Format('В подразделении "%s" нет сотрудников',
      [Division.Title]);
    Exit;
  end;
  lbPerson.Visible := True;
end;

procedure TfrmPervonEvents.cbWordBreakClick(Sender: TObject);
begin
  FResultGrid.WordBreak := cbWordBreak.Checked;
end;

procedure TfrmPervonEvents.cbResizeColumnClick(Sender: TObject);
begin
  inherited;
  Self.FResultGrid.ResizeColumn := cbResizeColumn.Checked;
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
  end else SelectPerson := nil;
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

procedure TfrmPervonEvents.lbPersonClick(Sender: TObject);
var
  Division: TDivision;
  Person: TPerson;
  Str: string;
begin
  lbOvertime.Visible := False;
  if lbPerson.ItemIndex < 0 then begin
    lbMessage.Font.Color := clRed;
    lbMessage.Caption := 'Сотрудник не выбран !';
    lbOvertime.Visible := False;
    Exit;
  end;
  Person := TPerson(lbPerson.Items.Objects[lbPerson.ItemIndex]);
  Division := Person.Division;
  if not Assigned(Division.Schedule) then begin
    lbMessage.Font.Color := clRed;
    lbMessage.Caption := Format('Для подразделения "%s" не задан график',
      [Division.Title]);
    Exit;
  end;
  //
  Analysis(Person);
  lbMessage.Font.Color := clNavy;
  lbMessage.Caption := Format('Сотрудник "%s". График "%s"',
      [Person.Name, Division.Schedule.Title]);
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
  lbOvertime.Visible := True;
end;

{ Анализ. }

procedure TfrmPervonEvents.WriteTotalTime(TotalDayResylt: TPersonResult);

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
  lbTotalSchedule.Caption := FormatMinutes(TotalDayResylt.Schedule);
  lbTotalWorkToSchedule.Caption := FormatMinutes(TotalDayResylt.TotalWork);
  if TotalDayResylt.Overtime > 0 then
    lbTotalOvertime.Caption := FormatMinutes(TotalDayResylt.Overtime)
      else lbTotalOvertime.Caption := 'нет';
  TotalTime := TotalDayResylt.TotalWork + TotalDayResylt.Overtime;
  lbTotalWork.Caption := FormatMinutes(TotalTime);
  if (TotalTime >= TotalDayResylt.Schedule) then begin
        lbTotalWorkCaption.Font.Color := clGreen;
        lbTotalWork.Font.Color := clGreen;
      end else begin
        lbTotalWorkCaption.Font.Color := clRed;
        lbTotalWork.Font.Color := clRed;
      end;
  lbLateToShift.Font.Color := clGray;
  lbTotalHooky.Font.Color := clGray;
  if TotalDayResylt.LateCount = 0 then
    lbLateToShift.Caption := 'нет'
      else begin
        lbLateToShift.Font.Color := clRed;
        lbLateToShift.Caption := IntToStr(TotalDayResylt.LateCount);
      end;
  if TotalDayResylt.Hooky = 0 then
    lbTotalHooky.Caption := 'нет'
      else begin
        lbTotalHooky.Font.Color := clRed;
        lbTotalHooky.Caption := FormatMinutes(TotalDayResylt.Hooky);
      end;
end;

procedure TfrmPervonEvents.Analysis(Sender: TObject);
var
  Person: TPerson;
  PersonList: TStringList;
  Division: TDivision;
begin
  if not Self.lbPerson.Visible then Exit;
  if lbPerson.ItemIndex < 0 then begin
    lbMessage.Font.Color := clRed;
    lbMessage.Caption := 'Сотрудник не выбран !';
    lbOvertime.Visible := False;
    Exit;
  end;
  if Sender is TPerson then Person := TPerson(Sender)
    else Person := TPerson(lbPerson.Items.Objects[lbPerson.ItemIndex]);
  Division := Person.Division;
  if (not Assigned(Person)) or (not Assigned(Division)) then Exit;

  PersonList := TStringList.Create;
  PersonList.Add(Person.PersonId + '=' + Person.Name);
  Self.ChangeTitle(Person.Name + ' c ' + DateToStr(dtpStartDate.Date)
        + ' по ' + DateToStr(dtpEndDate.Date));

  FAnalysis.SetParametrs(PersonList, Division.Schedule,
    dtpStartDate.Date, dtpEndDate.Date, HolydaysList);
  EndAnalysis(FAnalysis.Analysis)
end;

procedure TfrmPervonEvents.EndAnalysis(Result: boolean);
begin
  if not Result then begin
      lbMessage.Font.Color := clRed;
      lbMessage.Caption := 'Ошибка при выполнении анализа !';
      Exit;
    end;
  FResultGrid.UpdateAnalys;
  WriteTotalTime(Self.FAnalysis.PersonState[0].TotalDayResult);
  btnPrint.Enabled := True;
  FResultGrid.Visible := True;
  pnTotalResult.Visible := True;
end;

{ Print }

procedure TfrmPervonEvents.btnPrintClick(Sender: TObject);
var
  ReportForm: TfrmReport;
  RepVar: TStringList;
  Text: string;
begin
  ReportForm := TfrmReport.Create(Self);
  ReportForm.FormBtnParentPanel := Self.FormBtnParentPanel;
  ReportForm.ShowFomButton(bsPrint);
  RepVar := TStringList.Create;
  RepVar.Add('RepCaption=' + Self.Caption);
  RepVar.Add('ScheduleTitel=' + Self.FAnalysis.ScheduleTemplate.Title);
  RepVar.Add('ScheduleDescr=' + Self.lbOvertime.Caption);
  RepVar.Add('ScheduleTime=' + Self.lbTotalSchedule.Caption);
  RepVar.Add('WorkTime=' + Self.lbTotalWorkToSchedule.Caption);
  RepVar.Add('Overtime=' + Self.lbTotalOvertime.Caption);
  Text := Self.lbTotalWork.Caption;
  if Self.lbTotalWork.Font.Color = clGreen then Text := Text + ' (норма)'
    else Text := Text + ' (ниже нормы)';
  RepVar.Add('TotalWork=' + Text);
  RepVar.Add('ScheduleConf=' + 'test');
  RepVar.Add('LateToShift=' + Self.lbLateToShift.Caption);
  RepVar.Add('TotalHooky=' + Self.lbTotalHooky.Caption);
  if not ReportForm.PrintPersonReport(Self.FResultGrid, RepVar)
    then ReportForm.Close;
end;

end.
