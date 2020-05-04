package masteryMenu
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	
	public dynamic class masteryMenu_DescriptionSkill extends MovieClip
	{
		public var skillId:String;
		public var icon_mc:IconDisplay;

		public function masteryMenu_DescriptionSkill()
		{
			super();
			addFrameScript(0,this.frame1);
		}

		internal function frame1() : *
		{
			stop();
		}

		public function init(skill:String,icon:String="") : *
		{
			this.skillId = skill
			if (icon != "")
			{
				icon_mc = new IconDisplay();
				icon_mc.setIcon(IconAtlases.larianSkillIcons, 10);
				addChild(icon_mc);
				addEventListener(MouseEvent.ROLL_OUT,this.onOut);
				addEventListener(MouseEvent.ROLL_OVER,this.onOver);
			}
		}
		
		public function onOver(e:MouseEvent) : *
		{
			var pos:Point = icon_mc.localToGlobal(new Point(0,0));
			ExternalInterface.call("mastery_showSkillTooltip",Registry.CharacterHandle,skillId,pos.x,pos.y,icon_mc.width,icon_mc.height);
		}

		public function onOut(e:MouseEvent) : *
		{
			ExternalInterface.call("hideTooltip");
			ExternalInterface.call("mastery_hideSkillTooltip");
		}
	}
}