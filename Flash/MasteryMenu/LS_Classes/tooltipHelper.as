package LS_Classes
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	
	public class tooltipHelper extends MovieClip
	{
		 
		
		public function tooltipHelper()
		{
			super();
		}
		
		public static function ShowItemTooltipForMC(param1:MovieClip, param2:DisplayObject, param3:String = "right") : void
		{
			var _loc4_:Number = param1.width;
			var _loc5_:Number = param1.height;
			var _loc6_:Number = 0;
			var _loc7_:Number = 0;
			var _loc8_:Number = -1;
			if(param1.tooltipOverrideW)
			{
				_loc4_ = param1.tooltipOverrideW;
			}
			if(param1.tooltipOverrideH)
			{
				_loc5_ = param1.tooltipOverrideH;
			}
			if(param1.tooltipXOffset)
			{
				_loc6_ = param1.tooltipXOffset;
			}
			if(param1.tooltipYOffset)
			{
				_loc7_ = param1.tooltipYOffset;
			}
			if(param1.contextParam)
			{
				_loc8_ = param1.contextParam;
			}
			var _loc9_:Point = getGlobalPositionOfMC(param1,param2);
			ExternalInterface.call("showItemTooltip",param1.itemHandle,_loc9_.x + _loc6_,_loc9_.y + _loc7_,_loc4_,_loc5_,_loc8_,param3);
			var _loc10_:MovieClip = param2 as MovieClip;
			_loc10_.hasTooltip = true;
		}
		
		public static function ShowTooltipForMC(targetMC:MovieClip, displayObj:DisplayObject, tooltipPos:String = "right", stayOpen:Boolean = true) : void
		{
			var xOffset:Number = NaN;
			var yOffset:Number = NaN;
			var width:Number = NaN;
			var height:Number = NaN;
			var globalPos:Point = null;
			var displayMC:MovieClip = null;
			if(targetMC.tooltip && targetMC.tooltip != "")
			{
				xOffset = 0;
				yOffset = 0;
				width = targetMC.width;
				height = targetMC.height;
				if(targetMC.tooltipOverrideW)
				{
					width = targetMC.tooltipOverrideW;
				}
				if(targetMC.tooltipOverrideH)
				{
					height = targetMC.tooltipOverrideH;
				}
				if(targetMC.tooltipXOffset)
				{
					xOffset = targetMC.tooltipXOffset;
				}
				if(targetMC.tooltipYOffset)
				{
					yOffset = targetMC.tooltipYOffset;
				}
				globalPos = getGlobalPositionOfMC(targetMC,displayObj);
				ExternalInterface.call("showTooltip",targetMC.tooltip,globalPos.x + xOffset,globalPos.y + yOffset,width,height,tooltipPos,stayOpen);
				displayMC = displayObj as MovieClip;
				displayMC.hasTooltip = true;
			}
		}
		
		public static function ShowStatusTooltipForMC(param1:MovieClip, param2:DisplayObject, param3:String = "right") : void
		{
			var _loc4_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc8_:Point = null;
			var _loc9_:MovieClip = null;
			if(param1.owner && param1.id)
			{
				_loc4_ = 0;
				_loc5_ = 0;
				_loc6_ = param1.width;
				_loc7_ = param1.height;
				if(param1.tooltipOverrideW)
				{
					_loc6_ = param1.tooltipOverrideW;
				}
				if(param1.tooltipOverrideH)
				{
					_loc7_ = param1.tooltipOverrideH;
				}
				if(param1.tooltipXOffset)
				{
					_loc4_ = param1.tooltipXOffset;
				}
				if(param1.tooltipYOffset)
				{
					_loc5_ = param1.tooltipYOffset;
				}
				_loc8_ = getGlobalPositionOfMC(param1,param2);
				ExternalInterface.call("showStatusTooltip",param1.owner,param1.id,_loc8_.x + _loc4_,_loc8_.y + _loc5_,_loc6_,_loc7_,param3);
				_loc9_ = param2 as MovieClip;
				_loc9_.hasTooltip = true;
			}
		}
		
		public static function getGlobalPositionOfMC(param1:MovieClip, param2:DisplayObject) : Point
		{
			var _loc3_:Point = param1.localToGlobal(new Point(0,0));
			_loc3_.x = _loc3_.x - param2.x;
			_loc3_.y = _loc3_.y - param2.y;
			return _loc3_;
		}
	}
}
