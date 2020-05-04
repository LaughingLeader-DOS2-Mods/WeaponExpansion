package masteryMenu
{
	import flash.display.MovieClip;
	
	public dynamic class masteryMenu_lockScreen extends MovieClip
	{
		public function masteryMenu_lockScreen()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		function frame1() : *
		{
			stop();
			this.visible = false;
		}
	}
}