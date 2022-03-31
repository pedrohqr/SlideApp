//
// Created by the DataSnap proxy generator.
// 31/03/2022 00:16:44
//

unit DS_Functions;

interface

uses System.JSON, Data.DBXCommon, Data.DBXClient, Data.DBXDataSnap, Data.DBXJSON, Datasnap.DSProxy, System.Classes, System.SysUtils, Data.DB, Data.SqlExpr, Data.DBXDBReaders, Data.DBXCDSReaders, Data.FireDACJSONReflect, Data.DBXJSONReflect;

type
  TLoginClient = class(TDSAdminClient)
  private
    FAuth_LoginCommand: TDBXCommand;
    FRegister_UserCommand: TDBXCommand;
    FLoadParishCommand: TDBXCommand;
    FRegister_Parish_UserCommand: TDBXCommand;
    FgetParishIDByTokenCommand: TDBXCommand;
  public
    constructor Create(ADBXConnection: TDBXConnection); overload;
    constructor Create(ADBXConnection: TDBXConnection; AInstanceOwner: Boolean); overload;
    destructor Destroy; override;
    function Auth_Login(Username: string; Password: string; DeviceID: string): TFDJSONDataSets;
    function Register_User(AName: string; AUsername: string; APassword: string; AToken: string): Integer;
    function LoadParish(ID_User: Integer): TFDJSONDataSets;
    function Register_Parish_User(User_ID: Integer; Parish_ID: Integer; Token: string): string;
    function getParishIDByToken(Token: string): Integer;
  end;

  TMassClient = class(TDSAdminClient)
  private
    FGet_MomentsCommand: TDBXCommand;
    FGet_EucPrayerCommand: TDBXCommand;
    FGet_MassCommand: TDBXCommand;
    FGet_SongsCommand: TDBXCommand;
    FDownloadSlidePPTXCommand: TDBXCommand;
    FDownloadSlidePDFCommand: TDBXCommand;
    FRegister_MassCommand: TDBXCommand;
  public
    constructor Create(ADBXConnection: TDBXConnection); overload;
    constructor Create(ADBXConnection: TDBXConnection; AInstanceOwner: Boolean); overload;
    destructor Destroy; override;
    function Get_Moments: TFDJSONDataSets;
    function Get_EucPrayer: TFDJSONDataSets;
    function Get_Mass(pag: SmallInt; User_ID: Integer; Parish_ID: Integer; Filter: string; Text: string; Asc: Boolean): TFDJSONDataSets;
    function Get_Songs(pag: SmallInt; Text: string): TFDJSONDataSets;
    function DownloadSlidePPTX(Mass_ID: Integer): TJSONArray;
    function DownloadSlidePDF(Mass_ID: Integer): TJSONArray;
    procedure Register_Mass(var DS: TFDJSONDataSets);
  end;

  TSongClient = class(TDSAdminClient)
  private
    FGet_SongsCommand: TDBXCommand;
  public
    constructor Create(ADBXConnection: TDBXConnection); overload;
    constructor Create(ADBXConnection: TDBXConnection; AInstanceOwner: Boolean); overload;
    destructor Destroy; override;
    function Get_Songs(Page: SmallInt; Text: string): TFDJSONDataSets;
  end;

implementation

function TLoginClient.Auth_Login(Username: string; Password: string; DeviceID: string): TFDJSONDataSets;
begin
  if FAuth_LoginCommand = nil then
  begin
    FAuth_LoginCommand := FDBXConnection.CreateCommand;
    FAuth_LoginCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FAuth_LoginCommand.Text := 'TLogin.Auth_Login';
    FAuth_LoginCommand.Prepare;
  end;
  FAuth_LoginCommand.Parameters[0].Value.SetWideString(Username);
  FAuth_LoginCommand.Parameters[1].Value.SetWideString(Password);
  FAuth_LoginCommand.Parameters[2].Value.SetWideString(DeviceID);
  FAuth_LoginCommand.ExecuteUpdate;
  if not FAuth_LoginCommand.Parameters[3].Value.IsNull then
  begin
    FUnMarshal := TDBXClientCommand(FAuth_LoginCommand.Parameters[3].ConnectionHandler).GetJSONUnMarshaler;
    try
      Result := TFDJSONDataSets(FUnMarshal.UnMarshal(FAuth_LoginCommand.Parameters[3].Value.GetJSONValue(True)));
      if FInstanceOwner then
        FAuth_LoginCommand.FreeOnExecute(Result);
    finally
      FreeAndNil(FUnMarshal)
    end
  end
  else
    Result := nil;
end;

function TLoginClient.Register_User(AName: string; AUsername: string; APassword: string; AToken: string): Integer;
begin
  if FRegister_UserCommand = nil then
  begin
    FRegister_UserCommand := FDBXConnection.CreateCommand;
    FRegister_UserCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FRegister_UserCommand.Text := 'TLogin.Register_User';
    FRegister_UserCommand.Prepare;
  end;
  FRegister_UserCommand.Parameters[0].Value.SetWideString(AName);
  FRegister_UserCommand.Parameters[1].Value.SetWideString(AUsername);
  FRegister_UserCommand.Parameters[2].Value.SetWideString(APassword);
  FRegister_UserCommand.Parameters[3].Value.SetWideString(AToken);
  FRegister_UserCommand.ExecuteUpdate;
  Result := FRegister_UserCommand.Parameters[4].Value.GetInt32;
end;

function TLoginClient.LoadParish(ID_User: Integer): TFDJSONDataSets;
begin
  if FLoadParishCommand = nil then
  begin
    FLoadParishCommand := FDBXConnection.CreateCommand;
    FLoadParishCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FLoadParishCommand.Text := 'TLogin.LoadParish';
    FLoadParishCommand.Prepare;
  end;
  FLoadParishCommand.Parameters[0].Value.SetInt32(ID_User);
  FLoadParishCommand.ExecuteUpdate;
  if not FLoadParishCommand.Parameters[1].Value.IsNull then
  begin
    FUnMarshal := TDBXClientCommand(FLoadParishCommand.Parameters[1].ConnectionHandler).GetJSONUnMarshaler;
    try
      Result := TFDJSONDataSets(FUnMarshal.UnMarshal(FLoadParishCommand.Parameters[1].Value.GetJSONValue(True)));
      if FInstanceOwner then
        FLoadParishCommand.FreeOnExecute(Result);
    finally
      FreeAndNil(FUnMarshal)
    end
  end
  else
    Result := nil;
end;

function TLoginClient.Register_Parish_User(User_ID: Integer; Parish_ID: Integer; Token: string): string;
begin
  if FRegister_Parish_UserCommand = nil then
  begin
    FRegister_Parish_UserCommand := FDBXConnection.CreateCommand;
    FRegister_Parish_UserCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FRegister_Parish_UserCommand.Text := 'TLogin.Register_Parish_User';
    FRegister_Parish_UserCommand.Prepare;
  end;
  FRegister_Parish_UserCommand.Parameters[0].Value.SetInt32(User_ID);
  FRegister_Parish_UserCommand.Parameters[1].Value.SetInt32(Parish_ID);
  FRegister_Parish_UserCommand.Parameters[2].Value.SetWideString(Token);
  FRegister_Parish_UserCommand.ExecuteUpdate;
  Result := FRegister_Parish_UserCommand.Parameters[3].Value.GetWideString;
end;

function TLoginClient.getParishIDByToken(Token: string): Integer;
begin
  if FgetParishIDByTokenCommand = nil then
  begin
    FgetParishIDByTokenCommand := FDBXConnection.CreateCommand;
    FgetParishIDByTokenCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FgetParishIDByTokenCommand.Text := 'TLogin.getParishIDByToken';
    FgetParishIDByTokenCommand.Prepare;
  end;
  FgetParishIDByTokenCommand.Parameters[0].Value.SetWideString(Token);
  FgetParishIDByTokenCommand.ExecuteUpdate;
  Result := FgetParishIDByTokenCommand.Parameters[1].Value.GetInt32;
end;

constructor TLoginClient.Create(ADBXConnection: TDBXConnection);
begin
  inherited Create(ADBXConnection);
end;

constructor TLoginClient.Create(ADBXConnection: TDBXConnection; AInstanceOwner: Boolean);
begin
  inherited Create(ADBXConnection, AInstanceOwner);
end;

destructor TLoginClient.Destroy;
begin
  FAuth_LoginCommand.DisposeOf;
  FRegister_UserCommand.DisposeOf;
  FLoadParishCommand.DisposeOf;
  FRegister_Parish_UserCommand.DisposeOf;
  FgetParishIDByTokenCommand.DisposeOf;
  inherited;
end;

function TMassClient.Get_Moments: TFDJSONDataSets;
begin
  if FGet_MomentsCommand = nil then
  begin
    FGet_MomentsCommand := FDBXConnection.CreateCommand;
    FGet_MomentsCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FGet_MomentsCommand.Text := 'TMass.Get_Moments';
    FGet_MomentsCommand.Prepare;
  end;
  FGet_MomentsCommand.ExecuteUpdate;
  if not FGet_MomentsCommand.Parameters[0].Value.IsNull then
  begin
    FUnMarshal := TDBXClientCommand(FGet_MomentsCommand.Parameters[0].ConnectionHandler).GetJSONUnMarshaler;
    try
      Result := TFDJSONDataSets(FUnMarshal.UnMarshal(FGet_MomentsCommand.Parameters[0].Value.GetJSONValue(True)));
      if FInstanceOwner then
        FGet_MomentsCommand.FreeOnExecute(Result);
    finally
      FreeAndNil(FUnMarshal)
    end
  end
  else
    Result := nil;
end;

function TMassClient.Get_EucPrayer: TFDJSONDataSets;
begin
  if FGet_EucPrayerCommand = nil then
  begin
    FGet_EucPrayerCommand := FDBXConnection.CreateCommand;
    FGet_EucPrayerCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FGet_EucPrayerCommand.Text := 'TMass.Get_EucPrayer';
    FGet_EucPrayerCommand.Prepare;
  end;
  FGet_EucPrayerCommand.ExecuteUpdate;
  if not FGet_EucPrayerCommand.Parameters[0].Value.IsNull then
  begin
    FUnMarshal := TDBXClientCommand(FGet_EucPrayerCommand.Parameters[0].ConnectionHandler).GetJSONUnMarshaler;
    try
      Result := TFDJSONDataSets(FUnMarshal.UnMarshal(FGet_EucPrayerCommand.Parameters[0].Value.GetJSONValue(True)));
      if FInstanceOwner then
        FGet_EucPrayerCommand.FreeOnExecute(Result);
    finally
      FreeAndNil(FUnMarshal)
    end
  end
  else
    Result := nil;
end;

function TMassClient.Get_Mass(pag: SmallInt; User_ID: Integer; Parish_ID: Integer; Filter: string; Text: string; Asc: Boolean): TFDJSONDataSets;
begin
  if FGet_MassCommand = nil then
  begin
    FGet_MassCommand := FDBXConnection.CreateCommand;
    FGet_MassCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FGet_MassCommand.Text := 'TMass.Get_Mass';
    FGet_MassCommand.Prepare;
  end;
  FGet_MassCommand.Parameters[0].Value.SetInt16(pag);
  FGet_MassCommand.Parameters[1].Value.SetInt32(User_ID);
  FGet_MassCommand.Parameters[2].Value.SetInt32(Parish_ID);
  FGet_MassCommand.Parameters[3].Value.SetWideString(Filter);
  FGet_MassCommand.Parameters[4].Value.SetWideString(Text);
  FGet_MassCommand.Parameters[5].Value.SetBoolean(Asc);
  FGet_MassCommand.ExecuteUpdate;
  if not FGet_MassCommand.Parameters[6].Value.IsNull then
  begin
    FUnMarshal := TDBXClientCommand(FGet_MassCommand.Parameters[6].ConnectionHandler).GetJSONUnMarshaler;
    try
      Result := TFDJSONDataSets(FUnMarshal.UnMarshal(FGet_MassCommand.Parameters[6].Value.GetJSONValue(True)));
      if FInstanceOwner then
        FGet_MassCommand.FreeOnExecute(Result);
    finally
      FreeAndNil(FUnMarshal)
    end
  end
  else
    Result := nil;
end;

function TMassClient.Get_Songs(pag: SmallInt; Text: string): TFDJSONDataSets;
begin
  if FGet_SongsCommand = nil then
  begin
    FGet_SongsCommand := FDBXConnection.CreateCommand;
    FGet_SongsCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FGet_SongsCommand.Text := 'TMass.Get_Songs';
    FGet_SongsCommand.Prepare;
  end;
  FGet_SongsCommand.Parameters[0].Value.SetInt16(pag);
  FGet_SongsCommand.Parameters[1].Value.SetWideString(Text);
  FGet_SongsCommand.ExecuteUpdate;
  if not FGet_SongsCommand.Parameters[2].Value.IsNull then
  begin
    FUnMarshal := TDBXClientCommand(FGet_SongsCommand.Parameters[2].ConnectionHandler).GetJSONUnMarshaler;
    try
      Result := TFDJSONDataSets(FUnMarshal.UnMarshal(FGet_SongsCommand.Parameters[2].Value.GetJSONValue(True)));
      if FInstanceOwner then
        FGet_SongsCommand.FreeOnExecute(Result);
    finally
      FreeAndNil(FUnMarshal)
    end
  end
  else
    Result := nil;
end;

function TMassClient.DownloadSlidePPTX(Mass_ID: Integer): TJSONArray;
begin
  if FDownloadSlidePPTXCommand = nil then
  begin
    FDownloadSlidePPTXCommand := FDBXConnection.CreateCommand;
    FDownloadSlidePPTXCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FDownloadSlidePPTXCommand.Text := 'TMass.DownloadSlidePPTX';
    FDownloadSlidePPTXCommand.Prepare;
  end;
  FDownloadSlidePPTXCommand.Parameters[0].Value.SetInt32(Mass_ID);
  FDownloadSlidePPTXCommand.ExecuteUpdate;
  Result := TJSONArray(FDownloadSlidePPTXCommand.Parameters[1].Value.GetJSONValue(FInstanceOwner));
end;

function TMassClient.DownloadSlidePDF(Mass_ID: Integer): TJSONArray;
begin
  if FDownloadSlidePDFCommand = nil then
  begin
    FDownloadSlidePDFCommand := FDBXConnection.CreateCommand;
    FDownloadSlidePDFCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FDownloadSlidePDFCommand.Text := 'TMass.DownloadSlidePDF';
    FDownloadSlidePDFCommand.Prepare;
  end;
  FDownloadSlidePDFCommand.Parameters[0].Value.SetInt32(Mass_ID);
  FDownloadSlidePDFCommand.ExecuteUpdate;
  Result := TJSONArray(FDownloadSlidePDFCommand.Parameters[1].Value.GetJSONValue(FInstanceOwner));
end;

procedure TMassClient.Register_Mass(var DS: TFDJSONDataSets);
begin
  if FRegister_MassCommand = nil then
  begin
    FRegister_MassCommand := FDBXConnection.CreateCommand;
    FRegister_MassCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FRegister_MassCommand.Text := 'TMass.Register_Mass';
    FRegister_MassCommand.Prepare;
  end;
  if not Assigned(DS) then
    FRegister_MassCommand.Parameters[0].Value.SetNull
  else
  begin
    FMarshal := TDBXClientCommand(FRegister_MassCommand.Parameters[0].ConnectionHandler).GetJSONMarshaler;
    try
      FRegister_MassCommand.Parameters[0].Value.SetJSONValue(FMarshal.Marshal(DS), True);
      if FInstanceOwner then
        DS.Free
    finally
      FreeAndNil(FMarshal)
    end
  end;
  FRegister_MassCommand.ExecuteUpdate;
  if not FRegister_MassCommand.Parameters[0].Value.IsNull then
  begin
    FUnMarshal := TDBXClientCommand(FRegister_MassCommand.Parameters[0].ConnectionHandler).GetJSONUnMarshaler;
    try
      DS := TFDJSONDataSets(FUnMarshal.UnMarshal(FRegister_MassCommand.Parameters[0].Value.GetJSONValue(True)));
      if FInstanceOwner then
        FRegister_MassCommand.FreeOnExecute(DS);
    finally
      FreeAndNil(FUnMarshal)
    end;
  end
  else
    DS := nil;
end;

constructor TMassClient.Create(ADBXConnection: TDBXConnection);
begin
  inherited Create(ADBXConnection);
end;

constructor TMassClient.Create(ADBXConnection: TDBXConnection; AInstanceOwner: Boolean);
begin
  inherited Create(ADBXConnection, AInstanceOwner);
end;

destructor TMassClient.Destroy;
begin
  FGet_MomentsCommand.DisposeOf;
  FGet_EucPrayerCommand.DisposeOf;
  FGet_MassCommand.DisposeOf;
  FGet_SongsCommand.DisposeOf;
  FDownloadSlidePPTXCommand.DisposeOf;
  FDownloadSlidePDFCommand.DisposeOf;
  FRegister_MassCommand.DisposeOf;
  inherited;
end;

function TSongClient.Get_Songs(Page: SmallInt; Text: string): TFDJSONDataSets;
begin
  if FGet_SongsCommand = nil then
  begin
    FGet_SongsCommand := FDBXConnection.CreateCommand;
    FGet_SongsCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FGet_SongsCommand.Text := 'TSong.Get_Songs';
    FGet_SongsCommand.Prepare;
  end;
  FGet_SongsCommand.Parameters[0].Value.SetInt16(Page);
  FGet_SongsCommand.Parameters[1].Value.SetWideString(Text);
  FGet_SongsCommand.ExecuteUpdate;
  if not FGet_SongsCommand.Parameters[2].Value.IsNull then
  begin
    FUnMarshal := TDBXClientCommand(FGet_SongsCommand.Parameters[2].ConnectionHandler).GetJSONUnMarshaler;
    try
      Result := TFDJSONDataSets(FUnMarshal.UnMarshal(FGet_SongsCommand.Parameters[2].Value.GetJSONValue(True)));
      if FInstanceOwner then
        FGet_SongsCommand.FreeOnExecute(Result);
    finally
      FreeAndNil(FUnMarshal)
    end
  end
  else
    Result := nil;
end;

constructor TSongClient.Create(ADBXConnection: TDBXConnection);
begin
  inherited Create(ADBXConnection);
end;

constructor TSongClient.Create(ADBXConnection: TDBXConnection; AInstanceOwner: Boolean);
begin
  inherited Create(ADBXConnection, AInstanceOwner);
end;

destructor TSongClient.Destroy;
begin
  FGet_SongsCommand.DisposeOf;
  inherited;
end;

end.

