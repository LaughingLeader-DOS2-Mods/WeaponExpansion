package
{
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	
	public dynamic class iconDisplay extends MovieClip
	{
		public var displayBitmap:Bitmap;

		public static var spriteSheet:Bitmap;

		public static var spriteW:int = 64;
		public static var spriteH:int = 64;
		public static var sheetW:int = 5;
		
		public function iconDisplay()
		{
			super();
			addFrameScript(0,this.frame1,1);
		}
		
		function frame1() : *
		{
			stop();
		}

		public function setIcon(index:int) : *
		{
			displayBitmap.bitmapData.copyPixels(spriteSheet.bitmapData, 
				new Rectangle((spriteIndex % sheetW) * spriteW, Math.floor(spriteIndex / sheetW) * spriteH, spriteW, spriteH),
				new Point(0,0)
			);
		}
	}
}