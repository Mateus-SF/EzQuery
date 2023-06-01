unit EzQuery.Connection;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IniFiles,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.ConsoleUI.Wait,
  FireDAC.Comp.Client,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.Phys.IBBase,

  {$IF NOT DEFINED(LINUX64)}
  FireDAC.VCLUI.Wait,
  {$IFEND}

  Data.DB,

  EzQuery.Manager,

  Horse,
  Horse.Response,
  FireDAC.Comp.UI;

type

  TConnection = class(TDataModule)

    DB: TFDConnection;
    PhysFBDriverLink: TFDPhysFBDriverLink;
    WaitCursor: TFDGUIxWaitCursor;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);

  private

    FParamsConn: TStrings;

  public

  end;

  TDBCallback = reference to procedure(Conn: TConnection; AReq: THorseRequest; ARes: THorseResponse; ANext: TProc);

function DBCallback(const Callback: TDBCallback): THorseCallback;

var
  Connection: TConnection;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure TConnection.DataModuleCreate(Sender: TObject);
var
  Config  : TIniFile;

begin

  try

    {$IF DEFINED(DEBUG)}
    Config := TIniFile.Create('../../../config/firebird.ini');
//    Config := TIniFile.Create('../config/firebird.ini');
    {$ELSE}
    Config := TIniFile.Create('../config/firebird.ini');
    {$IFEND}

    PhysFBDriverLink
      .VendorLib := Config.ReadString('FIREBIRD', 'VendorLib', 'Falha');

  finally
    FreeAndNil(Config);

  end;

  DB.Connected := False;
  DB.Params.Clear();
  DB.ConnectionDefName := 'DB';
  DB.Connected := True;

end;

procedure TConnection.DataModuleDestroy(Sender: TObject);
begin

  DB.Close();

end;

function DBCallback(const Callback: TDBCallback): THorseCallback;
begin

  Result := procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  var
    Conn  : TConnection;

  begin

    try

      Conn := TConnection.Create(nil);
      Callback(Conn, Req, Res, Next);

    finally
      FreeAndNil(Conn);

    end;

  end;

end;

end.
