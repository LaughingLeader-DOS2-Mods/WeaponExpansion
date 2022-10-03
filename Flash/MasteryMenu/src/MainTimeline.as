package
{
	import flash.display.MovieClip;
	import flash.display.InteractiveObject;
	import flash.external.ExternalInterface;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import menu.MasteryMenuPanel;
	
	public class MainTimeline extends MovieClip
	{
		public var masteryMenuMC:MasteryMenuPanel;

		public var layout:String;
		
		public var alignment:String;
		
		public const anchorId:String = "masteryMenu";
		public const anchorPos:String = "center";
		public const anchorTPos:String = "center";
		public const anchorTarget:String = "screen";
		
		public var events:Array;

		public var active:Boolean = false;

		private var lastFocus:InteractiveObject;

		public const designResolution:Point = new Point(1920,1080);
		public var uiScaling:Number;
		public var isResizing:Boolean;
		public var controllerEnabled:Boolean = false;

		public var characterHandle:Number = 0;

		public function MainTimeline()
		{
			super();
			Registry.Init();
			this.addFrameScript(0,this.frame1);
		}
		
		public function onEventInit() : void
		{
			Registry.call("registerAnchorId",this.anchorId);
			Registry.call("setAnchor",this.anchorPos,this.anchorTarget,this.anchorTPos);
		}

		public function onEventResolution(width:Number, height:Number) : void
		{
			Registry.call("LeaderLib_OnEventResolution", "WeaponExpansionMasteryMenu");
		}

		public function OpenMenu() : void
		{
			if (!this.active)
			{
				Registry.call("PlaySound","UI_Game_PauseMenu_Open");
				Registry.call("focus");
				Registry.call("inputfocus");
				if(this.lastFocus != null)
				{
					this.stage.focus = this.lastFocus;
				}
				this.active = true;
			}
		}

		public function CloseMenu(skipRequest:Boolean = false) : void
		{
			if (this.active)
			{
				Registry.call("PlaySound","UI_Game_PauseMenu_Close");
				//Registry.call("PlaySound","UI_Game_Inventory_Close");
				if(!skipRequest) {
					Registry.call("LLWEAPONEX_MasteryMenu_RequestCloseUI");
				}
				Registry.call("inputFocusLost");
				Registry.call("focusLost");
				lastFocus = stage.focus;
				stage.focus = null;

				active = false;
			}
		}

		public function toggleMenu() : void
		{
			if (this.active)
			{
				this.CloseMenu();
			}
			else
			{
				this.OpenMenu();
			}
			Registry.call("PlaySound","UI_Generic_Click");
		}

		public var ctrlDown:Boolean = false;
		public var shiftDown:Boolean = false;
		
		public function onEventUp(eventIndex:Number) : Boolean
		{
			var eventName:String = this.events[eventIndex];
			var handled:Boolean = false;
			if (active)
			{
				//Registry.call("UIAssert","[WeaponExpansion] onEventUp ", this.events[eventIndex], eventIndex, param2, param3);
				switch(eventName)
				{
					case "IE UIAccept":
						break;
					case "IE UICancel":
					case "IE ToggleInGameMenu":
						handled = true;
						this.CloseMenu();
						break;
					case "IE UIUp":
					case "IE UIDown":
						handled = true;
						break;
					case "IE UIDialogTextUp":
					case "IE UIDialogTextDown":
					case "IE UITooltipUp":
					case "IE UITooltipDown":
						this.masteryMenuMC.stopScrollText();
						this.masteryMenuMC.descriptionList.m_scrollbar_mc.stopAutoScroll();
						handled = true;
						break;
				}
			}

			switch(eventName)
			{
				case "IE FlashCtrl":
					ctrlDown = false;
					break;
				case "IE SplitItemToggle":
					shiftDown = false;
					break;
			}
			
			return handled;
		}
		
		public function onEventDown(eventIndex:Number) : Boolean
		{
			var handled:Boolean = false;
			//Registry.call("UIAssert","[WeaponExpansion] onEventDown ", this.events[eventIndex], eventIndex, param2, param3);
			var eventName:String = this.events[eventIndex];
			if (active)
			{
				switch(eventName)
				{
					case "IE UIUp":
						this.masteryMenuMC.previous();
						this.masteryMenuMC.adjustMainScroll();
						handled = true;
						break;
					case "IE UIDown":
						this.masteryMenuMC.next();
						this.masteryMenuMC.adjustMainScroll();
						handled = true;
						break;
					case "IE UIDialogTextUp":
						//this.masteryMenuMC.startScrollText(true,param3);
						handled = true;
						break;
					case "IE UIDialogTextDown":
						//this.masteryMenuMC.startScrollText(false,param3);
						handled = true;
						break;
					case "IE UITooltipUp":
						this.masteryMenuMC.descriptionList.m_scrollbar_mc.startAutoScroll(false);
						handled = true;
						break;
					case "IE UITooltipDown":
						this.masteryMenuMC.descriptionList.m_scrollbar_mc.startAutoScroll(true);
						handled = true;
						break;
					case "IE PartyManagement":
						this.masteryMenuMC.top();
						handled = true;
						break;
					case "IE PanelSelect":
						this.masteryMenuMC.bottom();
						handled = true;
						break;
					case "IE UILeft":
					case "IE PrevObject":
						this.masteryMenuMC.previous(3);
						handled = true;
						break;
					case "IE UIRight":
					case "IE NextObject":
						this.masteryMenuMC.next(3);
						handled = true;
						break;
				}
			}
			switch(eventName)
			{
				case "IE FlashCtrl":
					ctrlDown = !controllerEnabled;
					break;
				case "IE SplitItemToggle":
					shiftDown = !controllerEnabled;
					break;
				case "IE ToggleMap":
					if (!this.controllerEnabled && shiftDown)
					{
						handled = true;
						if(this.active)
						{
							Registry.call("LLWEAPONEX_MasteryMenu_RequestCloseUI");
						}
					}
					break;
			}
			return handled;
		}

		public function onEventTerminate(eventIndex:Number) : Boolean
		{
			return false;
		}

		public function setPlayerHandle(handle:* = null) : void
		{
			if(!isNaN(handle))
			{
				Registry.CharacterHandle = Number(handle);
			}
			else
			{
				Registry.CharacterHandle = characterHandle;
			}
		}
		
		public function setMaxRank(maxRank:int) : void
		{
			Registry.MaxRank = maxRank;
		}
		
		public function setTitle(title:String) : void
		{
			this.masteryMenuMC.setTitle(title);
		}
		
		public function setEmptyListText(title:String, description:String) : void
		{
			this.masteryMenuMC.setEmptyListText(title, description);
		}

		public function setTooltipText(masteredText:String) : void
		{
			Registry.MasteredText = masteredText;
		}
		
		public function setButtonText(text:String) : void
		{
			this.masteryMenuMC.setButtonText(text);
		}
		
		public function showControllerHints(enabled:Boolean) : void
		{
			this.masteryMenuMC.showControllerHints(enabled);
		}
		
		public function addBtnHint(id:Number, iconId:Number, hintText:String) : void
		{
			this.masteryMenuMC.buttonHintBar_mc.addBtnHint(id,hintText,iconId);
		}

		public function resetList() : void
		{
			this.masteryMenuMC.resetList();
		}
		
		public function addMastery(mastery:String, title:String, descriptionTitle:String, currentRank:uint, barPercentage:Number=0, isMastered:Boolean=false) : void
		{
			this.masteryMenuMC.addMastery(mastery,title,descriptionTitle,currentRank,barPercentage,isMastered);
		}

		public function setRankNodePosition(rank:uint, barPercentage:Number) : void
		{
			Registry.RankNodePositions[rank] = barPercentage
		}

		public function setExperienceBarTooltip(mastery:String, text:String) : void
		{
			this.masteryMenuMC.setExperienceBarTooltip(mastery, text);
		}

		public function setRankTooltipText(mastery:String, rank:int, text:String) : void
		{
			this.masteryMenuMC.setRankTooltipText(mastery, rank, text);
		}
		
		public function selectMastery(id:String, instant:Boolean = false) : void
		{
			this.masteryMenuMC.selectMastery(id,instant);
		}
		
		internal function frame1() : void
		{
			this.layout = "fixed";
			this.alignment = "none";
			this.events = new Array("IE UICancel","IE UIUp","IE UIDown","IE UIDialogTextUp","IE UIDialogTextDown", "IE ToggleInGameMenu", "IE PartyManagement", "IE PanelSelect", "IE UILeft", "IE UIRight", "IE PrevObject", "IE NextObject", "IE UITooltipUp", "IE UITooltipDown", "IE ToggleMap", "IE FlashCtrl", "IE SplitItemToggle");
			Registry.RankNodePositions[0] = 0.0;
			Registry.RankNodePositions[4] = 1.0;
			//var icon = new iconDisplay(32,32);
			//icon.setIcon(IconAtlases.larianSkillIcons, 10);
			//this.masteryMenuMC.addChild(icon);
		}
	}
}
