unit APIClient;

interface

uses
  SysUtils, Variants, Classes, Dialogs, StdCtrls, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, IdAuthentication, IdHeaderList,
  IdAuthenticationDigest, IdIntercept, IdLogBase, IdLogFile, DigestHeader;

type
  IAPIClient = interface
    procedure ConnectLoger(Logger: TIdLogFile);
    procedure SetHostPort(Host: string; Port: integer);
    procedure SetLoginPassword(Login, Password: string);
    function Get(Url: string; var Response: TStringList): integer;
    function Post(Url, Body: string; var Response: TStringList): integer;
  end;

  THTTPClient = class(TInterfacedObject, IAPIClient)
    private
      FTryCount: byte;
      FHost: string;
      FHTTP: TIdHTTP;
      FLogin: string;
      FPassword: string;
      function Request(Method: TRequestMethod; Url, Body: string;
        var Response: TStringList): integer;
    public
      constructor Create;
      destructor Destroy; override;
      procedure SetHostPort(Host: string; Port: integer);
      procedure ConnectLoger(Logger: TIdLogFile);
      procedure SetLoginPassword(Login, Password: string);
      function Get(Url: string; var Response: TStringList): integer;
      function Post(Url, Body: string; var Response: TStringList): integer;
  end;

  TTCPClient = class(TInterfacedObject, IAPIClient)
    private
      FTryCount: byte;
      FTCP: TIdTCPClient;
      FLogin: string;
      FPassword: string;
      function GetWWWAuthenticate(Response: TStringList): string;
      procedure DeleteHeader(Response: TStringList);
      function Request(Method: TRequestMethod; Url, Body: string;
        var Response: TStringList): integer;
    public
      constructor Create;
      destructor Destroy; override;
      procedure SetHostPort(Host: string; Port: integer);
      procedure ConnectLoger(Logger: TIdLogFile);
      procedure SetLoginPassword(Login, Password: string);
      function Get(Url: string; var Response: TStringList): integer;
      function Post(Url, Body: string; var Response: TStringList): integer;
  end;

implementation

// TIdHTTP client.

constructor THTTPClient.Create;
begin
  inherited Create;
  FTryCount := 3;
  FHTTP := TIdHTTP.Create(nil);
  FHTTP.HandleRedirects := True;
  FHTTP.ConnectTimeout := 1000;
  FHTTP.Request.BasicAuthentication := False;
end;

destructor THTTPClient.Destroy;
begin
  FHTTP.Free;
  inherited Destroy;
end;

procedure THTTPClient.SetHostPort(Host: string; Port: integer);
begin
  FHTTP.Disconnect;
  FHost := 'http://' + Host;
  FHTTP.Port := Port;
end;

procedure THTTPClient.ConnectLoger(Logger: TIdLogFile);
begin
  FHTTP.Intercept := Logger;
end;

procedure THTTPClient.SetLoginPassword(Login, Password: string);
begin
  FLogin := Login;
  FPassword := Password;
end;

function THTTPClient.Request(Method: TRequestMethod; Url, Body: string;
  var Response: TStringList): integer;
var
  TryCount: integer;
  DigestResponse: TDigestResponse;
  RespHeader, Header: string;
  ARequest: TStringList;
begin
  ARequest := TStringList.Create;
  ARequest.Text := Body;
  TryCount := Self.FTryCount;
  Result := -1;
  repeat
    try
      Dec(TryCount);
      FHTTP.Request.ContentType := 'application/json';
      FHTTP.Request.ContentEncoding := 'utf-8';
      FHTTP.Request.Accept := 'application/json';
      if Method = rmGET then Response.Text := FHTTP.Get(FHost + Url)
        else Response.Text := FHTTP.Post(FHost + Url, ARequest);
      Result := FHTTP.ResponseCode;
    except on E: Exception do
      if FHTTP.ResponseCode = 401 then begin
        RespHeader := FHTTP.Response.WWWAuthenticate.Text;
        DigestResponse := TDigestResponse.Create;
        Header := DigestResponse.GetResponseHeader(Method, RespHeader, URL,
          FLogin, FPassword, 1);
        FHTTP.Request.CustomHeaders.Clear;
        FHTTP.Request.CustomHeaders.Add(Header);
        DigestResponse.Free;
      end else begin
        Response.Text := E.Message + chr(13) + Response.Text;
        Break;
      end;
    end;
  until (Result = 200) or (TryCount < 0);
  ARequest.Free;
end;

function THTTPClient.Get(Url: string; var Response: TStringList): integer;
begin
  Result := Self.Request(rmGET, Url, '', Response);
end;

function THTTPClient.Post(Url, Body: string; var Response: TStringList): integer;
begin
  Result := Self.Request(rmPOST, Url, Body, Response);
end;

// TIdTCP client.

constructor TTCPClient.Create;
begin
  inherited Create;
  FTryCount := 3;
  FTCP := TIdTCPClient.Create(nil);
  FTCP.ReadTimeout := 10000;
end;

destructor TTCPClient.Destroy;
begin
  FTCP.Free;
  inherited Destroy;
end;

procedure TTCPClient.SetHostPort(Host: string; Port: integer);
begin
  FTCP.Disconnect;
  FTCP.Host := Host;
  FTCP.Port := Port;
end;

procedure TTCPClient.ConnectLoger(Logger: TIdLogFile);
begin
  FTCP.Intercept := Logger;
end;

procedure TTCPClient.SetLoginPassword(Login, Password: string);
begin
  FLogin := Login;
  FPassword := Password;
end;

function TTCPClient.GetWWWAuthenticate(Response: TStringList): string;
var
  I: integer;
begin
  Result := '';
  for I := 0 to Response.Count - 1 do
    if Pos('WWW-Authenticate', Response[I]) = 1 then Result := Response[I]
end;

procedure TTCPClient.DeleteHeader(Response: TStringList);
begin
  while Length(Response[0]) > 0 do Response.Delete(0);
  if Response.Count > 0 then Response.Delete(0);
end;

function TTCPClient.Request(Method: TRequestMethod; Url, Body: string;
  var Response: TStringList): integer;
var
  TryCount: integer;
  DigestResponse: TDigestResponse;
  Header: string;
begin
  TryCount := Self.FTryCount;
  Result := -1;
  Header := '';
  repeat
    try
      Dec(TryCount);
      FTCP.Connect;
      if Method = rmGET then FTCP.WriteLn('GET ' + Url + ' HTTP/1.1')
        else FTCP.WriteLn('POST ' + Url + ' HTTP/1.1');
      FTCP.WriteLn('Host: ' + FTCP.Host);
      if Method = rmPOST then begin
        FTCP.WriteLn('Content-Length: ' + IntToStr(Length(Body)));
        FTCP.WriteLn('Content-Type: application/json');
      end;
      if Length(Header) > 0 then FTCP.WriteLn(Header);
      FTCP.WriteLn('');
      if Method = rmPOST then FTCP.WriteLn(Body);
      Response.Text := FTCP.AllData;
      if Pos('401 Unauthorized', Response[0]) > 0 then begin
        DigestResponse := TDigestResponse.Create;
        Header := DigestResponse.GetResponseHeader(
          Method,
          Self.GetWWWAuthenticate(Response),
          Url, FLogin, FPassword, 1);
        DigestResponse.Free;
      end;
      if Pos('200', Response[0]) > 0 then begin
        Result := 200;
        Self.DeleteHeader(Response);
        Break;
      end;
      Response.Text := Response[0];
    except on E: Exception do begin
        Response.Text := E.Message;
        Break;
      end;
    end;
  until (Result = 200) or (TryCount < 0);
end;

function TTCPClient.Get(Url: string; var Response: TStringList): integer;
begin
  Result := Self.Request(rmGET, Url, '', Response);
end;

function TTCPClient.Post(Url, Body: string; var Response: TStringList): integer;
begin
  Result := Self.Request(rmPOST, Url, Body, Response);
end;


end.
