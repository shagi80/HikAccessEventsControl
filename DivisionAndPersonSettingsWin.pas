unit DivisionAndPersonSettingsWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CHILDWIN, ComCtrls, TWebButton, ExtCtrls, StdCtrls, TheSchedule,
  MonthSchedulePresent, Grids, TheDivisions,  ThePersons;

type
  TfrmDivisionAndPersonSettings = class(TMDIChild)
    Panel1: TPanel;
    btnDivision: TWebSpeedButton;
    btnPerson: TWebSpeedButton;
    pnMain: TPanel;
    pnButtons: TPanel;
    btnUpdate: TWebSpeedButton;
    btnSave: TWebSpeedButton;
    btnDelete: TWebSpeedButton;
    btnEdit: TWebSpeedButton;
    btnAdd: TWebSpeedButton;
    pcPages: TPageControl;
    tabDivision: TTabSheet;
    pnSchedule: TPanel;
    pnScheduleCB: TPanel;
    btnIncMonth: TWebSpeedButton;
    lbMonth: TLabel;
    btnDecMonth: TWebSpeedButton;
    lbSchedule: TLabel;
    sbSchedule: TScrollBox;
    tabPerson: TTabSheet;
    Splitter1: TSplitter;
    tvDivision: TTreeView;
    pnPersonDivisionCaption: TPanel;
    btnPastePersonFromClipborad: TWebSpeedButton;
    lbPersonDivision: TLabel;
    sgPerson: TStringGrid;
    procedure sgPersonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnPastePersonFromClipboradClick(Sender: TObject);
    procedure btnDecMonthClick(Sender: TObject);
    procedure btnIncMonthClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure tvDivisionChange(Sender: TObject; Node: TTreeNode);
    procedure btnEditClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure tvDivisionDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure tvDivisionDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure SelectPageBtnClick(Sender: TObject);
    procedure ResizePersonGrid(Sender: TObject);
  private
    { Private declarations }
    FModified: boolean;
    FCurrentMonth: TDate;
    FSchedulePresent: TMonthSchedulePresent;
    procedure UpdateBtnsState(Sender: TObject);
    procedure SetModified(Value: boolean);
    procedure UpdateDivisionPage(Sender: TObject);
    procedure UpdateDivisionsTV(TreeView: TTreeView);
    function AddDivision: boolean;
    function EditDivision: boolean;
    function DeleteDivision: boolean;
    procedure UpdateMonthLabel;
    procedure ChangeSchedule(Value: TSchedule);
    procedure UpdatePersonPage(Sender: TObject);
    procedure UpdatePersonList(Value: TDivision);
    function AddPerson: boolean;
    function EditPerson: boolean;
    function DeletePerson: boolean;
  public
    { Public declarations }
  end;


implementation

{$R *.dfm}

uses DivisionEditWin, TheSettings, DateUtils, Clipbrd, PersonEditWin;


procedure TfrmDivisionAndPersonSettings.FormCreate(Sender: TObject);
begin
  inherited;
  Self.LoadFromBD;
  FSchedulePresent := TMonthSchedulePresent.Create(Self.sbSchedule);
  FSchedulePresent.Parent := Self.sbSchedule;
  FSchedulePresent.Align := alNone;
  FSchedulePresent.Top := 0;
  FSchedulePresent.Left := 0;
  ChangeSchedule(nil);
  pcPages.ActivePageIndex := 0;
  sgPerson.Cells[0, 0] := '  Код';
  sgPerson.Cells[1, 0] := '  Сотрудник';
  sgPerson.Cells[2, 0] := '  График';
  SelectPageBtnClick(Self.btnDivision);
end;

procedure TfrmDivisionAndPersonSettings.btnAddClick(Sender: TObject);
var
  Update: boolean;
begin
  Update := False;
  case pcPages.ActivePageIndex of
    0: Update := AddDivision;
    1: Update := AddPerson;
  end;
  if Update then begin
    UpdateBtnsState(Self);
    SetModified(True);
  end;
end;

procedure TfrmDivisionAndPersonSettings.btnDeleteClick(Sender: TObject);
var
  Update: boolean;
begin
  Update := False;
  case pcPages.ActivePageIndex of
    0: Update := DeleteDivision;
    1: Update := DeletePerson;
  end;
  if Update then begin
    UpdateBtnsState(Self);
    SetModified(True);
  end;
end;

procedure TfrmDivisionAndPersonSettings.btnEditClick(Sender: TObject);
var
  Update: boolean;
begin
  Update := False;
  case pcPages.ActivePageIndex of
    0: Update := EditDivision;
    1: Update := EditPerson;
  end;
  if Update then begin
    UpdateBtnsState(Self);
    SetModified(True);
  end;
end;

procedure TfrmDivisionAndPersonSettings.btnSaveClick(Sender: TObject);
begin
  case pcPages.ActivePageIndex of
    0: DivisionsList.SaveToBD(Settings.GetInstance.DBFileName);
    1: PersonsList.SaveToBD(Settings.GetInstance.DBFileName);
  end;
  Self.SetModified(False);
end;

procedure TfrmDivisionAndPersonSettings.btnUpdateClick(Sender: TObject);
begin
  Self.LoadFromBD;
  case pcPages.ActivePageIndex of
    0: Self.UpdateDivisionPage(Self);
    1: Self.UpdatePersonPage(Self);
  end;
  Self.SetModified(False);
end;

procedure TfrmDivisionAndPersonSettings.SelectPageBtnClick(Sender: TObject);
begin
  if False{not CanChange(TWebSpeedButton(Sender).Tag)} then begin
    case pcPages.ActivePageIndex of
      0: btnDivision.Down := True;
      1: btnPerson.Down := True;
    end;
    Exit;
  end;
  TWebSpeedButton(Sender).Down := True;
  pcPages.ActivePageIndex := TWebSpeedButton(Sender).Tag - 1;
  Self.UpdateDivisionsTV(Self.tvDivision);
  tvDivision.Selected := tvDivision.Items[0];
  case pcPages.ActivePageIndex of
    0: Self.UpdateDivisionPage(Self);
    1: Self.UpdatePersonPage(Self);
  end;
  Self.UpdateBtnsState(Self);
  Self.SetModified(False);
end;

procedure TfrmDivisionAndPersonSettings.UpdateBtnsState(Sender: TObject);
var
  Row: integer;
begin
  case pcPages.ActivePageIndex of
    0: begin
        btnAdd.Enabled := Assigned(tvDivision.Selected);
        btnEdit.Enabled := Assigned(tvDivision.Selected);
        btnDelete.Enabled := Assigned(tvDivision.Selected)
          and (tvDivision.Selected.Parent <> nil)
          and (not tvDivision.Selected.HasChildren);
      end;
    1: begin
        Row := sgPerson.Selection.Top;
        btnAdd.Enabled := Assigned(tvDivision.Selected);
        btnEdit.Enabled := (Row > 0) and (Assigned(sgPerson.Objects[0, Row]));
        btnDelete.Enabled := (Row > 0) and (Assigned(sgPerson.Objects[0, Row]));
        btnPastePersonFromClipborad.Enabled := Length(Clipboard.AsText) > 0;
      end;
  end;
end;

procedure TfrmDivisionAndPersonSettings.SetModified(Value: boolean);
begin
  Self.FModified := Value;
  btnSave.Enabled := FModified;
  btnUpdate.Enabled := FModified;
end;

procedure TfrmDivisionAndPersonSettings.UpdateDivisionsTV(TreeView: TTreeView);

  procedure AddChildDivision(ParentNode: TTreeNode; ParentDivision: TDivision);
  var
    J: integer;
    Node: TTreeNode;
    Division: TDivision;
  begin
    for J := 0 to DivisionsList.Count - 1 do begin
      Division := DivisionsList[J];
      if Division.ParentDivision = ParentDivision then begin
        Node := TreeView.Items.AddChild(ParentNode, Division.Title);
        Node.Data := Division;
        AddChildDivision(Node, Division);
      end;
    end;
  end;

var
  Division: TDivision;
  Node: TTreeNode;
begin
  TreeView.Items.BeginUpdate;
  try
    TreeView.Items.Clear;
    Division := DivisionsList.Items['parent'];
    Node := TreeView.Items.AddObject(nil, Division.Title, Division);
    AddChildDivision(Node, Division);
    TreeView.Items.Item[0].Expand(True);
  finally
    TreeView.Items.EndUpdate;
  end;
end;

procedure TfrmDivisionAndPersonSettings.tvDivisionChange(Sender: TObject;
  Node: TTreeNode);
begin
  UpdateBtnsState(Self);
  case Self.pcPages.ActivePageIndex of
    0: ChangeSchedule(TDivision(Node.Data).Schedule);
    1: Self.UpdatePersonList(TDivision(Node.Data));
  end;
end;

{ Division page }

procedure TfrmDivisionAndPersonSettings.UpdateDivisionPage(Sender: TObject);
begin
  FCurrentMonth := DateUtils.StartOfTheMonth(now);
  UpdateMonthLabel;
end;

function TfrmDivisionAndPersonSettings.AddDivision: boolean;
var
  Division: TDivision;
  ParentNode, Node: TTreeNode;
begin
  tvDivision.EndDrag(False);
  Result := False;
  ParentNode := tvDivision.Selected;
  if not Assigned(ParentNode) then Exit;
  Division := TDivision.Create;
  Division.ParentDivision := TDivision(ParentNode.Data);
  if frmDivisionEdit.Edit(Division, SchedulesList) then begin
    DivisionsList.Add(Division);
    Node := tvDivision.Items.AddChild(ParentNode, Division.Title);
    Node.Data := Division;
    ParentNode.Expand(False);
    tvDivision.Selected := Node;
    ChangeSchedule(Division.Schedule);
    Result := True;
  end else Division.Free;
end;

function TfrmDivisionAndPersonSettings.EditDivision: boolean;
var
  Node: TTreeNode;
  Division: TDivision;
begin
  tvDivision.EndDrag(False);
  Result := False;
  Node := tvDivision.Selected;
  if not Assigned(Node) then Exit;
  Division := TDivision(Node.Data);
  if frmDivisionEdit.Edit(Division, SchedulesList) then begin
    Node.Text := Division.Title;
    ChangeSchedule(Division.Schedule);
    Result := True;
  end;
end;

function TfrmDivisionAndPersonSettings.DeleteDivision: boolean;
var
  Text: string;
  Node: TTreeNode;
  Division: TDivision;
begin
  Result := False;
  Node := tvDivision.Selected;
  if not Assigned(Node) then Exit;
  Division := TDivision(Node.Data);
  Text := Format('Вы действительно хотите удалить подразделение "%s"?',
    [Division.Title]);
  if MessageDlg(Text, mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
    DivisionsList.Extract(Division);
    tvDivision.Items.Delete(Node);
    Result := True;
  end;
end;

procedure TfrmDivisionAndPersonSettings.ChangeSchedule(Value: TSchedule);
var
  Text: string;
begin
  pnScheduleCB.Enabled := (Value <> nil);
  Self.sbSchedule.Visible := pnScheduleCB.Enabled;
  FSchedulePresent.Schedule := Value;
  if pnScheduleCB.Enabled then Text := 'График "' + Value.Title + '"'
    else Text := 'График не задан';
  lbSchedule.Caption := Text;
end;

procedure TfrmDivisionAndPersonSettings.UpdateMonthLabel;
begin
  lbMonth.Caption := FormatDateTime('mmmm YYYY', Self.FCurrentMonth);
  FSchedulePresent.Month := Self.FCurrentMonth;
end;

procedure TfrmDivisionAndPersonSettings.btnIncMonthClick(Sender: TObject);
begin
  FCurrentMonth := StartOfTheMonth(IncDay(EndOfTheMonth(FCurrentMonth), 1));
  UpdateMonthLabel;
end;

procedure TfrmDivisionAndPersonSettings.btnDecMonthClick(Sender: TObject);
begin
  FCurrentMonth := StartOfTheMonth(IncDay(FCurrentMonth, -1));
  UpdateMonthLabel;
end;

{ Person page }

procedure TfrmDivisionAndPersonSettings.UpdatePersonPage(Sender: TObject);
begin
  UpdatePersonList(TDivision(tvDivision.Items.Item[0].Data));
end;

procedure TfrmDivisionAndPersonSettings.UpdatePersonList(Value: TDivision);
var
  I, RowCount: integer;
  Person: TPerson;
begin
  Self.lbPersonDivision.Caption := Value.Title;
  for I := 1 to sgPerson.RowCount - 1 do sgPerson.Rows[I].Clear;
  sgPerson.RowCount := PersonsList.Count + 2;
  sgPerson.Enabled := False;
  RowCount := 0;
  for I := 0 to Self.PersonsList.Count - 1 do begin
    Person := PersonsList.Items[I];
    if Person.Division = Value then begin
      Inc(RowCount);
      sgPerson.Cells[0, RowCount] := Person.PersonId;
      sgPerson.Cells[1, RowCount] := Person.Name;
      if Assigned(Person.Schedule) then
        sgPerson.Cells[2, RowCount] := Person.Schedule.Title
      else
        if Assigned(Value.Schedule) then
          sgPerson.Cells[2, RowCount] := Value.Schedule.Title
        else
          sgPerson.Cells[2, RowCount] := 'не задан';
      sgPerson.Objects[0, RowCount] := Person;
    end;
  end;
  sgPerson.Enabled := (RowCount > 0);
  if RowCount = 0 then sgPerson.RowCount := 2
    else sgPerson.RowCount := RowCount + 1;
  sgPerson.Row := 1;
  ResizePersonGrid(Self);
  Self.UpdateBtnsState(Self);
end;

procedure TfrmDivisionAndPersonSettings.ResizePersonGrid(Sender: TObject);
begin
  if pcPages.ActivePageIndex = 0 then Exit;
  sgPerson.ColWidths[0] := Trunc(sgPerson.Width * 0.2);
  sgPerson.ColWidths[2] := Trunc(sgPerson.Width * 0.4);
  sgPerson.ColWidths[1] := sgPerson.Width - sgPerson.ColWidths[0]
    - sgPerson.ColWidths[2] - 25;
end;

function TfrmDivisionAndPersonSettings.AddPerson: boolean;
var
  Person: TPerson;
  Node: TTreeNode;
begin
  Result := False;
  Node := tvDivision.Selected;
  if not Assigned(Node) then Exit;
  Person := TPerson.Create;
  Person.Division := TDivision(Node.Data);
  if frmPersonEdit.Edit(Person, DivisionsList, SchedulesList) then begin
    PersonsList.Add(Person);
    Self.UpdatePersonList(Person.Division);
    Result := True;
  end else Person.Free;
end;

function TfrmDivisionAndPersonSettings.EditPerson: boolean;
var
  Person: TPerson;
  Row: integer;
begin
  Result := False;
  Row := sgPerson.Selection.Top;
  if (Row < 1) or (not Assigned(sgPerson.Objects[0, Row])) then Exit;
  Person := TPerson(sgPerson.Objects[0, Row]);
  if frmPersonEdit.Edit(Person, DivisionsList, SchedulesList) then begin
    Self.UpdatePersonList(Person.Division);
    Result := True;
  end;
end;

function TfrmDivisionAndPersonSettings.DeletePerson: boolean;
var
  Text: string;
  Person: TPerson;
  Row: integer;
begin
  Result := False;
  Row := sgPerson.Selection.Top;
  if (Row < 1) or (not Assigned(sgPerson.Objects[0, Row])) then Exit;
  Person := TPerson(sgPerson.Objects[0, Row]);
  Text := Format('Вы действительно хотите удалить сотрудника "%s"?',
    [Person.Name]);
  if MessageDlg(Text, mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
    PersonsList.Extract(Person);
    Self.UpdatePersonList(Person.Division);
    Result := True;
  end;
end;

procedure TfrmDivisionAndPersonSettings.btnPastePersonFromClipboradClick(
  Sender: TObject);
var
  Strings: TStringList;
  I: integer;
  Str: string;
  Division: TDivision;
  Person: TPerson;
begin
  Strings := TStringList.Create;
  Strings.Text := Clipbrd.Clipboard.AsText;
  Division := TDivision(tvDivision.Selected.Data);
  if (Length(Strings.Text) = 0) or (not Assigned(Division)) then Exit;
  for I := 0 to Strings.Count - 1 do begin
    Person := TPerson.Create;
    try
      Str := Strings[I];
      Person.PersonId := Copy(Str, 1, Pos(chr(9), Str) - 1);
      if Length(Person.PersonId) = 0 then
       raise Exception.Create('Не задан PersonId');
      Str := Copy(Str, Pos(chr(9), Str) + 1, MaxInt);
      if Pos(chr(9), Str) <= 0 then Person.Name := Str
        else Person.Name := Copy(Str, 1, Pos(chr(9), Str) - 1);
      Person.Division := Division;
      Person.Schedule := nil;
      PersonsList.Add(Person);
      Self.SetModified(True);
    except
      Person.Free;
    end;
  end;
  PersonsList.SortByTitle;
  Self.UpdatePersonList(Division);
  Strings.Free;
end;

{ DragDrop }

procedure TfrmDivisionAndPersonSettings.sgPersonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not (ssDouble in Shift) then sgPerson.BeginDrag(True);
end;

procedure TfrmDivisionAndPersonSettings.tvDivisionDragDrop(Sender,
  Source: TObject; X, Y: Integer);
var
  DestNode: TTreeNode;
  Row: integer;
  OldDivision: TDivision;
begin
  DestNode := tvDivision.GetNodeAt(X, Y);
  Row := sgPerson.Selection.Top;
  if (not (Source = sgPerson)) or (DestNode = nil) or (Row < 1)
    or (not Assigned(sgPerson.Objects[0, Row])) then Exit;
  OldDivision := TPerson(sgPerson.Objects[0, Row]).Division;
  TPerson(sgPerson.Objects[0, Row]).Division := TDivision(DestNode.Data);
  Self.UpdatePersonList(OldDivision);
  Self.UpdateBtnsState(Self);
  Self.SetModified(True);
end;

procedure TfrmDivisionAndPersonSettings.tvDivisionDragOver(Sender,
  Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  Node: TTreeNode;
  Row: integer;
begin
  Row := sgPerson.Selection.Top;
  Node := tvDivision.GetNodeAt(X, Y);
  Accept := (Source = sgPerson) and (Node <> nil)
    and (Row > 0) or (Assigned(sgPerson.Objects[0, Row]));
end;

end.
