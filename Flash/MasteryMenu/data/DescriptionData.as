package data
{
	public class DescriptionData
	{
		public var descriptionText:String = "";
		public var skills:Array;
		public var skillsCount:int = 0;

		public function DescriptionData(text:String)
		{
			descriptionText = text;
		}

		public function addSkillData(skillId:String, icon:String) : *
		{
			var d:SkillData = new SkillData(skillId, icon);
			skills.push(d);
			skillsCount += 1;
		}
	}
}