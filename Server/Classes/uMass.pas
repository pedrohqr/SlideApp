unit uMass;

interface

uses
  System.Classes, LibDB, FireDAC.Comp.Client, Data.FireDACJSONReflect,
  System.JSON;

  {Provides the queryes to client build the mass}

  {$METHODINFO ON}
type
  TMass = class(TComponent)
    private
      FConn : TConnection;
      function Create_Slide(Mass_ID: Integer): String;
    public
      constructor Create(AOwner : TComponent); override;
      destructor Destroy; override;

      function Get_Moments: TFDJSONDataSets;
      function Get_Mass(const pag : SmallInt; User_ID, Parish_ID : Integer;
                      Filter, Text : String; Asc : Boolean): TFDJSONDataSets;
      function Get_Songs(pag : SmallInt; Text : String): TFDJSONDataSets;
      function DownloadSlide(Mass_ID : Integer): TJSONArray;
      procedure Register_Mass(var DS : TFDJSONDataSets);
  end;
  {$METHODINFO OFF}
implementation

uses
  System.SysUtils, FireDAC.Stan.Param, DM_SlideCreator, System.IOUtils,
  Data.DBXJSONCommon;

const Page_Size = 20;

{ TMass }

/// <summary> Return the list of masses of the user into your comunity
/// </summary>
/// <param name="pag"> The page of the search
/// </param>
/// <param name="User_ID"> The ID of the User_App
/// </param>
/// <param name="Parish_ID"> The ID of the Parish
/// </param>
/// <param name="Filter"> Filter the order by of query: 'DATE'=DATE_MASS;
/// 'DATE_GEN'=GENERATE_DATE; 'TITLE'=TITLE; 'MASS_ID'=MASS_ID; 'USER_ID'=USER_ID
/// </param>
/// <param name="Asc"> Provides if the order by is ascendent(ASC=True)
/// or descendent(ASC=False)
/// </param>
function TMass.Get_Mass(const pag: SmallInt; User_ID, Parish_ID: Integer;
                  Filter, Text : String; Asc : Boolean): TFDJSONDataSets;
begin
  Result := TFDJSONDataSets.Create;
  FConn.CreateQuery;
  if Pag > 1 then
  begin
  FConn.Query.SQL.Add('SELECT FIRST :pPageSize SKIP :pPage ');
  FConn.Query.ParamByName('pPage').Value := (Page_Size*Pag)-Page_Size;
  end
  else
  FConn.Query.SQL.Add('SELECT FIRST :pPageSize SKIP 0 ');
  FConn.Query.SQL.Add('    M.MASS_ID,         '+
                     '    M.TITLE,           '+
                     '    P.NAME AS UNAME,   '+
                     '    M.MASS_DATE,       '+
                     '    M.GENERATE_DATE    '+
                     'FROM MASS M            '+
                     '    INNER JOIN USER_APP U          '+
                     '    ON M.USER_ID = U.USER_ID       '+
                     '    INNER JOIN PERSON P            '+
                     '    ON P.PERSON_ID = U.USER_ID     '+
                     'WHERE                              '+
                     '    (M.PARISH_ID = :pParishID)     ');

  if not Text.IsEmpty then
  begin
  FConn.Query.SQL.Add(' AND ((M.TITLE LIKE :pText)  OR     '+
                     '      (M.TITLE LIKE :pText)         '+
//                     '      (M.MASS_DATE = :pText)        '+
                     '     )                              ');
  FConn.Query.ParamByName('pText').AsString := '%'+Text+'%';
  end;
  FConn.Query.ParamByName('pPageSize').AsInteger := Page_Size;
  FConn.Query.ParamByName('pParishID').AsInteger := Parish_ID;

  if User_ID <> 0 then
  begin
  FConn.Query.SQL.Add(' AND (M.USER_ID = :pID)  ');
  FConn.Query.ParamByName('pID').AsInteger := User_ID;
  end;

  if Trim(Filter) = 'DATE' then
    FConn.Query.SQL.Add(' ORDER BY M.MASS_DATE ')
  else
  if Trim(Filter) = 'DATE_GEN' then
    FConn.Query.SQL.Add(' ORDER BY M.GENERATE_DATE ')
  else
  if Trim(Filter) = 'TITLE' then
    FConn.Query.SQL.Add(' ORDER BY M.TITLE ')
  else
  if Trim(Filter) = 'MASS_ID' then
    FConn.Query.SQL.Add(' ORDER BY M.MASS_ID ')
  else
  if Trim(Filter) = 'USER_ID' then
    FConn.Query.SQL.Add(' ORDER BY M.USER_ID ');

  if Asc then
    FConn.Query.SQL.Add(' ASC;')
  else
    FConn.Query.SQL.Add(' DESC;');

  TFDJSONDataSetsWriter.ListAdd(Result, FConn.Query);
end;

/// <summary> Return all moments and your ID's into the TFDJSONDataSets
/// </summary>
function TMass.Get_Moments: TFDJSONDataSets;
begin
  Result := TFDJSONDataSets.Create;
  FConn.CreateQuery;
  FConn.Query.SQL.Text := 'SELECT * FROM MOMENTS;';
  TFDJSONDataSetsWriter.ListAdd(Result, FConn.Query);
end;

/// <summary> Return the song of search, using pagination. If the text is empty,
/// search for all.
/// </summary>
function TMass.Get_Songs(pag: SmallInt; Text: String): TFDJSONDataSets;
begin
  Result := TFDJSONDataSets.Create;
  FConn.CreateQuery;
  FConn.Query.SQL.Add('SELECT                           '+
                     '    S.SONG_ID,                   '+
                     '    S.NAME,                      '+
                     '    P.NAME AS ARTIST,            '+
                     '    COALESCE(S.AUDIO_LINK, '''') '+
                     '    AS AUDIO_LINK                '+
                     'FROM SONG S                      '+
                     '    INNER JOIN PERSON P          '+
                     '    ON S.ARTIST_ID = P.PERSON_ID ');
  if not Trim(Text).IsEmpty then
  begin
  FConn.Query.SQL.Add('WHERE                            '+
                     '    S.NAME LIKE :pNameMusic         ');
  FConn.Query.ParamByName('pNameMusic').AsString := '%'+Text+'%';
  end;
  FConn.Query.SQL.Add('ORDER BY S.NAME;');
  TFDJSONDataSetsWriter.ListAdd(Result, FConn.Query);
end;

/// <summary> Register a new mass in database
/// </summary>
procedure TMass.Register_Mass(var DS: TFDJSONDataSets);
var
  Mass_MT      : TFDMemTable;
  Mass_Song_MT : TFDMemTable;
  Mass_ID      : Integer;
begin
  Mass_MT      := TFDMemTable.Create(nil);
  Mass_Song_MT := TFDMemTable.Create(nil);
  try
     Mass_MT.AppendData(TFDJSONDataSetsReader.GetListValue(DS, 0));
     Mass_Song_MT.AppendData(TFDJSONDataSetsReader.GetListValue(DS, 1));

     FConn.CreateSP('REG_MASS');
     while not Mass_MT.Eof do
     with Mass_MT do
     begin
       FConn.SP.Prepare;
       FConn.SP.ParamByName('V_MASS_ID').AsInteger        := FieldByName('MASS_ID').AsInteger;
       FConn.SP.ParamByName('V_TITLE').AsString           := FieldByName('TITLE').AsString;
       FConn.SP.ParamByName('V_MASS_DATE').AsDateTime     := FieldByName('MASS_DATE').AsDateTime;
       FConn.SP.ParamByName('V_LIT_TIME_ID').AsInteger    := FieldByName('LIT_TIME_ID').AsInteger;
       FConn.SP.ParamByName('V_GENERATE_DATE').AsDateTime := FieldByName('GENERATE_DATE').AsDateTime;
       FConn.SP.ParamByName('V_USER_ID').AsInteger        := FieldByName('USER_ID').AsInteger;
       FConn.SP.ParamByName('V_PARISH_ID').AsInteger      := FieldByName('PARISH_ID').AsInteger;
       FConn.SP.ExecProc;

       Mass_ID := FConn.SP.ParamByName('PID').AsInteger;

       FConn.CreateSP('REG_MASS_SONG');
       while not Mass_Song_MT.Eof do
       with Mass_Song_MT do
       begin
         FConn.SP.Prepare;
         FConn.SP.ParamByName('V_MASS_SONG_ID').Clear;
         FConn.SP.ParamByName('V_MASS_ID').AsInteger      := Mass_ID;
         FConn.SP.ParamByName('V_SONG_ID').AsInteger      := FieldByName('SONG_ID').AsInteger;
         FConn.SP.ParamByName('V_MOMENT_ID').AsInteger    := FieldByName('MOMENT_ID').AsInteger;
         FConn.SP.ParamByName('V_SONG_ORDER').AsInteger   := FieldByName('SONG_ORDER').AsInteger;
         FConn.SP.ParamByName('V_SONG_ORDER').Clear;
         FConn.SP.ExecProc;
         Next;
       end;

       Create_Slide(Mass_ID);

       Next;
     end;
  finally
    if Assigned(Mass_MT) then
      FreeAndNil(Mass_MT);
    if Assigned(Mass_Song_MT) then
      FreeAndNil(Mass_Song_MT);
  end;
end;

constructor TMass.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FConn := TConnection.Create(AOwner);
end;

function TMass.Create_Slide(Mass_ID: Integer): String;
var
  FileName : String;
begin
  FileName := 'Missa_'+Mass_ID.ToString+'.pptx';
  FConn.CreateQuery;
  with FConn.Query do
  begin

    Active := False;
    SQL.Text := 'SELECT                            '+
                '   M.TITLE,                       '+
                '   M.MASS_DATE,                   '+
                '   COALESCE(P.NAME, '''')         '+
                '        AS PARISH_NAME,           '+
                '   S.LYRICS,                      '+
                '   MO.NAME AS MOMENT              '+
                'FROM MASS M                       '+
                '   INNER JOIN MASS_SONG MS        '+
                '   ON M.MASS_ID = MS.MASS_ID      '+
                '   INNER JOIN SONG S              '+
                '   ON S.SONG_ID = MS.SONG_ID      '+
                '   INNER JOIN MOMENTS MO          '+
                '   ON MO.MOMENT_ID = MS.MOMENT_ID '+
                '   INNER JOIN PARISH P            '+
                '   ON P.PARISH_ID = M.PARISH_ID   '+
                'WHERE                             '+
                '    M.MASS_ID = :pID;             ';
    ParamByName('pID').AsInteger := Mass_ID;
    Active := True;
  end;

  DSSlideCreator.frxDBDataset.DataSet := FConn.Query;

  DSSlideCreator.frxPPTXExport.FileName := FileName;
  DSSlideCreator.frxPPTXExport.DefaultPath := ExtractFilePath(ParamStr(0)) + 'reports\';

  with DSSlideCreator.frxReportPPTX do
  begin
    Variables['txt_welcome'] := QuotedStr('Seja muito bem vindo!');
    Variables['txt_title']  := QuotedStr(FConn.Query.FieldByName('TITLE').AsString);
    Variables['txt_parish']  := QuotedStr(FConn.Query.FieldByName('PARISH_NAME').AsString);
    Variables['txt_date']  := QuotedStr(FConn.Query.FieldByName('MASS_DATE').AsString);

//    if ( FileExists(ExtractFilePath(ParamStr(0)) + '\images\harsoft.png') and (FindComponent('logoImg')<> nil ) ) then  //imagem do relatorio
//          TfrxPictureView(FindComponent('logoImg')).Picture.LoadFromFile(ExtractFilePath(ParamStr(0)) + '\images\harsoft.png');
    PrepareReport;
    PrintOptions.ShowDialog := False;
    DSSlideCreator.frxPPTXExport.ShowDialog := False;
    DSSlideCreator.frxPPTXExport.OpenAfterExport := False;
    DSSlideCreator.frxReportPPTX.Export(DSSlideCreator.frxPPTXExport);
    Result := TPath.Combine(DSSlideCreator.frxPPTXExport.DefaultPath, FileName);
  end;
end;

destructor TMass.Destroy;
begin
  if Assigned(FConn) then
    FreeAndNil(FConn);
  inherited;
end;

/// <summary> Return the File in JSON format
/// </summary>
function TMass.DownloadSlide(Mass_ID: Integer): TJSONArray;
var
  FStream : TFileStream;
  FilePath : String;
begin
  FilePath := ExtractFilePath(ParamStr(0)) + 'reports\Missa_'+Mass_ID.ToString+'.pptx';
  FStream := TFileStream.Create(FilePath, fmOpenRead);
  try
    if not FileExists(FilePath) then
      raise Exception.Create('Server: Arquivo n�o encontrado em:'+FilePath)
    else
      Result := TDBXJSONTools.StreamToJSON(FStream, 0, FStream.Size);
  finally
    FreeAndNil(FStream);
  end;
end;

end.
