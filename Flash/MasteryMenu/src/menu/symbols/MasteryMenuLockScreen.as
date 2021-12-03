package menu.symbols
{
	import flash.display.MovieClip;
	
	public dynamic class MasteryMenuLockScreen extends MovieClip
	{
		public function MasteryMenuLockScreen()
		{
			super();
			this.addFrameScript(0,this.frame1);
		}
		
		internal function frame1() : void
		{
			this.stop();
			this.visible = false;
		}
	}
}