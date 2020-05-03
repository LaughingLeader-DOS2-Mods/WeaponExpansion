package
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.filters.ColorMatrixFilter;
	import fl.motion.AdjustColor;
	import flash.events.MouseEvent;

	public dynamic class MasteryBarRankNode extends MovieClip
	{
		public var isUnlocked:Boolean = false;
		public var colorTransform:ColorTransform;

		public function MasteryBarRankNode()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onOut(param1:MouseEvent) : *
		{
			ExternalInterface.call("hideTooltip");
			this.gotoAndStop(1);
		}
		
		public function onOver(param1:MouseEvent) : *
		{
			this.gotoAndStop(2);
			//ExternalInterface.call("PlaySound","UI_Generic_Over");
			tooltipHelper.ShowTooltipForMC(this,root,"top");
		}

		public function setTooltip(text:String) : *
		{
			this.tooltip = text;
		}

		public function setUnlocked(unlocked:Boolean) : *
		{
			this.isUnlocked = unlocked;
			if (unlocked)
			{
				this.filters = new Array();
			}
			else
			{
				var adjustColor:AdjustColor = new AdjustColor();
				adjustColor.saturation = -100;
				adjustColor.brightness  = 50;
				adjustColor.contrast = 50;
				adjustColor.hue = 50;

				var matrix:Array = adjustColor.CalculateFinalFlatArray();
				var colorMatrix:ColorMatrixFilter = new ColorMatrixFilter(matrix);
				this.filters = [colorMatrix];
			}
			//this.transform.colorTransform = colorTransform;
		}
		
		function frame1() : *
		{
			this.stop();
			this.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			this.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
			//this.colorTransform = new ColorTransform();
			//this.colorTransform.color = 0xFFFFFF;
		}
	}
}