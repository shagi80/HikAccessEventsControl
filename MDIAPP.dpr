program Mdiapp;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  about in 'about.pas' {AboutBox},
  TheShift in 'Models\TheShift.pas',
  FastInt64 in 'Source\TinyJson\FastInt64.pas',
  Hashes in 'Source\TinyJson\Hashes.pas',
  JSON in 'Source\TinyJson\JSON.pas',
  ShiftPresent in 'Controls\ShiftPresent.pas',
  TheEventsLoader in 'HikAPI\TheEventsLoader.pas',
  APIClient in 'HikAPI\APIClient.pas',
  DigestHeader in 'HikAPI\DigestHeader.pas',
  SQLite3 in 'Source\SQLiteWrapper\SQLite3.pas',
  sqlite3udf in 'Source\SQLiteWrapper\sqlite3udf.pas',
  SQLiteTable3 in 'Source\SQLiteWrapper\SQLiteTable3.pas',
  TWebButton in 'Source\WeButton\TWebButton.pas',
  APIProcessWin in 'HikAPI\APIProcessWin.pas' {frmProcess},
  TheAPIThreadStateLoader in 'HikAPI\TheAPIThreadStateLoader.pas',
  TheAPIThreadEventsLoader in 'HikAPI\TheAPIThreadEventsLoader.pas',
  TheEventPairs in 'Models\TheEventPairs.pas',
  TheSettings in 'Models\TheSettings.pas',
  PersonEventsWin in 'PersonEventsWin.pas' {frmPervonEvents},
  TheSchedule in 'Models\TheSchedule.pas',
  TheBreaks in 'Models\TheBreaks.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.Run;
end.
