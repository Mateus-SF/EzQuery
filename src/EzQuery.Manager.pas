unit EzQuery.Manager;

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
  TManager = class(TDataModule)
    DBManager: TFDManager;
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Manager: TManager;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure TManager.DataModuleCreate(Sender: TObject);
begin

  {$IF DEFINED(RELEASE)}
  DBManager.ConnectionDefFileName := '../config/database.ini';
  {$IFEND}

end;

procedure TManager.DataModuleDestroy(Sender: TObject);
begin

  DBManager.Close();

end;

initialization

  Manager := TManager.Create(nil);

finalization

  FreeAndNil(Manager);

end.
