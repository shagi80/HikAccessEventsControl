unit SubdivisionEventsWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TheAnalysisByMinute, AnalysisByMinPresent, TWebButton, ExtCtrls,
  CHILDWIN, TheSettings, ComCtrls, StdCtrls, TheDivisions, TheAnalysisByMinuteThread,
  PersonEventsWin;

type
  TfrmSubdivisionEvents = class(TMDIChild)
    Panel1: TPanel;
    Label1: TLabel;
    cbDivision: TComboBox;
    Label2: TLabel;
    dtpEndDate: TDateTimePicker;
    Label3: TLabel;
    dtpStartDate: TDateTimePicker;
    tbScale: TTrackBar;
    Label4: TLabel;
    btnCurrentMonth: TWebSpeedButton;
    btnUpdate: TWebSpeedButton;
    btnPreviosMonth: TWebSpeedButton;
    pnMain: TPanel;
    Panel3: TPanel;
    Panel2: TPanel;
    lbMessage: TLabel;
    btnClose: TWebSpeedButton;
    lbOvertime: TLabel;
    Bevel1: TBevel;
    btnPrint: TWebSpeedButton;
    procedure btnPrintClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure btnPreviosMonthClick(Sender: TObject);
    procedure btnCurrentMonthClick(Sender: TObject);
    procedure tbScaleChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Analysis(Sender: TObject);
  private
    { Private declarations }
    FAnalysisByMinPresent: TAnalysisByMinPresent;
    FAnalysisByMinute: TAnalysisByMinute;
    Thread: TAnalysisByMinuteThread;
    procedure UpdateDivisionListForPerson(CurDivision: TDivision);
    procedure EndAnalysis(Result: boolean);
  public
    { Public declarations }
  end;


implementation

{$R *.dfm}

uses DateUtils, ThePersons, ProgressWin, PrintWin;


procedure TfrmSubdivisionEvents.FormCreate(Sender: TObject);
begin
  inherited;
  FAnalysisByMinute := TAnalysisByMinute.Create;
  FAnalysisByMinPresent := TAnalysisByMinPresent.Create(pnMain);
  FAnalysisByMinPresent.MinPerPixel := 10;
  tbScale.Position := 10;
  FAnalysisByMinPresent.Align := alClient;
  FAnalysisByMinPresent.Analysis := FAnalysisByMinute;
  FAnalysisByMinPresent.Parent := pnMain;
  tbScale.Enabled := FAnalysisByMinPresent.Enabled;
  FAnalysisByMinPresent.Visible := False;
  Self.dtpStartDate.Date := StartOfTheMonth(now);
  Self.dtpEndDate.Date := now;
  Self.DoubleBuffered := True;
  Self.LoadFromBD;
  UpdateDivisionListForPerson(nil);
end;

procedure TfrmSubdivisionEvents.FormDestroy(Sender: TObject);
begin
  //FAnalysisByMinPresent.Free;
  FAnalysisByMinute.Free;
  inherited;
end;

procedure TfrmSubdivisionEvents.tbScaleChange(Sender: TObject);
begin
  inherited;
  FAnalysisByMinPresent.MinPerPixel := tbScale.Position;
end;

procedure TfrmSubdivisionEvents.UpdateDivisionListForPerson(
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

procedure TfrmSubdivisionEvents.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmSubdivisionEvents.btnPreviosMonthClick(Sender: TObject);
begin
  Self.dtpStartDate.Date := StartOfTheMonth(IncDay(StartOfTheMonth(now), -1));
  Self.dtpEndDate.Date := DateUtils.EndOfTheMonth(dtpStartDate.Date);
  Analysis(Self);
end;

procedure TfrmSubdivisionEvents.btnUpdateClick(Sender: TObject);
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

procedure TfrmSubdivisionEvents.btnCurrentMonthClick(Sender: TObject);
begin
  Self.dtpStartDate.Date := StartOfTheMonth(now);
  Self.dtpEndDate.Date := now;
  Analysis(Self);
end;

procedure TfrmSubdivisionEvents.Analysis(Sender: TObject);
var
  PersonList: TStringList;
  Division: TDivision;
  Person: TPerson;
  I: integer;
  Str: string;
begin
  FAnalysisByMinPresent.Visible := False;
  lbOvertime.Visible := FAnalysisByMinPresent.Visible;
  tbScale.Enabled := FAnalysisByMinPresent.Visible;
  btnPrint.Enabled := False;
  if cbDivision.ItemIndex < 0 then begin
    lbMessage.Font.Color := clRed;
    lbMessage.Caption := '������������� �� �������';
    Exit;
  end;
  Division := TDivision(cbDivision.Items.Objects[cbDivision.ItemIndex]);
  if not Assigned(Division.Schedule) then begin
    lbMessage.Font.Color := clRed;
    lbMessage.Caption := Format('��� ������������� "%s" �� ����� ������',
      [Division.Title]);
    Exit;
  end;
  PersonList := TStringList.Create;
  for I := 0 to PersonsList.Count - 1 do begin
    Person := PersonsList.Items[I];
    if Person.Division = Division then
      PersonList.Add(Person.PersonId + '=' + Person.Name);
  end;
  if PersonList.Count = 0 then begin
    lbMessage.Font.Color := clRed;
    lbMessage.Caption := Format('� ������������� "%s" ��� �����������',
      [Division.Title]);
    Exit;
  end;
  //
  lbMessage.Font.Color := clNavy;
  lbMessage.Caption := Format('������������� "%s". ������ "%s"',
      [Division.Title, Division.Schedule.Title]);
  Self.ChangeTitle(Division.Title + ' c ' + DateToStr(dtpStartDate.Date)
        + ' �� ' + DateToStr(dtpEndDate.Date));
  Str := '����������� �� �����������.';
  if Division.Schedule.CanOvertime then begin
    if Division.Schedule.OvertimeMin = 0 then
      Str := '����������� ����� �����������.'
        else Str := '����������� ����������� ����� '
          + IntToStr(Division.Schedule.OvertimeMin) + ' �����.';
      if Division.Schedule.UseOvertimeForHooky then Str := Str
        + ' ����������� ������������ ���������.';
  end;
  if Division.Schedule.CanWorkToBreak then
    Str := Str + ' ��������� �������� � ��������.';
  lbOvertime.Caption := Str;
  //
  FAnalysisByMinute.SetParametrs(PersonList, Division.Schedule,
    dtpStartDate.Date, dtpEndDate.Date, HolydaysList);

  //EndAnalysis(FAnalysisByMinute.Analysis);

  Thread := TAnalysisByMinuteThread.Create(True);
  Thread.FreeOnTerminate := True;
  Thread.Analysis := Self.FAnalysisByMinute;
  Thread.Present := Self.FAnalysisByMinPresent;
  Thread.OnAnalysisEnd := Self.EndAnalysis;
  Thread.Resume;
end;

procedure TfrmSubdivisionEvents.EndAnalysis(Result: boolean);
begin
  if not Result then begin
      lbMessage.Font.Color := clRed;
      lbMessage.Caption := '������ ��� ���������� ������� !';
    end else begin
      //FAnalysisByMinPresent.UpdateAnalys;
      FAnalysisByMinPresent.Visible := True;
    end;
  lbOvertime.Visible := FAnalysisByMinPresent.Visible;
  btnPrint.Enabled := FAnalysisByMinPresent.Visible;
  tbScale.Enabled := FAnalysisByMinPresent.Visible;
end;

//

procedure TfrmSubdivisionEvents.btnPrintClick(Sender: TObject);
var
  ReportForm: TfrmReport;
begin
  ReportForm := TfrmReport.Create(Application.MainForm);
  ReportForm.FormBtnParentPanel := Self.FormBtnParentPanel;
  ReportForm.ShowFomButton(bsPrint);
  if not ReportForm.PrintDivisionReport(FAnalysisByMinPresent,
    Self.Caption) then ReportForm.Close;
end;

end.
