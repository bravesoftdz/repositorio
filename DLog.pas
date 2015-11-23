unit DLog;

interface

uses
  SysUtils, Classes, Windows, acStrUtils, acSysUtils, forms;

type
  TDataLog = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    logFile: TextFile;
    FbaseDir: string;
    procedure openLogFile;
    procedure SetbaseDir(const Value: string);
  public
    paused: boolean;
    property baseDir: string read FbaseDir write SetbaseDir;
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

procedure TDataLog.log(mensagem: string; classe: string = ''; newLine: boolean = true);
var
  linha: string;
begin
  if paused then exit;
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
    logDate := now;
  if not(DirectoryExists(baseDir)) then
    CreateDir(baseDir);
  result := baseDir + FormatDateTime('yyyy_mm_dd_hh_mm_ss', logDate) + '.log';
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

procedure TDataLog.DataModuleCreate(Sender: TObject);
begin
  baseDir := ExtractFileDir(Application.ExeName); //getWindowsTempPath;
//  paused := true;
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

initialization
  InitializeCriticalSection(CritSectLog);

finalization
  DeleteCriticalSection(CritSectLog);

end.
