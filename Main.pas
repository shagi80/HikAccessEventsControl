unit MAIN;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls, StdActns,
  ActnList, ToolWin, ImgList, Grids, TWebButton, ButtonGroup, Tabs, DockTabSet;

type
  TMainForm = class(TForm)
    Panel2: TPanel;
    btnPerson: TWebSpeedButton;
    btnProcess: TWebSpeedButton;
    btnDivisionReport: TWebSpeedButton;
    btnPersonReport: TWebSpeedButton;
    btnSchedule: TWebSpeedButton;
    sbFormButtons: TScrollBox;
    pnFormButtons: TPanel;
    TabSet1: TTabSet;
    procedure btnPersonReportClick(Sender: TObject);
    procedure btnPersonClick(Sender: TObject);
    procedure btnScheduleClick(Sender: TObject);
    procedure btnDivisionReportClick(Sender: TObject);
    procedure btnProcessClick(Sender: TObject);
  private
    { Private declarations }
    function HasChildren(AClassName: string): boolean;
    procedure UnselectFormButton;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{$R res.RES}

uses about, DateUtils, APIProcessWin, TheSettings, TheEventPairs,
  PersonEventsWin, ScheduleEditWin, TheShift, TheSchedule,
  TheBreaks, ScheduleAndShiftSettingsWin, TheAnalysisByMinute,
  AnalysisByMinPresent, SubdivisionEventsWin, DivisionAndPersonSettingsWin;


function TMainForm.HasChildren(AClassName: string): boolean;
var
  I: integer;
begin
  Result := False;
  for I := 0 to Self.MDIChildCount - 1 do begin
    Result := (Self.MDIChildren[I].ClassName = AClassName);
    if Result then begin
      Self.MDIChildren[I].Show;
      Exit;
    end;
  end;

end;

procedure TMainForm.UnselectFormButton;
var
  I: integer;
begin
  for I := 0 to Self.pnFormButtons.ControlCount - 1 do
    TWebSpeedButton(Self.pnFormButtons.Controls[I]).Down := False;
end;

procedure TMainForm.btnProcessClick(Sender: TObject);
var
  frmProcess: TfrmProcess;
begin
  frmProcess := TfrmProcess.Create(Self);
  frmProcess.ShowModal;
  frmProcess.Free;
end;

procedure TMainForm.btnDivisionReportClick(Sender: TObject);
var
  frmSubdivisionEvents: TfrmSubdivisionEvents;
begin
  frmSubdivisionEvents := TfrmSubdivisionEvents.Create(Self);
  frmSubdivisionEvents.ShowFomButton(pnFormButtons);
  frmSubdivisionEvents.WindowState := wsMaximized;
end;

procedure TMainForm.btnPersonReportClick(Sender: TObject);
var
  frmPervonEvents: TfrmPervonEvents;
begin
  MessageDlg('Это еще не работает !', mtWarning, [mbOk], 0);
  Exit;
  frmPervonEvents := TfrmPervonEvents.Create(Self);
  frmPervonEvents.ShowFomButton(pnFormButtons);
end;

procedure TMainForm.btnScheduleClick(Sender: TObject);
var
  frmShiftSettings: TfrmShift;
begin
  if not Self.HasChildren(TfrmShift.ClassName) then
    frmShiftSettings := TfrmShift.Create(Self);
  UnselectFormButton
end;

procedure TMainForm.btnPersonClick(Sender: TObject);
var
  frmPersonSettings: TfrmDivisionAndPersonSettings;
begin
  if not Self.HasChildren(TfrmDivisionAndPersonSettings.ClassName) then
    frmPersonSettings := TfrmDivisionAndPersonSettings.Create(Self);
  UnselectFormButton
end;


end.
