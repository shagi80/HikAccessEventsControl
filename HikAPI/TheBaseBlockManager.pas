unit TheBaseBlockManager;

interface

uses ExtCtrls;

type
  TBaseBlockManager = class(TObject)
  private
    FDBFileName: string;
    FMaxBlockTime: integer;
    FTimer: TTimer;
    procedure DeleteBlock;
    function GetFilePath: string;
  public
    constructor Create(DBFileName: string; MaxBlockTime: integer = 5);
    destructor Destroy; override;
    procedure SetBlock(Time: TDateTime);
    procedure ContinueBlock(Sender: TObject);
    function CheckBlock(var EndTime: integer): boolean;
  end;

implementation

uses Forms, DateUtils, SysUtils;

constructor TBaseBlockManager.Create(DBFileName: string;
  MaxBlockTime: integer = 5);
begin
  inherited Create;
  FDBFileName := DBFileName;
  FMaxBlockTime := MaxBlockTime;
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := FMaxBlockTime * 60 * 1000 - 10;
  FTimer.OnTimer := Self.ContinueBlock;
end;

destructor TBaseBlockManager.Destroy;
begin
  Self.DeleteBlock;
  FTimer.Free;
  inherited Destroy;
end;

function TBaseBlockManager.GetFilePath: string;
begin
  Result := ExtractFilePath(FDBFileName);
  if Length(Result) = 0 then
    Result := ExtractFilePath(Application.ExeName);
end;

procedure TBaseBlockManager.SetBlock(Time: TDateTime);
var
  FilePath: string;
  BlockFile: file of TDateTime;
begin
  FilePath := GetFilePath;
  AssignFile(BlockFile, FilePath + 'base_block');
  try
    Rewrite(BlockFile);
    Write(BlockFile, Time);
    FTimer.Enabled := True;
  finally
    CloseFile(BlockFile);
  end;
end;

procedure TBaseBlockManager.DeleteBlock;
var
  FilePath: string;
begin
  FilePath := GetFilePath;
  if FileExists(FilePath + 'base_block') then
    SysUtils.DeleteFile(FilePath + 'base_block');
  FTimer.Enabled := False;
end;

procedure TBaseBlockManager.ContinueBlock(Sender: TObject);
begin
  SetBlock(Now);
end;

function TBaseBlockManager.CheckBlock(var EndTime: integer): boolean;
var
  FilePath: string;
  BlockFile: file of TDateTime;
  BlockTime: TDateTime;
  MinutesDiff: integer;
begin
  Result := False;
  EndTime := 0;
  FilePath := GetFilePath;
  if not FileExists(FilePath + 'base_block') then Exit;
  AssignFile(BlockFile, FilePath + 'base_block');
  try
    Reset(BlockFile);
    if not Eof(BlockFile) then
      Read(BlockFile, BlockTime)
    else
      Exit;
  finally
    CloseFile(BlockFile);
  end;
  MinutesDiff := DateUtils.MinutesBetween(BlockTime, now);
  if MinutesDiff < FMaxBlockTime then begin
    Result := True;
    EndTime := FMaxBlockTime - MinutesDiff;
  end else begin
    Self.DeleteBlock;
    Result := False;
  end;
end;

end.
