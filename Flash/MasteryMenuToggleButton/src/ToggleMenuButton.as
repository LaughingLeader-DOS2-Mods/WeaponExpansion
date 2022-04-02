package
{
	import LS_Classes.tooltipHelper;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	public dynamic class ToggleMenuButton extends MovieClip
	{	
		public var graphic_mc:MovieClip;
		public var bg_mc:MovieClip;

		public var tooltip:String;
		public var tooltipYOffset:Number = -2;
	
		public function ToggleMenuButton()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onOut(e:MouseEvent) : void
		{
			MainTimeline.Instance.hasTooltip = false;
			ExternalInterface.call("hideTooltip");
			this.graphic_mc.removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			this.graphic_mc.gotoAndStop(1);
		}
		
		public function onOver(e:MouseEvent) : void
		{
			this.graphic_mc.gotoAndStop(2);
			ExternalInterface.call("PlaySound","UI_Generic_Over");
			tooltipHelper.ShowTooltipForMC(this, MainTimeline.Instance,"top");
		}
		
		public function onDown(e:MouseEvent) : void
		{
			this.graphic_mc.addEventListener(MouseEvent.MOUSE_UP,this.onUp);
			this.graphic_mc.gotoAndStop(3);
		}
		
		public function onUp(e:MouseEvent) : void
		{
			this.graphic_mc.removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			ExternalInterface.call("PlaySound","UI_Generic_Click");
			ExternalInterface.call("LLWEAPONEX_MasteryMenu_ToggleMasteryMenu");
			this.graphic_mc.gotoAndStop(2);
		}

		public function setTooltip(text:String) : void
		{
			this.tooltip = text;
		}
		
		internal function frame1() : void
		{
			this.graphic_mc.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			this.graphic_mc.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
			this.graphic_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);

			this.tooltipYOffset = this.tooltipYOffset - this.bg_mc.height;
		}
	}
}
