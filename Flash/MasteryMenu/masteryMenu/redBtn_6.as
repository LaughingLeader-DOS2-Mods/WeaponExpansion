package masteryMenu
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class redBtn_6 extends MovieClip
	{
		public var bg_mc:MovieClip;
		
		public var text_txt:TextField;
		
		public var base:MovieClip;
		
		public var buttonType:Number;
		public var buttonCallback:String = "buttonPressed";
		
		public var buttonState:Boolean;
		
		public var disableTxt:String;
		
		public var enableTxt:String;
		
		public var textY:Number;
		
		public function redBtn_6()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function setButtonType(param1:Number) : *
		{
			this.buttonType = param1;
			this.text_txt.y = this.textY;
		}

		public function setButtonEvent(eventName:String) : *
		{
			this.buttonCallback = eventName;
		}
		
		public function setToggleText(param1:String, param2:String) : *
		{
			this.enableTxt = param1;
			this.disableTxt = param2;
		}
		
		public function onOut(param1:MouseEvent) : *
		{
			removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			this.bg_mc.gotoAndStop(1);
			this.text_txt.y = this.textY;
		}
		
		public function onOver(param1:MouseEvent) : *
		{
			this.bg_mc.gotoAndStop(2);
			ExternalInterface.call("PlaySound","UI_Generic_Over");
		}
		
		public function onUp(param1:MouseEvent) : *
		{
			removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			this.bg_mc.gotoAndStop(2);
			this.text_txt.y = this.textY;
			ExternalInterface.call("PlaySound","UI_Generic_Click");
			if(this.buttonType == 0)
			{
				this.buttonState = !this.buttonState;
				this.text_txt.htmlText = !!this.buttonState?this.enableTxt:this.disableTxt;
			}
			ExternalInterface.call(this.buttonCallback,this.buttonType,this.buttonState);
		}
		
		public function onDown(param1:MouseEvent) : *
		{
			addEventListener(MouseEvent.MOUSE_UP,this.onUp);
			this.bg_mc.gotoAndStop(3);
			this.text_txt.y = this.textY + 2;
		}
		
		function frame1() : *
		{
			addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			addEventListener(MouseEvent.ROLL_OVER,this.onOver);
			addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
			this.base = parent as MovieClip;
			this.buttonType = 3;
			this.buttonState = false;
			this.textY = 12;
		}
	}
}
