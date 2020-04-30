package masteryMenu
{
	import LS_Classes.scrollList;
	import LS_Classes.scrollbar_text;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	public dynamic class masteryMenu_Main extends MovieClip
	{
		 
		
		public var accept_mc:MovieClip;
		
		public var btn_bg:MovieClip;
		
		public var buttonHintBar_mc:buttonHintBar;
		
		public var close_btn:MovieClip;
		
		public var desc_txt:TextField;
		
		public var masteryHandle:MovieClip;
		
		public var name_txt:TextField;
		
		public var title_txt:TextField;
		
		public var masteryCount;
		
		public var m_isController:Boolean;
		
		public const scrollPaneW:Number = 845;
		
		public const scrollPaneH:Number = 773;
		
		public const ELH:Number = 300;
		
		public var masteryList:scrollList;
		
		public var _scrollbar:scrollbar_text;
		
		public var time:Timer;
		
		public function masteryMenu_Main()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function masteryListInit() : *
		{
			this.masteryList = new scrollList();
			this.masteryList.setFrame(this.scrollPaneW,this.scrollPaneH);
			this.masteryList.SB_SPACING = 10;
			this.masteryList.TOP_SPACING = 15;
			this.masteryList.SIDE_SPACING = 20;
			this.masteryList.EL_SPACING = 20;
			this.masteryList.mouseWheelWhenOverEnabled = true;
			this.masteryList.m_scrollbar_mc.m_hideWhenDisabled = true;
			this.masteryList.m_customElementHeight = this.ELH;
			this.masteryList.m_scrollbar_mc.m_SCROLLSPEED = this.ELH;
			this.masteryList.m_scrollbar_mc.m_scrollOverShoot = this.ELH;
			this.masteryList.m_scrollbar_mc.x = this.masteryList.m_scrollbar_mc.x - 15;
			this.masteryList.m_cyclic = true;
			this.masteryList.OnSelectionChanged = this.onSelectionChanged;
			this.masteryList.m_scrollbar_mc.m_animateScrolling = true;
			this.masteryHandle.addChild(this.masteryList);
			this._scrollbar = new scrollbar_text("downText_id","upText_id","handleText_id","scrollStory_bg_id");
			addChild(this._scrollbar);
			this._scrollbar.SB_SPACING = 20;
			this._scrollbar.m_scaleBG = false;
			this._scrollbar.addContent(this.desc_txt);
			this._scrollbar.scrollbarVisible();
			this._scrollbar.m_bg_mc.alpha = 0;
			this.desc_txt.addEventListener(MouseEvent.MOUSE_OVER,this.onDescriptionMouseIn);
			this.desc_txt.addEventListener(MouseEvent.MOUSE_OUT,this.onDescriptionMouseOut);
			this.buttonHintBar_mc.centerButtons = true;
			ExternalInterface.call("PlaySound","UI_Generic_Click");
		}
		
		public function onLoaded(param1:Event) : *
		{
			ExternalInterface.call("masteryMenuLoaded");
		}
		
		public function onDescriptionMouseIn(param1:MouseEvent) : void
		{
			this._scrollbar.mouseWheelEnabled = true;
		}
		
		public function onDescriptionMouseOut(param1:MouseEvent) : void
		{
			this._scrollbar.mouseWheelEnabled = false;
		}
		
		public function resetTextScrollbar() : *
		{
			this._scrollbar.scrollTo(0,false);
			this._scrollbar.resetScrollbar();
			this._scrollbar.adjustScrollHandle(0);
		}
		
		public function startScrollText(param1:Boolean, param2:Number) : *
		{
			if(param1)
			{
				this._scrollbar.scrollUp();
			}
			else
			{
				this._scrollbar.scrollDown();
			}
		}
		
		public function stopScrollText() : *
		{
			this._scrollbar.stopAutoScroll();
		}
		
		public function setTitle(param1:String) : *
		{
			this.title_txt.htmlText = param1.toUpperCase();
		}
		
		public function setButtonText(param1:String) : *
		{
			this.accept_mc.text_txt.htmlText = param1;
			this.accept_mc.setButtonType(2);
		}
		
		public function showControllerHints(param1:Boolean) : *
		{
			this.m_isController = param1;
			this.buttonHintBar_mc.centerButtons = true;
			this.buttonHintBar_mc.visible = param1;
			this.accept_mc.visible = !param1;
			this.close_btn.visible = !param1;
			this.btn_bg.setController(param1);
			this.masteryList.m_allowKeepIntoView = param1;
		}
		
		public function addMastery(masteryId:Number, title:String, description:String, showIcon:Boolean) : *
		{
			var masteryMC:MovieClip = this.masteryList.getElementByNumber("id",masteryId);
			if(masteryMC == null)
			{
				masteryMC = new MasteryEntry();
				masteryMC.name = "mod" + masteryId;
				masteryMC.id = masteryId;
				this.masteryList.addElement(masteryMC);
				this.masteryList.checkScrollBar();
			}
			masteryMC.setId(masteryId);
			masteryMC.setTitle(title);
			masteryMC.setDescription(description);
			masteryMC.alpha = 1;
			if(showIcon)
			{
				masteryMC.newIcon.gotoAndStop(2);
			}
			this.masteryList.selectByListID(0);
		}
		
		public function adjustMainScroll() : void
		{
			if(!this.m_isController)
			{
				this.masteryList.m_scrollbar_mc.scrollToPercent(this.getCurrentSelection() / (this.masteryList.length - 1),true);
			}
		}
		
		public function previous() : *
		{
			this.masteryList.previous();
		}
		
		public function next() : *
		{
			this.masteryList.next();
		}
		
		public function onSelectionChanged() : *
		{
			var entry:MasteryEntry = this.masteryList.getCurrentMovieClip() as MasteryEntry;
			this.name_txt.htmlText = entry.getTitle();
			this.desc_txt.htmlText = entry.getDescription();
			this.resetTextScrollbar();
		}
		
		public function select(id:Number) : *
		{
			var currentMC:MovieClip = this.masteryList.getCurrentMovieClip();
			var nextMC:MovieClip = this.masteryList.getElement(id);
			if(currentMC != nextMC)
			{
				currentMC.deselectElement();
			}
			this.masteryList.selectMC(nextMC);
		}
		
		public function getCurrentSelection() : int
		{
			return this.masteryList.currentSelection;
		}
		
		function frame1() : *
		{
			this.masteryCount = 2;
			this.m_isController = false;
			this.time = new Timer(1,1);
			this.time.addEventListener(TimerEvent.TIMER_COMPLETE,this.onLoaded);
			this.time.start();
		}
	}
}
