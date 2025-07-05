unit PersonEventsWin;

interface

uses Windows, Classes, Graphics, Forms, Controls, StdCtrls, TWebButton,
  ComCtrls, ExtCtrls, Grids, Buttons, CHILDWIN, TheDivisions,
  TheAnalysisByMinute, TheAnalysisByMinuteThread;

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
    Panel3: TPanel;
    lbMessage: TLabel;
    btnClose: TWebSpeedButton;
    pnPerson: TPanel;
    Splitter1: TSplitter;
    Label1: TLabel;
    lbPerson: TListBox;
    pnData: TPanel;
    reEvents: TRichEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbDivisionChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure btnPreviosMonthClick(Sender: TObject);
    procedure btnCurrentMonthClick(Sender: TObject);
    procedure WebSpeedButton1Click(Sender: TObject);
    procedure Analysis(Sender: TObject);
  private
    { Private declarations }
    FAnalysisByMinute: TAnalysisByMinute;
    FThread: TAnalysisByMinuteThread;
    procedure UpdateDivisionListForPerson(CurDivision: TDivision);
    procedure EndAnalysis(var Result: boolean);
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses  TheSettings, SysUtils, DateUtils, TheEventPairs, ThePersons;

procedure TfrmPervonEvents.FormCreate(Sender: TObject);
begin
  inherited;
  FAnalysisByMinute := TAnalysisByMinute.Create;
  Self.dtpStartDate.Date := StartOfTheMonth(now);
  Self.dtpEndDate.Date := now;
  Self.DoubleBuffered := True;
  Self.LoadFromBD;
  UpdateDivisionListForPerson(nil);
  cbDivisionChange(Self);
end;

procedure TfrmPervonEvents.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FAnalysisByMinute.Free;
  inherited;
end;


procedure TfrmPervonEvents.UpdateDivisionListForPerson(
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

procedure TfrmPervonEvents.cbDivisionChange(Sender: TObject);
var
  Division: TDivision;
  Person: TPerson;
  I: integer;
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
  lbPerson.Clear;
  for I := 0 to PersonsList.Count - 1 do begin
    Person := PersonsList.Items[I];
    if (Division.ParentDivision = nil) or (Person.Division = Division) then
      lbPerson.AddItem(Person.Name, Person);
  end;
  if lbPerson.Count = 0 then begin
    lbMessage.Font.Color := clRed;
    lbMessage.Caption := Format('В подразделении "%s" нет сотрудников',
      [Division.Title]);
    Exit;
  end;
  lbPerson.Visible := True;
  lbMessage.Font.Color := clNavy;
  lbMessage.Caption := Format('График для подразделения "%s": %s',
      [Division.Title, Division.Schedule.Title]);
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
  if not Self.lbPerson.Visible then Exit; 
  if lbPerson.ItemIndex < 0 then begin
    lbMessage.Font.Color := clRed;
    lbMessage.Caption := 'Сотрудник не выбран !';
    Exit;
  end; 
  Person := TPerson(lbPerson.Items.Objects[lbPerson.ItemIndex]);
  Division := TDivision(cbDivision.Items.Objects[cbDivision.ItemIndex]);
  if (not Assigned(Person)) or (not Assigned(Division)) then Exit;

  PersonList := TStringList.Create;
  PersonList.Add(Person.PersonId + '=' + Person.Name);
  Self.ChangeTitle(Person.Name + ' c ' + DateToStr(dtpStartDate.Date)
        + ' по ' + DateToStr(dtpEndDate.Date));

  reEvents.Lines.Clear;      
  ADate := dtpStartDate.Date;
  while DateOf(dtpEndDate.Date) >= DateOf(ADate) do begin
    PersonList := TStringList.Create;
    PersonList.Add(Person.PersonId + '=' + Person.Name);
    FAnalysisByMinute.SetParametrs(PersonList, Division.Schedule,
      ADate, ADate, HolydaysList);
    FAnalysisByMinute.Analysis;
    //Total := FAnalysisByMinute.PersonState[0].TotalTime;
    if FAnalysisByMinute.ScheduleTotalTime = 0 then begin
      ADate := IncDay(ADate, 1);
      Continue;
    end;
    reEvents.Lines.Add(DateToStr(ADate));
    {reEvents.Lines.Add('Всего: ' + IntToStr(Total.TotalWork));
    reEvents.Lines.Add('Ушел раньше: ' + IntToStr(Total.EarlyFromShiftOrBreak));
    reEvents.Lines.Add('Опоздал на смену: ' + IntToStr(Total.LateToShift));
    reEvents.Lines.Add('Опоздал с перерыва: ' + IntToStr(Total.LateFromBreak));
    reEvents.Lines.Add('Прогул: ' + IntToStr(Total.Hooky));
     }
    ADate := IncDay(ADate, 1);
  end;










    
  {FThread := TAnalysisByMinuteThread.Create(True);
  FThread.FreeOnTerminate := True;
  FThread.Analysis := Self.FAnalysisByMinute;
  FThread.Present := nil;
  FThread.OnAnalysisEnd := Self.EndAnalysis;
  FThread.Resume;}
end;

procedure TfrmPervonEvents.EndAnalysis(var Result: boolean);
begin
  if not Result then begin
      lbMessage.Font.Color := clRed;
      lbMessage.Caption := 'Ошибка при выполнении анализа !';
    end else begin
      lbMessage.Caption := 'Все получилось';
    end;
end;

procedure TfrmPervonEvents.WebSpeedButton1Click(Sender: TObject);
var
  Pairs: TEmplPairs;
  Date, PreviosDate: TDate;
  I: integer;
begin
{  Pairs := TEmplPairs.Create('1', 10);
  Pairs.CreatePairsFromBD(Settings.GetInstance.DBFileName,
    StrToDateTime('16.04.2025'), now);

  PairGrid.RowCount := Pairs.Count + 1;
  for I := 0 to Pairs.Count - 1 do begin
    PairGrid.Cells[0, I + 1] := IntToStr(I + 1);

    //PairGrid.Cells[0, I + 1] := IntToStr(ord(Pairs.Pair[I].State));

    if Pairs.Pair[I].InTime > 0 then Date := DateOf(Pairs.Pair[I].InTime)
      else Date := DateOf(Pairs.Pair[I].OutTime);
    if I = 0 then PairGrid.Cells[1, I + 1] := DateToStr(Date)
      else begin
        if Pairs.Pair[I - 1].InTime > 0 then
            PreviosDate := DateOf(Pairs.Pair[I - 1].InTime)
          else
            PreviosDate := DateOf(Pairs.Pair[I - 1].OutTime);
        if PreviosDate = Date then PairGrid.Cells[1, I + 1] := ''
          else PairGrid.Cells[1, I + 1] := DateToStr(Date);
      end;





    if Pairs.Pair[I].InTime = 0  then PairGrid.Cells[2, I + 1] := '-'
      else PairGrid.Cells[2, I + 1] := DateTimeToStr(Pairs.Pair[I].InTime);
    if Pairs.Pair[I].OutTime = 0  then PairGrid.Cells[3, I + 1] := '-'
      else PairGrid.Cells[3, I + 1] := DateTimeToStr(Pairs.Pair[I].OutTime);
  end;
  Pairs.Free;
 }
end;

end.
