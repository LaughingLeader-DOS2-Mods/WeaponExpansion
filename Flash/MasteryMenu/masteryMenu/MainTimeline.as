package masteryMenu
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	
	public dynamic class MainTimeline extends MovieClip
	{
		 
		
		public var masteryMenuMC:MovieClip;
		
		public var layout:String;
		
		public var alignment:String;
		
		public const anchorId:String = "giftMenu";
		
		public const anchorPos:String = "center";
		
		public const anchorTPos:String = "center";
		
		public const anchorTarget:String = "screen";
		
		public var events:Array;
		
		public var items_array:Array;
		
		public var isContentView:Boolean;
		
		public function MainTimeline()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onEventInit() : *
		{
			ExternalInterface.call("registerAnchorId",this.anchorId);
			ExternalInterface.call("setAnchor",this.anchorPos,this.anchorTarget,this.anchorTPos);
			this.masteryMenuMC.masteryListInit();
		}
		
		public function onEventUp(param1:Number) : *
		{
			var _loc2_:Boolean = false;
			switch(this.events[param1])
			{
				case "IE UICancel":
					_loc2_ = true;
					if(this.isContentView)
					{
						this.isContentView = false;
					}
					ExternalInterface.call("buttonPressed",2,0);
					break;
				case "IE UIUp":
				case "IE UIDown":
					_loc2_ = true;
					break;
				case "IE UIDialogTextUp":
				case "IE UIDialogTextDown":
					this.masteryMenuMC.stopScrollText();
					_loc2_ = true;
			}
			return _loc2_;
		}
		
		public function onEventDown(param1:Number, param2:Number, param3:Number) : *
		{
			var _loc4_:Boolean = false;
			switch(this.events[param1])
			{
				case "IE UICancel":
					_loc4_ = true;
					break;
				case "IE UIUp":
					this.masteryMenuMC.previous();
					this.masteryMenuMC.adjustMainScroll();
					_loc4_ = true;
					break;
				case "IE UIDown":
					this.masteryMenuMC.next();
					this.masteryMenuMC.adjustMainScroll();
					_loc4_ = true;
					break;
				case "IE UIDialogTextUp":
					this.masteryMenuMC.startScrollText(true,param3);
					_loc4_ = true;
					break;
				case "IE UIDialogTextDown":
					this.masteryMenuMC.startScrollText(false,param3);
					_loc4_ = true;
			}
			return _loc4_;
		}
		
		public function setTitle(title:String) : *
		{
			this.masteryMenuMC.setTitle(title);
		}
		
		public function setButtonText(text:String) : *
		{
			this.masteryMenuMC.setButtonText(text);
		}
		
		public function showControllerHints(enabled:Boolean) : *
		{
			this.masteryMenuMC.showControllerHints(enabled);
		}
		
		public function addBtnHint(param1:Number, param2:Number, param3:String) : *
		{
			this.masteryMenuMC.buttonHintBar_mc.addBtnHint(param1,param3,param2);
		}
		
		public function addMastery(param1:Number, param2:String, param3:String, param4:Boolean) : *
		{
			this.masteryMenuMC.addMastery(param1,param2,param3,param4);
		}
		
		public function showMasteryMenu() : *
		{
			this.masteryMenuMC.visible = true;
		}
		
		public function selectMastery(param1:Number) : *
		{
			this.masteryMenuMC.select(param1);
		}
		
		function frame1() : *
		{
			this.layout = "fixed";
			this.alignment = "none";
			this.events = new Array("IE UICancel","IE UIUp","IE UIDown","IE UIDialogTextUp","IE UIDialogTextDown");
			this.items_array = new Array();
			this.isContentView = false;
		}
	}
}
