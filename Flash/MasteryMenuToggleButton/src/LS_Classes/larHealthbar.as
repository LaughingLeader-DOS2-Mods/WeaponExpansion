package LS_Classes
{
	import fl.motion.Color;
	import fl.motion.easing.Sine;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	public class larHealthbar extends MovieClip
	{
		 
		
		public var hBar_mc:MovieClip;
		
		public var hBar2_mc:MovieClip;
		
		public var easingFunction:Function;
		
		private var timeline:larTween;
		
		private var percHB:Number = 0;
		
		private var percTemp:Number = 0;
		
		private var m_BarColour:uint;
		
		public var tweenDelay:Number = 0.8;
		
		public var tweenTime:Number = 0.5;
		
		private var m_FinishCallback:Function = null;
		
		public function larHealthbar()
		{
			this.easingFunction = Sine.easeOut;
			super();
			this.hBar_mc.scaleX = this.hBar2_mc.scaleX = 0;
		}
		
		public function set onComplete(callback:Function) : *
		{
			this.m_FinishCallback = callback;
		}
		
		public function get onComplete() : Function
		{
			return this.m_FinishCallback;
		}
		
		public function setBar(barPercentage:Number, animate:Boolean) : Boolean
		{
			var needsAnimating:Boolean = false;
			this.stopHPTweens();
			if(barPercentage > 1)
			{
				barPercentage = 1;
			}
			else if(barPercentage < 0)
			{
				barPercentage = 0;
			}
			if(animate)
			{
				this.percTemp = barPercentage;
				if(this.percHB < this.percTemp)
				{
					this.hBar2_mc.scaleX = this.percTemp;
					this.timeline = new larTween(this.hBar_mc,"scaleX",this.easingFunction,this.hBar_mc.scaleX,this.percTemp,this.tweenTime,null,null,this.tweenDelay);
				}
				else
				{
					this.hBar_mc.scaleX = this.percTemp;
					this.timeline = new larTween(this.hBar2_mc,"scaleX",this.easingFunction,this.hBar2_mc.scaleX,this.percTemp,this.tweenTime,null,null,this.tweenDelay);
				}
				this.timeline.onComplete = this.m_FinishCallback;
			}
			else
			{
				this.hBar_mc.scaleX = barPercentage;
				this.hBar2_mc.scaleX = barPercentage;
			}
			if(this.percHB != barPercentage)
			{
				needsAnimating = true;
			}
			this.percHB = barPercentage;
			return needsAnimating;
		}
		
		public function stopHPTweens() : *
		{
			if(this.timeline)
			{
				this.timeline.stop();
				this.timeline = null;
			}
		}
		
		public function setBarColour(setColor:uint) : *
		{
			var colorTransform:ColorTransform = this.hBar_mc.transform.colorTransform;
			colorTransform.color = setColor;
			this.hBar_mc.transform.colorTransform = colorTransform;
			var nextBarColor:Color = new Color();
			nextBarColor.color = setColor;
			nextBarColor = this.changeColour(nextBarColor,200);
			this.m_BarColour = setColor;
			var bar2ColorTransform:ColorTransform = this.hBar2_mc.transform.colorTransform;
			bar2ColorTransform.color = nextBarColor.color;
			this.hBar2_mc.transform.colorTransform = bar2ColorTransform;
		}
		
		public function get barColour() : Number
		{
			return this.m_BarColour;
		}
		
		private function changeColour(color:Color, colorOffset:Number) : Color
		{
			color.blueOffset = color.blueOffset + colorOffset;
			color.redOffset = color.redOffset + colorOffset;
			color.greenOffset = color.greenOffset + colorOffset;
			if(color.blueOffset > 255)
			{
				color.blueOffset = 255;
			}
			if(color.greenOffset > 255)
			{
				color.greenOffset = 255;
			}
			if(color.redOffset > 255)
			{
				color.redOffset = 255;
			}
			return color;
		}
	}
}
