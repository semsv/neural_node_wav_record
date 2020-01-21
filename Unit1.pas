

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, MMSystem;

type
  TData8 = array [0..127] of byte;
  PData8 = ^TData8;
  TData16 = array [0..127] of smallint;
  PData16 = ^TData16;
  TPointArr = array [0..127] of TPoint;
  PPointArr = ^TPointArr;
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    PaintBox1: TPaintBox;
    CheckBox1: TCheckBox;
    TrackBar1: TTrackBar;
    Image1: TImage;
    Timer1: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    procedure OnWaveIn(var Msg: TMessage); message MM_WIM_DATA;
end;

var
  Form1: TForm1;

implementation
{$R *.DFM}
Uses Unit2;

var
  WaveIn: hWaveIn;
  hBuf: THandle;
  BufHead: TWaveHdr;
  bufsize: integer;
  Bits16: boolean;
  p: PPointArr;
  stop: boolean = false;
  curr_index : integer;

procedure TForm1.Button1Click(Sender: TObject);
var
  header: TWaveFormatEx;
  BufLen: word;
  buf: pointer;
begin
  BufSize := TrackBar1.Position * 500 + 100; { Ðàçìåð áóôåðà }
  Bits16 := CheckBox1.Checked;
  with header do
  begin
    wFormatTag := WAVE_FORMAT_PCM;
    nChannels := 1; { êîëè÷åñòâî êàíàëîâ }
    nSamplesPerSec := 22050; { ÷àñòîòà }
    wBitsPerSample := integer(Bits16) * 8 + 8; { 8 / 16 áèò }
    nBlockAlign := nChannels * (wBitsPerSample div 8);
    nAvgBytesPerSec := nSamplesPerSec * nBlockAlign;
    cbSize := 0;
  end;
  WaveInOpen(Addr(WaveIn), WAVE_MAPPER, addr(header),
  Form1.Handle, 0, CALLBACK_WINDOW);
  BufLen := header.nBlockAlign * BufSize;
  hBuf := GlobalAlloc(GMEM_MOVEABLE and GMEM_SHARE, BufLen);
  Buf := GlobalLock(hBuf);
  with BufHead do
  begin
    lpData := Buf;
    dwBufferLength := BufLen;
    dwFlags := WHDR_BEGINLOOP;
  end;
  WaveInPrepareHeader(WaveIn, Addr(BufHead), sizeof(BufHead));
  WaveInAddBuffer(WaveIn, addr(BufHead), sizeof(BufHead));
  GetMem(p, BufSize * sizeof(TPoint));
  stop := true;
  WaveInStart(WaveIn);
  timer1.Enabled := true;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if stop = false then
    Exit;
  stop := false;
  while not stop do
    Application.ProcessMessages;
  stop := false;
  WaveInReset(WaveIn);
  WaveInUnPrepareHeader(WaveIn, addr(BufHead), sizeof(BufHead));
  WaveInClose(WaveIn);
  GlobalUnlock(hBuf);
  GlobalFree(hBuf);
  FreeMem(p, BufSize * sizeof(TPoint));
  form1.Caption := '';
  timer1.Enabled := false;
end;

procedure TForm1.OnWaveIn;
var
  i: integer;
  data8: PData8;
  data16: PData16;
  h: integer;
  XScale, YScale: single;

  RESULT_MAX : single;
  RESULT_MIN : single;
  flag   : boolean;
begin
  h := PaintBox1.Height;
  XScale := PaintBox1.Width / BufSize;
  if Bits16 then
  begin
    data16 := PData16(PWaveHdr(Msg.lParam)^.lpData);
    YScale := h / (1 shl 16);
    for i := 0 to BufSize - 1 do
      p^[i] := Point(round(i * XScale),
    round(h / 2 - data16^[i] * YScale));
  end
  else
  begin
    Data8 := PData8(PWaveHdr(Msg.lParam)^.lpData);
    YScale := h / (1 shl 8);
    for i := 0 to BufSize - 1 do
      p^[i] := Point(round(i * XScale),
    round(h - data8^[i] * YScale));
  end;
  (*
  with PaintBox1.Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(ClipRect);
    Rectangle(0, round(h / 2) - round(h / 8), PaintBox1.Width, round(h / 2) - round(h / 4));
    Rectangle(0, round(h / 2) + round(h / 8), PaintBox1.Width, round(h / 2) + round(h / 4));
    Polyline(Slice(p^, BufSize));
  end;   (**)
  with image1.Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(ClipRect);
    Rectangle(0, round(h / 2) - round(h / 8), PaintBox1.Width, round(h / 2) - round(h / 4));
    Rectangle(0, round(h / 2) + round(h / 8), PaintBox1.Width, round(h / 2) + round(h / 4));
    Polyline(Slice(p^, BufSize));
  end;
  RESULT_MAX := 0;
  RESULT_MIN := h;
  flag := true;
(*   flag := false; for i := 0 to BufSize - 1 do
  begin
    if (p^[i].Y > round(h / 4)) and
       (p^[i].Y < round(h / 2))  then
    begin
      flag := true;
      break;
    end;
  end; *)
  if flag then
  begin
    for i := 0 to BufSize - 1 do
    begin
      if RESULT_MAX < p^[i].Y then
        RESULT_MAX := p^[i].Y;
      if RESULT_MIN > p^[i].Y then
        RESULT_MIN := p^[i].Y;
    end;
    if RESULT_MAX - RESULT_MIN > 20 then
      begin


        label4.Caption := inttostr( Load_Node_Array_From_Image( image1 ) );
        compare_xy_in_node;
//        image1.Picture.SaveToFile( Format('c:\tmp\%da.bmp', [curr_index]));
        curr_index := curr_index + 1;
      end;  
  end;

  if stop then
    WaveInAddBuffer(WaveIn, PWaveHdr(Msg.lParam), SizeOf(TWaveHdr))
  else
    stop := true;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Button2.Click;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  if stop then
  begin
    Button2.Click;
    Button1.Click;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  curr_index := 1;
  TrackBar1.OnChange := CheckBox1Click;
  Button1.Caption := 'Start';
  Button2.Caption := 'Stop';
  CheckBox1.Caption := '16 / 8 bit';
  Setup_Neural_Network('Ïðèâåò!');
  switch := 0;
  label2.Caption := inttostr(switch);
end;

// AVal - ìàññèâ àíàëèçèðóåìûõ äàííûõ, Nvl - äëèíà ìàññèâà, äîëæíà áûòü êðàòíà ñòåïåíè 2.
// FTvl - ìàññèâ ïîëó÷åííûõ çíà÷åíèé, Nft - äëèíà ìàññèâà, äîëæíà áûòü ðàâíà Nvl / 2 èëè ìåíüøå.

type
  TArrayValues = array of Double;

const
  TwoPi = 6.283185307179586;
procedure FFTAnalysis(var AVal, FTvl: TArrayValues; Nvl, Nft: Integer);
var
  i, j, n, m, Mmax, Istp: Integer;
  Tmpr, Tmpi, Wtmp, Theta: Double;
  Wpr, Wpi, Wr, Wi: Double;
  Tmvl: TArrayValues;
begin
  n:= Nvl * 2; SetLength(Tmvl, n);

  for i:= 0 to Nvl-1 do begin
    j:= i * 2; Tmvl[j]:= 0; Tmvl[j+1]:= AVal[i];
  end;

  i:= 1; j:= 1;
  while i < n do begin
    if j > i then begin
      Tmpr:= Tmvl[i]; Tmvl[i]:= Tmvl[j]; Tmvl[j]:= Tmpr;
      Tmpr:= Tmvl[i+1]; Tmvl[i+1]:= Tmvl[j+1]; Tmvl[j+1]:= Tmpr;
    end;
    i:= i + 2; m:= Nvl;
    while (m >= 2) and (j > m) do begin
      j:= j - m; m:= m div 2;
    end;
    j:= j + m;
  end;

  Mmax:= 2;
  while n > Mmax do begin
    Theta:= -TwoPi / Mmax; Wpi:= Sin(Theta);
    Wtmp:= Sin(Theta / 2); Wpr:= Wtmp * Wtmp * 2;
    Istp:= Mmax * 2; Wr:= 1; Wi:= 0; m:= 1;

    while m < Mmax do begin
      i:= m; m:= m + 2; Tmpr:= Wr; Tmpi:= Wi;
      Wr:= Wr - Tmpr * Wpr - Tmpi * Wpi;
      Wi:= Wi + Tmpr * Wpi - Tmpi * Wpr;

      while i < n do begin
        j:= i + Mmax;
        Tmpr:= Wr * Tmvl[j] - Wi * Tmvl[j-1];
        Tmpi:= Wi * Tmvl[j] + Wr * Tmvl[j-1];

        Tmvl[j]:= Tmvl[i] - Tmpr; Tmvl[j-1]:= Tmvl[i-1] - Tmpi;
        Tmvl[i]:= Tmvl[i] + Tmpr; Tmvl[i-1]:= Tmvl[i-1] + Tmpi;
        i:= i + Istp;
      end;
    end;

    Mmax:= Istp;
  end;

  for i:= 0 to Nft-1 do begin
    j:= i * 2; FTvl[ i ]:= 2*Sqrt(Sqr(Tmvl[j]) + Sqr(Tmvl[j+1]))/Nvl;
  end;

  SetLength(Tmvl, 0);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
 if stop = false then exit;

 if switch = 0 then
 switch := 1 else
 begin
   switch := 0;
   label6.Caption := inttostr( delete_broken_node ); // ïðè ïåðåõîäå ñ åäèíèöû íà íîëü óäàëÿåì ñëîìàííûå íîäû
 end;

 timer1.Enabled := false;
 label2.Caption := inttostr(switch);
 button2.Click;
end;

end.
