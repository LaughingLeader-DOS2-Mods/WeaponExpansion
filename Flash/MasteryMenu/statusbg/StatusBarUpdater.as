package statusbg
{
	import flash.display.MovieClip;
	
	public dynamic class StatusBarUpdater extends MovieClip
	{
		public function StatusBarUpdater()
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