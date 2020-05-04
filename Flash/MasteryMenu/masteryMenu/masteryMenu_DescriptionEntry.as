package masteryMenu
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import data.DescriptionData;
	import data.SkillData;
	
	public dynamic class masteryMenu_DescriptionEntry extends MovieClip
	{
		public var icons:Array;
		public var description_txt:TextField;

		public function masteryMenu_DescriptionEntry()
		{
			super();
			addFrameScript(0,this.frame1);
		}

		internal function frame1() : *
		{
			stop();
		}

		public function init(descriptionData:DescriptionData) : *
		{
			// var result:Object = Registry.SkillPattern.exec(description);
			// trace(result);
			// while (result != null) {
			// 	trace ( result.index, "\t", result);
			// 	result = result.exec(description);
			// }

			description_txt.htmlText = descriptionData.descriptionText;

			if (descriptionData.skillsCount > 0)
			{
				var i:uint = 0;
				while (i < descriptionData.skillsCount)
				{
					var skillData:SkillData = descriptionData.skills[i];
					addSkill(skillData.id, skillData.icon);
					i += 1;
				}

				alignSkills();
			}
		}

		public function addSkill(skill:String,icon:String="") : *
		{
			var skillEntry:masteryMenu_DescriptionSkill = new masteryMenu_DescriptionSkill();
			skillEntry.init(skill,icon);
			icons.push(skillEntry);
			addChild(skillEntry);
		}

		public function alignSkills() : *
		{
			var i:uint = 0;
			var lastX:Number = 0;
			var lastY:Number = 0;
			var lastHeight:Number = 0;
			while(i < icons.length)
			{
				var icon:masteryMenu_DescriptionSkill = icons[i];
				if (icon != null)
				{
					lastHeight = icon.height;
					icon.x = lastX;
					lastX = lastX + icon.icon_mc.width + 2;
					if (lastX > description_txt.width)
					{
						lastX = 0;
						lastY = icon.height + 2;
					}
				}
				i = i + 1;
			}
			description_txt.y = lastY + lastHeight;
		}
	}
}