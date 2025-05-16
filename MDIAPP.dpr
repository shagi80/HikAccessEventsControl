program Mdiapp;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  CHILDWIN in 'CHILDWIN.PAS' {MDIChild},
  about in 'about.pas' {AboutBox},
  TheShift in 'Models\TheShift.pas',
  FastInt64 in 'Source\TinyJson\FastInt64.pas',
  Hashes in 'Source\TinyJson\Hashes.pas',
  JSON in 'Source\TinyJson\JSON.pas',
  ShiftPresent in 'Controls\ShiftPresent.pas',
  TheEventsLoader in 'HikAPI\TheEventsLoader.pas',
  APIClient in 'HikAPI\APIClient.pas',
  DigestHeader in 'HikAPI\DigestHeader.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.Run;
end.
