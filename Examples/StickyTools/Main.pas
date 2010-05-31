unit Main;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, StdCtrls, AccessQuery, AQPControlAnimations, AQPMessages;

type
	TMainForm = class(TForm)
		Label1:TLabel;
		AnimateCheckBox:TCheckBox;
		procedure FormCreate(Sender:TObject);
		procedure AnimateCheckBoxClick(Sender:TObject);
	end;

var
	MainForm:TMainForm;

implementation

{$R *.dfm}

uses
	Tools, AQPStickyTools;

procedure TMainForm.AnimateCheckBoxClick(Sender: TObject);
begin
	TAQPStickyTools.AnimateStick:=AnimateCheckBox.Checked;
end;

procedure TMainForm.FormCreate(Sender:TObject);
var
	PaddingLeft, PaddingTop, ExitSizeMoveCount, WindowPosChangedCount:Integer;
	BlinkEach:TEachFunction;
begin
	PaddingLeft:=GetSystemMetrics(SM_CXSIZEFRAME)
		+ GetSystemMetrics(SM_CXBORDER)
		+ GetSystemMetrics(SM_CXPADDEDBORDER)
		+ 1;
	PaddingTop:=GetSystemMetrics(SM_CYSIZEFRAME)
		+ GetSystemMetrics(SM_CYBORDER)
		+ GetSystemMetrics(SM_CXPADDEDBORDER)
		+ 1;

	with TToolsForm.Create(Self) do
	begin
		PopupParent:=Self;
		Top:=Self.Top;
		Left:=Self.Left - 80 - PaddingLeft;
		Height:=300;
		Width:=80;
		Show;
	end;

	with TToolsForm.Create(Self) do
	begin
		PopupParent:=Self;
		Top:=Self.Top + Self.Height + PaddingTop;
		Left:=Self.Left;
		Height:=80;
		Width:=Self.Width;
		Show;
	end;

	with TToolsForm.Create(Self) do
	begin
		PopupParent:=Self;
		Top:=Self.Top + PaddingTop + GetSystemMetrics(SM_CYCAPTION) - 1;
		Left:=Self.Left + Self.ClientWidth - 202;
		Height:=200;
		Width:=200;
		Show;
	end;

	Take(Self)
		.ChildrenChain
			.FilterChain(TToolsForm)
				.Plugin<TAQPStickyTools>
				.WorkAQ
			.EndChain
			.Die
		.EndChain
	.Die;

	ExitSizeMoveCount:=0;
	WindowPosChangedCount:=0;
	with Take(Self).Plugin<TAQPMessages> do
	begin
		EachMessage(WM_EXITSIZEMOVE,
			function(AQ:TAQ; O:TObject; Message:TMessage):Boolean
			begin
				Inc(ExitSizeMoveCount);
				Caption:='WM_EXITSIZEMOVE ' + IntToStr(ExitSizeMoveCount);
				Result:=TRUE;
			end, 111);
		EachMessage(WM_WINDOWPOSCHANGED,
			function(AQ:TAQ; O:TObject; Message:TMessage):Boolean
			begin
				Inc(WindowPosChangedCount);
				Caption:='WM_WINDOWPOSCHANGED ' + IntToStr(WindowPosChangedCount);
				Result:=TRUE;
			end, 111);
	end;

	BlinkEach:=function(AQ:TAQ; O:TObject):Boolean
	var
		TargetColor:TColor;
	begin
		if TLabel(O).Font.Color = clBlack then
			TargetColor:=clRed
		else
			TargetColor:=clBlack;

		AQ
			.Plugin<TAQPControlAnimations>
			.FontColorAnimation(TargetColor, 500, 0, TAQ.Ease(etQuadratic),
			 procedure(Sender:TObject)
			 begin
				Take(Sender).EachDelay(200, BlinkEach);
			 end);
		Result:=FALSE;
	end;

	Take(Label1).Each(BlinkEach);
end;

end.