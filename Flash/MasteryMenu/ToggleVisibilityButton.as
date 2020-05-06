package
{
	import flash.display.MovieClip;
	
	public dynamic class ToggleVisibilityButton extends MovieClip
	{
		public var hasTooltip:Boolean;
		public var tooltipYOffset:Number = 0;

		public function ToggleVisibilityButton()
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