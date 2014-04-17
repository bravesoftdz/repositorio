{
  * Nesta vers�o funciona apenas localizando o INI no diret�rio especificado na cria��o
  *

  TODO: suportar 64bits com detec��o auto
}
unit BemaFIIniFileUnit;

interface

uses
  System.IniFiles, System.Classes, System.SysUtils, System.Win.Registry,
    Dialogs, Winapi.Windows;

type

TBemaFIIniFile = class
  constructor create(rootPath: string);
  private
    FIniFileName: string;
    function getPath: string;
    procedure setPath(const Value: string);
    procedure setIniFileName(const Value: string);
    function getPorta: string;
    procedure setPorta(const Value: string);
    function getCalculoICMSCupom: string;
    function getConfigRede: string;
    function getControlePorta: string;
    function getCrLfGerencial: string;
    function getCrLfVinculado: string;
    function getEmulMFD: string;
    function getForceWTSClient: string;
    function getGerarRFD: string;
    function getHabilitaRFDImpMFD: string;
    function getLog: string;
    function getLogDiario: string;
    function getModeloImp: string;
    function getModoGaveta: string;
    function getRetorno: string;
    function getRetriesWTSCmd: string;
    function getStatus: string;
    function getStatusCheque: string;
    function getStatusFuncao: string;
    function getTimeoutGerencial: string;
    procedure setCalculoICMSCupom(const Value: string);
    procedure setConfigRede(const Value: string);
    procedure setControlePorta(const Value: string);
    procedure setCrLfGerencial(const Value: string);
    procedure setCrLfVinculado(const Value: string);
    procedure setEmulMFD(const Value: string);
    procedure setForceWTSClient(const Value: string);
    procedure setGerarRFD(const Value: string);
    procedure setHabilitaRFDImpMFD(const Value: string);
    procedure setLog(const Value: string);
    procedure setLogDiario(const Value: string);
    procedure setModeloImp(const Value: string);
    procedure setModoGaveta(const Value: string);
    procedure setRetorno(const Value: string);
    procedure setRetriesWTSCmd(const Value: string);
    procedure setStatus(const Value: string);
    procedure setStatusCheque(const Value: string);
    procedure setStatusFuncao(const Value: string);
    procedure setTimeoutGerencial(const Value: string);
  public
    procedure localizarImpressora;
    function testarConfig: boolean;
    property iniFileName: string read FIniFileName write setIniFileName;
    property porta: string read getPorta write setPorta;
    property path: string read getPath write setPath;
    property Status: string read getStatus write setStatus;
    property Retorno: string read getRetorno write setRetorno;
    property StatusFuncao: string read getStatusFuncao write setStatusFuncao;
    property ControlePorta: string read getControlePorta write setControlePorta;
    property ModeloImp: string read getModeloImp write setModeloImp;
    property ConfigRede: string read getConfigRede write setConfigRede;
    property ModoGaveta: string read getModoGaveta write setModoGaveta;
    property Log: string read getLog write setLog;
    property LogDiario: string read getLogDiario write setLogDiario;
    property CrLfVinculado: string read getCrLfVinculado write setCrLfVinculado;
    property CrLfGerencial: string read getCrLfGerencial write setCrLfGerencial;
    property TimeOutGerencial: string read getTimeoutGerencial write setTimeoutGerencial;
    property EmulMFD: string read getEmulMFD write setEmulMFD;
    property StatusCheque: string read getStatusCheque write setStatusCheque;
    property CalculoIcmsCupom: string read getCalculoICMSCupom write setCalculoICMSCupom;
    property ForceWTSClient: string read getForceWTSClient write setForceWTSClient;
    property RetriesWTSCmd: string read getRetriesWTSCmd write setRetriesWTSCmd;
    property HabilitaRFDImpMFD: string read getHabilitaRFDImpMFD write setHabilitaRFDImpMFD;
    property GerarRFD: string read getGerarRFD write setGerarRFD;
  protected
    ini: TIniFile;
    procedure readProperties;
    function readProperty(section, name, default: string): string;
    procedure writeProperty(section, name, value: string);
end;

implementation

uses Bematech;

constructor TBemaFIIniFile.create(rootPath: string);
begin
  iniFileName := IncludeTrailingPathDelimiter(rootPath) + 'bemafi32.ini';
  readProperties;
end;

function TBemaFIIniFile.testarConfig: boolean;
begin
  loadAllBematechFunctions;
  result := Bematech_FI_AbrePortaSerial = 1;
  if result then
    ShowMessage('Impressora localizada na porta: ' + porta)
  else
    ShowMessage('N�O est� na porta: ' + porta);
  unloadBematechFunctions;
end;

procedure TBemaFIIniFile.writeProperty(section, name, value: string);
begin
  ini.WriteString(section, name, Value)
end;

procedure TBemaFIIniFile.localizarImpressora;
var
  i: integer;
  coms: TStrings;
begin
  porta := 'USB';
  if testarConfig then exit;
  for i := 0 to coms.count-1 do
  begin
    porta := 'COM' + IntToStr(i);
    if testarConfig then exit;
  end;
end;

function getListaCOMs: TStrings;
var
  reg: TRegistry;
  st: Tstrings;
  i: Integer;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    reg.OpenKey('hardware\devicemap\serialcomm', False);
    st := TstringList.Create;
    reg.GetValueNames(st);
    reg.CloseKey;
  finally
    reg.Free;
  end;
end;

procedure TBemaFIIniFile.readProperties;
begin
  getPorta;
  getPath;
  getCalculoICMSCupom;
  getConfigRede;
  getControlePorta;
  getCrLfGerencial;
  getCrLfVinculado;
  getEmulMFD;
  getForceWTSClient;
  getGerarRFD;
  getHabilitaRFDImpMFD;
  getLog;
  getLogDiario;
  getModeloImp;
  getModoGaveta;
  getRetorno;
  getRetriesWTSCmd;
  getStatus;
  getStatusCheque;
  getStatusFuncao;
  getTimeoutGerencial;
  ini.UpdateFile;
end;

function TBemaFIIniFile.readProperty(section, name, default: string): string;
begin
  result := ini.ReadString(section, name, default);
  writeProperty(section, name, result);
end;

//setters
procedure TBemaFIIniFile.setCalculoICMSCupom(const Value: string);
begin
  writeProperty('sistema', 'CalculoICMSCupom', value);
end;

procedure TBemaFIIniFile.setConfigRede(const Value: string);
begin
  writeProperty('sistema', 'ConfigRede', value);
end;

procedure TBemaFIIniFile.setControlePorta(const Value: string);
begin
  writeProperty('sistema', 'ControlePorta', value);
end;

procedure TBemaFIIniFile.setCrLfGerencial(const Value: string);
begin
  writeProperty('sistema', 'CrLfGerencial', value);
end;

procedure TBemaFIIniFile.setCrLfVinculado(const Value: string);
begin
  writeProperty('sistema', 'CrLfVinculado', value);
end;

procedure TBemaFIIniFile.setEmulMFD(const Value: string);
begin
  writeProperty('sistema', 'EmulMFD', value);
end;

procedure TBemaFIIniFile.setForceWTSClient(const Value: string);
begin
  writeProperty('sistema', 'ForceWTSClient', value);
end;

procedure TBemaFIIniFile.setGerarRFD(const Value: string);
begin
  writeProperty('sistema', 'GerarRFD', value);
end;

procedure TBemaFIIniFile.setHabilitaRFDImpMFD(const Value: string);
begin
  writeProperty('sistema', 'HabilitaRFDImpMFD', value);
end;

procedure TBemaFIIniFile.setIniFileName(const Value: string);
begin
  FIniFileName := Value;
  ini := TIniFile.Create(Value);
end;

procedure TBemaFIIniFile.setLog(const Value: string);
begin
  writeProperty('sistema', 'Log', value);
end;

procedure TBemaFIIniFile.setLogDiario(const Value: string);
begin
  writeProperty('sistema', 'LogDiario', value);
end;

procedure TBemaFIIniFile.setModeloImp(const Value: string);
begin
  writeProperty('sistema', 'ModeloImp', value);
end;

procedure TBemaFIIniFile.setModoGaveta(const Value: string);
begin
  writeProperty('sistema', 'ModoGaveta', value);
end;

procedure TBemaFIIniFile.setPath(const Value: string);
begin
  writeProperty('sistema', 'path', value);
end;

procedure TBemaFIIniFile.setPorta(const Value: string);
begin
  writeProperty('sistema', 'porta', value);
end;

procedure TBemaFIIniFile.setRetorno(const Value: string);
begin
  writeProperty('sistema', 'Retorno', value);
end;

procedure TBemaFIIniFile.setRetriesWTSCmd(const Value: string);
begin
  writeProperty('sistema', 'WTSCommand', value);
end;

procedure TBemaFIIniFile.setStatus(const Value: string);
begin
  writeProperty('sistema', 'Status', value);
end;

procedure TBemaFIIniFile.setStatusCheque(const Value: string);
begin
  writeProperty('sistema', 'StatusCheque', value);
end;

procedure TBemaFIIniFile.setStatusFuncao(const Value: string);
begin
  writeProperty('sistema', 'StatusFuncao', value);
end;

procedure TBemaFIIniFile.setTimeoutGerencial(const Value: string);
begin
  writeProperty('sistema', 'TimeoutGerencial', value);
end;

//Getters
function TBemaFIIniFile.getPath: string;
begin
  result := readProperty('sistema', 'path', extractFilePath(FIniFileName));
end;

function TBemaFIIniFile.getPorta: string;
begin
  result := readProperty('sistema', 'porta', 'usb');
end;

function TBemaFIIniFile.getCalculoICMSCupom: string;
begin
  result := readProperty('sistema', 'CalculoICMSCupom', '0');
end;

function TBemaFIIniFile.getConfigRede: string;
begin
  result := readProperty('sistema', 'ConfigRede', '0');
end;

function TBemaFIIniFile.getControlePorta: string;
begin
  result := readProperty('sistema', 'ControlePorta', '1');
end;

function TBemaFIIniFile.getCrLfGerencial: string;
begin
  result := readProperty('sistema', 'CrLfGerencial', '0');
end;

function TBemaFIIniFile.getCrLfVinculado: string;
begin
  result := readProperty('sistema', 'CrLfVinculado', '0');
end;

function TBemaFIIniFile.getEmulMFD: string;
begin
  result := readProperty('sistema', 'EmulMFD', '0');
end;

function TBemaFIIniFile.getForceWTSClient: string;
begin
  result := readProperty('sistema', 'ForceWTSClient', '1');
end;

function TBemaFIIniFile.getGerarRFD: string;
begin
  result := readProperty('sistema', 'GerarRFD', '0');
end;

function TBemaFIIniFile.getHabilitaRFDImpMFD: string;
begin
  result := readProperty('sistema', 'HabilitaRFDImpMFD', '0');
end;

function TBemaFIIniFile.getLog: string;
begin
  result := readProperty('sistema', 'Log', '0');
end;

function TBemaFIIniFile.getLogDiario: string;
begin
  result := readProperty('sistema', 'LogDiario', '0');
end;

function TBemaFIIniFile.getModeloImp: string;
begin
  result := readProperty('sistema', 'modeloImp', 'BEMATCH');
end;

function TBemaFIIniFile.getModoGaveta: string;
begin
  result := readProperty('sistema', 'ModoGaveta', '0');
end;

function TBemaFIIniFile.getRetorno: string;
begin
  result := readProperty('sistema', 'Retorno', '0');
end;

function TBemaFIIniFile.getRetriesWTSCmd: string;
begin
  result := readProperty('sistema', 'WTSCmd', '');
end;

function TBemaFIIniFile.getStatus: string;
begin
  result := readProperty('sistema', 'Status', '0');
end;

function TBemaFIIniFile.getStatusCheque: string;
begin
  result := readProperty('sistema', 'StatusCheuqe', '');
end;

function TBemaFIIniFile.getStatusFuncao: string;
begin
  result := readProperty('sistema', 'StatusFuncao', '0');
end;

function TBemaFIIniFile.getTimeoutGerencial: string;
begin
  result := readProperty('sistema', 'TimeoutGerencial', '40');
end;

end.


{
[Sistema]

[MFD]
Impressora=1
StatusErro=1
TimeOutZ=99
}
