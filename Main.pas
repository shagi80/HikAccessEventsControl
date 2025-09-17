unit MAIN;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls, StdActns,
  ActnList, ToolWin, ImgList, Grids, TWebButton, ButtonGroup, Tabs, DockTabSet,
  TheAPIThreadStateLoader, jpeg, AppEvnts;

type
  TMainForm = class(TForm)
    Panel2: TPanel;
    btnPerson: TWebSpeedButton;
    btnProcess: TWebSpeedButton;
    btnShowDivPanel: TWebSpeedButton;
    btnPersonReport: TWebSpeedButton;
    btnSchedule: TWebSpeedButton;
    sbFormButtons: TScrollBox;
    pnFormButtons: TPanel;
    TabSet1: TTabSet;
    btnSettings: TWebSpeedButton;
    pnState: TPanel;
    lbLastTime: TLabel;
    Image1: TImage;
    pnReportButtons: TPanel;
    btnTableReport: TWebSpeedButton;
    Panel3: TPanel;
    btnHideButtonsPanel: TSpeedButton;
    btnGraphicReport: TWebSpeedButton;
    tmButtonsPanel: TTimer;
    Label1: TLabel;
    procedure btnHideButtonsPanelClick(Sender: TObject);
    procedure btnGraphicReportClick(Sender: TObject);
    procedure btnTableReportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure btnPersonReportClick(Sender: TObject);
    procedure btnPersonClick(Sender: TObject);
    procedure btnScheduleClick(Sender: TObject);
    procedure btnShowDivPanelClick(Sender: TObject);
    procedure btnProcessClick(Sender: TObject);
    procedure HidePanel(Sender: TObject);
  private
    { Private declarations }
    FLastTimeInBD: TDateTime;
    FConnectToBd: boolean;
    function HasChildren(AClassName: string): boolean;
    procedure UnselectFormButton;
    procedure SetButtonsEnabled;
    function UpdateLastTime: boolean;
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
  AnalysisByMinPresent, SubdivisionEventsWin, DivisionAndPersonSettingsWin,
  SettingsWin, TheEventsLoader, CHILDWIN, DivisionTableWin;

procedure TMainForm.FormShow(Sender: TObject);
begin
  FConnectToBd := Self.UpdateLastTime;
  SetButtonsEnabled;
end;

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
  Self.HidePanel(Self);
  for I := 0 to Self.pnFormButtons.ControlCount - 1 do
    TWebSpeedButton(Self.pnFormButtons.Controls[I]).Down := False;
end;

procedure TMainForm.SetButtonsEnabled;
begin
  Self.HidePanel(Self);
  Self.btnSchedule.Enabled := (Settings.GetInstance.AccessLevel > 0)
    and (FConnectToBd);
  Self.btnPerson.Enabled := (Settings.GetInstance.AccessLevel > 0)
    and (FConnectToBd);
  Self.btnProcess.Enabled := FConnectToBd;
  Self.btnGraphicReport.Enabled := FConnectToBd;
  Self.btnTableReport.Enabled := FConnectToBd;
  Self.btnPersonReport.Enabled := FConnectToBd;
  lbLastTime.Visible := FConnectToBd;
  if Self.FConnectToBd then begin
    lbLastTime.Caption := 'Данные актуальны на ' + FormatDateTime(
      'dd mmmm YY hh:MM:ss', FLastTimeInBD);
    pnState.Caption := '';
  end else
    pnState.Caption := 'Нет связи с базой данных ...';
end;

function TMainForm.UpdateLastTime: boolean;
var
  Loader: TEventsLoader;
  Device: TDevice;
  I, J: integer;
  DeviceTime, MinorTime: TDateTime;
begin
  Result := False;
  Loader := TEventsLoader.Create(Settings.GetInstance.DBFileName);
  FLastTimeInBD := now;
  for I := 0 to Loader.DeviceCount - 1 do begin
    Device := Loader.Device[I];
    DeviceTime := 0;
    for j := 0 to Loader.MinorEventCount - 1 do begin
      MinorTime := Loader.LastTimeInDB(I, J);
      if MinorTime > DeviceTime then DeviceTime := MinorTime;
      Result := True;
    end;
    if DeviceTime < FLastTimeInBD then FLastTimeInBD := DeviceTime;
  end;
  Loader.Free;
end;


//

procedure TMainForm.btnShowDivPanelClick(Sender: TObject);
begin
  tmButtonsPanel.Enabled := True;
  pnReportButtons.Visible := True;
end;

procedure TMainForm.HidePanel(Sender: TObject);
begin
  Self.pnReportButtons.Visible := False;
  Self.tmButtonsPanel.Enabled := False;
end;

procedure TMainForm.btnHideButtonsPanelClick(Sender: TObject);
begin
  Self.HidePanel(Self);
end;

//


procedure TMainForm.btnProcessClick(Sender: TObject);
var
  frmProcess: TfrmProcess;
begin
  Self.HidePanel(Self);
  frmProcess := TfrmProcess.Create(Self);
  frmProcess.ShowModal;
  frmProcess.Free;
  SetButtonsEnabled;
end;

procedure TMainForm.btnPersonReportClick(Sender: TObject);
var
  frmPersonEvents: TfrmPervonEvents;
begin
  Self.HidePanel(Self);
  frmPersonEvents := TfrmPervonEvents.Create(Self);
  frmPersonEvents.FormBtnParentPanel := pnFormButtons;
  frmPersonEvents.ShowFomButton(bsGrid);
end;

procedure TMainForm.btnScheduleClick(Sender: TObject);
var
  frmShiftSettings: TfrmShift;
begin
  if not Self.HasChildren(TfrmShift.ClassName) then
    frmShiftSettings := TfrmShift.Create(Self);
  UnselectFormButton
end;

procedure TMainForm.btnSettingsClick(Sender: TObject);
begin
  if frmSettings.ShowModal = mrOk then begin
    FConnectToBd := Self.UpdateLastTime;
    SetButtonsEnabled;
  end;
end;

procedure TMainForm.btnGraphicReportClick(Sender: TObject);
var
  frmSubdivisionEvents: TfrmSubdivisionEvents;
begin
  Self.HidePanel(Self);
  frmSubdivisionEvents := TfrmSubdivisionEvents.Create(Self);
  frmSubdivisionEvents.FormBtnParentPanel := pnFormButtons;
  frmSubdivisionEvents.ShowFomButton(bsGrid);
  frmSubdivisionEvents.WindowState := wsMaximized;
end;

procedure TMainForm.btnTableReportClick(Sender: TObject);
var
  frmDivisionTable: TfrmDivisionTable;
begin
  Self.HidePanel(Self);
  frmDivisionTable := TfrmDivisionTable.Create(Self);
  frmDivisionTable.FormBtnParentPanel := pnFormButtons;
  frmDivisionTable.ShowFomButton(bsGrid);
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
