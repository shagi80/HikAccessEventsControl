unit MAIN;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls, StdActns,
  ActnList, ToolWin, ImgList;

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
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FileNew1Execute(Sender: TObject);
    procedure FileOpen1Execute(Sender: TObject);
    procedure HelpAbout1Execute(Sender: TObject);
    procedure FileExit1Execute(Sender: TObject);
  private
    { Private declarations }
    procedure CreateMDIChild(const Name: string);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{$R res.RES}

uses CHILDWIN, about, Json, TheEventsLoader, APIClient;



function RemoveControlChars(const S: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
    if (s[i] in [#32..#126]) then
    //if Ord(S[i]) >= 32 then
      Result := Result + S[i];
end;



procedure TMainForm.Button1Click(Sender: TObject);
var
  Loader: TEventsLoader;
  Minors: TMinorEvents;
  EventCount: integer;
begin
  Loader := TEventsLoader.Create;
  Loader.AddMinorEvent(75);
 { ShowMessage('Loader created:' + chr(13)
    + 'device: ' + Loader.Device[0].Name + chr(13)
    + 'event: ' + IntToStr(Loader.MinorEvent[0]));    }
  //ShowMessage(DateTimeToStr(Loader.GetDeviceTime(0)));
 Loader.UseThread := True;

  if Loader.CheckConnection(0) then begin
    ShowMessage('Device on line 2 !');
    SetLength(Minors, 2);
    Minors[0] := 75;
    Minors[1] := 1;
    EventCount := Loader.GetEventsCount(0, 75, Loader.LastTimeInDB, now);
    ShowMessage(IntToStr(EventCount));
  end else ShowMessage('Not connect');


  
end;

procedure TMainForm.Button3Click(Sender: TObject);
var
  Strs: TStringList;
  JsonStr: AnsiString;
  JsonRoot: TJsonArray;
  AcsEvent, InfoList, InfoItem: TJsonBase;

  I: Integer;
  str: string;
begin
  //jsonStr := '{"test":"value"}';
  Strs := TStringList.Create;
  Strs.LoadFromFile('2.txt');
  JsonStr := RemoveControlChars(UTF8Decode(Strs.Text));
  try
    JsonRoot := JSON.ParseJSON(PAnsiChar(JsonStr));
    AcsEvent := JsonRoot.Field['AcsEvent'];
    InfoList := AcsEvent.Field['InfoList'];

    str := 'Values';
    for I := 0 to InfoList.Count - 1 do begin
      InfoItem := InfoList.Child[I];
      str := str + chr(13) + IntToStr(I + 1) + ' - minor: '
        + IntToStr(InfoItem.Field['minor'].Value);
      if InfoItem.Field['employeeNoString'] <> nil then
        str := str + ' - ' + InfoItem.Field['employeeNoString'].Value;
    end;
    ShowMessage(str);
  except
    on E: Exception do
      ShowMessage('Ошибка: ' + E.Message);
  end;
end;


procedure TMainForm.CreateMDIChild(const Name: string);
var
  Child: TMDIChild;
begin
  { create a new MDI child window }
  Child := TMDIChild.Create(Application);
  Child.Caption := Name;
  if FileExists(Name) then Child.Memo1.Lines.LoadFromFile(Name);
end;

procedure TMainForm.FileNew1Execute(Sender: TObject);
begin
  CreateMDIChild('NONAME' + IntToStr(MDIChildCount + 1));
end;

procedure TMainForm.FileOpen1Execute(Sender: TObject);
begin
  if OpenDialog.Execute then
    CreateMDIChild(OpenDialog.FileName);
end;

procedure TMainForm.HelpAbout1Execute(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TMainForm.FileExit1Execute(Sender: TObject);
begin
  Close;
end;

end.
