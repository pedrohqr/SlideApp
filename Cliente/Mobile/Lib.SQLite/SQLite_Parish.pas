unit SQLite_Parish;

interface

uses uSQLiteFunctions, System.Classes;

  type
    TParish = class(TConnectionDB)
      private
        FID : Integer;
        FName : String;
        function getID: Integer;
        function getName: String;
        procedure setID(const Value: Integer);
        procedure setName(const Value: String);
      public
        property ID : Integer read getID write setID;
        property Name : String read getName write setName;

        class procedure Insert_Parish(AID : Integer; AName : String);
        class procedure Insert_PU(AID_Parish, AID_User : Integer);
    end;

implementation

uses
  System.SysUtils, FireDAC.Stan.Param;

{ TParish }

function TParish.getID: Integer;
begin
  Result := FID;
end;

function TParish.getName: String;
begin
  Result := FName;
end;

/// <summary> Insert a Parish in DataBaseLocal.
/// </summary>
class procedure TParish.Insert_Parish(AID : Integer; AName: String);
var
  Conn : TConnectionDB;
begin
  Conn := TConnectionDB.Create(nil);
  try
    with Conn do
    begin
      CreateQuery;
      with Query do
      begin
        SQL.Add('INSERT INTO PARISH(PARISH_ID, '+
                '                   NAME)'+
                '          VALUES(:V_PARISH_ID,'+
                '                 :V_NAME);');
        ParamByName('V_PARISH_ID').AsInteger := AID;
        ParamByName('V_NAME').AsString := AName;
        ExecSQL;
      end;
    end;
  finally
    if Assigned(Conn) then
      FreeAndNil(Conn);
  end;
end;

/// <summary> Insert Parish_User in DataBaseLocal.
/// </summary>
class procedure TParish.Insert_PU(AID_Parish, AID_User: Integer);
var
  Conn : TConnectionDB;
begin
  Conn := TConnectionDB.Create(nil);
  try
    with Conn do
    begin
      CreateQuery;
      with Query do
      begin
        SQL.Add('INSERT INTO PARISH_USER(PARISH_ID, '+
                '                        USER_ID)'+
                '                 VALUES(:V_PARISH_ID,'+
                '                        :V_USER_ID);');
        ParamByName('V_PARISH_ID').AsInteger := AID_Parish;
        ParamByName('V_USER_ID').AsInteger := AID_User;
        ExecSQL;
      end;
    end;
  finally
    if Assigned(Conn) then
      FreeAndNil(Conn);
  end;
end;

procedure TParish.setID(const Value: Integer);
begin
  FID := Value;
end;

procedure TParish.setName(const Value: String);
begin
  FName := Value;
end;

end.
