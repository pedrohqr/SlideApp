unit LibDB;

interface

uses FireDAC.Comp.Client, FireDAC.Comp.UI, FireDAC.Phys.FB, System.IniFiles,
     FireDAC.Stan.StorageBin, System.Classes;

{This unit gives a connection to database(Firebird) of server.}

type
  TConnection = class(TComponent)
    private
      Conn : TFDConnection;
      GUI : TFDGUIxWaitCursor;
      Stan : TFDStanStorageBinLink;
      Driver : TFDPhysFBDriverLink;
      Ini_File : TIniFile;
    public
      Query : TFDQuery;
      SP : TFDStoredProc;

      constructor Create(AOwner : TComponent); override;
      destructor Destroy; override;

      procedure ClearAllFieldsQuery;
      procedure ClearAllFieldsSP;
  end;

implementation

{ TConection }

uses LibPaths, System.SysUtils;

/// <summary> Clear all fields of the Query.
/// </summary>
procedure TConnection.ClearAllFieldsQuery;
begin
  if Assigned(Query) then
  begin
    Query.Close;
    Query.SQL.Clear;
    Query.Params.Clear;
  end;
end;

/// <summary> Clear of fields of the StoredProcedure.
/// </summary>
procedure TConnection.ClearAllFieldsSP;
begin
  if Assigned(SP) then
  begin
    SP.Active := False;
    SP.StoredProcName := '';
    SP.Params.Clear;
  end;
end;

constructor TConnection.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);

  Driver := TFDPhysFBDriverLink.Create(AOwner);
  Driver.VendorLib := Path_VendorLibFB;
  GUI    := TFDGUIxWaitCursor.Create(AOwner);
  Conn   := TFDConnection.Create(AOwner);
  Stan   := TFDStanStorageBinLink.Create(AOwner);

  Ini_File := TIniFile.Create(Path_Config);

  with Conn.Params do
  begin
    DriverID := 'FB';
    Database := Path_DB;
    UserName := Ini_File.ReadString('DATABASE', 'USER', 'SYSDBA');
    Password := Ini_File.ReadString('DATABASE', 'PASSWORD', 'MASTERKEY');
  end;

  Conn.Connected := True;

  Query := TFDQuery.Create(AOwner);
  Query.Connection := Conn;

  SP := TFDStoredProc.Create(AOwner);
  SP.Connection := Conn;
end;

destructor TConnection.Destroy;
begin
  if Assigned(Stan) then
    FreeAndNil(Stan);

  if Assigned(SP) then
    FreeAndNil(SP);

  if Assigned(Query) then
    FreeAndNil(Query);

  if Assigned(Conn) then
    FreeAndNil(Conn);

  if Assigned(GUI) then
    FreeAndNil(GUI);

  if Assigned(Driver) then
    FreeAndNil(Driver);

  if  Assigned(Ini_File) then
    FreeAndNil(Ini_File);

  inherited;
end;

end.
