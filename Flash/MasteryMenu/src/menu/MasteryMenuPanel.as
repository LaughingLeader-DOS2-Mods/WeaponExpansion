package menu
{
	import LS_Classes.scrollList;
	import LS_Classes.scrollbar_text;
	import LS_Classes.textHelpers;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.geom.Point;
	import desc.DescriptionList;
	import LS_Symbols.buttonHintBar;
	import LS_Symbols.redBtn_6;
	
	public dynamic class MasteryMenuPanel extends MovieClip
	{
		public var accept_mc:redBtn_6;
		public var btn_bg:MovieClip;
		public var windowDragBG:MovieClip;
		
		public var buttonHintBar_mc:buttonHintBar;
		
		public var close_btn:MovieClip;
		
		public var masteryHandle:MovieClip;
		public var masteryDesc_mc:MovieClip;
		
		public var name_txt:TextField;
		
		public var title_txt:TextField;

		public var noMasteries_mc:MovieClip;
		
		public var masteryCount:int = 0;
		
		public var m_isController:Boolean;
		
		public const scrollPaneW:Number = 845;
		
		// Default frame height is 296, element spacing is EL_SPACING (20)
		public const scrollPaneH:Number = 773;
		
		public const ELH:Number = 110;//300;
		
		public var masteryList:scrollList;
		
		//public var descriptionList:scrollbar_text;
		public var descriptionList:DescriptionList;

		public var emptyListTitle:String = "";
		public var emptyListDescription:String = "";

		private var _initialized:Boolean = false;

		public var isDragging:Boolean = false;
		public var windowDragStarted:Boolean = false;
		public var dragStartMP:Point;
		public const startDragDiff:uint = 20;
		public var mousePosX:Number;
		public var mousePosY:Number;
		
		public function MasteryMenuPanel()
		{
			super();
			this.addFrameScript(0,this.frame1);
		}
		
		public function initLists() : void
		{
			this.masteryList = new scrollList();
			this.masteryList.setFrame(this.scrollPaneW,this.scrollPaneH);
			this.masteryList.SB_SPACING = 10;
			this.masteryList.TOP_SPACING = 15;
			this.masteryList.SIDE_SPACING = 20;
			this.masteryList.EL_SPACING = 1;
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

			this.descriptionList = new DescriptionList();
			this.masteryDesc_mc.addChild(this.descriptionList);
			this.descriptionList.scrollbarSpacing = 0;
			//this.descriptionList.x = masteryDesc_mc.x;
			//this.descriptionList.y = masteryDesc_mc.y;
			this.descriptionList.setFrame(this.masteryDesc_mc.width,this.masteryDesc_mc.height);
			this.descriptionList.setFrame(440,670);
			//this.descriptionList.SB_SPACING = 10;
			this.descriptionList.TOP_SPACING = 36;
			this.descriptionList.SIDE_SPACING = 4;
			//this.descriptionList.EL_SPACING = 1;
			this.descriptionList.mouseWheelWhenOverEnabled = true;
			//this.descriptionList.m_scrollbar_mc.m_hideWhenDisabled = true;
			//this.descriptionList.m_customElementHeight = this.ELH;
			this.descriptionList.m_scrollbar_mc.m_SCROLLSPEED = 20
			//this.descriptionList.m_scrollbar_mc.m_scrollOverShoot = this.ELH;
			//this.descriptionList.m_scrollbar_mc.x = this.descriptionList.m_scrollbar_mc.x - 64;
			this.descriptionList.m_scrollbar_mc.m_animateScrolling = true;
			this.descriptionList.checkScrollBar();
			// this.descriptionList = new scrollbar_text("downText_id","upText_id","handleText_id","scrollStory_bg_id");
			// addChild(this.descriptionList);
			// this.descriptionList.SB_SPACING = 20;
			// this.descriptionList.m_scaleBG = false;
			// this.descriptionList.addContent(this.desc_mc);
			// this.descriptionList.scrollbarVisible();
			// this.descriptionList.m_bg_mc.alpha = 0;
			this.descriptionList.addEventListener(MouseEvent.MOUSE_OVER,this.onDescriptionMouseIn);
			this.descriptionList.addEventListener(MouseEvent.MOUSE_OUT,this.onDescriptionMouseOut);
			this.buttonHintBar_mc.centerButtons = true;
		}
		
		public function onDescriptionMouseIn(e:MouseEvent) : *
		{
			this.descriptionList.mouseWheelEnabled = true;
		}
		
		public function onDescriptionMouseOut(e:MouseEvent) : *
		{
			this.descriptionList.mouseWheelEnabled = false;
		}
		
		public function resetTextScrollbar() : void
		{
			this.descriptionList.m_scrollbar_mc.scrollTo(0,false);
			this.descriptionList.resetScroll();
			this.descriptionList.m_scrollbar_mc.adjustScrollHandle(0);
			this.descriptionList.checkScrollBar();
		}
		
		public function startScrollText(up:Boolean, increment:Number) : void
		{
			if(up)
			{
				this.descriptionList.m_scrollbar_mc.scrollUp();
			}
			else
			{
				this.descriptionList.m_scrollbar_mc.scrollDown();
			}
		}
		
		public function stopScrollText() : void
		{
			this.descriptionList.m_scrollbar_mc.stopAutoScroll();
		}
		
		public function setTitle(str:String) : void
		{
			this.title_txt.htmlText = str.toUpperCase();
		}
		
		public function setEmptyListText(title:String, description:String) : void
		{
			this.emptyListTitle = title;
			this.emptyListDescription = description;

			if (this.masteryCount <= 0 && this.descriptionList.length == 0)
			{
				this.name_txt.htmlText = this.emptyListTitle;
				this.descriptionList.addText(emptyListDescription);
			}
		}
		
		public function setButtonText(str:String) : void
		{
			this.accept_mc.text_txt.htmlText = str;
		}

		public function addMastery(mastery:String, title:String, descriptionTitle:String, currentRank:uint, barPercentage:Number=0, isMastered:Boolean=false) : void
		{
			this.noMasteries_mc.visible = false;

			var masteryMC:MovieClip = this.masteryList.getElementByString("id", mastery);
			if(masteryMC == null)
			{
				masteryMC = new MasteryEntry();
				masteryMC.id = mastery;
				this.masteryList.addElement(masteryMC);
				this.masteryList.checkScrollBar();
				this.masteryCount = this.masteryCount + 1;
			}
			masteryMC.setTitle(title, descriptionTitle);
			masteryMC.alpha = 1;
			masteryMC.createRankNodes(currentRank, Registry.MaxRank);
			masteryMC.setBar(barPercentage, false);
			masteryMC.setIsMastered(isMastered);
			this.masteryList.selectByListID(0);
		}

		public function setExperienceBarTooltip(mastery:String, text:String) : void
		{
			var masteryMC:MovieClip = this.masteryList.getElementByString("id", mastery);
			if(masteryMC != null)
			{
				masteryMC.setExperienceBarTooltip(text);
			}
		}

		public function setRankTooltipText(mastery:String, rank:int, text:String) : void
		{
			var masteryMC:MovieClip = this.masteryList.getElementByString("id", mastery);
			if(masteryMC != null)
			{
				masteryMC.setRankTooltipText(rank, text);
			}
		}

		public function positionRankNodes(mastery:String, currentRank:int) : void
		{
			var masteryMC:MovieClip = this.masteryList.getElementByString("id", mastery);
			if(masteryMC != null)
			{
				masteryMC.positionRankNodes(currentRank);
			}
		}
		
		public function resetList() : void
		{
			this.masteryList.clearElements();
			this.name_txt.htmlText = this.emptyListTitle;
			this.descriptionList.clearElements();
			this.descriptionList.addText(emptyListDescription);
			this.descriptionList.clearIcons();
			this.resetTextScrollbar();
			this.masteryCount = 0;
			this.noMasteries_mc.visible = true;
			//textHelpers.setFormattedText(this.name_txt, this.emptyListTitle);
		}

		public function showControllerHints(visible:Boolean) : void
		{
			this.m_isController = visible;
			this.buttonHintBar_mc.centerButtons = true;
			this.buttonHintBar_mc.visible = visible;
			this.accept_mc.visible = !visible;
			this.close_btn.visible = !visible;
			this.btn_bg.setController(visible);
			this.masteryList.m_allowKeepIntoView = visible;
		}
		
		public function adjustMainScroll() : void
		{
			if(!this.m_isController)
			{
				this.masteryList.m_scrollbar_mc.scrollToPercent(this.getCurrentSelection() / (this.masteryList.length - 1),true);
			}
		}

		public function updateSelection(): void
		{
			var currentMC:MasteryEntry = this.masteryList.getCurrentMovieClip() as MasteryEntry;
			if (currentMC != null)
			{
				this.name_txt.htmlText = currentMC.masteryDescriptionTitle;
				Registry.call("LLWEAPONEX_MasteryMenu_MasterySelected", currentMC.id);
			}
		}
		
		public function previous(byAmount:int = 1) : void
		{
			this.masteryList.previous(byAmount);
			this.updateSelection();
		}
		
		public function next(byAmount:int = 1) : void
		{
			this.masteryList.next(byAmount);
			this.updateSelection();
		}

		public function top() : void
		{
			this.masteryList.selectFirstVisible();
			this.updateSelection();
		}

		public function bottom() : void
		{
			this.masteryList.selectLastElement();
			this.updateSelection();
		}

		public function selectNone() : void
		{
			this.masteryList.clearSelection();
		}
		
		public function onSelectionChanged() : void
		{
			//var entry:MasteryEntry = this.masteryList.getCurrentMovieClip() as MasteryEntry;
		}
		
		public function selectMastery(mastery:String, instant:Boolean = false) : void
		{
			var currentMC:MasteryEntry = this.masteryList.getCurrentMovieClip() as MasteryEntry;
			var nextMC:MasteryEntry = this.masteryList.getElementByString("id", mastery) as MasteryEntry;
			if(currentMC != null && currentMC != nextMC)
			{
				currentMC.deselectElement();
			}
			this.masteryList.m_scrollbar_mc.m_animateScrolling = !instant;
			if (nextMC != null)
			{
				this.masteryList.selectMC(nextMC);
				this.masteryList.m_scrollbar_mc.m_animateScrolling = true;
				this.name_txt.htmlText = nextMC.masteryDescriptionTitle;
				Registry.call("LLWEAPONEX_MasteryMenu_MasterySelected", nextMC.id);
			}
		}

		public function selectEntry(nextMC:MasteryEntry, instant:Boolean = false) : void
		{
			var currentMC:MasteryEntry = this.masteryList.getCurrentMovieClip() as MasteryEntry;
			if(currentMC != null && currentMC != nextMC)
			{
				currentMC.deselectElement();
			}
			this.masteryList.m_scrollbar_mc.m_animateScrolling = !instant;
			this.masteryList.selectMC(nextMC);
			this.masteryList.m_scrollbar_mc.m_animateScrolling = true;
			if (nextMC != null)
			{
				this.name_txt.htmlText = nextMC.masteryDescriptionTitle;
				Registry.call("LLWEAPONEX_MasteryMenu_MasterySelected", nextMC.id);
			}
		}
		
		public function getCurrentSelection() : int
		{
			return this.masteryList.currentSelection;
		}

		public function windowUp(e:MouseEvent) : *
		{
			if(this.isDragging)
			{
				Registry.call("cancelDragging");
			}
		}

		public function dragInit(e:MouseEvent) : *
		{
			Registry.call("UIAssert","[WeaponExpansion] dragInit");
			this.windowDragStarted = false;
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.dragMoveWindow);
			this.dragStartMP.y = stage.mouseY;
			this.dragStartMP.x = stage.mouseX;
			this.stage.addEventListener(MouseEvent.MOUSE_UP,this.stopDragWindow);
		}

		public function dragMoveWindow(e:MouseEvent) : *
		{
			Registry.call("UIAssert","[WeaponExpansion] dragMoveWindow");
			if(this.dragStartMP.x + this.startDragDiff > stage.mouseX || this.dragStartMP.y + this.startDragDiff > stage.mouseY || this.dragStartMP.x - this.startDragDiff < stage.mouseX || this.dragStartMP.y - this.startDragDiff < stage.mouseY)
			{
				Registry.call("hideTooltip");
				Registry.call("startMoveWindow");
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.dragMoveWindow);
				this.windowDragStarted = true;
			}
		}

		public function stopDragWindow(e:MouseEvent) : *
		{
			Registry.call("UIAssert","[WeaponExpansion] stopDragWindow");
			if(this.windowDragStarted)
			{
				Registry.call("cancelMoveWindow");
			}
			else
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.dragMoveWindow);
			}
			this.stage.removeEventListener(MouseEvent.MOUSE_UP,this.stopDragWindow);
			this.windowDragStarted = false;
		}
		
		private function frame1() : void
		{
			if(!this._initialized)
			{
				this.initLists();
				this._initialized = true;

				this.accept_mc.text_txt.htmlText = "Close";
				this.accept_mc.setButtonType(2);
				this.accept_mc.setButtonEvent("LLWEAPONEX_MasteryMenu_RequestCloseUI");
			}
			this.masteryCount = 0;
			this.m_isController = false;
			Registry.Main = this;

			this.windowDragBG.addEventListener(MouseEvent.MOUSE_DOWN,this.dragInit);
			this.windowDragBG.addEventListener(MouseEvent.MOUSE_UP,this.windowUp);
			this.dragStartMP = new Point();
			this.windowDragBG.addEventListener(MouseEvent.MOUSE_DOWN,this.dragInit);
		}
	}
}
