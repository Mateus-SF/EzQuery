unit EzQuery.Errors;

interface

uses
  Data.DB,

  Horse.Exception,
  Horse;

type

  EEntityNotFound = class(EHorseException)

  public

    constructor Create(); reintroduce;

  end;

  EDefaultPostError = class(EHorseException)

  public

    constructor Create(const pError: String); reintroduce;
    class procedure SelfRaise(
      DataSet: TDataSet;
      E: EDatabaseError;
      var Action: TDataAction
    );

  end;

implementation

{ EEntityNotFound }

constructor EEntityNotFound.Create;
begin

  inherited Create();

  Error('Entity not found');
  Status(THTTPStatus.NotFound);

end;

{ EDefaultPostError }

constructor EDefaultPostError.Create(const pError: String);
begin

  inherited Create();

  Error(pError);
  Status(THTTPStatus.BadRequest);

end;

class procedure EDefaultPostError.SelfRaise(DataSet: TDataSet;
  E: EDatabaseError; var Action: TDataAction);
begin

  raise EDefaultPostError.Create(E.Message);

end;

end.
