unit ProgressWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  TfrmProgress = class(TForm)
    lbText: TLabel;
    pbProgress: TProgressBar;
    tmMain: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Tik(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure TikBegin(Text: string; MaxPos: integer);
    procedure TikEnd(Text: string; SleepTime: integer);
  end;

var
  frmProgress: TfrmProgress;

implementation

{$R *.dfm}

procedure TfrmProgress.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Self.tmMain.Enabled := False;
end;

procedure TfrmProgress.TikBegin(Text: string; MaxPos: integer);
begin
  Self.lbText.Caption := Text;
  Self.pbProgress.Position := 0;
  pbProgress.Max := MaxPOs;
  Self.tmMain.Enabled := True;
  Self.Show;
end;

procedure TfrmProgress.TikEnd(Text: string; SleepTime: integer);
begin
  Self.lbText.Caption := Text;
  Application.ProcessMessages;
  Sleep(SleepTime);
  Self.Close;
end;

procedure TfrmProgress.Tik(Sender: TObject);
begin
  pbProgress.Position := pbProgress.Position + 1;
  if pbProgress.Position >= pbProgress.Max then pbProgress.Position := 0;
  //Application.ProcessMessages;
end;

end.
