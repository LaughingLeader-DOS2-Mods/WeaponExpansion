package LS_Classes
{
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;
	
	public class controllerBtnHint extends MovieClip
	{
		 
		
		public var iconHL_mc:MovieClip;
		
		public var icon_mc:MovieClip;
		
		public function controllerBtnHint()
		{
			super();
			this.iconHL_mc = new MovieClip();
			this.icon_mc = new MovieClip();
			addChild(this.icon_mc);
			addChild(this.iconHL_mc);
		}
		
		public function setHintIcon(buttonId:Number, showBig:Boolean = false) : *
		{
			var iconMC:MovieClip = null;
			var hlcIconMC:MovieClip = null;
			var iconClass:Class = null;
			var hlcIconClass:Class = null;
			var hlcIconName:String = controllerHelper.getIconHLClassName(buttonId,showBig);
			var iconName:String = controllerHelper.getIconClassName(buttonId,showBig);
			if(!iconMC && iconName != "")
			{
				iconClass = getDefinitionByName(iconName) as Class;
				iconMC = new iconClass();
			}
			if(iconMC)
			{
				this.icon_mc.addChild(iconMC);
			}
			if(!hlcIconMC && hlcIconName != "")
			{
				hlcIconClass = getDefinitionByName(hlcIconName) as Class;
				hlcIconMC = new hlcIconClass();
			}
			if(hlcIconMC)
			{
				this.iconHL_mc.addChild(hlcIconMC);
			}
			this.iconHL_mc.visible = false;
		}
	}
}
