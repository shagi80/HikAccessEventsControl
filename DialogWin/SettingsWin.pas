unit SettingsWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TWebButton, ExtCtrls, Mask, StdCtrls;

type
  TfrmSettings = class(TForm)
    Shape1: TShape;
    btnsave: TWebSpeedButton;
    btnCancel: TWebSpeedButton;
    GridPanel1: TGridPanel;
    Label1: TLabel;
    btnUpdatePassword: TWebSpeedButton;
    Label2: TLabel;
    edDBFileName: TEdit;
    btnOpenBDFile: TWebSpeedButton;
    Label3: TLabel;
    pnDev1: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    edDevIP_1: TEdit;
    edDevPort_1: TEdit;
    edDevLogin_1: TEdit;
    edDevPaswrd_1: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    pnDev2: TPanel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    edDevIP_2: TEdit;
    edDevPort_2: TEdit;
    edDevLogin_2: TEdit;
    edDevPaswrd_2: TEdit;
    edPassword: TMaskEdit;
    dlgOpen: TOpenDialog;
    procedure edDevPort_1KeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnsaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOpenBDFileClick(Sender: TObject);
    procedure btnUpdatePasswordClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SetDevControlEnabled;
    procedure LoadDeviceSettings(DBFileName: string);
    procedure SaveDeviceSettings;
  private
    { Private declarations }
    FOldPassword: string;
  public
    { Public declarations }
  end;

var
  frmSettings: TfrmSettings;

implementation

{$R *.dfm}

uses TheSettings, SQLiteTable3;



procedure TfrmSettings.btnCancelClick(Sender: TObject);
begin
  Self.ModalResult := mrCancel;
end;

procedure TfrmSettings.btnOpenBDFileClick(Sender: TObject);
begin
  if dlgOpen.Execute then begin
    Self.edDBFileName.Text := dlgOpen.FileName;
    Self.LoadDeviceSettings(dlgOpen.FileName);
  end;
end;

procedure TfrmSettings.btnsaveClick(Sender: TObject);
begin
  Self.ModalResult := mrOk;
end;

procedure TfrmSettings.btnUpdatePasswordClick(Sender: TObject);
begin
  Settings.GetInstance.CurrentPassword := Self.edPassword.Text;
  SetDevControlEnabled;
end;

procedure TfrmSettings.edDevPort_1KeyPress(Sender: TObject; var Key: Char);
const
  Toolskey = [13, 8, 46, 38..40, 48..57];
begin
  if not(ord(Key) in ToolsKey) then Key := chr(0);
end;

procedure TfrmSettings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Self.ModalResult = mrOk then begin
    Settings.GetInstance.DBFileName := Self.edDBFileName.Text;
    Settings.GetInstance.CurrentPassword := Self.edPassword.Text;
    Settings.GetInstance.SaveSettings;
    if Settings.GetInstance.AccessLevel > 0 then SaveDeviceSettings;
  end else
    Settings.GetInstance.CurrentPassword := Self.FOldPassword;
end;

procedure TfrmSettings.FormShow(Sender: TObject);
begin
  Self.edPassword.Text := Settings.GetInstance.CurrentPassword;
  FOldPassword := Settings.GetInstance.CurrentPassword;
  Self.edDBFileName.Text := Settings.GetInstance.DBFileName;
  LoadDeviceSettings(Settings.GetInstance.DBFileName);
  SetDevControlEnabled;
end;

procedure TfrmSettings.SetDevControlEnabled;
var
  I: integer;
begin
  for I := 0 to pnDev1.ControlCount - 1 do
    pnDev1.Controls[I].Enabled := (Settings.GetInstance.AccessLevel > 0);
  for I := 0 to pnDev2.ControlCount - 1 do
    pnDev2.Controls[I].Enabled := (Settings.GetInstance.AccessLevel > 0);
end;

procedure TfrmSettings.LoadDeviceSettings(DBFileName: string);
var
  DB: TSQLiteDatabase;
  Table: TSQLiteUniTable;
begin
  Self.edDevIP_1.Text := '';
  Self.edDevPort_1.Text := '';
  Self.edDevLogin_1.Text := '';
  Self.edDevPaswrd_1.Text := '';
  Self.edDevIP_2.Text := '';
  Self.edDevPort_2.Text := '';
  Self.edDevLogin_2.Text := '';
  Self.edDevPaswrd_2.Text := '';
  if not FileExists(DBFileName) then Exit;
  DB := TSQLiteDatabase.Create(DBFileName);
  if not DB.TableExists('devices') then Exit;
  Table := DB.GetUniTable('SELECT * FROM devices');
  try
    while not Table.EOF do begin
      if Table.FieldAsInteger(4) = 1 then begin
        Self.edDevIP_1.Text := Table.FieldAsString(2);
        Self.edDevPort_1.Text := Table.FieldAsString(3);
        Self.edDevLogin_1.Text := Table.FieldAsString(5);
        Self.edDevPaswrd_1.Text := Table.FieldAsString(6);
      end else begin
        Self.edDevIP_2.Text := Table.FieldAsString(2);
        Self.edDevPort_2.Text := Table.FieldAsString(3);
        Self.edDevLogin_2.Text := Table.FieldAsString(5);
        Self.edDevPaswrd_2.Text := Table.FieldAsString(6);
      end;
      Table.Next;
    end;
  finally
    Table.Free;
    DB.Free;
  end;
end;

procedure TfrmSettings.SaveDeviceSettings;
var
  DB: TSQLiteDatabase;
  SQL: string;
begin
  if not FileExists(Settings.GetInstance.DBFileName) then Exit;
  DB := TSQLiteDatabase.Create(Settings.GetInstance.DBFileName);
  if not DB.TableExists('devices') then Exit;
  try
    DB.BeginTransaction;
    SQL := 'UPDATE devices SET ip = ?, port = ?, login = ?, password = ? '
      + 'WHERE direction = 1';
    DB.ExecSQL(SQL, [Self.edDevIP_1.Text, Self.edDevPort_1.Text,
        Self.edDevLogin_1.Text, self.edDevPaswrd_1.Text]);
    SQL := 'UPDATE devices SET ip = ?, port = ?, login = ?, password = ? '
      + 'WHERE direction = 2';
    DB.ExecSQL(SQL, [Self.edDevIP_2.Text, Self.edDevPort_2.Text,
        Self.edDevLogin_2.Text, self.edDevPaswrd_2.Text]);
    DB.Commit;
  finally
    DB.Free
  end;
end;

end.
