unit EzQuery;

interface

uses
  System.SysUtils,
  System.JSON,
  System.Rtti,
  System.Classes,
  System.Generics.Collections,

  DataSet.Serialize,

  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  FireDAC.Stan.Option,

  Data.DB,

  Utils.Errors;

function GetEntityName(const DataSet: TFDTable): String;
procedure FetchOrError(const DataSet: TFDDataSet; const Error: Exception);
procedure FetchOrNotFound(const DataSet: TFDDataSet; const Entity: String);

type

  iEzQuery = interface ['{A83CF569-9B87-46AC-9EEF-CC3E6BD9B24B}']

    function Table(
      const Table: TFDTable;
      const ExcludeDeleted: Boolean = True;
      const DeleteAtColumnName: String = 'DELETED_AT'
    ): iEzQuery;
    function Filter(const Condition: String): iEzQuery;
    function &And(const Condition: String): iEzQuery;
    function &Or(const Condition: String): iEzQuery;
    function Join(
      const Alias: String;
      const DataSet: TFDTable;
      const DataSourse: TDataSource;
      const MasterFields: String
    ): iEzQuery;
    function NotDeleted(const ColumnName: String = 'DELETED_AT'): iEzQuery;
    function BeforeExec(const Event: TProc): iEzQuery;

    function Insert(
      const JSON: TJSONObject;
      const CreatedAtColumnName: String = 'CREATED_AT';
      const ReadOnly: Boolean = True
    ): TFDDataSet;

    function UpdateOne(
      const JSON: TJSONObject;
      const UpdatedAtColumnName: String = 'UPDATED_AT';
      const ReadOnly: Boolean = True
    ): TFDDataSet; overload;

    function UpdateOne(
      const Script: TProc;
      const UpdatedAtColumnName: String = 'UPDATED_AT';
      const ReadOnly: Boolean = True
    ): TFDDataSet; overload;

    function SoftDelete(
      const ColumnName: String = 'DELETED_AT';
      const ReadOnly: Boolean = True
    ): TFDDataSet; overload;

    function Fetch(): TFDDataSet;
    function FetchOrError(const Error: Exception): TFDDataSet;
    function FetchOrNotFound(): TFDDataSet;

  end;

  TEzQuery = class(TInterfacedObject, iEzQuery)

  strict private

    FConnection     : TFDConnection;
    FTable          : TFDTable;

    BeforeExecEvent : TProc;

    FOuterFilter    : String;

    procedure GroupFilter(const OuterFilter: String);

  public

    constructor Create(const Connection: TFDConnection); reintroduce;

    class function New(const Connection: TFDConnection): iEzQuery;

    function Table(
      const Table: TFDTable;
      const ExcludeDeleted: Boolean = True;
      const DeleteAtColumnName: String = 'DELETED_AT'
    ): iEzQuery;
    function Filter(const Condition: String): iEzQuery;
    function &And(const Condition: String): iEzQuery;
    function &Or(const Condition: String): iEzQuery;
    function Join(
      const Alias: String;
      const DataSet: TFDTable;
      const DataSourse: TDataSource;
      const MasterFields: String
    ): iEzQuery;
    function NotDeleted(const ColumnName: String = 'DELETED_AT'): iEzQuery;
    function BeforeExec(const Event: TProc): iEzQuery;

    function Insert(
      const JSON: TJSONObject;
      const CreatedAtColumnName: String = 'CREATED_AT';
      const ReadOnly: Boolean = True
    ): TFDDataSet;

    function UpdateOne(
      const JSON: TJSONObject;
      const UpdatedAtColumnName: String = 'UPDATED_AT';
      const ReadOnly: Boolean = True
    ): TFDDataSet; overload;

    function UpdateOne(
      const Script: TProc;
      const UpdatedAtColumnName: String = 'UPDATED_AT';
      const ReadOnly: Boolean = True
    ): TFDDataSet; overload;

    function SoftDelete(
      const ColumnName: String = 'DELETED_AT';
      const ReadOnly: Boolean = True
    ): TFDDataSet; overload;

    function Fetch(): TFDDataSet;
    function FetchOrError(const Error: Exception): TFDDataSet;
    function FetchOrNotFound(): TFDDataSet;

  end;

implementation

function GetEntityName(const DataSet: TFDTable): String;
begin

  Result := DataSet.TableName;

end;

procedure FetchOrError(const DataSet: TFDDataSet; const Error: Exception);
begin

  if DataSet.FetchNext() = 0 then
    raise Error
  else
    FreeAndNil(Error);

end;

procedure FetchOrNotFound(const DataSet: TFDDataSet; const Entity: String);
begin

  FetchOrError(DataSet, EEntidadeNaoEncontrada.Create(Entity));

end;

{$REGION 'TEzQuery'}

function TEzQuery.&And(const Condition: String): iEzQuery;
begin

  Result := Self;
  FTable.Filter := FTable.Filter + ' and (' + Condition + ') ';

end;

function TEzQuery.&Or(const Condition: String): iEzQuery;
begin

  Result := Self;
  FTable.Filter := FTable.Filter + ' or (' + Condition + ') ';

end;

function TEzQuery.SoftDelete(
      const ColumnName: String = 'DELETED_AT';
      const ReadOnly: Boolean = True
    ): TFDDataSet;
var
  DeletedAt : TField;

begin

  Result := FTable;

  FTable.Edit();

  if Assigned(BeforeExecEvent) then
    BeforeExecEvent();

  DeletedAt := FTable.FieldByName(ColumnName);
  DeletedAt.ReadOnly := False;
  DeletedAt.AsDateTime := Now();
  DeletedAt.ReadOnly := ReadOnly;
  FTable.Post();

end;

function TEzQuery.Table(
      const Table: TFDTable;
      const ExcludeDeleted: Boolean = True;
      const DeleteAtColumnName: String = 'DELETED_AT'
    ): iEzQuery;
begin

  Result := Self;

  FTable := Table;
  FTable.Connection := FConnection;
  FTable.FetchOptions.Mode := TFDFetchMode.fmManual;
  FTable.Open();

  if ExcludeDeleted then
    FOuterFilter := DeleteAtColumnName + ' IS NULL';

end;

function TEzQuery.UpdateOne(
      const Script: TProc;
      const UpdatedAtColumnName: String = 'UPDATED_AT';
      const ReadOnly: Boolean = True
): TFDDataSet;
var
  UpdatedAt : TField;

begin

  FetchOrNotFound();
  FTable.Edit();

  if Assigned(BeforeExecEvent) then
    BeforeExecEvent();

  if Assigned(Script) then
    Script();

  UpdatedAt := FTable.FieldByName(UpdatedAtColumnName);
  UpdatedAt.ReadOnly := False;
  UpdatedAt.AsDateTime := Now();
  UpdatedAt.ReadOnly := ReadOnly;

  FTable.Post();

end;

function TEzQuery.BeforeExec(const Event: TProc): iEzQuery;
begin

  Result := Self;
  BeforeExecEvent := Event;

end;

constructor TEzQuery.Create(const Connection: TFDConnection);
begin

  inherited Create();

  FConnection := Connection;
  BeforeExecEvent := nil;

end;

function TEzQuery.Fetch: TFDDataSet;
begin

  Result := FTable;
  GroupFilter(FOuterFilter);
  FTable.FetchNext();

end;

function TEzQuery.FetchOrError(const Error: Exception): TFDDataSet;
begin

  Result := FTable;

  GroupFilter(FOuterFilter);
  FTable.FetchNext();
  if FTable.RecordCount = 0 then
    raise Error
  else
    FreeAndNil(Error);

end;

function TEzQuery.FetchOrNotFound: TFDDataSet;
begin

  Result := FTable;
  FetchOrError(EEntidadeNaoEncontrada.Create( GetEntityName(FTable) ));

end;

function TEzQuery.Filter(const Condition: String): iEzQuery;
begin

  Result := Self;

  FTable.Filtered := True;

  if FTable.Filter.IsEmpty then
    FTable.Filter := ' (' + Condition + ') '

  else
    &And(Condition);

end;

procedure TEzQuery.GroupFilter(const OuterFilter: String);
begin

  FTable.Filter := '(' + FOuterFilter + ') AND (' + FTable.Filter + ')';

end;

function TEzQuery.Insert(
      const JSON: TJSONObject;
      const CreatedAtColumnName: String = 'CREATED_AT';
      const ReadOnly: Boolean = True
    ): TFDDataSet;
var
  CreatedAt : TField;

begin

  Result := FTable;

  FTable.Open();
  FTable.Insert();

  if Assigned(BeforeExecEvent) then
    BeforeExecEvent();

  CreatedAt := FTable.FieldByName(CreatedAtColumnName);
  CreatedAt.ReadOnly := False;
  CreatedAt.AsDateTime := Now();
  CreatedAt.ReadOnly := ReadOnly;

  FTable.MergeFromJSONObject(JSON, False);

  if FTable.State <> TDataSetState.dsBrowse then
    FTable.Post();

end;

function TEzQuery.Join(
      const Alias: String;
      const DataSet: TFDTable;
      const DataSourse: TDataSource;
      const MasterFields: String
    ): iEzQuery;
begin

  Result := Self;

  DataSet.Connection := FConnection;
  DataSet.FetchOptions.Mode := TFDFetchMode.fmManual;
  DataSet.Name := Alias;
  DataSet.MasterSource := DataSourse;
  DataSet.MasterFields := MasterFields;
  DataSet.Open();

end;

class function TEzQuery.New(const Connection: TFDConnection): iEzQuery;
begin

  Result := TEzQuery.Create(Connection);

end;

function TEzQuery.NotDeleted(const ColumnName: String): iEzQuery;
begin

  Result := Self;

  &And(ColumnName + ' IS NULL');

end;

function TEzQuery.UpdateOne(
      const JSON: TJSONObject;
      const UpdatedAtColumnName: String = 'UPDATED_AT';
      const ReadOnly: Boolean = True
): TFDDataSet;
var
  UpdatedAt : TField;

begin

  Result := FTable;

  FTable.Open();
  FetchOrNotFound();

  FTable.Edit();

  if Assigned(BeforeExecEvent) then
    BeforeExecEvent();

  UpdatedAt := FTable.FieldByName(UpdatedAtColumnName);
  UpdatedAt.ReadOnly := False;
  UpdatedAt.AsDateTime := Now();
  UpdatedAt.ReadOnly := ReadOnly;

  FTable.MergeFromJSONObject(JSON, False);

end;

{$ENDREGION}

{$REGION 'EntityName'}

constructor EntityName.Create(const pName: String);
begin

  inherited Create();

  FName := Name;

end;

{$ENDREGION}

end.