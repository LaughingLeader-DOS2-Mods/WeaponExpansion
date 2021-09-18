package statusbg
{
	import LS_Classes.larTween;
	import fl.motion.easing.Quartic;
	import flash.display.MovieClip;
	
	public dynamic class StatusBarEnder extends MovieClip
	{
		public var status:MovieClip;
		
		public const tweenTime:Number = 0.3;
		
		public function StatusBarEnder()
		{
			super();
			addFrameScript(0,this.frame1,63,this.frame64);
		}
		
		internal function frame1() : *
		{
			stop();
		}
		
		internal function frame64() : *
		{
			this.status = parent as MovieClip;
			if(this.status.fadeTween)
			{
				this.status.fadeTween.stop();
			}
			if(this.status.fadeTween2)
			{
				this.status.fadeTween2.stop();
			}
			this.status.fadeTween = new larTween(this.status,"alpha",Quartic.easeOut,this.status.alpha,0,this.tweenTime,this.status.tweenComplete);
			this.status.fadeTween2 = new larTween(this.status,"widthOverride",Quartic.easeOut,this.status.widthOverride,0,this.tweenTime);
		}
	}
}
