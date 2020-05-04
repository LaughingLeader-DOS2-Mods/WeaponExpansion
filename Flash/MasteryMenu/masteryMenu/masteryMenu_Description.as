package masteryMenu
{
	import flash.display.MovieClip;
	import data.DescriptionData;
	import data.SkillData;
	
	public dynamic class masteryMenu_Description extends MovieClip
	{
		public var rows:Array = new Array();
		public var lastY:Number = 0;

		public function masteryMenu_Description()
		{
			super();

			rows = new Array();

			addFrameScript(0,this.frame1);
		}

		internal function frame1() : *
		{
			stop();
		}

		public function addEntry(description:DescriptionData) : *
		{
			var entry:masteryMenu_DescriptionEntry = new masteryMenu_DescriptionEntry();
			entry.init(description);
			rows.push(entry);
			entry.y = lastY;
			lastY = entry.y + entry.height;
		}

		public function addSkill(entryId:uint, skill:String,icon:String="") : *
		{
			var entry:masteryMenu_DescriptionEntry = rows[entryId];
			if (entry != null)
			{
				entry.addSkill(skill,icon);
			}
		}

		public function alignEntries() : *
		{
			var i:uint = 0;
			lastY = 0;
			while(i < rows.length)
			{
				var entry:masteryMenu_DescriptionEntry = rows[i];
				if (entry != null)
				{
					entry.y = lastY;
					lastY = entry.height + 2;
				}
				i = i + 1;
			}
		}

		public function clearElements() : *
		{
			var i:uint = 0;
			while(i < rows.length)
			{
				var entry:masteryMenu_DescriptionEntry = rows[i];
				if (entry != null)
				{
					this.removeChild(entry);
				}
				i = i + 1;
			}
			rows = new Array();
		}
	}
}