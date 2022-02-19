unit Lib_General;

interface

  function Path_Ini : String;
  function PathSlide: String;
  procedure Vibrate(const Time : Integer);
  procedure OpenYouTubeVideo(ALink : String);
  procedure StoragePermission;
  procedure ShareWhatsApp(FileName: String);
  procedure OpenPPTX(const AFileName: string);

implementation

uses
  {$IFDEF MSWINDOWS}
  Winapi.ShellAPI, Winapi.Windows,
  {$ENDIF}
  {$IFDEF ANDROID}
  Androidapi.Jni.Os,
  Androidapi.jni.GraphicsContentViewText,
  Androidapi.Helpers,
  Androidapi.JNIBridge,
  IdURI,
  Androidapi.JNI.App,
  FMX.Platform.Android,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Net,
  System.Permissions,
  {$ENDIF}
  System.SysUtils, System.IOUtils, FMX.Dialogs;

/// <summary> Returns the path of ini file in Android and Windows.
/// </summary>
function Path_Ini : String;
var
  path: String;
begin
  {$IFDEF ANDROID}
    path := System.IOUtils.TPath.GetHomePath;
  {$ENDIF}
  {$IFDEF MSWINDOWS}
    path := ExtractFilePath(ParamStr(0));
  {$ENDIF}

  if not TDirectory.Exists(path) then
    TDirectory.CreateDirectory(path);

  path := System.IOUtils.TPath.Combine(path, 'config.ini');

  if not FileExists(path) then
    FileCreate(path);

  Result := path;

  if not FileExists(Result) then
    raise Exception.Create('CLIENTE: Arquivo "config.ini" n�o encontrado em: ' + Result);
end;

/// <summary> Does vibrate in the Android. Time in miliseconds.
/// </summary>
procedure Vibrate(const Time : Integer);
{$IFDEF ANDROID}
var
  Vibrator : JVibrator;
{$ENDIF}
begin
{$IFDEF ANDROID}
  Vibrator := TJVibrator.Wrap((TAndroidHelper.Context.getSystemService(TJContext.JavaClass.VIBRATOR_SERVICE) as ILocalObject).getObjectID);
  Vibrator.vibrate(Time);
{$ENDIF}
end;

/// <summary> Open the video on YouTube. Works on Android and Windows.
/// </summary>
procedure OpenYouTubeVideo(ALink : String);
  {$IFDEF ANDROID}
var
  Intent : JIntent;
  {$ENDIF}
begin
  {$IFDEF MSWINDOWS}
   ShellExecute(0, 'OPEN', PChar(ALink), '', '', SW_SHOWNORMAL);
  {$ENDIF}
  {$IFDEF ANDROID}
    try
      Intent := TJIntent.JavaClass.init(TJIntent.JavaClass.ACTION_VIEW);
      Intent.setData(TJnet_Uri.JavaClass.parse(StringToJString(TIdURI.URLEncode(ALink))));
      TAndroidHelper.Activity.StartActivity(Intent);
    except on E: Exception do
      ShowMessage(E.Message);
    end;
  {$ENDIF}
end;

/// <summary> Request to the user permission to save the file
/// </summary>
procedure StoragePermission;
begin
  {$IFDEF ANDROID}
  PermissionsService.RequestPermissions([JStringToString(TJManifest_permission.JavaClass.READ_EXTERNAL_STORAGE)],
  procedure(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>)
  begin
    if (Length(AGrantResults) = 1) and (AGrantResults[0] = TPermissionStatus.Granted) then
    begin

    end
  end)
  {$ENDIF}
end;

/// <summary> Return the path of the .pptx will be saved in client application
/// </summary>
function PathSlide: String;
var
  Path : String;
begin
  {$IFDEF MSWINDOWS}
  Path := ExtractFilePath(ParamStr(0)) + 'reports'+PathDelim;
  if ForceDirectories(Path) then
    Result := Path
  else
    raise Exception.Create('Erro - N�o foi poss�vel criar o diret�rio: '+Path);
  {$ENDIF}
  {$IFDEF ANDROID}
  Path := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetSharedDocumentsPath, 'SlideApp');
  if not TDirectory.Exists(path) then
    TDirectory.CreateDirectory(path);
  Result := path;
  {$ENDIF}
end;

/// <summary> Share the file in WhatsApp
/// </summary>
procedure ShareWhatsApp(FileName: String);
{$IFDEF ANDROID}
var
   Intent: JIntent;
   FileUri: Jnet_Uri;
   ListArqs: JArrayList;
{$ENDIF}
begin
{$IFDEF ANDROID}
   ListArqs := TJArrayList.Create;
   FileUri := TJNet_Uri.JavaClass.fromFile(TJFile.JavaClass.init(StringToJString(FileName)));
   ListArqs.Add(0, FileUri); // if intend to send more file change the index (default 0)
   try
      Intent := TJIntent.JavaClass.init(TJIntent.JavaClass.ACTION_GET_CONTENT);
      Intent.setDataAndTypeAndNormalize(FileUri, StringToJString('*/*'));
      Intent.putParcelableArrayListExtra(TJIntent.JavaClass.EXTRA_STREAM, ListArqs);
//      Intent.setPackage(StringToJString('com.whatsapp'));
//       Intent.setPackage(StringToJString('com.microsoft.office.powerpoint'));
      Intent.addFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
      if MainActivity.getPackageManager.queryIntentActivities(Intent, TJPackageManager.JavaClass.MATCH_DEFAULT_ONLY).size > 0 then
        TAndroidHelper.Activity.startActivityForResult(Intent, 0)
      else
        ShowMessage('N�o foi encontrado um app padr�o para abrir esse tipo de arquivo (.pptx)');
   except
      on E: Exception do
         ShowMessage(E.Message);
   end;
{$ENDIF}
end;

/// <summary> Open the Slide with the default viwer
/// </summary>
procedure OpenPPTX(const AFileName: string);
{$IFDEF ANDROID}
var
  LIntent: JIntent;
  LUri: Jnet_Uri;
{$ENDIF}
begin
{$IFDEF ANDROID}
  try
    LUri := TAndroidHelper.JFileToJURI(TJFile.JavaClass.init(StringToJString(AFileName)));
    LIntent := TJIntent.JavaClass.init(TJIntent.JavaClass.ACTION_VIEW);
    LIntent.setDataAndType(LUri, StringToJString('application/vnd.openxmlformats-officedocument.presentationml.presentation'));
    LIntent.setFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
    TAndroidHelper.Activity.startActivity(LIntent);
  except on e : exception do
    ShowMessage(e.Message)
  end;
{$ENDIF}
end;

end.
