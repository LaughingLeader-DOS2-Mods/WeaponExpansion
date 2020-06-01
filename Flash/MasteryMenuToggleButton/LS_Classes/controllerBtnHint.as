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
		
		public function setHintIcon(param1:Number, param2:Boolean = false) : *
		{
			var _loc5_:MovieClip = null;
			var _loc6_:MovieClip = null;
			var _loc7_:Class = null;
			var _loc8_:Class = null;
			var _loc3_:String = controllerHelper.getIconHLClassName(param1,param2);
			var _loc4_:String = controllerHelper.getIconClassName(param1,param2);
			if(!_loc5_ && _loc4_ != "")
			{
				_loc7_ = getDefinitionByName(_loc4_) as Class;
				_loc5_ = new _loc7_();
			}
			if(_loc5_)
			{
				this.icon_mc.addChild(_loc5_);
			}
			if(!_loc6_ && _loc3_ != "")
			{
				_loc8_ = getDefinitionByName(_loc3_) as Class;
				_loc6_ = new _loc8_();
			}
			if(_loc6_)
			{
				this.iconHL_mc.addChild(_loc6_);
			}
			this.iconHL_mc.visible = false;
		}
	}
}
