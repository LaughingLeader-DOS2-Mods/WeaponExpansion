package  {
	
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.events.MouseEvent;
	
	public class SkillIcon extends MovieClip {
		
		
		public function SkillIcon() {
			super();
			addFrameScript(0,this.frame1);
		}

		public function onOut(param1:MouseEvent) : *
		{
			ExternalInterface.call("hideTooltip");
			ExternalInterface.call("hideSkillTooltip");
		}
		
		public function onOver(param1:MouseEvent) : *
		{
			ExternalInterface.call("showSkillTooltip",3.4431514429141e-282,"Target_CripplingBlow",339.00001335144, 940.0, 50.522705078125, 58.118209838867);
		}

		function frame1() : *
		{
			stop();

			this.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			this.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
		}
	}
	
}
