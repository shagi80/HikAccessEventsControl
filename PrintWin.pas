unit PrintWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, frxClass, frxPreview, AnalysisByMinPresent, ChildWin, TWebButton,
  ExtCtrls, StdCtrls, frxExportPDF, frxExportODF, frxExportXLS;

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
    FRepCaption: string;
    procedure frxDivisionReportGetValue(const VarName: string;
  var Value: Variant);
  public
    { Public declarations }
    function PrintDivisionReport(AnalysisPresent: TAnalysisByMinPresent;
      RepCaption: string): boolean;
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

procedure TfrmReport.frxDivisionReportGetValue(const VarName: string;
  var Value: Variant);
var
  ARow: integer;
begin
  Value := '???';
  ARow := frxUDS1.RecNo + 1;
  if VarName = 'RepCaption' then
    Value := Self.FRepCaption;
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
  FRepCaption := RepCaption;
  Self.ChangeTitle('Печать: ' + FRepCaption);
  frxReport.LoadFromFile(FileName);
  frxReport.OnGetValue := frxDivisionReportGetValue;
  frxUDS1.RangeEndCount := FAnalysisPresent.RowCount
    - FAnalysisPresent.FixedRows;
  frxReport.ShowReport(True);
  Result := True;
end;

end.
