package desc
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import iggy.IggyIcon;
	import iggy.IggyStatusIcon;

	public dynamic class DescriptionIcon extends MovieClip
	{
		public var id:String;
		public var icon:String;
		public var icon_mc:MovieClip;
		public var iconType:int = 0
		public var hasTooltip:Boolean = false;

		public var statusbg_mc:MovieClip;

		public function DescriptionIcon()
		{
			super();
			addFrameScript(0,this.frame1);
		}

		//Deprecated
		public function createIcon_symbol(w:int=64,h:int=64) : void
		{
			if (this.iconType >= 2)
			{
				w = 40;
				h = 40;
				if (this.iconType == 2)
				{
					this.statusbg_mc = new StatusBackground();
					this.addChild(this.statusbg_mc);
				}
			}
			this.icon_mc = new IconDisplay(icon,w,h);
			addChild(this.icon_mc);

			this.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			this.addEventListener(MouseEvent.ROLL_OVER,this.onOver);

			this.icon_mc.width = w;
			this.icon_mc.height = h;
		}

		public function createIcon(w:int=64,h:int=64) : void
		{
			if (this.iconType == 2)
			{
				this.statusbg_mc = new StatusBackground();
				this.addChild(this.statusbg_mc);
			}
			
			if (this.iconType >= 2)
			{
				this.icon_mc = new IggyStatusIcon();
			}
			else
			{
				this.icon_mc = new IggyIcon();
			}

			this.icon_mc.name = this.icon;
			this.addChild(icon_mc);

			this.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			this.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
		}

		public function setAltBackground() : void
		{
			this.statusbg_mc = new StatusBackgroundAlt();
			this.statusbg_mc.width = 51;
			this.statusbg_mc.height = 51;
			this.addChild(this.statusbg_mc);
			icon_mc.x = 5.5;
			icon_mc.y = 5.5;
		}

		public function onOver(e:MouseEvent) : *
		{
			if (!this.hasTooltip)
			{
				var pos:Point = this.localToGlobal(new Point(0,0));
				Registry.call("LLWEAPONEX_MasteryMenu_ShowIconTooltip",iconType,id,pos.x,pos.y,width,height);
				this.hasTooltip = true;
			}
		}

		public function onOut(e:MouseEvent) : *
		{
			if (this.hasTooltip)
			{
				Registry.call("hideTooltip");
				Registry.call("LLWEAPONEX_MasteryMenu_HideIconTooltip", iconType);
				this.hasTooltip = false;
			}
		}

		internal function frame1() : void
		{
			stop();
		}
	}
}