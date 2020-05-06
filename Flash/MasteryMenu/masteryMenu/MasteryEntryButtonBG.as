package masteryMenu
{
	import flash.display.MovieClip;
	
	public dynamic class MasteryEntryButtonBG extends MovieClip
	{
		public function MasteryEntryButtonBG()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function setController(param1:Boolean) : *
		{
			if(param1)
			{
				gotoAndStop(1);
			}
			else
			{
				gotoAndStop(2);
			}
		}
		
		internal function frame1() : *
		{
			stop();
		}
	}
}
