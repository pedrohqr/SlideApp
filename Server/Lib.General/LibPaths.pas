unit LibPaths;

interface

  function Path_VendorLibFB : String;
  function Path_DB : String;
  function Path_Config : String;

implementation

uses ShlObj, System.SysUtils;

const MAX_PATH = 1000;

/// <summary> Return the path of the Windows constants.
/// </summary>
function GetSpecialFolderPath(CSIDLFolder: Integer): string;
var
   FilePath: array [0..MAX_PATH] of char;
begin
  SHGetFolderPath(0, CSIDLFolder, 0, 0, FilePath);
  Result := FilePath;
end;


/// <summary> Give the path of fbclient.dll for Firebird connection.
/// </summary>
function Path_VendorLibFB : String;
begin
  {$IFDEF MSWINDOWS}
  Result := GetSpecialFolderPath(CSIDL_PROGRAM_FILESX86);
  Result := Result             + PathDelim +
            'Firebird'         + PathDelim +
            'Firebird_2_5'     + PathDelim +
            'bin'              + PathDelim +
            'fbclient.dll';
  {$ENDIF}
  if not FileExists(Result) then
    raise Exception.Create('SERVER: Arquivo "fbclient.dll" n�o encontrado em: ' + Result);
end;

/// <summary> Give the path of the database file .fdb.
/// Default: same folder of .exe.
// <summary>
function Path_DB : String;
begin
  Result := 'C:\Users\pedro\Desktop\SlideApp\Server\DataBase' + PathDelim + 'SERVER.FDB';
  if not FileExists(Result) then
    raise Exception.Create('SERVER: Banco de Dados "SERVER.FDB" n�o encontrado em: ' + Result);
end;

/// <summary> Give the path of the config.ini file. If file not exists, then created.
/// Default: same folder of .exe
/// </summary>
function Path_Config : String;
var
  Path : String;
begin
  Path := ExtractFilePath(ParamStr(0)) + 'config.ini';

  if not FileExists(Path) then
    FileCreate(Path);

  Result := Path;

  if not FileExists(Result) then
    raise Exception.Create('SERVER: Arquivo "config.ini" n�o encontrado em: ' + Result);

end;

end.
