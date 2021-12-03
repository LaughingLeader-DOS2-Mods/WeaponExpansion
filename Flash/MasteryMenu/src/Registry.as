package
{
	import menu.MasteryMenuPanel;
	import flash.utils.getDefinitionByName;
	import flash.utils.Dictionary;

	public class Registry
	{
		public static var MasteredText:String = "Mastered";
		public static var MaxRank:int = 4;
		public static var RankNodePositions:Array;
		public static var CharacterHandle:Number;

		public static var Main:MasteryMenuPanel;

		//public static var SkillPattern:RegExp;

		public static function Init() : *
		{
			RankNodePositions = new Array();
			//SkillPattern = new RegExp("<skill id='.*?' icon='(.*?)'\/>", "gi");
		}

		private static var ClassMap:Dictionary = new Dictionary();

		public static function getClass(path:String) : Class
		{
			try
			{
				if(ClassMap[path] != null) {
					return ClassMap[path] as Class;
				}
				var c:Object = getDefinitionByName(path);
				if (c != null)
				{
					ClassMap[path] = c;
					return c as Class;
				}
			}
			catch(e:*) {
				trace(e);
			}
			trace("Failed to find class with path: " + path);
			return null;
		}
	}
}