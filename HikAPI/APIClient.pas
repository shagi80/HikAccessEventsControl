unit APIClient;

interface

uses
  SysUtils, Variants, Classes, Dialogs, StdCtrls, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, IdAuthentication, IdHeaderList,
  IdAuthenticationDigest, IdIntercept, IdLogBase, IdLogFile, DigestHeader;

type
  THTTPClient = class(TObject)
    private
      FTryCount: byte;
      FHost: string;
      FHTTP: TIdHTTP;
      FLogin: string;
      FPassword: string;
    public
      constructor Create;
      destructor Destroy; override;
      property IdHTTP: TIdHTTP read FHTTP;
      procedure SetHostPort(Host: string; Port: integer);
      procedure ConnectLoger(Logger: TIdLogFile);
      procedure SetLoginPassword(Login, Password: string);
      function Request(Method: TRequestMethod; Url, Body: string;
        var Response: TStringList): integer;
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


end.
