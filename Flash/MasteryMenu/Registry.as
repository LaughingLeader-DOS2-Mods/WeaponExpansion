package
{
	public class Registry
	{
		public static var MasteredText:String = "Mastered";
		public static var MaxRank:int = 4;
		public static var RankNodePositions:Array;
		public static var CharacterHandle:Number;

		//public static var SkillPattern:RegExp;

		public static function Init() : *
		{
			RankNodePositions = new Array();
			//SkillPattern = new RegExp("<skill id='.*?' icon='(.*?)'\/>", "gi");
		}
	}
}