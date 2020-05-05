package
{
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	public dynamic class iconDisplay extends MovieClip
	{
		public var iconData:BitmapData;
		public var iconBitmap:Bitmap;
		public var iconWidth:int = 64;
		public var iconHeight:int = 64;
		
		public function iconDisplay()
		{
			super();
			iconData = new BitmapData(iconWidth, iconHeight, true, 0xFFFFFFFF);
			iconBitmap = new Bitmap(iconData);
			addChild(iconBitmap);

			addFrameScript(0,this.frame1);
		}
		
		function frame1() : *
		{
			stop();

			iconData.draw(this);
		}

		public function setIcon(sourceData:BitmapData, index:int) : *
		{
			iconData.copyPixels(sourceData, 
				new Rectangle((index % 32) * iconWidth, Math.floor(index / 32) * iconHeight, iconWidth, iconHeight),
				new Point(0,0)
			);
			//iconData.draw(this);
		}
	}
}