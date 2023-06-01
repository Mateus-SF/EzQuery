program EzQueryProject;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  EzQuery in '..\src\EzQuery.pas',
  EzQuery.Connection in '..\src\EzQuery.Connection.pas' {Connection: TDataModule},
  EzQuery.Manager in '..\src\EzQuery.Manager.pas' {Manager: TDataModule};

begin

  try



  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);

  end;

end.
