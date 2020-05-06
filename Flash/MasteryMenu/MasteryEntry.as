package
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
		
		public var m_Id:Number;
		public var masteryId:String;
		public var masteryTitle:String;
		public var masteryDescriptionTitle:String;

		public const DECOR_MARGIN:uint = 8;

		public var xpBar:MasteryBar;
		
		public function MasteryEntry()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function setId(id:Number, mastery:String) : *
		{
			this.m_Id = id;
			this.masteryId = mastery;
		}
		
		public function setTitle(title:String, descriptionTitle:String = "") : *
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
		
		public function positioningText() : *
		{
			this.masteryFrame.title_txt.height = this.masteryFrame.title_txt.textHeight;
			this.masteryFrame.title_txt.y = (this.masteryFrame.height/2) - (this.masteryFrame.title_txt.textHeight / 2);
			//this.masteryFrame.title_txt.y = (this.xpBar.y + (this.xpBar.height/2)) - (this.masteryFrame.title_txt.textHeight/2);

			this.masteryFrame.top_decor.y = this.masteryFrame.title_txt.y - this.DECOR_MARGIN;
			this.masteryFrame.bottom_decor.y = this.masteryFrame.title_txt.y + this.masteryFrame.title_txt.height + this.DECOR_MARGIN * 2;
		}

		public function setBar(barPercentage:Number, animate:Boolean) : *
		{
			this.xpBar.setBar(barPercentage, animate);
		}

		public function setBarColor(color:uint) : *
		{
			this.xpBar.setBarColour(color);
		}

		public function xpBar_onOut(e:MouseEvent) : *
		{
			ExternalInterface.call("hideTooltip");
			xpBar.hasTooltip = false;
		}
		
		public function xpBar_onOver(e:MouseEvent) : *
		{
			tooltipHelper.ShowTooltipForMC(xpBar,root,"right");
		}

		public function setExperienceBarTooltip(text:String) : *
		{
			xpBar.tooltip = text;
			xpBar.addEventListener(MouseEvent.ROLL_OVER,this.xpBar_onOver);
			xpBar.addEventListener(MouseEvent.ROLL_OUT,this.xpBar_onOut);
		}

		public function masteryStar_onOut(e:MouseEvent) : *
		{
			ExternalInterface.call("hideTooltip");
			icon_mc.hasTooltip = false;
		}
		
		public function masteryStar_onOver(e:MouseEvent) : *
		{
			tooltipHelper.ShowTooltipForMC(icon_mc,root,"right");
		}

		public function setIsMastered(isMastered:Boolean=false) : *
		{
			icon_mc.visible = isMastered;

			if (isMastered)
			{
				icon_mc.gotoAndPlay(1);
				icon_mc.addEventListener(MouseEvent.ROLL_OVER,this.masteryStar_onOver);
				icon_mc.addEventListener(MouseEvent.ROLL_OUT,this.masteryStar_onOut);
			}
			else
			{
				icon_mc.removeEventListener(MouseEvent.ROLL_OVER,this.masteryStar_onOver);
				icon_mc.removeEventListener(MouseEvent.ROLL_OUT,this.masteryStar_onOut);
			}
		}

		public function setRankTooltipText(rank:int, text:String) : *
		{
			this.xpBar.setRankTooltipText(rank, text);
		}

		public function createRankNodes(currentRank:int, maxRank:int) : *
		{
			this.xpBar.createRankNodes(currentRank, maxRank);
		}

		public function positionRankNodes(currentRank:int) : *
		{
			this.xpBar.positionRankNodes(currentRank);
		}
		
		public function selectElement() : *
		{
			this.masteryFrame.select();
		}
		
		public function deselectElement() : *
		{
			this.masteryFrame.deselect();
		}

		public function onOut(e:MouseEvent) : *
		{
			masteryFrame.onOut(e);
		}
		
		public function onOver(e:MouseEvent) : *
		{
			masteryFrame.onOver(e);
			ExternalInterface.call("overMastery", this.m_Id, this.masteryId);
		}

		public function onDown(e:MouseEvent) : *
		{
			masteryFrame.onDown(e);
			ExternalInterface.call("PlaySound","UI_Generic_Click");
			//ExternalInterface.call("selectedMastery", this.m_Id, this.masteryId);
			Registry.Main.selectEntry(this, false);
		}
		
		internal function frame1() : *
		{
			stop();
			//this.xpBar.mouseChildren = false;
			//this.xpBar.mouseEnabled = false;
			icon_mc.tooltip = Registry.MasteredText;

			addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			addEventListener(MouseEvent.ROLL_OVER,this.onOver);
			addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
		}
	}
}
