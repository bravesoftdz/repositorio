unit acNetUtils;

interface

uses idHTTP, SysUtils, System.Classes, IdSSL, IdIOHandler;

function getRemoteXmlContent(pUrl: string; http: TIdHTTP = nil): String; overload
function getRemoteXmlContent(const pUrl: string; http: TIdHTTP; var erro: string; aRetornoStream: TStringStream): boolean; overload
function getHTTPInstance: TidHTTP;
procedure downloadFile(url, filename: string);

implementation

function getHTTPInstance: TidHTTP;
var
  http: TIdHTTP;
begin
  http := TIdHTTP.Create(nil);
  http.HandleRedirects := True;
  http.ProtocolVersion := pv1_1;
  http.HTTPOptions := http.HTTPOptions + [hoKeepOrigProtocol];
  http.Request.Connection := 'keep-alive';
  result := http;
end;

function getRemoteXmlContent(pUrl: string; http: TIdHTTP = nil): String;
var
  criouHTTP: boolean;
begin
  criouHttp := false;
  if http = nil then
  begin
    criouHTTP := true;
    http := getHTTPINstance;
  end;

  try
    try
      result := http.Get(pUrl);
    except
      result := '';
    end;
  finally
    if criouHTTP and (http <> nil) then
      FreeAndNil(http);
  end;
end;

function getRemoteXmlContent(const pUrl: string; http: TIdHTTP; var erro: string; aRetornoStream: TStringStream): boolean;
var
  criouHTTP: boolean;
begin
  criouHTTP := False;

  erro := EmptyStr;
  try
    if http = nil then
    begin
      criouHTTP := true;
      http := getHTTPINstance;
    end;

    try
      http.ConnectTimeout := 30000;
      http.ReadTimeOut := 30000;
      http.Get(pUrl, aRetornoStream);
    except
      on E: EIdHTTPProtocolException do
        erro := E.ErrorMessage;
    end;

    Result := erro.IsEmpty;
  finally
    if criouHTTP and (http <> nil) then
      FreeAndNil(http);
  end;
end;


procedure downloadFile(url, filename: string);

var

  http: TIdHTTP;

  ms: TMemoryStream;

begin

  http := getHTTPInstance;
  ms := TMemoryStream.Create;
  try
    http.Get(url, ms);
    ms.SaveToFile(filename);
  finally
    FreeAndNil(http);
  end;
end;


end.
