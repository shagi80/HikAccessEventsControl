unit TheAnalysisByMinuteThread;

interface

uses
  Classes, TheAnalysisByMinute, AnalysisByMinPresent, ProgressWin;

type
  TAnalysisEnd = procedure (Result: boolean) of object;

  TAnalysisByMinuteThread = class(TThread)
  private
    { Private declarations }
    FPresent: TAnalysisByMinPresent;
    FAnalysis: TAnalysisByMinute;
    FAnalysisEnd: TAnalysisEnd;
    FResult: boolean;
    FHideProgress: boolean;
    procedure SyncTikBegin;
    procedure SyncTikEnd;
  protected
    procedure Execute; override;
  public
    property Present: TAnalysisByMinPresent read FPresent write FPresent;
    property Analysis: TAnalysisByMinute read FAnalysis write FAnalysis;
    property OnAnalysisEnd: TAnalysisEnd read FAnalysisEnd write FAnalysisEnd;
    property HideProgress: boolean read FHideProgress write FHideProgress;
  end;

implementation


procedure TAnalysisByMinuteThread.SyncTikBegin;
begin
  frmProgress.TikBegin('Анализ данных ...', FAnalysis.PersonCount);
end;

procedure TAnalysisByMinuteThread.SyncTikEnd;
begin
  if Assigned(FPresent) then begin
    FPresent.OnTikEvent := frmProgress.Tik;
    FPresent.UpdateAnalys;
    FPresent.OnTikEvent := nil;
  end;
  if Assigned(FAnalysisEnd) then FAnalysisEnd(FResult);
  if not FHideProgress then
    frmProgress.TikEnd('Все получилось !', 500);
end;

procedure TAnalysisByMinuteThread.Execute;
begin
  if not FHideProgress then Synchronize(Self.SyncTikBegin);
  FResult := FAnalysis.Analysis;
  Synchronize(Self.SyncTikEnd);
end;

end.
