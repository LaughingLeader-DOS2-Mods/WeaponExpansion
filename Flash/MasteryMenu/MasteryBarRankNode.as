package
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.filters.ColorMatrixFilter;
	import fl.motion.AdjustColor;
	import flash.events.MouseEvent;
	import LS_Classes.tooltipHelper;
	import flash.external.ExternalInterface;
	
	public dynamic class MasteryBarRankNode extends MovieClip
	{
		public var crystal_mc:MovieClip;
		public var isUnlocked:Boolean = false;
		public var colorTransform:ColorTransform;

		public function MasteryBarRankNode()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onOut(param1:MouseEvent) : *
		{
			if(!this.isUnlocked)
			{
				crystal_mc.gotoAndStop(1);
			}
			ExternalInterface.call("hideTooltip");
		}
		
		public function onOver(param1:MouseEvent) : *
		{
			if(!this.isUnlocked)
			{
				crystal_mc.gotoAndStop(2);
			}
			//ExternalInterface.call("PlaySound","UI_Generic_Over");
			tooltipHelper.ShowTooltipForMC(this,root,"top");
		}

		public function setTooltip(text:String) : *
		{
			this.tooltip = text;
		}

		private var aMatrix:Array = [
			0, 0, 0, 0, 0xD5,
			0, 0, 0, 0, 0xE4,
			0, 0, 0, 0, 0x0D,
			0, 0, 0, 1, 0 
		];
		private var aYellow:ColorMatrixFilter = new ColorMatrixFilter(aMatrix);

		public function setUnlocked(unlocked:Boolean) : *
		{
			this.isUnlocked = unlocked;
			if (unlocked)
			{
				crystal_mc.filters = [aYellow];
				crystal_mc.gotoAndStop(2);
			}
			else
			{
				crystal_mc.filters = null;
				// var adjustColor:AdjustColor = new AdjustColor();
				// adjustColor.saturation = -100;
				// adjustColor.brightness  = 50;
				// adjustColor.contrast = 50;
				// adjustColor.hue = 50;

				// var matrix:Array = adjustColor.CalculateFinalFlatArray();
				// var colorMatrix:ColorMatrixFilter = new ColorMatrixFilter(matrix);
				// crystal_mc.filters = [colorMatrix];
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