package
{
	import flash.display.MovieClip;
	import flash.display.InteractiveObject;
	import flash.external.ExternalInterface;
	import fl.motion.easing.Quartic;
	import LS_Classes.larTween;
	import flash.geom.Point;
	
	public dynamic class MainTimeline extends MovieClip
	{
		public var menu_btn:MovieClip;
		
		public var events:Array;
		public var alignment:String = "none";
		public var layout:String = "fillVFit";
		public var anchorId:String = "masteryMenuToggleButton";
		public var anchorPos:String = "topleft";
		public var anchorTPos:String = "topleft";
		public var anchorTarget:String = "screen";
		public var uiScaling:Number = 1.0;
		public var scaleChange:Number = 0.0;
		public const designResolution:Point = new Point(1920,1080);
		public var defaultButtonPosition:Point = new Point(147,930);
		public var screenWidth:Number = 0;
		public var screenHeight:Number = 0;
		public var sizeHelper:MovieClip;

		public function MainTimeline()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onEventInit() : *
		{
			ExternalInterface.call("registerAnchorId",this.anchorId);
			ExternalInterface.call("setAnchor",this.anchorPos,this.anchorTarget,this.anchorTPos);
		}

		public function onEventResize() : *
		{
			ExternalInterface.call("setPosition",this.anchorPos,this.anchorTarget,this.anchorPos);
		}

		public function setShared(b:Boolean) : *
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

		public function onEventResolution(w:Number, h:Number) : *
		{
			// w = w / this.uiScaling;
			// h = h / this.uiScaling;
			// var resRatio:uint = Math.floor(w / h * (this.designResWidth / this.uiScaling));
			// resWidth = w;
			// resHeight = h;
			if(this.screenWidth != w || this.screenHeight != h)
			{
				this.screenWidth = w;
				this.screenHeight = h;

				//this.sizeHelper.scaleX = (this.designResolution.x / w);
				//this.sizeHelper.scaleY = (this.designResolution.y / h);
				this.sizeHelper.x = 0;
				this.sizeHelper.u = 0;
				this.sizeHelper.width = w;
				this.sizeHelper.height = h;
				ExternalInterface.call("setPosition",this.anchorPos,this.anchorTarget,this.anchorPos);
				this.scaleChange = h / this.designResolution.y;
				ExternalInterface.call("repositionMasteryMenuToggleButton", w, h);
			}
		}
		
		public function setToggleButtonTooltip(text:String) : *
		{
			this.menu_btn.setTooltip(text);
		}

		public function setToggleButtonVisibility(setVisible:Boolean) : *
		{
			this.menu_btn.visible = setVisible;
		}

		public var toggleButtonDefaultX:Number = 175;
		public var toggleButtonDefaultY:Number = 1015.45;
		public var toggleButtonDialogX:Number = 86;
		public var toggleButtonDialogY:Number = 0;

		public function setDialogOpened(isOpened:Boolean) : *
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

		public function setToggleButtonPosition(buttonX:Number, buttonY:Number) : *
		{
			this.menu_btn.x = buttonX;
			this.menu_btn.y = buttonY;
		}

		private var fadeTween:larTween;

		public function fade(startAlpha:Number, endAlpha:Number, speed:Number) : *
		{
			if(fadeTween)
			{
				fadeTween.stop();
			}
			this.menu_btn.alpha = startAlpha;
			fadeTween = new larTween(this.menu_btn,"alpha",Quartic.easeIn,startAlpha,endAlpha,speed);
		}
		
		public function frame1() : void
		{
			this.anchorId = "masteryMenuToggleButton";
			this.anchorPos = "bottom";
			this.anchorTPos = "bottom";
			this.anchorTarget = "splitscreen";
			//fixed, fitVertical, fitHorizontal, fit, fill, fillVFit
			this.layout = "fillVFit";
			this.uiScaling = 1;

			//this.sizeHelper.visible = false;
			this.sizeHelper.mouseEnabled = false;
			this.sizeHelper.mouseChildren = false;
			this.sizeHelper.buttonMode = false;
			//this.sizeHelper.enabled = false;
			this.sizeHelper.doubleClickEnabled = false;
			this.sizeHelper.tabEnabled = false;
			this.sizeHelper.tabChildren = false;

			this.defaultButtonPosition.y = this.menu_btn.y;
			this.defaultButtonPosition.x = this.menu_btn.x;
		}
	}
}
