unit EzQuery.Base.Manager;

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
  FireDAC.Phys,
  FireDAC.Comp.Client;

type

  TBaseManager = class(TDataModule)

    DBManager: TFDManager;
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);

  private

  public

  end;

var
  BaseManager: TBaseManager;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure TBaseManager.DataModuleCreate(Sender: TObject);
begin

  {$IF DEFINED(RELEASE)}
  DBManager.ConnectionDefFileName := '../config/database.ini';
  {$IFEND}

end;

procedure TBaseManager.DataModuleDestroy(Sender: TObject);
begin

  DBManager.Close();

end;

end.
