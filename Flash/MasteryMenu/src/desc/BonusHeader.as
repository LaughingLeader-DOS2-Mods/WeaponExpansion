package desc
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import LS_Classes.tooltipHelper;
	
	public dynamic class BonusHeader extends MovieClip
	{
		public var content_txt:TextField;
		public var checkbox_mc:Checkbox;

		public var bonusID:String;
		public static var enabledTooltip:String = "Click to Disable Bonus<br>(Currently Enabled)";
		public static var disabledTooltip:String = "Click to Enable Bonus<br>(Currently Disabled)";

		private var base:MovieClip;

		public function BonusHeader()
		{
			super();
			this.addFrameScript(0,this.frame1);
			this.checkbox_mc.interactiveTextOnClick = false;
			this.checkbox_mc.init(onCheckbox);
			this.checkbox_mc.onOverFunc = showCheckboxTooltip;
			this.checkbox_mc.onOutFunc = hideCheckboxTooltip;
		}

		public function setText(text:String):void
		{
			this.content_txt.htmlText = text;
			//this.content_txt.height = this.content_txt.textHeight;
			this.checkbox_mc.x = this.content_txt.x + this.content_txt.textWidth + 6;
		}

		public function setEnabled(b:Boolean, fireExternalCall:Boolean = true):void
		{
			this.checkbox_mc.setActive(b);
			if(fireExternalCall)
			{
				Registry.call("LLWEAPONEX_MasteryMenu_SetBonusEnabled", this.bonusID, b);
			}
			if(b)
			{
				this.checkbox_mc.tooltip = BonusHeader.enabledTooltip;
			}
			else
			{
				this.checkbox_mc.tooltip = BonusHeader.disabledTooltip;
			}
		}

		public function onCheckbox():void
		{
			Registry.call("LLWEAPONEX_MasteryMenu_SetBonusEnabled", this.bonusID, this.checkbox_mc.isActive);
			if(this.checkbox_mc.isActive)
			{
				this.checkbox_mc.tooltip = BonusHeader.enabledTooltip;
			}
			else
			{
				this.checkbox_mc.tooltip = BonusHeader.disabledTooltip;
			}
			if(this.base.hasTooltip && this.base.currentTooltip == this.bonusID)
			{
				showCheckboxTooltip();
			}
		}

		public function showCheckboxTooltip():void
		{
			tooltipHelper.ShowTooltipForMC(this.checkbox_mc,this.base,"right");
			this.base.currentTooltip = this.bonusID;
		}

		public function hideCheckboxTooltip():void
		{
			Registry.call("hideTooltip");
			this.base.hasTooltip = false;
			this.base.currentTooltip = "";
		}

		internal function frame1() : *
		{
			this.stop();
			this.base = this.root as MovieClip;
		}
	}
}