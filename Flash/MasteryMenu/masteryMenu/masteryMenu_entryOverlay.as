package masteryMenu
{
	import flash.display.MovieClip;
	
	public dynamic class masteryMenu_entryOverlay extends MovieClip
	{
		 
		
		public function masteryMenu_entryOverlay()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		function frame1() : *
		{
			stop();
		}
	}
}
