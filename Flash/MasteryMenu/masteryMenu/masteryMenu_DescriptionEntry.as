package masteryMenu
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import data.DescriptionData;
	import data.SkillData;
	
	public dynamic class masteryMenu_DescriptionEntry extends MovieClip
	{
		public var icons:Array = new Array();
		public var description_txt:TextField;

		public var EL_SPACING:Number = 4;

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
			description_txt.height = 0;
			description_txt.height = description_txt.textHeight;

			if (descriptionData.skillsCount > 0)
			{
				var i:uint = 0;
				while (i < descriptionData.skillsCount)
				{
					var skillData:SkillData = descriptionData.skills[i];
					if (skillData != null)
					{
						this.createSkillMC(skillData.id, skillData.icon);
					}
					i += 1;
				}

				alignElements();
			}
		}

		public function createSkillMC(skill:String,icon:String="") : *
		{
			var skillEntry:masteryMenu_DescriptionSkill = new masteryMenu_DescriptionSkill();
			skillEntry.init(skill,icon);
			icons.push(skillEntry);
			addChild(skillEntry);
		}

		public function alignElements() : *
		{
			var i:uint = 0;
			var lastY:Number = 0;
			var lastX:Number = 0;
			var lastHeight:Number = 0;
			description_txt.x = 0;
			description_txt.y = 0;
			lastY = description_txt.y + description_txt.textHeight + EL_SPACING;

			while(i < icons.length)
			{
				var icon:masteryMenu_DescriptionSkill = icons[i];
				if (icon != null)
				{
					lastHeight = icon.height;
					icon.x = lastX;
					icon.y = lastY;
					lastX += icon.width + EL_SPACING;
					if (lastX > description_txt.width)
					{
						lastX = 0;
						lastY += icon.height + EL_SPACING;
					}
				}
				i += 1;
			}
		}
	}
}