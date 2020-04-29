package masteryMenu
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	public dynamic class closePopupButton_2 extends MovieClip
	{
		 
		
		public var bg_mc:MovieClip;
		
		public var base:MovieClip;
		
		public function closePopupButton_2()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onOut(param1:MouseEvent) : *
		{
			removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			this.bg_mc.gotoAndStop(1);
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
			ExternalInterface.call("PlaySound","UI_Generic_Click");
			ExternalInterface.call("buttonPressed",2,0);
		}
		
		public function onDown(param1:MouseEvent) : *
		{
			addEventListener(MouseEvent.MOUSE_UP,this.onUp);
			this.bg_mc.gotoAndStop(3);
		}
		
		function frame1() : *
		{
			addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			addEventListener(MouseEvent.ROLL_OVER,this.onOver);
			addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
			this.base = parent as MovieClip;
		}
	}
}
