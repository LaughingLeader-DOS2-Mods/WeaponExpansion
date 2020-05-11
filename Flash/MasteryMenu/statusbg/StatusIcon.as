package statusbg
{
	import flash.display.MovieClip;
	
	public dynamic class StatusIcon extends MovieClip
	{
		public function StatusIcon()
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