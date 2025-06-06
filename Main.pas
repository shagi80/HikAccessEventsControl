unit MAIN;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls, StdActns,
  ActnList, ToolWin, ImgList, Grids;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileCloseItem: TMenuItem;
    Window1: TMenuItem;
    Help1: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    WindowCascadeItem: TMenuItem;
    WindowTileItem: TMenuItem;
    WindowArrangeItem: TMenuItem;
    HelpAboutItem: TMenuItem;
    OpenDialog: TOpenDialog;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    Edit1: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    WindowMinimizeItem: TMenuItem;
    StatusBar: TStatusBar;
    ActionList1: TActionList;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    FileNew1: TAction;
    FileSave1: TAction;
    FileExit1: TAction;
    FileOpen1: TAction;
    FileSaveAs1: TAction;
    WindowCascade1: TWindowCascade;
    WindowTileHorizontal1: TWindowTileHorizontal;
    WindowArrangeAll1: TWindowArrange;
    WindowMinimizeAll1: TWindowMinimizeAll;
    HelpAbout1: TAction;
    FileClose1: TWindowClose;
    WindowTileVertical1: TWindowTileVertical;
    WindowTileItem2: TMenuItem;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton9: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ImageList1: TImageList;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit2: TEdit;
    Button4: TButton;
    Button5: TButton;
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{$R res.RES}

uses about, DateUtils, APIProcessWin, TheSettings, TheEventPairs,
  PersonEventsWin, ShiftWin, ScheduleEditWin, TheShift, TheSchedule,
  TheBreaks;


procedure TMainForm.Button1Click(Sender: TObject);
var
  frmProcess: TfrmProcess;
begin
  frmProcess := TfrmProcess.Create(Self);
  frmProcess.ShowModal;
  frmProcess.Free;
end;

procedure TMainForm.Button2Click(Sender: TObject);
var
  frmShift: TfrmShift;
begin
  frmShift := TfrmShift.Create(Self);
end;

procedure TMainForm.Button3Click(Sender: TObject);
var
  frmPervonEvents: TfrmPervonEvents;
begin
  frmPervonEvents := TfrmPervonEvents.Create(Self);
  //frmPervonEvents.Show;
end;

procedure TMainForm.Button4Click(Sender: TObject);
var
  g: tguid;
begin
  CreateGUID(g);
  Edit2.Text := GuidToString(g);
end;

procedure TMainForm.Button5Click(Sender: TObject);
var
  FShiftList: TShiftList;
  FBreakList: TBreakList;
  ScheduleList: TScheduleList;
  Schedule: TSchedule;
begin
  ScheduleList := TScheduleList.Create(True);
  FShiftList := TShiftList.Create(True);
  FBreakList := TBreakList.Create(True);
  FBreakList.LoadFromBD(Settings.GetInstance.DBFileName);
  FShiftList.LoadFromBD(Settings.GetInstance.DBFileName, FBreakList);
  ScheduleList.LoadFromBD(Settings.GetInstance.DBFileName, FShiftList);
  Schedule := ScheduleList.Items[0];
  if frmScheduleEdit.Edit(Schedule, FShiftList) then
    ScheduleList.SaveToBD(Settings.GetInstance.DBFileName);

  ScheduleList.Free;
  FShiftList.Free;
  FBreakList.Free;

end;

end.
