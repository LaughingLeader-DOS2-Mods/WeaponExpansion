package menu.symbols
{
	import flash.display.MovieClip;
	
	public dynamic class MasteryEntryButtonBG extends MovieClip
	{
		public function MasteryEntryButtonBG()
		{
			super();
			this.addFrameScript(0,this.frame1);
		}
		
		public function setController(enabled:Boolean) : void
		{
			if(enabled)
			{
				gotoAndStop(1);
			}
			else
			{
				gotoAndStop(2);
			}
		}
		
		internal function frame1() : void
		{
			this.stop();
		}
	}
}
