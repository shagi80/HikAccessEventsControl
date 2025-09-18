unit DivisionTableWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, TWebButton, ExtCtrls, ChildWin,
  TheSettings, TheDivisions, TheAnalysisByMinute,
  TheAnalysisByMinuteThread, TablePresent;

type
  TfrmDivisionTable = class(TMDIChild)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    btnCurrentMonth: TWebSpeedButton;
    btnUpdate: TWebSpeedButton;
    btnPreviosMonth: TWebSpeedButton;
    cbDivision: TComboBox;
    dtpEndDate: TDateTimePicker;
    dtpStartDate: TDateTimePicker;
    pnMain: TPanel;
    Panel3: TPanel;
    lbOvertime: TLabel;
    Panel2: TPanel;
    lbMessage: TLabel;
    btnClose: TWebSpeedButton;
    btnPrint: TWebSpeedButton;
    procedure btnUpdateClick(Sender: TObject);
    procedure btnCurrentMonthClick(Sender: TObject);
    procedure btnPreviosMonthClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
  private
    { Private declarations }
    FAnalysisByMinute: TAnalysisByMinute;
    FTablePresent: TTablePresent;
    Thread: TAnalysisByMinuteThread;
    procedure UpdateDivisionListForPerson(CurDivision: TDivision);
    function PrepareLabels(var PersonList: TStringList;
      var Division: TDivision): boolean;
    procedure Analysis(Sender: TObject);
    procedure EndAnalysis(Result: boolean);
  public
    { Public declarations }
  end;

var
  frmDivisionTable: TfrmDivisionTable;

implementation

{$R *.dfm}

uses DateUtils, ThePersons, PrintWin;


procedure TfrmDivisionTable.FormCreate(Sender: TObject);
begin
  inherited;
  FAnalysisByMinute := TAnalysisByMinute.Create;
  FTablePresent := TTablePresent.Create(pnMain);
  FTablePresent.Align := alClient;
  FTablePresent.Analysis := FAnalysisByMinute;
  FTablePresent.Name := 'FTablePresent';
  FTablePresent.Parent := pnMain;
  FTablePresent.Visible := False;
  Self.dtpStartDate.Date := StartOfTheMonth(now);
  Self.dtpEndDate.Date := now;
  Self.DoubleBuffered := True;
  Self.LoadFromBD;
  UpdateDivisionListForPerson(nil);
end;

procedure TfrmDivisionTable.FormDestroy(Sender: TObject);
begin
  FAnalysisByMinute.Free;
  inherited;
end;

procedure TfrmDivisionTable.UpdateDivisionListForPerson(
  CurDivision: TDivision);

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
  for I := 0 to cbDivision.Items.Count - 1 do
    if cbDivision.Items.Objects[I] = CurDivision then begin
      cbDivision.ItemIndex := I;
      Break;
    end;
end;

procedure TfrmDivisionTable.btnCloseClick(Sender: TObject);
begin
  inherited;
  Self.Close;
end;

procedure TfrmDivisionTable.btnCurrentMonthClick(Sender: TObject);
begin
  inherited;
  Self.dtpStartDate.Date := StartOfTheMonth(now);
  Self.dtpEndDate.Date := now;
  Analysis(Self);
end;

procedure TfrmDivisionTable.btnPreviosMonthClick(Sender: TObject);
begin
  inherited;
  Self.dtpStartDate.Date := StartOfTheMonth(IncDay(StartOfTheMonth(now), -1));
  Self.dtpEndDate.Date := DateUtils.EndOfTheMonth(dtpStartDate.Date);
  Analysis(Self);
end;

procedure TfrmDivisionTable.btnUpdateClick(Sender: TObject);
var
  SelectDivision: TDivision;
  SelectDivGUID: TGUID;
begin
  if cbDivision.ItemIndex < 0 then Exit;  
  SelectDivision := TDivision(cbDivision.Items.Objects[cbDivision.ItemIndex]);
  SelectDivGUID := SelectDivision.GUID;
  Self.LoadFromBD;
  SelectDivision := DivisionsList.Items[SelectDivGUID];
  UpdateDivisionListForPerson(SelectDivision);
  Analysis(Self);
end;

//

function TfrmDivisionTable.PrepareLabels(var PersonList: TStringList;
  var Division: TDivision): boolean;
var
  Person: TPerson;
  I: integer;
  Str: string;
begin
  Result := False;
  FTablePresent.Visible := False;
  btnPrint.Enabled := False;
  lbOvertime.Caption := '';
  //tbScale.Enabled := FTablePresent.Visible;
  btnPrint.Enabled := False;
  // Проверяем выбор подразделения.
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
  // Создение списка сотрудников.
  for I := 0 to PersonsList.Count - 1 do begin
    Person := PersonsList.Items[I];
    if Person.Division = Division then
      PersonList.Add(Person.PersonId + '=' + Person.Name);
  end;
  // Если список сотрудников пуст...
  if PersonList.Count = 0 then begin
    lbMessage.Font.Color := clRed;
    lbMessage.Caption := Format('В подразделении "%s" нет сотрудников',
      [Division.Title]);
    Exit;
  end;
  // Если сотрудники в списке имеются ...
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

  Result := True;
end;

procedure TfrmDivisionTable.Analysis(Sender: TObject);
var
  PersonList: TStringList;
  Division: TDivision;
begin
  PersonList := TStringList.Create;
  Division := nil;
  if not Self.PrepareLabels(PersonList, Division) then begin
    PersonList.Free;
    Exit;
  end;

  FAnalysisByMinute.SetParametrs(PersonList, Division.Schedule,
    dtpStartDate.Date, dtpEndDate.Date, HolydaysList);

  //EndAnalysis(FAnalysisByMinute.Analysis);

  Thread := TAnalysisByMinuteThread.Create(True);
  Thread.FreeOnTerminate := True;
  Thread.Analysis := Self.FAnalysisByMinute;
  Thread.Present := nil;//Self.FAnalysisByMinPresent;
  Thread.OnAnalysisEnd := Self.EndAnalysis;
  Thread.Resume;
end;

procedure TfrmDivisionTable.EndAnalysis(Result: boolean);
begin
  FTablePresent.Visible := True;
  btnPrint.Enabled := True;
  FTablePresent.UpdateAnalys;
end;

{ Print }

procedure TfrmDivisionTable.btnPrintClick(Sender: TObject);
var
  ReportForm: TfrmReport;
  RepVar: TStringList;
begin
  ReportForm := TfrmReport.Create(Self);
  ReportForm.FormBtnParentPanel := Self.FormBtnParentPanel;
  ReportForm.ShowFomButton(bsPrint);
  RepVar := TStringList.Create;
  RepVar.Add('RepCaption=' + Self.Caption);
  RepVar.Add('ScheduleTitel=' + Self.FAnalysisByMinute.ScheduleTemplate.Title);
  RepVar.Add('ScheduleDescr=' + Self.lbOvertime.Caption);
  if not ReportForm.PrintTableReport(Self.FTablePresent, RepVar)
    then ReportForm.Close;
end;


end.
