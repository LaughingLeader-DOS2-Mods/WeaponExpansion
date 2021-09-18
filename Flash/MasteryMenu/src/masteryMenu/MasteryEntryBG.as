package masteryMenu
{
	import flash.display.MovieClip;
	
	public dynamic class MasteryEntryBG extends MovieClip
	{
		 
		
		public function MasteryEntryBG()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		internal function frame1() : *
		{
			stop();
		}
	}
}
