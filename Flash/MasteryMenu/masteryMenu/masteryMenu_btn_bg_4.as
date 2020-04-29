package masteryMenu
{
	import flash.display.MovieClip;
	
	public dynamic class masteryMenu_btn_bg_4 extends MovieClip
	{
		 
		
		public function masteryMenu_btn_bg_4()
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
		
		function frame1() : *
		{
			stop();
		}
	}
}
