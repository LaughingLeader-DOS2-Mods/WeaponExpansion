package menu
{
	import flash.display.MovieClip;
	import LS_Classes.textHelpers;
	import LS_Classes.tooltipHelper;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	public dynamic class MasteryEntry extends MovieClip
	{
		public var masteryFrame:MovieClip;
		public var icon_mc:MovieClip;
		
		public var id:String;
		public var masteryTitle:String;
		public var masteryDescriptionTitle:String;

		public const DECOR_MARGIN:uint = 8;

		public var xpBar:MasteryBar;
		
		public function MasteryEntry()
		{
			super();
			this.addFrameScript(0,this.frame1);
		}
		
		public function setTitle(title:String, descriptionTitle:String = "") : void
		{
			this.masteryTitle = title;
			if (descriptionTitle == "")
			{
				descriptionTitle = title;
			}
			this.masteryDescriptionTitle = descriptionTitle;
			//textHelpers.setFormattedText(this.masteryFrame.title_txt, this.masteryTitle);
			this.masteryFrame.title_txt.htmlText = this.masteryTitle;
			//this.masteryFrame.title_txt.htmlText = this.masteryTitle;
			this.positioningText();
		}
		
		public function positioningText() : void
		{
			this.masteryFrame.title_txt.height = this.masteryFrame.title_txt.textHeight;
			this.masteryFrame.title_txt.y = 33.15;
			//this.masteryFrame.title_txt.y = (this.masteryFrame.height/2) - (this.masteryFrame.title_txt.textHeight / 2);
			//this.masteryFrame.title_txt.y = (this.xpBar.y + (this.xpBar.height/2)) - (this.masteryFrame.title_txt.textHeight/2);

			this.masteryFrame.top_decor.y = this.masteryFrame.title_txt.y - this.DECOR_MARGIN;
			this.masteryFrame.bottom_decor.y = this.masteryFrame.title_txt.y + this.masteryFrame.title_txt.height + this.DECOR_MARGIN * 2;
		}

		public function setBar(barPercentage:Number, animate:Boolean) : void
		{
			this.xpBar.setBar(barPercentage, animate);
		}

		public function setBarColor(color:uint) : void
		{
			this.xpBar.setBarColour(color);
		}

		public function xpBar_onOut(e:MouseEvent) : *
		{
			Registry.call("hideTooltip");
			this.xpBar.hasTooltip = false;
		}
		
		public function xpBar_onOver(e:MouseEvent) : *
		{
			tooltipHelper.ShowTooltipForMC(this.xpBar,this.root,"right");
		}

		public function setExperienceBarTooltip(text:String) : void
		{
			this.xpBar.tooltip = text;
			this.xpBar.addEventListener(MouseEvent.ROLL_OVER,this.xpBar_onOver);
			this.xpBar.addEventListener(MouseEvent.ROLL_OUT,this.xpBar_onOut);
		}

		public function masteryStar_onOut(e:MouseEvent) : *
		{
			Registry.call("hideTooltip");
			this.icon_mc.hasTooltip = false;
		}
		
		public function masteryStar_onOver(e:MouseEvent) : *
		{
			tooltipHelper.ShowTooltipForMC(icon_mc,root,"right");
		}

		public function setIsMastered(isMastered:Boolean=false) : void
		{
			this.icon_mc.visible = isMastered;

			if (isMastered)
			{
				this.icon_mc.gotoAndPlay(1);
				this.icon_mc.addEventListener(MouseEvent.ROLL_OVER,this.masteryStar_onOver);
				this.icon_mc.addEventListener(MouseEvent.ROLL_OUT,this.masteryStar_onOut);
			}
			else
			{
				this.icon_mc.removeEventListener(MouseEvent.ROLL_OVER,this.masteryStar_onOver);
				this.icon_mc.removeEventListener(MouseEvent.ROLL_OUT,this.masteryStar_onOut);
			}
		}

		public function setRankTooltipText(rank:int, text:String) : void
		{
			this.xpBar.setRankTooltipText(rank, text);
		}

		public function createRankNodes(currentRank:int, maxRank:int) : void
		{
			this.xpBar.createRankNodes(currentRank, maxRank);
		}

		public function positionRankNodes(currentRank:int) : void
		{
			this.xpBar.positionRankNodes(currentRank);
		}
		
		public function selectElement() : void
		{
			this.masteryFrame.select();
		}
		
		public function deselectElement() : void
		{
			this.masteryFrame.deselect();
		}

		public function onOut(e:MouseEvent) : *
		{
			this.masteryFrame.onOut(e);
		}
		
		public function onOver(e:MouseEvent) : *
		{
			this.masteryFrame.onOver(e);
			Registry.call("overMastery", this.id);
		}

		public function onDown(e:MouseEvent) : *
		{
			this.masteryFrame.onDown(e);
			Registry.call("PlaySound","UI_Generic_Click");
			Registry.Main.selectEntry(this, false);
		}
		
		internal function frame1() : void
		{
			this.stop();
			//this.xpBar.mouseChildren = false;
			//this.xpBar.mouseEnabled = false;
			this.icon_mc.tooltip = Registry.MasteredText;

			this.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			this.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
			this.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
		}
	}
}
