package
{
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	public dynamic class iconDisplay extends MovieClip
	{
		public var iconData:BitmapData;
		public var iconBitmap:Bitmap;
		public var iconWidth:int = 64;
		public var iconHeight:int = 64;
		
		public function iconDisplay(w:int=64,h:int=64)
		{
			super();
			iconWidth = w;
			iconHeight = h;
			iconData = new BitmapData(iconWidth, iconHeight, true, 0x000000);
			iconBitmap = new Bitmap(iconData, PixelSnapping.NEVER, true);
			addChild(iconBitmap);

			addFrameScript(0,this.frame1);
		}
		
		function frame1() : *
		{
			stop();
		}

		public function setIcon(sourceData:BitmapData, index:int, sourceWidth=64, sourceHeight=64) : *
		{
			var copyData = IconAtlases.resizeBitmapData(sourceData, 32, 32)
			iconData.copyPixels(copyData, 
				new Rectangle((index % 32) * sourceWidth, Math.floor(index / 32) * sourceHeight, sourceWidth, sourceHeight),
				new Point(0,0)
			);
		}
	}
}