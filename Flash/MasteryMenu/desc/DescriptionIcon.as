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

		public function DescriptionIcon()
		{
			super();
			addFrameScript(0,this.frame1);
		}

		internal function frame1() : *
		{
			stop();

			addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			addEventListener(MouseEvent.ROLL_OVER,this.onOver);
		}

		public function createIcon(w:int=64,h:int=64) : *
		{
			icon_mc = new IconDisplay(icon,w,h);
			addChild(icon_mc);
		}

		public function onOver(e:MouseEvent) : *
		{
			if (id != "" && iconType > 0)
			{
				var pos:Point = this.localToGlobal(new Point(0,0));
				ExternalInterface.call("mastery_showIconTooltip", iconType,id,pos.x,pos.y,width,height);
			}
		}

		public function onOut(e:MouseEvent) : *
		{
			if (id != "" && iconType > 0)
			{
				ExternalInterface.call("hideTooltip");
				ExternalInterface.call("mastery_hideIconTooltip", iconType);
			}
		}
	}
}