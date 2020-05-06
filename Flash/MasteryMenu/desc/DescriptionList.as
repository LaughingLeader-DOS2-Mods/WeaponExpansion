package desc
{
	import flash.display.MovieClip;
	import LS_Classes.scrollList;
	
	public dynamic class DescriptionList extends scrollList
	{
		public function DescriptionList()
		{
			super();
			addFrameScript(0,this.frame1);
		}

		internal function frame1() : *
		{
			stop();
		}

		public function addText(text:String, reposition:Boolean = true) : *
		{
			var entryContent:DescriptionText = new DescriptionText();
			entryContent.setText(text);
			entryContent.width = this.width - (this.SIDE_SPACING * 2);
			addElement(entryContent, reposition, false);
		}

		public function addSkill(skill:String, icon:String = "", reposition:Boolean = true) : *
		{
			var entryContent:DescriptionSkill = new DescriptionSkill();
			entryContent.skill = skill;
			entryContent.icon = icon;
			entryContent.createIcon();
			addElement(entryContent, reposition, false);
		}
	}
}