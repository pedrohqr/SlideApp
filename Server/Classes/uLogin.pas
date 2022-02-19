unit uLogin;

interface

uses
  System.SysUtils, System.Classes, Datasnap.DSServer,
  Datasnap.DSAuth, Datasnap.DSProviderDataModuleAdapter, LibDB,
  Data.FireDACJSONReflect;

 {Provides management for the users of the Client Application}

  {$METHODINFO ON}
type
  TLogin = class(TComponent)
  public
    function Auth_Login(Username, Password : String): Integer;
    function Register_User(Name, Username, Password: String): String;
    function LoadParish(ID_User : Integer): TFDJSONDataSets;
  end;
  {$METHODINFO OFF}

implementation

uses FireDAC.Stan.Param, FireDAC.Stan.Def, FireDAC.DApt, FireDAC.Stan.Async,
  uDMDB;


/// <summary> Verify integrity of the user by Username and Password
/// through 'USER_APP' table of DataBase.
/// </summary>
/// <returns> Return the USER_ID before authentication. If not find, return 0.
/// </returns>
function TLogin.Auth_Login(Username, Password: String): Integer;
begin
  Result := 0;

  DMDB.ClearAllFieldsQuery;

  with DMDB.Query do
  begin
    SQL.Add('SELECT                      '+
            '    USER_ID                 '+
            'FROM                        '+
            '    USER_APP                '+
            'WHERE                       '+
            '    LOGIN = :vUsername AND  '+
            '    PW    = :vPassword;     ');
    ParamByName('vUsername').AsString := Username;
    ParamByName('vPassword').AsString := Password;
    Open;
    if RecordCount > 0 then
      Result := FieldByName('USER_ID').AsInteger;
  end;
end;

/// <summary> Load the Parishs that user is registred
/// </summary>
function TLogin.LoadParish(ID_User: Integer): TFDJSONDataSets;
begin
  Result := TFDJSONDataSets.Create;

  DMDB.ClearAllFieldsQuery;

  with DMDB.Query do
  begin
    SQL.Add('SELECT                                '+
            '   P.*                                '+
            'FROM                                  '+
            '   PARISH_USER PU INNER JOIN PARISH P '+
            '   ON PU.PARISH_ID = P.PARISH_ID      '+
            'WHERE                                 '+
            '    PU.USER_ID = :vID_User;           ');
    ParamByName('vID_User').AsInteger := ID_User;
    TFDJSONDataSetsWriter.ListAdd(Result, DMDB.Query);
  end;
end;

/// <summary> Register a new user in DataBase
/// </summary>
/// <returns> Return a empty string if sucess, else, return the exception.
/// </returns>
function TLogin.Register_User(Name, Username, Password: String): String;
begin
  Result := '';
  try
    DMDB.ClearAllFieldsSP;

    with DMDB.SP do
    begin
      StoredProcName := 'REG_USER';
      Params.ParamByName('V_NAME').AsString := Name;
      Params.ParamByName('V_LOGIN').AsString := Username;
      Params.ParamByName('V_PW').AsString := Password;
      ExecProc;
    end;
  except on e : exception do
    Result := e.Message;
  end;
end;

end.
