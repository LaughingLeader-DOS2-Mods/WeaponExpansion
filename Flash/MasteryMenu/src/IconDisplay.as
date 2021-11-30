package
{
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import icons.*;
	import flash.external.ExternalInterface;

	public dynamic class IconDisplay extends MovieClip
	{
		public var iconData:BitmapData;
		public var iconBitmap:Bitmap;
		public var iconWidth:int = 64;
		public var iconHeight:int = 64;
		
		public function IconDisplay(iconClass:String, w:int=64,h:int=64)
		{
			super();
			iconWidth = w;
			iconHeight = h;

			try
			{
				var iconImageClass:Class = Registry.getClass("icons."+iconClass);
				if (iconImageClass != null)
				{
					iconData = new iconImageClass();
				}
				else
				{
					iconData = new LeaderLib_Placeholder();
				}
				
				iconBitmap = new Bitmap(iconData);
				addChild(iconBitmap);
			}
			catch(e:Error)
			{
				ExternalInterface.call("UIAssert","[WeaponEx] Error creating icon image from name '"+iconClass+"':",e.getStackTrace());
				iconData = new LeaderLib_Placeholder();
				iconBitmap = new Bitmap(iconData);
				addChild(iconBitmap);
			}
			
			addFrameScript(0,this.frame1);
		}
		
		internal function frame1() : *
		{
			stop();
		}

		public function setIcon(sourceData:BitmapData, index:int, sourceWidth:int=64, sourceHeight:int=64, sheetColumns:int=32) : *
		{
			//var copyData:BitmapData = IconAtlases.resizeBitmapData(sourceData, 32, 32)
			iconData.copyPixels(sourceData, 
				new Rectangle((index % sheetColumns) * iconWidth, Math.floor(index / sheetColumns) * iconHeight, iconWidth, iconHeight),
				new Point(0,0)
			);
			//iconData = copyData;
			//iconBitmap.bitmapData = iconData;
		}
	}
}