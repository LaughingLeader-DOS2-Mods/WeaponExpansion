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
		
		public static function ShowTooltipForMC(targetMC:MovieClip, displayObj:DisplayObject, tooltipPos:String = "right", allowDelay:Boolean = true) : void
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
				ExternalInterface.call("showTooltip", targetMC.tooltip, globalPos.x + xOffset, globalPos.y + yOffset, width, height, tooltipPos, allowDelay);
				displayMC = displayObj as MovieClip;
				displayMC.hasTooltip = true;
			}
		}
		
		public static function ShowStatusTooltipForMC(statusMC:MovieClip, obj:DisplayObject, tooltipPos:String = "right") : void
		{
			var xOffset:Number = NaN;
			var yOffset:Number = NaN;
			var tooltipWidth:Number = NaN;
			var tooltipHeight:Number = NaN;
			var targetTooltipPos:Point = null;
			var displayObjMC:MovieClip = null;
			if(statusMC.owner && statusMC.id)
			{
				xOffset = 0;
				yOffset = 0;
				tooltipWidth = statusMC.width;
				tooltipHeight = statusMC.height;
				if(statusMC.tooltipOverrideW)
				{
					tooltipWidth = statusMC.tooltipOverrideW;
				}
				if(statusMC.tooltipOverrideH)
				{
					tooltipHeight = statusMC.tooltipOverrideH;
				}
				if(statusMC.tooltipXOffset)
				{
					xOffset = statusMC.tooltipXOffset;
				}
				if(statusMC.tooltipYOffset)
				{
					yOffset = statusMC.tooltipYOffset;
				}
				targetTooltipPos = getGlobalPositionOfMC(statusMC,obj);
				ExternalInterface.call("showStatusTooltip", statusMC.owner, statusMC.id, targetTooltipPos.x + xOffset,targetTooltipPos.y + yOffset, tooltipWidth, tooltipHeight,tooltipPos);
				displayObjMC = obj as MovieClip;
				displayObjMC.hasTooltip = true;
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
