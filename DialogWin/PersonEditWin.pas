unit PersonEditWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, TWebButton, ExtCtrls, TheSchedule, ThePersons,
  TheDivisions;

type
  TfrmPersonEdit = class(TForm)
    Shape1: TShape;
    btnsave: TWebSpeedButton;
    btnCancel: TWebSpeedButton;
    Label1: TLabel;
    edPersonId: TEdit;
    edTitle: TEdit;
    cbSchedule: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    cbDivision: TComboBox;
    procedure btnCancelClick(Sender: TObject);
    procedure btnsaveClick(Sender: TObject);
    procedure UpdateBtnState(Sender: TObject);
  private
    { Private declarations }
    procedure UpdateScheduleListForPerson(ScheduleList: TScheduleList;
      CurSchedule: TSchedule);
    procedure UpdateDivisionListForPerson(DivisionList: TDivisionList;
      CurDivision: TDivision);
  public
    { Public declarations }
    function Edit(var Person: TPerson; DivisionList: TDivisionList;
      ScheduleList: TScheduleList): boolean;
  end;

var
  frmPersonEdit: TfrmPersonEdit;

implementation

{$R *.dfm}

procedure TfrmPersonEdit.UpdateDivisionListForPerson(
  DivisionList: TDivisionList; CurDivision: TDivision);

  procedure AddChildDivision(Level: integer; ParentDivision: TDivision);
  var
    J, I: integer;
    Text: string;
    Division: TDivision;
  begin
    for J := 0 to DivisionList.Count - 1 do begin
      Division := DivisionList[J];
      if Division.ParentDivision = ParentDivision then begin
        Text := Division.Title;
        for I := 0 to Level - 1 do Text := '- ' + Text;
        cbDivision.Items.AddObject(Text, Division);
        AddChildDivision(Level + 1, Division);
      end;
    end;
  end;

var
  I: integer;
  Division: TDivision;
begin
  cbDivision.Clear;
  Division := DivisionList.Items['parent'];
  cbDivision.Items.AddObject(Division.Title, Division);
  AddChildDivision(1, Division);
  cbDivision.ItemIndex := 0;
  for I := 0 to cbDivision.Items.Count - 1 do
    if cbDivision.Items.Objects[I] = CurDivision then begin
      cbDivision.ItemIndex := I;
      Break;
    end;
end;

procedure TfrmPersonEdit.UpdateScheduleListForPerson(
  ScheduleList: TScheduleList; CurSchedule: TSchedule);
var
  I, ItemInd: integer;
  Schedule: TSchedule;
begin
  cbSchedule.Clear;
  cbSchedule.Items.AddObject('по подразделению', nil);
  ItemInd := 0;
  for I := 0 to ScheduleList.Count - 1 do begin
    Schedule := ScheduleList.Items[I];
    cbSchedule.Items.AddObject(Schedule.Title, Schedule);
    if Schedule = CurSchedule then ItemInd := I + 1;
  end;
  cbSchedule.ItemIndex := ItemInd;
end;

procedure TfrmPersonEdit.UpdateBtnState;
begin
  Self.btnSave.Enabled := (Length(edPersonId.Text) > 0)
    and (Length(edTitle.Text) > 0);
end;

procedure TfrmPersonEdit.btnCancelClick(Sender: TObject);
begin
  Self.ModalResult := mrCancel;
end;

procedure TfrmPersonEdit.btnsaveClick(Sender: TObject);
begin
  Self.ModalResult := mrOk;
end;

function TfrmPersonEdit.Edit(var Person: TPerson;
  DivisionList: TDivisionList; ScheduleList: TScheduleList): boolean;
begin
  edPersonId.Text := Person.PersonId;
  edTitle.Text := Person.Name;
  cbSchedule.Enabled := False;
  UpdateDivisionListForPerson(DivisionList, Person.Division);
  UpdateScheduleListForPerson(ScheduleList, Person.Schedule);
  //
  Result := (ShowModal = mrOk);
  if Result then begin
    Person.PersonId := edPersonId.Text;
    Person.Name := edTitle.Text;
    Person.Division := TDivision(cbDivision.Items.Objects[
      cbDivision.ItemIndex]);
    Person.Schedule := TSchedule(cbSchedule.Items.Objects[
      cbSchedule.ItemIndex]);
  end;
end;

end.
