unit TWebButton;

interface

uses
  SysUtils, Classes, Controls, Buttons, Messages, Windows, StdCtrls, Graphics,
  Dialogs;

type
  TWebSpeedButton = class(TGraphicControl)
  private
    { Private declarations }
    FMouseInControl: boolean;
    FAlignment: TAlignment;
    FBevel: Integer;
    FGlyphWidth: Integer;
    FGlyphHeight: Integer;
    FSpaceWidth: Integer;
    FGlyph: TBitmap;
    FDown: boolean;
    FSelectColor: TColor;
    FActiveColor: TColor;
    FSelectFontColor: TColor;
    FActiveFontColor: TColor;
    FDisableFontColor: TColor;
    FSwitcher: boolean;
    FMargin: Integer;
    FGroupIndex: Integer;
    procedure SetColor(Index: Integer; NewColor: TColor);
    function GetColor(Index: Integer): TColor;
    procedure SetGlyph(Value: TBitmap);
    procedure SetDown(Value: boolean);
    procedure SetMargin(Value: Integer);
    procedure SetSpaceWidth(Value: Integer);
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMButtonPressed(var Message: TMessage); message CM_BUTTONPRESSED;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMSysColorChange(var Message: TMessage); message CM_SYSCOLORCHANGE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
  protected
    { Protected declarations }
    procedure Paint; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
  published
    { Published declarations }
    property Caption;
    property Aligment: TAlignment read FAlignment write FAlignment;
    property Glyph: TBitmap read FGlyph write SetGlyph;
    property Color;
    property SelectColor: TColor index 1 read GetColor write SetColor;
    property ActiveColor: TColor index 2 read GetColor write SetColor;
    property Font;
    property DisableFontColor: TColor index 5 read GetColor write SetColor;
    property SelectFontColor: TColor index 3 read GetColor write SetColor;
    property ActiveFontColor: TColor index 4 read GetColor write SetColor;
    property Enabled;
    property OnClick;
    property Down: boolean read FDown write SetDown default False;
    property Switcher: boolean read FSwitcher write FSwitcher default False;
    property Margin: Integer read FMargin write SetMargin default -1;
    property ShowHint;
    property GroupIndex: Integer read FGroupIndex write FGroupIndex default 0;
    property Align;
    property SpaceWidth: Integer read FSpaceWidth write SetSpaceWidth;
    property Bevel: integer read FBevel write FBevel;
  end;

procedure Register;

implementation


constructor TWebSpeedButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMouseInControl := False;
  FAlignment := taLeftJustify;
  FBevel := 5;
  FSpaceWidth := 2;
  FGlyphWidth := 16;
  FGlyphHeight := 16;
  FGlyph := TbitMap.Create;
  FGlyph.Assign(nil);
end;

destructor TWebSpeedButton.Destroy;
begin
  FGlyph.Free;
  inherited Destroy;
end;

procedure TWebSpeedButton.Paint;
var
  ClientRect: TRect;
  GlyphRect: TRect;
  TextRect: TRect;
  TotalWidth: integer;
  GlyphLeft: Integer;
  TextLeft: Integer;
  Space: Integer;
  DrawFlags: Cardinal;
  Buffer: TBitmap;
begin
  Buffer := TBitmap.Create;
  ClientRect := Canvas.ClipRect;
  try
    Buffer.Width := ClientRect.Right;
    Buffer.Height := ClientRect.Bottom;
    with Buffer do begin
      Canvas.Font := Self.Font;
      Canvas.Brush.Color := Self.Color;
      if Enabled then begin
        if FMouseInControl then begin
          Canvas.Brush.Color := FSelectColor;
          Canvas.Font.Color := FSelectFontColor;
        end;
        if FDown then begin
          Canvas.Brush.Color := FActiveColor;
          Canvas.Font.Color := FActiveFontColor;
        end;
      end else
        Canvas.Font.Color := FDisableFontColor;
      Canvas.FillRect(ClientRect);
      // Определяем размеры прямтоугольников для иконки и текста
      if (FGlyph = nil) or (FGlyph.Width = 0) or (FGlyph.Height = 0) then begin
        GlyphRect := Rect(0, 0, 0, 0);
        Space := 0;
      end else begin
        GlyphRect := Rect(0, 0, FGlyphWidth, FGlyphHeight);
        Space := FSpaceWidth;
      end;
      TextRect := Rect(0, 0, Canvas.TextWidth(Caption), Canvas.TextHeight(Caption));
      TotalWidth := GlyphRect.Right + TextRect.Right + Space;
      if TotalWidth > (ClientRect.Right - FBevel * 2) then begin
        TextRect.Right := ClientRect.Right - FBevel * 2 - GlyphRect.Right - Space;
        TotalWidth := GlyphRect.Right + TextRect.Right;
      end;
      // Определяем смещение прямоугольников по горизонтали
      GlyphLeft := 0;
      TextLeft := 0;
      case FAlignment of
        taLeftJustify: begin
          GlyphLeft := FBevel;
          TextLeft := GlyphLeft + GlyphRect.Right + Space;
        end;
        taRightJustify: begin
          GlyphLeft := ClientRect.Right - FBevel - GlyphRect.Right;
          TextLeft := GlyphLeft - TextRect.Right - Space;
        end;
        taCenter: begin
          GlyphLeft := trunc((ClientRect.Right - TotalWidth) / 2);
          TextLeft := GlyphLeft + GlyphRect.Right + Space;
        end;
      end;
      // Позиционируем прямоугольники
      OffsetRect(GlyphRect, GlyphLeft,
        trunc((ClientRect.Bottom - GlyphRect.Bottom) / 2));
      OffsetRect(TextRect, TextLeft,
        trunc((ClientRect.Bottom - TextRect.Bottom) / 2));
      if FDown and not FSwitcher then begin
        OffsetRect(GlyphRect, 1, 1);
        OffsetRect(TextRect, 1, 1);
      end;
      // Отрисовываем иконку и текст
      Canvas.Brush.Style := bsClear;
      if (FGlyph <> nil) and (FGlyph.Width <> 0) and (FGlyph.Height <> 0) then begin
        FGlyph.Transparent := True;
        FGlyph.TransparentMode := tmAuto;
        Canvas.Draw(GlyphRect.Left, GlyphRect.Top, FGlyph);
      end;
      DrawFlags := DT_SINGLELINE or DT_END_ELLIPSIS;
      DrawText(Canvas.Handle, PAnsiChar(Caption), Length(Caption),
        TextRect, DrawFlags);
    end;
    Self.Canvas.Draw(0, 0, Buffer);
  finally
    Buffer.Free;
  end;
end;

procedure TWebSpeedButton.SetColor(Index: Integer; NewColor: TColor);
begin
  case Index of
    1: FSelectColor := NewColor;
    2: FActiveColor := NewColor;
    3: FSelectFontColor := NewColor;
    4: FActiveFontColor := NewColor;
    5: FDisableFontColor := NewColor;
  end;
  Repaint;
end;

function TWebSpeedButton.GetColor(Index: Integer): TColor;
begin
  Result := clBlack;
  case Index of
    1: Result := FSelectColor;
    2: Result := FActiveColor;
    3: Result := FSelectFontColor;
    4: Result := FActiveFontColor;
    5: Result := FDisableFontColor;
  end;
end;

procedure TWebSpeedButton.SetSpaceWidth(Value: Integer);
begin
  FSpaceWidth := Value;
  Repaint;
end;

procedure TWebSpeedButton.SetGlyph(Value: TBitmap);
begin
  FGlyph.Assign(Value);
  Invalidate;
end;

procedure TWebSpeedButton.SetDown(Value: Boolean);
var
  Msg: TMessage;
begin
  FDown := Value;
  Invalidate;
  if (FGroupIndex <> 0) and (Parent <> nil) then begin
    Msg.Msg := CM_BUTTONPRESSED;
    Msg.WParam := FGroupIndex;
    Msg.LParam := Longint(Self);
    Msg.Result := 0;
    Parent.Broadcast(Msg);
  end;
end;

procedure TWebSpeedButton.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
end;

procedure TWebSpeedButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  FMouseInControl := Enabled;
  if Enabled then Repaint;
end;

procedure TWebSpeedButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FMouseInControl := False;
  if Enabled then Repaint;
end;

procedure TWebSpeedButton.CMEnabledChanged(var Message: TMessage);
begin
  Repaint;
end;

procedure TWebSpeedButton.CMButtonPressed(var Message: TMessage);
var
  Sender: TWebSpeedButton;
begin
  if Message.WParam = FGroupIndex then begin
    Sender := TWebSpeedButton(Message.LParam);
    if Sender <> Self then begin
      if Sender.Down and FDown then begin
        FDown := False;
        Invalidate;
      end;
    end;
  end;
end;

procedure TWebSpeedButton.CMDialogChar(var Message: TCMDialogChar);
begin
  {with Message do
    if IsAccel(CharCode, Caption) and Enabled and Visible and
      (Parent <> nil) and Parent.Showing then
    begin
      Click;
      Result := 1;
    end else
      inherited;  }
end;

procedure TWebSpeedButton.CMFontChanged(var Message: TMessage);
begin
  Invalidate;
end;

procedure TWebSpeedButton.CMSysColorChange(var Message: TMessage);
begin
  Invalidate;
end;

procedure TWebSpeedButton.WMLButtonDown(var Message: TWMLButtonUp);
begin
  if Enabled then begin
    if FSwitcher then SetDown(not FDown) else SetDown(True);
    Invalidate;
  end;
  inherited;
end;

procedure TWebSpeedButton.WMLButtonUp(var Message: TWMLButtonDown);
begin
  if Enabled and not FSwitcher then begin
    SetDown(False);
    Invalidate;
  end;
  inherited;
end;

procedure TWebSpeedButton.Click;
begin
  inherited Click;
end;

procedure TWebSpeedButton.SetMargin(Value: Integer);
begin
  if (Value <> FMargin) and (Value >= -1) then begin
    FMargin := Value;
    Invalidate;
  end;
end;


procedure Register;
begin
  RegisterComponents('Samples', [TWebSpeedButton]);
end;

end.
