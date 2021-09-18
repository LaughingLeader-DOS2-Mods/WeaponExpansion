package desc
{
	import flash.display.MovieClip;
	
	public dynamic class StatusBackground extends MovieClip
	{

		public function StatusBackground()
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