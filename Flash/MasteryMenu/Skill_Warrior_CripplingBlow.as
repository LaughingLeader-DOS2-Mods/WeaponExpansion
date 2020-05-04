package  {
	
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.events.MouseEvent;
	
	public class Skill_Warrior_CripplingBlow extends MovieClip {
		public function Skill_Warrior_CripplingBlow() {
			addFrameScript(0,this.frame1);
			this.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			this.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
			trace("Skill_Warrior_CripplingBlow init")
			this.name = "Skill_Warrior_CripplingBlow";
		}

		public function onOut(param1:MouseEvent) : *
		{
			ExternalInterface.call("hideTooltip");
		}
		
		public function onOver(param1:MouseEvent) : *
		{
			ExternalInterface.call("showSkillTooltip",3.4431514429141e-282,"Target_CripplingBlow",339.00001335144, 940.0, 50.522705078125, 58.118209838867);
			trace("Skill_Warrior_CripplingBlow mouse over")
		}

		function frame1() : *
		{
			stop();
			trace("Skill_Warrior_CripplingBlow frame 1")
		}
	}
	
}
