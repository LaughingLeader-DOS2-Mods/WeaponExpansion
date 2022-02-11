package
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import fl.motion.easing.Quartic;
	import LS_Classes.larTween;
	import flash.geom.Point;
	
	public class MainTimeline extends MovieClip
	{
		public var menu_btn:MovieClip;
		
		public var events:Array;
		public var layout:String = "fixed";
		//public var anchorId:String = "WeaponExpansionMasteryMenuToggleButton";

		public var defaultButtonPosition:Point = new Point(104, 938);

		public function MainTimeline()
		{
			super();
		}
		
		public function onEventInit() : void
		{
			ExternalInterface.call("registerAnchorId", "WeaponExpansionMasteryMenuToggleButton");
			ExternalInterface.call("setAnchor","bottom","screen","bottom");

			this.defaultButtonPosition.y = this.menu_btn.y;
			this.defaultButtonPosition.x = this.menu_btn.x;
		}

		public function onEventResolution() : void
		{
			ExternalInterface.call("LeaderLib_OnEventResolution", "WeaponExpansionMasteryMenuToggleButton");
		}

		public function setShared(b:Boolean) : void
		{
			if(!b)
			{
				ExternalInterface.call("setAnchor","bottom","splitscreen","bottom");
			}
			else
			{
				ExternalInterface.call("setAnchor","bottom","screen","bottom");
			}
		}
		
		public function setToggleButtonTooltip(text:String) : void
		{
			this.menu_btn.setTooltip(text);
		}

		public function setToggleButtonVisibility(setVisible:Boolean) : void
		{
			this.menu_btn.visible = setVisible;
		}

		public var toggleButtonDefaultX:Number = 175;
		public var toggleButtonDefaultY:Number = 1015.45;
		public var toggleButtonDialogX:Number = 86;
		public var toggleButtonDialogY:Number = 0;

		public function setDialogOpened(isOpened:Boolean) : void
		{
			if (isOpened)
			{
				this.menu_btn.x = toggleButtonDialogX;
				this.menu_btn.y = toggleButtonDialogY;
			}
			else
			{
				this.menu_btn.x = toggleButtonDefaultX;
				this.menu_btn.y = toggleButtonDefaultY;
			}
		}

		public function setToggleButtonPosition(buttonX:Number, buttonY:Number) : void
		{
			this.menu_btn.x = buttonX;
			this.menu_btn.y = buttonY;
		}

		private var fadeTween:larTween;

		private function onFadeIn():void
		{
			ExternalInterface.call("LLWEAPONEX_MasteryMenu_ToggleButton_FadeinComplete");
		}

		private function onFadeOut():void
		{
			ExternalInterface.call("LLWEAPONEX_MasteryMenu_ToggleButton_FadeOutComplete");
		}

		public function fade(startAlpha:Number, endAlpha:Number, speed:Number) : void
		{
			if(fadeTween)
			{
				fadeTween.stop();
			}
			this.menu_btn.alpha = startAlpha;
			fadeTween = new larTween(this.menu_btn,"alpha",Quartic.easeIn,startAlpha,endAlpha,speed);
			if(endAlpha >= 1.0) {
				fadeTween.onComplete = onFadeIn;
			}
			else if (endAlpha <= 0)
			{
				fadeTween.onComplete = onFadeOut;
			}
		}
	}
}
