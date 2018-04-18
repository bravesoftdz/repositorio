unit PDVIntfUnit;

interface

uses
  SysUtils;

type
  IOperacaoPDV = interface(IInterface)
  ['{CC490FE4-E0E6-43FD-BF97-01D4C6DD9920}']
    function GetServerId: Integer;
    function GetNextNumeroItem: Integer;

    property ServerId: Integer read GetServerId;
  end;

  IItemPDV = interface(IInterface)
  ['{A50DFA46-CE10-408D-95FF-0607F9FCF8AC}']
    function GetServerId: Integer;
    function GetIndex: Integer;
    function GetOperacaoPDV: IOperacaoPDV;

    property ServerId: Integer read GetServerId;
    property Index: Integer read GetIndex;
    property OperacaoPDV: IOperacaoPDV read GetOperacaoPDV;
  end;

  { Cada forma de pagamento ser� uma classe que implementa IPagamentoPDV, e � ela que sabe que
    par�metros passar ao Server e ao Printer. }
  IPagamentoPDV = interface(IInterface)
  ['{AB4B89C7-0011-4992-AC76-0412313EADBB}']
    { EfetuarPagamentoServer precisa retornar o id do pagamento. }
    function EfetuarPagamentoServer(const OperacaoPDV: IOperacaoPDV;
        const ServerRef: IInterface): Integer;
    { EfetuarPagamentoPrinter precisa retornar o valor de retorno da fun��o que for chamada em
      PrinterRef para que a classe que implementa IPDV.EfetuarPagamento possa chamar o
      IPDVPrinter.CheckStatus. Seria melhor que o pr�prio implementador de
      EfetuarPagamentoPrinter chamasse CheckStatus, mas ele n�o estar� implementado pelo
      PrinterRef (que ser�, por exemplo, um IBematech). Assim eu sinto que CheckStatus deveria
      ser declarado em IBematech (ou equivalente), para deixar esta interface mais elegante, mas
      da� seria mais complicado testar CheckStatus, um m�todo importante que exige muitos
      testes. }
    function EfetuarPagamentoPrinter(const OperacaoPDV: IOperacaoPDV;
        const PrinterRef: IInterface): Integer;
  end;

  { Se a transa��o for bem-sucedida IPDVTransactionRunner.Run retornar� o IPDVTransactionResult
    resultante da chamada a IPDVTransactionState.Commit. }
  IPDVTransactionResult = interface(IInterface)
  ['{740AD2E3-A604-4668-BD0C-0A041A529860}']
  end;

  { Uma inst�ncia desta interface deve ser devolvida por cada m�todo da interface IPDV, para que
    que o Transaction Runner possa chamar Rollback e Commit ao executar o IPDVTransaction. }
  IPDVTransactionState = interface(IInterface)
  ['{2CC925A3-2CFB-4E82-ACE4-1756E3953474}']
    function Commit: IPDVTransactionResult;
    procedure Rollback;
  end;

  { M�todos a serem executados tanto no servidor quanto na impressora, de forma pseudo-at�mica.
    ("Pseudo-at�mica" porque vai proporcionar um mecanismo extremamente simples de transa��o:
    (a) executa no servidor; (b) executa na impressora; (c) se deu erro em b faz rollback no
    servidor; e (d) se foi bem sucedido faz commit no servidor.) }
  IPDV = interface(IInterface)
  ['{95AA2369-84BA-4D1F-B31B-6A25E269EE85}']
    function CriarOperacao(VendedorId, ClienteId,
        TipoOperacaoId: Integer;
        const NomeCliente, Documento, Endereco: string): IPDVTransactionState;
    function CancelarOperacao(const OperacaoPDV: IOperacaoPDV): IPDVTransactionState;

    function IniciarFechamento(const OperacaoPDV: IOperacaoPDV; ValorDesconto,
        PorcentualDesconto: Currency; const NomeSupervisor,
        SenhaSupervisor: AnsiString): IPDVTransactionState;
    procedure EfetuarPagamento(forma: AnsiString; valor: currency);
    function TerminarFechamento(const OperacaoPDV: IOperacaoPDV; mensagem: AnsiString): IPDVTransactionState;

    function InserirItem(const OperacaoPDV: IOperacaoPDV; MercadoriaId: Integer;
        const Codigo, Descricao, Unidade, tipoTributacao: AnsiString; AliquotaICMS, Quantidade, PrecoUnitario,
        Desconto: Currency): IPDVTransactionState;
    function RemoverItem(const Item: IItemPDV; const NomeSupervisor,
        SenhaSupervisor: AnsiString): IPDVTransactionState;
    function numeroUltimoCupom: integer;
  end;

  { Interface a ser implementada por cada m�todo transacional. }
  IPDVTransaction = interface(IInterface)
  ['{046E14B4-82D7-4D34-B94C-A2B92D9AEB66}']
    function Execute(const PDV: IPDV): IPDVTransactionState;
  end;

  { Seu implementador ser� respons�vel por coordenar as chamadas a Execute em cada uma das
    inst�ncias de IPDV e Commit e Rollback na inst�ncia do servidor. }
  IPDVTransactionRunner = interface(IInterface)
  ['{CD717714-FA48-4A22-9D55-A1D75C515752}']
    // O objeto que implementa IPDVTransaction geralmente ser� instanciado na lista de
    // par�metros de Run. Nesse caso n�o podemos fazer o par�metro 'const' porque, de outra
    // forma, o Delphi n�o chamar� o _Release, causando um memory leak. (Na verdade nem � uma
    // boa id�ia usar 'const' com qualquer par�metro do tipo IInterface. N�o tem vantagem
    // nenhuma e sempre vai deixar o risco de memory leaks dif�ceis de serem descobertos.)
    function Run(PDVTransaction: IPDVTransaction): IPDVTransactionResult;
  end;

  EPDVPermissionDenied = class(Exception)
  end;

implementation

end.
