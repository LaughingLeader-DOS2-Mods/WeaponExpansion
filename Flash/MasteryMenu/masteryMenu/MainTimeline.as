package masteryMenu
{
	import flash.display.MovieClip;
	import flash.display.InteractiveObject;
	import flash.external.ExternalInterface;
	
	public dynamic class MainTimeline extends MovieClip
	{
		 
		
		public var masteryMenuMC:MovieClip;

		public var menu_btn:MovieClip;
		
		public var layout:String;
		
		public var alignment:String;
		
		public const anchorId:String = "masteryMenu";
		
		public const anchorPos:String = "center";
		
		public const anchorTPos:String = "center";
		
		public const anchorTarget:String = "screen";
		
		public var events:Array;
		
		public var items_array:Array;

		private var lastFocus:InteractiveObject;
		
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
			this.masteryMenuMC.visible = false;
		}

		public function openMenu() : *
		{
			if (!this.masteryMenuMC.visible)
			{
				ExternalInterface.call("PlaySound","UI_Game_PauseMenu_Open");
				ExternalInterface.call("focus");
				ExternalInterface.call("inputfocus");
				this.masteryMenuMC.visible = true;
				stage.focus = lastFocus;
			}
		}

		public function closeMenu() : *
		{
			if (this.masteryMenuMC.visible)
			{
				ExternalInterface.call("PlaySound","UI_Game_PauseMenu_Close");
				//ExternalInterface.call("PlaySound","UI_Game_Inventory_Close");
				ExternalInterface.call("requestCloseUI");
				ExternalInterface.call("inputFocusLost");
				ExternalInterface.call("focusLost");
				this.masteryMenuMC.visible = false;
				lastFocus = stage.focus;
				stage.focus = null;
			}
		}
		
		public function onEventUp(eventIndex:Number, param2:Number, param3:Number) : *
		{
			var handled:Boolean = false;
			ExternalInterface.call("UIAssert","[WeaponExpansion] onEventUp ", this.events[eventIndex], eventIndex, param2, param3);
			switch(this.events[eventIndex])
			{
				case "IE UIAccept":
					break;
				case "IE UICancel":
				case "IE ToggleInGameMenu":
					handled = true;
					closeMenu();
					break;
				case "IE UIUp":
				case "IE UIDown":
					handled = true;
					break;
				case "IE UIDialogTextUp":
				case "IE UIDialogTextDown":
					this.masteryMenuMC.stopScrollText();
					handled = true;
					break;
			}
			return handled;
		}
		
		public function onEventDown(eventIndex:Number, param2:Number, param3:Number) : *
		{
			var handled:Boolean = false;
			ExternalInterface.call("UIAssert","[WeaponExpansion] onEventDown ", this.events[eventIndex], eventIndex, param2, param3);

			switch(this.events[eventIndex])
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
					this.masteryMenuMC.startScrollText(true,param3);
					handled = true;
					break;
				case "IE UIDialogTextDown":
					this.masteryMenuMC.startScrollText(false,param3);
					handled = true;
			}
			return handled;
		}

		public function onEventTerminate(eventIndex:Number) : *
		{
			return true;
		}
		
		public function setTitle(title:String) : *
		{
			this.masteryMenuMC.setTitle(title);
		}
		
		public function setEmptyListText(title:String, description:String) : *
		{
			this.masteryMenuMC.setEmptyListText(title, description);
		}
		
		public function setButtonText(text:String) : *
		{
			this.masteryMenuMC.setButtonText(text);
		}
		
		public function setToggleButtonTooltip(text:String) : *
		{
			this.menu_btn.setTooltip(text);
		}
		
		public function showControllerHints(enabled:Boolean) : *
		{
			this.masteryMenuMC.showControllerHints(enabled);
		}
		
		public function addBtnHint(id:Number, iconId:Number, hintText:String) : *
		{
			this.masteryMenuMC.buttonHintBar_mc.addBtnHint(id,hintText,iconId);
		}

		public function resetList() : *
		{
			this.masteryMenuMC.resetList();
		}
		
		public function addMastery(listId:Number, mastery:String, title:String, descriptionTitle:String, description:String, showIcon:Boolean, xpAmount:Number=0, animateBar:Boolean = true) : *
		{
			this.masteryMenuMC.addMastery(listId,mastery,title,descriptionTitle,description,showIcon,xpAmount,animateBar);
		}
		
		public function selectMastery(id:Number) : *
		{
			this.masteryMenuMC.select(id);
		}
		
		function frame1() : *
		{
			this.layout = "fixed";
			this.alignment = "none";
			this.events = new Array("IE UICancel","IE UIUp","IE UIDown","IE UIDialogTextUp","IE UIDialogTextDown", "IE ToggleInGameMenu");
			this.items_array = new Array();
		}
	}
}
