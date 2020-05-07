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

		public function addIcon(id:String, icon:String = "", iconType:int = 1, reposition:Boolean = true) : *
		{
			var entryContent:DescriptionIcon = new DescriptionIcon();
			entryContent.skill = id;
			entryContent.icon = icon;
			entryContent.iconType = iconType;
			entryContent.createIcon();
			addElement(entryContent, reposition, false);
		}
	}
}