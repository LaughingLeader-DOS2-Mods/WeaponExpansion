package
{
	import LS_Classes.tooltipHelper;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	public dynamic class ToggleMenuButton extends MovieClip
	{	
		public var button_mc:MovieClip;
		public var bg_mc:MovieClip;
	
		public function ToggleMenuButton()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onOut(param1:MouseEvent) : *
		{
			ExternalInterface.call("hideTooltip");
			this.button_mc.hasTooltip = false;
			this.button_mc.removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			this.button_mc.gotoAndStop(1);
		}
		
		public function onOver(param1:MouseEvent) : *
		{
			this.button_mc.gotoAndStop(2);
			ExternalInterface.call("PlaySound","UI_Generic_Over");
			tooltipHelper.ShowTooltipForMC(this.button_mc,root,"right");
		}
		
		public function onDown(param1:MouseEvent) : *
		{
			this.button_mc.addEventListener(MouseEvent.MOUSE_UP,this.onUp);
			this.button_mc.gotoAndStop(3);
		}
		
		public function onUp(param1:MouseEvent) : *
		{
			this.button_mc.removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			ExternalInterface.call("PlaySound","UI_Generic_Click");
			ExternalInterface.call("toggleMasteryMenu");
			this.button_mc.gotoAndStop(2);
		}

		public function setTooltip(text:String) : *
		{
			this.button_mc.tooltip = text;
			//this.button_mc.tooltipYOffset = -10.0;
		}
		
		function frame1() : *
		{
			this.button_mc.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			this.button_mc.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
			this.button_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
		}
	}
}
