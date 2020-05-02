package
{
	import flash.display.MovieClip;
	import LS_Classes.textHelpers;
	
	public dynamic class MasteryEntry extends MovieClip
	{
		public var masteryArt:MovieClip;
		public var masteryFrame:MovieClip;
		public var newIcon:MovieClip;
		public var m_Id:Number;
		
		public var m_MasteryId:String;
		public var m_MasteryTitle:String;
		public var m_MasteryDescriptionTitle:String;
		public var m_MasteryDesc:String;
		
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
			this.masteryArt.gotoAndStop(id + 2);
			this.masteryArt.visible = true;
			this.masteryArt.visible = false;
			this.m_MasteryId = mastery;
			this.masteryFrame.setId(id);
		}
		
		public function setTitle(title:String, descriptionTitle:String = "") : *
		{
			this.m_MasteryTitle = title;
			if (descriptionTitle == "")
			{
				descriptionTitle = title;
			}
			this.m_MasteryDescriptionTitle = descriptionTitle;
			//textHelpers.setFormattedText(this.masteryFrame.title_txt, this.m_MasteryTitle);
			this.masteryFrame.title_txt.htmlText = this.m_MasteryTitle;
			//this.masteryFrame.title_txt.htmlText = this.m_MasteryTitle;
			this.positioningText();
		}
		
		public function positioningText() : *
		{
			this.masteryFrame.title_txt.height = this.masteryFrame.title_txt.textHeight;
			this.masteryFrame.top_decor.y = this.masteryFrame.title_txt.y - this.DECOR_MARGIN;
			this.masteryFrame.bottom_decor.y = this.masteryFrame.title_txt.y + this.masteryFrame.title_txt.height + this.DECOR_MARGIN * 2;
		}
		
		public function setDescription(text:String) : *
		{
			this.m_MasteryDesc = text;
		}
		
		public function setBar(barPercentage:Number, animate:Boolean) : *
		{
			this.xpBar.setBar(barPercentage, animate);
		}

		public function setBarColor(color:uint) : *
		{
			this.xpBar.setBarColour(color);
		}
		
		public function getTitle() : *
		{
			return this.m_MasteryTitle;
		}

		public function getDescriptionTitle() : *
		{
			return this.m_MasteryDescriptionTitle;
		}
		
		public function getDescription() : *
		{
			return this.m_MasteryDesc;
		}
		
		public function selectElement() : *
		{
			this.masteryFrame.bg_mc.gotoAndStop(2);
			this.masteryFrame.masteryOverlay.gotoAndStop(2);
		}
		
		public function deselectElement() : *
		{
			this.masteryFrame.bg_mc.gotoAndStop(1);
			this.masteryFrame.masteryOverlay.gotoAndStop(1);
		}
		
		public function setAsNew() : *
		{
			this.newIcon.gotoAndStop(2);
		}
		
		function frame1() : *
		{
			this.xpBar.mouseChildren = false;
			this.xpBar.mouseEnabled = false;
		}
	}
}
