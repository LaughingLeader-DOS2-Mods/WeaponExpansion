package masteryMenu
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class MasteryEntryFrame extends MovieClip
	{
		public var bottom_decor:MovieClip;
		
		public var bg_mc:MovieClip;
		
		public var title_txt:TextField;
		
		public var top_decor:MovieClip;
		
		public var masteryEntry:MovieClip;
		
		public var buttonType:Number;

		public var selected:Boolean = false;
		
		public function MasteryEntryFrame()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onOut(e:MouseEvent) : *
		{
			if(!selected)
			{
				this.bg_mc.gotoAndStop(1);
			}
		}
		
		public function onOver(e:MouseEvent) : *
		{
			if(!selected)
			{
				this.bg_mc.gotoAndStop(2);
			}
		}

		public function onDown(e:MouseEvent) : *
		{
			this.select();
		}

		public function select(): *
		{
			this.selected = true;
			this.bg_mc.gotoAndStop(3);
		}

		public function deselect(): *
		{
			this.selected = false;
			this.bg_mc.gotoAndStop(1);
		}
		
		internal function frame1() : *
		{
			stop();
			this.masteryEntry = MovieClip(this.parent);
			this.buttonType = 1;
		}
	}
}
