unit uSong;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  uBase, FMX.Layouts, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, FMX.Controls.Presentation,
  FMX.Objects, FMX.Edit;

type
  TFrm_Songs = class(TFormBase)
    Rectangle1: TRectangle;
    Label1: TLabel;
    LV: TListView;
    lbl_info: TLabel;
    Ani: TAniIndicator;
    Rectangle5: TRectangle;
    Edt_Search: TEdit;
    SearchEditButton1: TSearchEditButton;
    ClearEditButton1: TClearEditButton;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure SearchEditButton1Click(Sender: TObject);
    procedure LVScrollViewChange(Sender: TObject);
    procedure Edt_SearchKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure ClearEditButton1Click(Sender: TObject);
    procedure LVPullRefresh(Sender: TObject);
    procedure LVItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
  private
    Page : SmallInt;
    procedure Insert_LVItem_Song(AID: Integer; AName, AArtist, ALink: String);
  public
    procedure LoadSongs(Text : String);
  end;

var
  Frm_Songs: TFrm_Songs;

implementation

{$R *.fmx}

uses DS_Functions, Data.FireDACJSONReflect, FireDAC.Comp.Client, uClientModule,
  uHome, Lib_General;

/// <summary> Insert the ListViewItem in the LV
/// </summary>
procedure TFrm_Songs.ClearEditButton1Click(Sender: TObject);
begin
  inherited;
  Page := 1;
  LV.Items.Clear;
  LoadSongs('');
end;

procedure TFrm_Songs.Edt_SearchKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  if Key = vkReturn then
    SearchEditButton1Click(self);
end;

procedure TFrm_Songs.FormCreate(Sender: TObject);
begin
  inherited;
  Page := 1;
  LV.Items.Clear;
  LoadSongs('');
end;

procedure TFrm_Songs.FormKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  if Key = vkHardwareBack then
  begin
    Key := 0;
    OpenForm(TFrm_Home);
  end;
end;

procedure TFrm_Songs.Insert_LVItem_Song(AID : Integer; AName, AArtist, ALink: String);
var
  AItem : TListViewItem;
begin
  LV.BeginUpdate;
  with AItem do
  begin
    AItem := LV.Items.Add;

    Data['song'] := AName;
    Data['artist'] := AArtist;
    Data['link'] := ALink;
    Tag := AID;
  end;
  LV.EndUpdate;
end;

/// <summary> Load the songs on the LV. If Text is empty, return all songs with
/// by page, else return the query by page
/// </summary>
procedure TFrm_Songs.LoadSongs(Text : String);
begin
  Ani.Visible := True;
  Ani.Enabled := True;
  TThread.CreateAnonymousThread(procedure
  var
    DS : TFDJSONDataSets;
    MT : TFDMemTable;
    Song : TSongClient;
  begin
    if not DM_DataSnap.DSConn.Connected then
     DM_DataSnap.DSConn.Connected := True;
    MT := TFDMemTable.Create(nil);
    Song := TSongClient.Create(DM_DataSnap.DSConn.DBXConnection);
    try
      try
        DS := Song.Get_Songs(Page, Text);
        MT.Active := False;
        MT.AppendData(TFDJSONDataSetsReader.GetListValue(DS, 0));
        MT.Active := True;

        TThread.Synchronize(nil, procedure
        begin
          while not MT.Eof do
          with MT do
          begin
            Insert_LVItem_Song(FieldByName('SONG_ID').AsInteger,
                               FieldByName('SONG_TITLE').AsString,
                               FieldByName('ARTIST_NAME').AsString,
                               FieldByName('AUDIO_LINK').AsString);
            Next;
          end;
          Ani.Enabled := False;
          Ani.Visible := False;
        end);
      except on e : exception do
        TThread.Synchronize(nil, procedure
        begin
          Ani.Enabled := False;
          Ani.Visible := False;
          ShowMessage(e.Message);
        end);
      end;
    finally
      if DM_DataSnap.DSConn.Connected then
        DM_DataSnap.DSConn.Connected := False;
      FreeAndNil(MT);
      FreeAndNil(Song);
    end;
  end).Start;
end;

procedure TFrm_Songs.LVItemClickEx(const Sender: TObject; ItemIndex: Integer;
  const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
begin
  inherited;
  if ItemObject.Name = 'link' then
  begin
    OpenYouTubeVideo(ItemObject.Data.AsString);
  end;
end;

procedure TFrm_Songs.LVPullRefresh(Sender: TObject);
begin
  inherited;
  Page := 1;
  LV.Items.Clear;
  LoadSongs(Edt_Search.Text);
end;

procedure TFrm_Songs.LVScrollViewChange(Sender: TObject);
var
  nTop, scrollTot: single;
begin
  nTop := LV.GetItemRect(LV.ItemCount - 1).top +
    LV.ScrollViewPos - LV.SideSpace - LV.LocalRect.top;
  scrollTot := nTop + LV.GetItemRect(LV.ItemCount - 1).height -
    LV.height;
  if LV.ScrollViewPos = scrollTot then
  begin
    TThread.CreateAnonymousThread(
      procedure
      begin
        TThread.Synchronize(nil,
          procedure
          begin
            Inc(Page, 1);
            if Edt_Search.Text.IsEmpty then
              LoadSongs('')
            else
              LoadSongs(Edt_Search.Text);
          end);
      end).Start;
  end;
end;

procedure TFrm_Songs.SearchEditButton1Click(Sender: TObject);
begin
  inherited;
  Page := 1;
  LV.Items.Clear;
  LoadSongs(Edt_Search.Text);
end;

end.
