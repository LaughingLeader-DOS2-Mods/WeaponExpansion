package statusbg
{
	import LS_Classes.larTween;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	
	public dynamic class StatusMC extends MovieClip
	{
		public var borderTimer_mc:MovieClip;
		
		public var fadeOut_mc:MovieClip;
		
		public var hit_mc:MovieClip;
		
		public var icon_mc:MovieClip;
		
		public var text_mc:MovieClip;
		
		public var updateAnim_mc:MovieClip;
		
		public var base:MovieClip;
		
		public var fadeTween:larTween;
		
		public var fadeTween2:larTween;
		
		public var turns:String;
		
		public var fadingOut:Boolean;
		
		public function StatusMC()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function init() : *
		{
			this.turns = "New";
			this.text_mc.textCtrl_txt.htmlText = this.turns;
			this.text_mc.text_txt.htmlText = this.turns;
		}
		
		public function onOver(param1:MouseEvent) : *
		{
			if(!this.fadingOut)
			{
				this.base.showStatusTooltipForMC(this);
			}
		}
		
		public function onOut(param1:MouseEvent) : *
		{
			ExternalInterface.call("hideTooltip");
			this.base.curTooltip = -1;
			this.base.hasTooltip = false;
		}
		
		public function setCoolDown(param1:Number) : *
		{
			this.borderTimer_mc.visible = Boolean(param1 != 0);
			if(param1 > 0)
			{
				this.borderTimer_mc.drawWedge(0,0,28,360 - 359.9 * param1 - 90,-90,16777215,0.9);
			}
		}
		
		public function setTurns(param1:String) : *
		{
			this.turns = param1;
			this.text_mc.textCtrl_txt.htmlText = this.turns;
			this.text_mc.text_txt.htmlText = this.turns;
		}
		
		public function tick() : *
		{
			this.updateAnim_mc.gotoAndPlay(1);
		}
		
		public function tweenComplete() : *
		{
			this.widthOverride = 0;
			this.fadingOut = false;
			this.base.fadeOutStatusComplete(this.id,this.owner);
		}
		
		public function fadeOut() : *
		{
			this.setTurns("");
			this.fadingOut = true;
			this.fadeOut_mc.gotoAndPlay(2);
			this.borderTimer_mc.drawWedge(0,0,28,0,0,0,0);
		}
		
		public function cancelFadeOut() : *
		{
			this.fadeOut_mc.gotoAndStop(1);
			this.fadingOut = false;
			this.alpha = 1;
			this.widthOverride = 40;
			if(this.fadeTween)
			{
				this.fadeTween.stop();
				this.fadeTween = null;
			}
			if(this.fadeTween2)
			{
				this.fadeTween2.stop();
				this.fadeTween2 = null;
			}
		}
		
		internal function frame1() : *
		{
			this.base = root as MovieClip;
			this.hit_mc.alpha = 0;
			this.fadingOut = false;
			this.borderTimer_mc.scrollRect = new Rectangle(-18,-18,36,36);
		}
	}
}
