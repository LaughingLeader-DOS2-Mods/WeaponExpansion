package masteryMenu
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
	import data.DescriptionData;
	
	public dynamic class masteryMenu_Main extends MovieClip
	{
		public var accept_mc:MovieClip;
		
		public var btn_bg:MovieClip;
		
		public var buttonHintBar_mc:buttonHintBar;
		
		public var close_btn:MovieClip;
		
		public var desc_mc:masteryMenu_Description;
		
		public var masteryHandle:MovieClip;
		
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
		
		//public var _scrollbar:scrollbar_text;
		public var descriptionPane:scrollList;
		
		public var time:Timer;

		public var emptyListTitle:String = "";
		public var emptyListDescription:String = "";
		public var emptyListData:DescriptionData;
		
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

			this.descriptionPane = new scrollList();
			this.descriptionPane.setFrame(462,672);
			//this.descriptionPane.SB_SPACING = 10;
			//this.descriptionPane.TOP_SPACING = 15;
			//this.descriptionPane.SIDE_SPACING = 20;
			//this.descriptionPane.EL_SPACING = 1;
			this.descriptionPane.mouseWheelWhenOverEnabled = true;
			this.descriptionPane.m_scrollbar_mc.m_hideWhenDisabled = true;
			this.descriptionPane.m_customElementHeight = this.ELH;
			this.descriptionPane.m_scrollbar_mc.m_SCROLLSPEED = this.ELH;
			this.descriptionPane.m_scrollbar_mc.m_scrollOverShoot = this.ELH;
			this.descriptionPane.m_scrollbar_mc.x = this.descriptionPane.m_scrollbar_mc.x - 15;
			this.descriptionPane.m_cyclic = true;
			this.descriptionPane.OnSelectionChanged = this.onSelectionChanged;
			this.descriptionPane.m_scrollbar_mc.m_animateScrolling = true;
			addChild(this.descriptionPane);
			this.descriptionPane.addElement(desc_mc);
			this.descriptionPane.checkScrollBar();
			// this._scrollbar = new scrollbar_text("downText_id","upText_id","handleText_id","scrollStory_bg_id");
			// addChild(this._scrollbar);
			// this._scrollbar.SB_SPACING = 20;
			// this._scrollbar.m_scaleBG = false;
			// this._scrollbar.addContent(this.desc_mc);
			// this._scrollbar.scrollbarVisible();
			// this._scrollbar.m_bg_mc.alpha = 0;
			this.desc_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onDescriptionMouseIn);
			this.desc_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onDescriptionMouseOut);
			this.buttonHintBar_mc.centerButtons = true;
			ExternalInterface.call("PlaySound","UI_Generic_Click");
		}
		
		public function onLoaded(e:Event) : *
		{
			ExternalInterface.call("masteryMenuLoaded");
		}
		
		public function onDescriptionMouseIn(e:MouseEvent) : void
		{
			this._scrollbar.mouseWheelEnabled = true;
		}
		
		public function onDescriptionMouseOut(e:MouseEvent) : void
		{
			this._scrollbar.mouseWheelEnabled = false;
		}
		
		public function resetTextScrollbar() : *
		{
			this._scrollbar.scrollTo(0,false);
			this._scrollbar.resetScrollbar();
			this._scrollbar.adjustScrollHandle(0);
		}
		
		public function startScrollText(up:Boolean, increment:Number) : *
		{
			if(up)
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
		
		public function setEmptyListText(title:String, description:String) : *
		{
			emptyListTitle = title;
			emptyListDescription = description;

			if(emptyListData == null)
			{
				emptyListData = new DescriptionData(emptyListDescription);
			}

			if (this.masteryCount <= 0)
			{
				this.name_txt.htmlText = this.emptyListTitle;
				this.desc_mc.addEntry(emptyListData);
			}
		}
		
		public function setButtonText(param1:String) : *
		{
			this.accept_mc.text_txt.htmlText = param1;
			this.accept_mc.setButtonType(2);
			this.accept_mc.setButtonEvent("requestCloseUI");
		}

		public function addMastery(listId:Number, mastery:String, title:String, descriptionTitle:String, description:String, currentRank:uint, barPercentage:Number=0, isMastered:Boolean=false) : *
		{
			noMasteries_mc.visible = false;

			var masteryMC:MovieClip = this.masteryList.getElementByNumber("id",listId);
			if(masteryMC == null)
			{
				masteryMC = new MasteryEntry();
				masteryMC.name = "mastery" + listId;
				masteryMC.id = listId;
				this.masteryList.addElement(masteryMC);
				this.masteryList.checkScrollBar();

				this.masteryCount = this.masteryCount + 1;
			}
			masteryMC.setId(listId,mastery);
			masteryMC.setTitle(title, descriptionTitle);
			masteryMC.setDescription(description);
			masteryMC.alpha = 1;
			masteryMC.createRankNodes(currentRank, Registry.MaxRank);
			masteryMC.setBar(barPercentage, false);
			masteryMC.setIsMastered(isMastered);
			this.masteryList.selectByListID(0);
		}

		public function addMasteryDescription(listId:Number, text:String) : *
		{
			var masteryMC:MovieClip = this.masteryList.getElementByNumber("id",listId);
			if(masteryMC != null)
			{
				masteryMC.addDescription(text);
			}
		}

		public function addMasterySkill(listId:Number, index:uint, skill:String, icon:String) : *
		{
			var masteryMC:MovieClip = this.masteryList.getElementByNumber("id",listId);
			if(masteryMC != null)
			{
				masteryMC.addSKill(index, skill, icon);
			}
		}

		public function setExperienceBarTooltip(listId:Number, text:String) : *
		{
			var masteryMC:MovieClip = this.masteryList.getElementByNumber("id",listId);
			if(masteryMC != null)
			{
				masteryMC.setExperienceBarTooltip(text);
			}
		}

		public function setRankTooltipText(listId:Number, rank:int, text:String) : *
		{
			var masteryMC:MovieClip = this.masteryList.getElementByNumber("id",listId);
			if(masteryMC != null)
			{
				masteryMC.setRankTooltipText(rank, text);
			}
		}

		public function positionRankNodes(listId:Number, currentRank:int) : *
		{
			var masteryMC:MovieClip = this.masteryList.getElementByNumber("id",listId);
			if(masteryMC != null)
			{
				masteryMC.positionRankNodes(currentRank);
			}
		}
		
		public function resetList() : *
		{
			this.masteryList.clearElements();
			this.name_txt.htmlText = this.emptyListTitle;
			this.desc_mc.clearElements();
			this.desc_mc.addEntry(this.emptyListData);
			this.resetTextScrollbar();
			this.masteryCount = 0;
			noMasteries_mc.visible = true;
			//textHelpers.setFormattedText(this.name_txt, this.emptyListTitle);
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
			this.name_txt.htmlText = entry.getDescriptionTitle();

			if (entry.descriptions.length > 0)
			{
				this.desc_mc.clearElements();
				var i:uint = 0;
				while (i < entry.descriptions.length)
				{
					this.desc_mc.addEntry(entry.descriptions[i]);
					i = i + 1;
				}
			}
			else
			{
				this.desc_mc.addEntry(this.emptyListData);
			}
			this.desc_mc.alignEntries();
			//textHelpers.setFormattedText(this.name_txt, entry.getDescriptionTitle());
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
			ExternalInterface.call("onMasterySelected", nextMC.m_Id, nextMC.m_MasteryId);
		}
		
		public function getCurrentSelection() : int
		{
			return this.masteryList.currentSelection;
		}
		
		internal function frame1() : *
		{
			this.masteryCount = 0;
			this.m_isController = false;
			this.time = new Timer(1,1);
			this.time.addEventListener(TimerEvent.TIMER_COMPLETE,this.onLoaded);
			this.time.start();
		}
	}
}
