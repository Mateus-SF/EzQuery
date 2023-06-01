program EzQueryProject;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  EzQuery in '..\src\EzQuery.pas',
  EzQuery.Base.Connection in '..\bases\EzQuery.Base.Connection.pas' {BaseConnection: TDataModule},
  EzQuery.Base.Manager in '..\bases\EzQuery.Base.Manager.pas' {BaseManager: TDataModule};

begin

  try



  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);

  end;

end.
