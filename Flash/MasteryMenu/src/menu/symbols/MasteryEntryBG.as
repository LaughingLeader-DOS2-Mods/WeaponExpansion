package menu.symbols
{
	import flash.display.MovieClip;
	
	public dynamic class MasteryEntryBG extends MovieClip
	{
		public function MasteryEntryBG()
		{
			super();
			this.addFrameScript(0,this.frame1);
		}
		
		internal function frame1() : void
		{
			this.stop();
		}
	}
}
