unit TheAPIExecutor;

interface

uses
  Classes {$IFDEF MSWINDOWS} , Windows {$ENDIF}, APIClient, DigestHeader,
  SyncObjs, SysUtils;

type
  TAPIExecutor = class(TThread)
  private
    FHTTPClient: THTTPClient;
    FMethod: TRequestMethod;
    FUrl: string;
    FBody: string;
    FResult: integer;
    FResponse: string;
    FExceptionMessage: string;
    FCriticalSection: TCriticalSection;
    procedure SetName;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
    property HTTPClient: THTTPClient read FHTTPClient write FHTTPClient;
    procedure PrepareRequest(Method: TRequestMethod; Url, Body: string);
    property Result: integer read FResult;
    property Response: string read FResponse;
    property ExceptionMessage: string read FExceptionMessage;
  end;


implementation

{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TAPIExecutor.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{$IFDEF MSWINDOWS}
type
  TThreadNameInfo = record
    FType: LongWord;     // must be 0x1000
    FName: PChar;        // pointer to name (in user address space)
    FThreadID: LongWord; // thread ID (-1 indicates caller thread)
    FFlags: LongWord;    // reserved for future use, must be zero
  end;
{$ENDIF}

{ TAPIExecutor }


constructor TAPIExecutor.Create;
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FCriticalSection := TCriticalSection.Create;
  FHTTPClient := THTTPClient.Create;
end;

destructor TAPIExecutor.Destroy;
begin
  FHTTPClient.Free;
  FCriticalSection.Free;
  inherited;
end;

procedure TAPIExecutor.SetName;
{$IFDEF MSWINDOWS}
var
  ThreadNameInfo: TThreadNameInfo;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  ThreadNameInfo.FType := $1000;
  ThreadNameInfo.FName := 'APIExecutor';
  ThreadNameInfo.FThreadID := $FFFFFFFF;
  ThreadNameInfo.FFlags := 0;

  try
    RaiseException( $406D1388, 0, sizeof(ThreadNameInfo) div sizeof(LongWord), @ThreadNameInfo );
  except
  end;
{$ENDIF}
end;

procedure TAPIExecutor.PrepareRequest(Method: TRequestMethod; Url, Body: string);
begin
  FMethod := Method;
  FUrl := Url;
  FBody := Body;
end;

procedure TAPIExecutor.Execute;
var
  Resp: TStringList;
begin
  SetName;
  FResult := -1;
  Resp := TStringList.Create;
  try
    try
      FCriticalSection.Enter;
      try
        FResult := FHTTPClient.Request(FMethod, FUrl, FBody, Resp);
        FResponse := Resp.Text;
      finally
        FCriticalSection.Leave;
      end;
    except
      on E: Exception do
      begin
        FExceptionMessage := E.Message;
        FResponse := '';
      end;
    end;
  finally
    Resp.Free;
  end;
end;

end.
