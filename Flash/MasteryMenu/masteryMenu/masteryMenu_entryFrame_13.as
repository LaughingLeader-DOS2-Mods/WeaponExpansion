package masteryMenu
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class masteryMenu_entryFrame_13 extends MovieClip
	{
		 
		
		public var bg_mc:MovieClip;
		
		public var bottom_decor:MovieClip;
		
		public var masteryOverlay:MovieClip;
		
		public var title_txt:TextField;
		
		public var top_decor:MovieClip;
		
		public var masteryEntry:MovieClip;
		
		public var buttonType:Number;
		
		public var m_Id:Number;
		
		public function masteryMenu_entryFrame_13()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function setId(param1:Number) : *
		{
			this.m_Id = param1;
		}
		
		public function onOut(param1:MouseEvent) : *
		{
			this.bg_mc.gotoAndStop(1);
			this.masteryOverlay.gotoAndStop(1);
		}
		
		public function onOver(param1:MouseEvent) : *
		{
			this.bg_mc.gotoAndStop(2);
			this.masteryOverlay.gotoAndStop(2);
			ExternalInterface.call("PlaySound","UI_Generic_Over");
			ExternalInterface.call("overMastery",this.m_Id);
		}
		
		function frame1() : *
		{
			addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			addEventListener(MouseEvent.ROLL_OVER,this.onOver);
			this.masteryEntry = MovieClip(this.parent);
			this.buttonType = 1;
		}
	}
}
