package masteryMenu
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import LS_Classes.tooltipHelper;
	import flash.external.ExternalInterface;
	
	public dynamic class MasteryBarRankNode extends MovieClip
	{
		public var crystal_mc:MovieClip;
		public var isUnlocked:Boolean = false;

		public function MasteryBarRankNode()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onOut(param1:MouseEvent) : *
		{
			if(!this.isUnlocked)
			{
				crystal_mc.gotoAndStop(1);
			}
			else
			{
				crystal_mc.gotoAndStop(3);
			}
			ExternalInterface.call("hideTooltip");
			this.hasTooltip = false;
		}
		
		public function onOver(param1:MouseEvent) : *
		{
			if(!this.isUnlocked)
			{
				crystal_mc.gotoAndStop(2);
			}
			else
			{
				crystal_mc.gotoAndStop(4);
			}
			//ExternalInterface.call("PlaySound","UI_Generic_Over");
			tooltipHelper.ShowTooltipForMC(this,root,"right");
		}

		public function setTooltip(text:String) : *
		{
			this.tooltip = text;
		}

		public function setUnlocked(unlocked:Boolean) : *
		{
			this.isUnlocked = unlocked;
			if (unlocked)
			{
				crystal_mc.gotoAndStop(3);
			}
			else
			{
				crystal_mc.gotoAndStop(1);
			}
		}
		
		internal function frame1() : *
		{
			this.stop();
			this.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			this.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
		}
	}
}