unit CHILDWIN;

interface

uses Windows, Classes, Graphics, Forms, Controls, StdCtrls, TheBreaks, TheShift,
  TheSchedule, TheSettings, TheDivisions, ThePersons, ExtCtrls, TWebButton,
  TheHolyday, Dialogs;

type
  TButtonStyle = (bsGrid, bsPrint);

  TMDIChild = class(TForm)
    imrGrid: TImage;
    imgPrint: TImage;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FFormButton: TWebSpeedButton;
    FFormBtnParentPanel: TPanel;
    procedure OnClickFormButton(Sender: TObject);
  protected
    ShiftsList: TShiftList;
    BreaksList: TBreakList;
    SchedulesList: TScheduleList;
    DivisionsList: TDivisionList;
    PersonsList: TPersonList;
    HolydaysList: THolydayList;
    function LoadFromBD: boolean;
  public
    { Public declarations }
    property FormButton: TWebSpeedButton read FFormButton;
    property FormBtnParentPanel: TPanel read FFormBtnParentPanel
      write FFormBtnParentPanel;
    procedure ChangeTitle(Value: string);
    procedure ShowFomButton(BtnStyle: TButtonStyle);
  end;

implementation

{$R *.dfm}


procedure TMDIChild.FormCreate(Sender: TObject);
begin
  ShiftsList := TShiftList.Create(True);
  BreaksList := TBreakList.Create(True);
  SchedulesList := TScheduleList.Create(True);
  DivisionsList := TDivisionList.Create(True);
  PersonsList := TPersonList.Create(True);
  HolydaysList := THolydayList.Create(True);
  FFormButton := TWebSpeedButton.Create(Self);
  FFormButton.Color := cl3DDkShadow;
  FFormButton.Caption := Self.Caption;
  FFormButton.Font.Color := clSilver;
  FFormButton.ActiveColor := clMaroon;
  FFormButton.ActiveFontColor := clWhite;
  FFormButton.SelectColor := cl3DDkShadow;
  FFormButton.SelectFontColor := clWhite;
  FFormButton.GroupIndex := 1;
  FFormButton.Width := 150;
  FFormButton.Height := 33;
  FFormButton.OnClick := Self.OnClickFormButton;
  FFormButton.AlignWithMargins := True;
  FFormButton.Align := alLeft;
  FFormButton.Left := MaxInt;
  FFormButton.SpaceWidth := 8;
end;

procedure TMDIChild.FormActivate(Sender: TObject);
var
  I: integer;
begin
  if Assigned(FFormBtnParentPanel) then
    for I := 0 to FFormBtnParentPanel.ControlCount - 1 do
      TWebSpeedButton(FFormBtnParentPanel.Controls[I]).Down := False;
  OnClickFormButton(Self);
end;

procedure TMDIChild.FormClose(Sender: TObject; var Action: TCloseAction);
var
  I: integer;
  HavePrintForm: boolean;
begin
  HavePrintForm := False;
  for I := 0 to Application.MainForm.MDIChildCount - 1 do
    if Application.MainForm.MDIChildren[I].Owner = Self then begin
      HavePrintForm := True;
      Break;
    end;
  if HavePrintForm then
    if MessageDlg('Внимание !' + chr(13)
      + 'Вместе с отчетом будут закрыты все печатные формы.',
      mtWarning, [mbOk, mbCancel], 0) = mrCancel then begin
        Action := caNone;
        Exit;
      end;
  ShiftsList.Free;
  BreaksList.Free;
  SchedulesList.Free;
  DivisionsList.Free;
  PersonsList.Free;
  FFormButton.Free;
  HolydaysList.Free;
  Action := caFree;
end;

function TMDIChild.LoadFromBD: boolean;
var
  DBFileName: string;
begin
  DBFileName := Settings.GetInstance.DBFileName;
  Result := False;
  if not (BreaksList.LoadFromBD(DBFileName)
    and ShiftsList.LoadFromBD(DBFileName, BreaksList)
    and SchedulesList.LoadFromBD(DBFileName, ShiftsList)
    and DivisionsList.LoadFromBD(DBFileName, SchedulesList)
    and PersonsList.LoadFromBD(DBFileName, DivisionsList, SchedulesList)
    and HolydaysList.LoadFromBD(DBFileName, SchedulesList)) then begin
      MessageDlg('Ошибка соединения с базой данных !', mtError, [mbOk], 0);
      Exit;
    end;
  BreaksList.SortByTitle;
  ShiftsList.SortByTitle;
  SchedulesList.SortByTitle;
  DivisionsList.SortByTitle;
  PersonsList.SortByTitle;
  HolydaysList.SortByDateDesc;
  Result := True;
end;

procedure TMDIChild.OnClickFormButton(Sender: TObject);
begin
  FFormButton.Down := True;
  if Sender is TWebSpeedButton then Self.Show;
end;

procedure TMDIChild.ChangeTitle(Value: string);
begin
  Self.Caption := Value;
  Self.FFormButton.Caption := Self.Caption;
end;

procedure TMDIChild.ShowFomButton(BtnStyle: TButtonStyle);
var
  I: integer;
begin
  if not Assigned(FFormBtnParentPanel) then Exit;
  if Assigned(FFormBtnParentPanel) then
    for I := 0 to FFormBtnParentPanel.ControlCount - 1 do
      TWebSpeedButton(FFormBtnParentPanel.Controls[I]).Down := False;
  FFormButton.Parent := FFormBtnParentPanel;
  FFormBtnParentPanel.Width := (FFormButton.Width + FFormButton.Margins.Left
    + FFormButton.Margins.Right) * FFormBtnParentPanel.ControlCount;
  case BtnStyle of
    bsGrid: FFormButton.Glyph := Self.imrGrid.Picture.Bitmap;
    bsPrint: FFormButton.Glyph := Self.imgPrint.Picture.Bitmap;
  end;
end;

end.
