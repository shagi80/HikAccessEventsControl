unit PrintWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, frxClass, frxPreview, AnalysisByMinPresent, ChildWin, TWebButton,
  ExtCtrls, StdCtrls, frxExportPDF, frxExportODF, frxExportXLS,
  TheAnalysisByMinute, PersonAnalysisPresent, TablePresent;

type
  TfrmReport = class(TMDIChild)
    frxReport: TfrxReport;
    frxPreview: TfrxPreview;
    frxUDS1: TfrxUserDataSet;
    Panel1: TPanel;
    btnClose: TWebSpeedButton;
    btnPrint: TWebSpeedButton;
    frxXLSExport: TfrxXLSExport;
    frxODSExport: TfrxODSExport;
    frxPDFExport1: TfrxPDFExport;
    btnPdfExport: TWebSpeedButton;
    btnXlsExport: TWebSpeedButton;
    btnOdsExport: TWebSpeedButton;
    procedure btnPrintClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
  private
    { Private declarations }
    FAnalysisPresent: TAnalysisByMinPresent;
    FPersonGrid: TPersonAnalysisPresent;
    FTablePresent: TTablePresent;
    procedure frxDivisionReportGetValue(const VarName: string;
      var Value: Variant);
    procedure frxPersonReportGetValue(const VarName: string;
      var Value: Variant);
    procedure frxTableReportGetValue(const VarName: string;
      var Value: Variant);
  public
    { Public declarations }
    function PrintDivisionReport(AnalysisPresent: TAnalysisByMinPresent;
      RepCaption: string): boolean;
    function PrintPersonReport(Grid: TPersonAnalysisPresent;
      RepVar: TStringList): boolean;
    function PrintTableReport(TablePresent: TTablePresent;
      RepVar: TStringList): boolean;
  end;


implementation

{$R *.dfm}

const
  FolderName = 'PrintForm/';

procedure TfrmReport.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmReport.btnPrintClick(Sender: TObject);
begin
  Self.frxReport.Print;
end;

procedure TfrmReport.btnExportClick(Sender: TObject);
begin
  case TControl(Sender).Tag of
    1: frxReport.Export(Self.frxODSExport);
    2: frxReport.Export(Self.frxXLSExport);
    3: frxReport.Export(Self.frxPDFExport1);
  end;
end;

{ Печать отчета по подразделению }

procedure TfrmReport.frxDivisionReportGetValue(const VarName: string;
  var Value: Variant);
var
  ARow: integer;
begin
  Value := '???';
  ARow := frxUDS1.RecNo + 1;
  if VarName = 'PersonName' then
    Value := FAnalysisPresent.Cells[0, ARow];
  if VarName = 'ScheduleTime' then
    Value := FAnalysisPresent.Cells[1, ARow];
  if VarName = 'ScheduleWork' then
    Value := FAnalysisPresent.Cells[2, ARow];
  if VarName = 'OvertimeWork' then
    if FAnalysisPresent.Cells[3, ARow] = 'no' then Value := 'нет'
      else Value := FAnalysisPresent.Cells[3, ARow];
  if VarName = 'TotalWork' then
    Value := FAnalysisPresent.Cells[4, ARow];
  if VarName = 'WorkMark' then
    if FAnalysisPresent.Cells[5, ARow] = 'yes' then Value := 'да'
      else Value := 'нет';
  if VarName = 'LateCount' then
    if FAnalysisPresent.Cells[6, ARow] = 'no' then Value := 'нет'
      else Value := 'да / ' + FAnalysisPresent.Cells[6, ARow] + ' дней';
  if VarName = 'TotalHooky' then
    if FAnalysisPresent.Cells[7, ARow] = 'no' then Value := 'нет'
      else Value := FAnalysisPresent.Cells[7, ARow];
end;

function TfrmReport.PrintDivisionReport(
  AnalysisPresent: TAnalysisByMinPresent; RepCaption: string): boolean;
var
  FileName: string;
begin
  Result := False;
  FileName := ExtractFilePath(Application.ExeName) + FolderName;
  FileName := IncludeTrailingPathDelimiter(FileName) + 'DivisionReport.fr3';
  if not FileExists(FileName) then Exit;
  FAnalysisPresent := AnalysisPresent;
  Self.ChangeTitle('Печать: ' + RepCaption);
  frxReport.LoadFromFile(FileName);
  frxReport.Variables['RepCaption'] := '''' + RepCaption + '''';
  frxUDS1.OnGetValue := frxDivisionReportGetValue;
  frxUDS1.RangeEndCount := FAnalysisPresent.RowCount
    - FAnalysisPresent.FixedRows;
  frxReport.ShowReport(True);
  Result := True;
end;

{ Печать отчета по сотруднику }

procedure TfrmReport.frxPersonReportGetValue(const VarName: string;
  var Value: Variant);
var
  ARow: integer;
begin
  Value := '???';
  ARow := frxUDS1.RecNo + 1;
  if VarName = 'Col0' then Value := Self.FPersonGrid.Cells[0, ARow];
  if VarName = 'Col1' then Value := Self.FPersonGrid.Cells[1, ARow];
  if VarName = 'Col2' then Value := Self.FPersonGrid.Cells[2, ARow];
  if VarName = 'Col3' then Value := Self.FPersonGrid.Cells[3, ARow];
  if VarName = 'Col4' then Value := Self.FPersonGrid.Cells[4, ARow];
end;

function TfrmReport.PrintPersonReport(Grid: TPersonAnalysisPresent;
  RepVar: TStringList): boolean;
var
  FileName: string;
begin
  Result := False;
  FileName := ExtractFilePath(Application.ExeName) + FolderName;
  FileName := IncludeTrailingPathDelimiter(FileName) + 'PersonReport.fr3';
  if not FileExists(FileName) then Exit;
  FPersonGrid := Grid;
  Self.ChangeTitle('Печать: ' + RepVar.Values['RepCaption']);
  frxReport.LoadFromFile(FileName);
  frxReport.Variables['RepCaption'] := '''' + RepVar.Values['RepCaption'] + '''';
  frxReport.Variables['ScheduleTitel'] := '''' + RepVar.Values['ScheduleTitel'] + '''';
  frxReport.Variables['ScheduleDescr'] := '''' + RepVar.Values['ScheduleDescr'] + '''';
  frxReport.Variables['ScheduleTime'] := '''' + RepVar.Values['ScheduleTime'] + '''';
  frxReport.Variables['WorkTime'] := '''' + RepVar.Values['WorkTime'] + '''';
  frxReport.Variables['Overtime'] := '''' + RepVar.Values['Overtime'] + '''';
  frxReport.Variables['TotalWork'] := '''' + RepVar.Values['TotalWork'] + '''';
  frxReport.Variables['ScheduleConf'] := '''' + RepVar.Values['ScheduleConf'] + '''';
  frxReport.Variables['LateToShift'] := '''' + RepVar.Values['LateToShift'] + '''';
  frxReport.Variables['TotalHooky'] := '''' + RepVar.Values['TotalHooky'] + '''';
  frxUDS1.OnGetValue := frxPersonReportGetValue;
  frxUDS1.RangeEndCount := FPersonGrid.RowCount - FPersonGrid.FixedRows;
  frxReport.ShowReport(True);
  Result := True;
end;

{ Печать табеля подразделения }

procedure TfrmReport.frxTableReportGetValue(const VarName: string;
  var Value: Variant);
var
  ARow, ACol: integer;
  TotalTime, LateCount: integer;
begin
  Value := '???';
  ARow := frxUDS1.RecNo;
  if VarName = 'Name' then
    Value := FTablePresent.Analysis.PersonState[ARow].PersonName;
  if VarName = 'Total' then begin
    TotalTime := FTablePresent.GetPersonTotalTime(
      FTablePresent.Analysis.PersonState[ARow].TotalDayResult);
    Value := FTablePresent.FormatMinutes(
        FTablePresent.Analysis.PersonState[ARow].TotalDayResult.Schedule)
           + ' / ' + FTablePresent.FormatMinutes(TotalTime);
  end;
  if VarName = 'Late' then begin
    LateCount := FTablePresent.Analysis.PersonState[ARow].TotalDayResult.LateCount;
    if LateCount = 0 then Value := 'нет'
      else Value := 'да, ' + IntToStr(LateCount) + ' дн.';
  end;
  if Pos('Col', VarName) = 1 then begin
    ACol := StrToIntDef(copy(VarName, 4, MaxInt), 0) - 1;
    if ACol < FTablePresent.LastDayCol then begin
      TotalTime := FTablePresent.GetDayTotalTime(
        FTablePresent.Analysis.PersonState[ARow].DayResult[ACol]);
      if TotalTime = 0 then begin
          if (FTablePresent.Analysis.PersonState[ARow].DayResult[ACol].Schedule > 0) then
            Value := 'НН' else Value := '';
      end else Value := FTablePresent.FormatMinutes(TotalTime);
    end else Value := '';
  end;
end;

function TfrmReport.PrintTableReport(TablePresent: TTablePresent;
  RepVar: TStringList): boolean;
var
  FileName: string;
begin
  Result := False;
  FileName := ExtractFilePath(Application.ExeName) + FolderName;
  FileName := IncludeTrailingPathDelimiter(FileName) + 'TableReport.fr3';
  if not FileExists(FileName) then Exit;
  FTablePresent := TablePresent;
  Self.ChangeTitle('Печать: ' + RepVar.Values['RepCaption']);
  frxReport.LoadFromFile(FileName);
  frxReport.Variables['RepCaption'] := '''' + RepVar.Values['RepCaption'] + '''';
  frxReport.Variables['ScheduleTitel'] := '''' + RepVar.Values['ScheduleTitel'] + '''';
  frxReport.Variables['ScheduleDescr'] := '''' + RepVar.Values['ScheduleDescr'] + '''';
  frxUDS1.OnGetValue := frxTableReportGetValue;
  frxUDS1.RangeEndCount := TablePresent.RowCount - 1;
  frxReport.ShowReport(True);
  Result := True;
end;

end.
