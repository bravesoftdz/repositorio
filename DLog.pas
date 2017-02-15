unit DLog;

interface

uses
  SysUtils, Classes, Windows, acStrUtils, acSysUtils;

type
  TDataLog = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    logFile: TextFile;
    FbaseDir: string;
    FLogPrefix: string;
    procedure openLogFile;
    procedure SetbaseDir(const Value: string);
    procedure SetLogPrefix(const Value: string);
  public
    paused: boolean;
    property baseDir: string read FbaseDir write SetbaseDir;
    property LogPrefix: string read FLogPrefix write SetLogPrefix;
    function getLogFileName(logDate: TDateTime = -1): string;
    procedure log(mensagem: string; classe: string = ''; newLine: boolean = true);
    procedure step(text: string = '.');
    procedure newLine;
    procedure pause;
    procedure resume;
  end;

var
  DataLog: TDataLog;
  CritSectLog: TRTLCriticalSection;

implementation

{$R *.dfm}

{ TDataLog }

procedure TDataLog.DataModuleCreate(Sender: TObject);
begin
  paused := False;
  FBaseDir := EmptyStr;
  FLogPrefix := EmptyStr;
end;

procedure TDataLog.DataModuleDestroy(Sender: TObject);
begin
  if not Paused then
    Self.pause;
end;


procedure TDataLog.log(mensagem: string; classe: string = ''; newLine: boolean = true);
var
  linha: string;
begin
  if paused then exit;
  if FBaseDir = EmptyStr then
    BaseDir := getWindowsTempPath;

  linha := '[' + FormatDateTime('yyyy-dd-mm hh:nn:ss,zzz', now) + ']';
  if classe <> '' then
    linha := linha + '[' + classe + ']';
  linha := linha + ' ' + mensagem;
  EnterCriticalSection(CritSectLog);
  if newLine then
    Writeln(logFile, linha)
  else
    Write(logFile, linha);
  Flush(logFile);
  LeaveCriticalSection(CritSectLog);
end;

procedure TDataLog.step(text: string = '.');
begin
  Write(logFile, text);
  Flush(logFile);
end;

function TDataLog.getLogFileName(logDate: TDateTime = -1): string;
begin
  if logDate = -1 then
    logDate := date;
  if not(DirectoryExists(baseDir)) then
    CreateDir(baseDir);
  result := baseDir + FLogPrefix + FormatDateTime('yyyy_mm_dd', logDate) + '.log';
end;

procedure TDataLog.pause;
begin
  log('Pausing Log');
  paused := true;
  CloseFile(logFile);
end;

procedure TDataLog.resume;
begin
  openLogFile;
  paused := false;
  log('Resumed Log')
end;

procedure TDataLog.openLogFile;
var
  fn: string;
begin
  fn := getLogFileName;
  AssignFile(logFile, fn);
  if FileExists(fn) then
    Append(logFile)
  else
    Rewrite(logFile);
end;

procedure TDataLog.newLine;
begin
  Writeln(logFile, '.');
  Flush(logFile);
end;

procedure TDataLog.SetbaseDir(const Value: string);
begin
  FbaseDir := EnsureTrailingSlash(Value);
  resume;
end;

procedure TDataLog.SetLogPrefix(const Value: string);
begin
  FLogPrefix := Value;
end;

initialization
  InitializeCriticalSection(CritSectLog);

finalization
  DeleteCriticalSection(CritSectLog);

end.
