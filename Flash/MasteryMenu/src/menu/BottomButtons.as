package menu
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import desc.Checkbox;
	import LS_Classes.tooltipHelper;
	
	public dynamic class BottomButtons extends MovieClip
	{
		public var enableAll_txt:TextField;
		public var enableAll_checkbox:Checkbox;

		private var base:MovieClip;

		public static var enableAllTooltip:String = "Click to Enable All Bonuses";
		public static var disableAllTooltip:String = "Click to Disable All Bonuses";
		
		public function BottomButtons()
		{
			super();

			this.addFrameScript(0,this.frame1);

			this.enableAll_checkbox.interactiveTextOnClick = false;
			this.enableAll_checkbox.init(onEnableAllCheckbox);
			this.enableAll_checkbox.tooltip = enableAllTooltip;
			this.enableAll_checkbox.onOverFunc = showCheckboxTooltip;
			this.enableAll_checkbox.onOutFunc = hideCheckboxTooltip;
		}

		internal function frame1() : *
		{
			this.stop();
			this.base = this.root as MovieClip;
		}

		public function onEnableAllCheckbox():void
		{
			Registry.call("LLWEAPONEX_MasteryMenu_ToggleAllBonuses", this.enableAll_checkbox.isActive);
			if(this.enableAll_checkbox.isActive)
			{
				this.enableAll_checkbox.tooltip = disableAllTooltip;
			}
			else
			{
				this.enableAll_checkbox.tooltip = enableAllTooltip;
			}
			if(this.base.currentTooltip == this.name)
			{
				showCheckboxTooltip(this.enableAll_checkbox);
			}
		}

		public function onDisableAllCheckbox():void
		{
			Registry.call("LLWEAPONEX_MasteryMenu_DisableAllBonuses");
		}

		public function showCheckboxTooltip(obj:MovieClip):void
		{
			tooltipHelper.ShowTooltipForMC(obj,this.base,"right");
			this.base.currentTooltip = this.name;
		}

		public function hideCheckboxTooltip():void
		{
			Registry.call("hideTooltip");
			this.base.hasTooltip = false;
			this.base.currentTooltip = "";
		}
	}
}