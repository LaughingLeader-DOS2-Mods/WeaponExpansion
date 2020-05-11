package desc
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;

	public dynamic class DescriptionIcon extends MovieClip
	{
		public var id:String;
		public var icon:String;
		public var icon_mc:IconDisplay;
		public var iconType:int = 0
		public var hasTooltip:Boolean = false;

		public var statusbg_mc:MovieClip;

		public function DescriptionIcon()
		{
			super();
			addFrameScript(0,this.frame1);
		}

		internal function frame1() : *
		{
			stop();

			//statusbg_mc.visible = false;
		}

		public function createIcon(w:int=64,h:int=64) : *
		{
			if (this.iconType == 2)
			{
				w = 40;
				h = 40;
				statusbg_mc = new StatusBackground();
				this.addChild(statusbg_mc);
			}
			icon_mc = new IconDisplay(icon,w,h);
			addChild(icon_mc);

			this.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			this.addEventListener(MouseEvent.ROLL_OVER,this.onOver);

			this.icon_mc.width = w;
			this.icon_mc.height = h;
		}

		public function setAltBackground() : *
		{
			statusbg_mc = new StatusBackgroundAlt();
			statusbg_mc.width = 51;
			statusbg_mc.height = 51;
			this.addChild(statusbg_mc);
			icon_mc.x = 5.5;
			icon_mc.y = 5.5;
		}

		public function onOver(e:MouseEvent) : *
		{
			if (!this.hasTooltip)
			{
				var pos:Point = this.localToGlobal(new Point(0,0));
				ExternalInterface.call("mastery_showIconTooltip",iconType,id,pos.x,pos.y,width,height);
				this.hasTooltip = true;
			}
		}

		public function onOut(e:MouseEvent) : *
		{
			if (this.hasTooltip)
			{
				ExternalInterface.call("hideTooltip");
				ExternalInterface.call("mastery_hideIconTooltip",iconType);
				this.hasTooltip = false;
			}
		}
	}
}