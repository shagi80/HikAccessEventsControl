unit DivisionEditWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, TWebButton, ExtCtrls, TheSchedule, TheDivisions;

type
  TfrmDivisionEdit = class(TForm)
    Shape1: TShape;
    btnsave: TWebSpeedButton;
    btnCancel: TWebSpeedButton;
    Label1: TLabel;
    edDivisionId: TEdit;
    edTitle: TEdit;
    edParent: TEdit;
    cbSchedule: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnsaveClick(Sender: TObject);
    procedure UpdateBtnState(Sender: TObject);
  private
    { Private declarations }
    procedure UpdateScheduleListForDivision(ScheduleList: TScheduleList;
      CurSchedule: TSchedule);
  public
    { Public declarations }
    function Edit(var Division: TDivision; ScheduleList: TScheduleList): boolean;
  end;

var
  frmDivisionEdit: TfrmDivisionEdit;

implementation

{$R *.dfm}


procedure TfrmDivisionEdit.UpdateScheduleListForDivision(
  ScheduleList: TScheduleList; CurSchedule: TSchedule);
var
  I, ItemInd: integer;
  Schedule: TSchedule;
begin
  cbSchedule.Clear;
  cbSchedule.Items.AddObject('не задан', nil);
  ItemInd := 0;
  for I := 0 to ScheduleList.Count - 1 do begin
    Schedule := ScheduleList.Items[I];
    cbSchedule.Items.AddObject(Schedule.Title, Schedule);
    if Schedule = CurSchedule then ItemInd := I + 1;
  end;
  cbSchedule.ItemIndex := ItemInd;
end;

procedure TfrmDivisionEdit.UpdateBtnState;
begin
  Self.btnSave.Enabled := (Length(edDivisionId.Text) > 0)
    and (Length(edTitle.Text) > 0);
end;

procedure TfrmDivisionEdit.btnCancelClick(Sender: TObject);
begin
  Self.ModalResult := mrCancel;
end;

procedure TfrmDivisionEdit.btnsaveClick(Sender: TObject);
begin
  Self.ModalResult := mrOk;
end;

function TfrmDivisionEdit.Edit(var Division: TDivision;
  ScheduleList: TScheduleList): boolean;
begin
  edDivisionId.Text := Division.DivisionId;
  edTitle.Text := Division.Title;
  edDivisionId.Enabled := (Division.ParentDivision <> nil);
  if Assigned(Division.ParentDivision) then
    edParent.Text := Division.ParentDivision.Title
      else edParent.Text := 'не установлено';
  UpdateScheduleListForDivision(ScheduleList, Division.Schedule);
  //
  Result := (ShowModal = mrOk);
  if Result then begin
    Division.DivisionId := edDivisionId.Text;
    Division.Title := edTitle.Text;
    Division.Schedule := TSchedule(cbSchedule.Items.Objects[
      cbSchedule.ItemIndex]);
  end;
end;

end.
