package desc
{
	import flash.display.MovieClip;
	import LS_Classes.scrollList;
	import LS_Classes.horizontalList;
	
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
			entryContent.id = id;
			entryContent.icon = icon;
			entryContent.iconType = iconType;
			entryContent.createIcon();
			addElement(entryContent, reposition, false);
		}

		public function addIconGroup(ids:String, icons:String, types:String, reposition:Boolean = true) : *
		{
			var entryList:horizontalList = new horizontalList();
			entryList.m_MaxWidth = this.width - (this.SIDE_SPACING * 2);
			var iconIds:Array = ids.split(",");
			var iconNames:Array = icons.split(",");
			var iconTypes:Array = types.split(",");

			var i:uint = 0;
			while (i < iconIds.length)
			{
				var iconId:String = iconIds[i];
				var iconName:String = iconNames[i];
				var iconType:int = int(iconTypes[i]);
				if (iconName == null)
				{
					iconName = "";
				}
				if (iconType < 0)
				{
					iconType = 1;
				}
				var entryContent:DescriptionIcon = new DescriptionIcon();
				entryContent.id = iconId;
				entryContent.icon = iconName;
				entryContent.iconType = iconType;
				entryContent.createIcon();
				entryList.addElement(entryContent, false, false);
			}

			entryList.positionElements();

			addElement(entryList, reposition, false);
		}
	}
}