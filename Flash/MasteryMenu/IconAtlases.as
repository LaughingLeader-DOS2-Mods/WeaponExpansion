package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.geom.Matrix;
	import flash.utils.getDefinitionByName;
	import icons.*;

	public class IconAtlases
	{
		public static function Init() : *
		{
			
		}

		/**
		 * Resize display object or bitmap data to a new size
		 **/
		public static function resizeBitmapData(bitmapDrawable:IBitmapDrawable, width:Number, height:Number, scaleMode:String="none", 
											smooth:Boolean = true, transparent:Boolean = true, fillColor:Number = 0x00000000):BitmapData {
			var sizedBitmapData:BitmapData;
			var matrix:Matrix;
			matrix = getSizeByScaleMode(width, height, Object(bitmapDrawable).width, Object(bitmapDrawable).height, scaleMode);
			sizedBitmapData = new BitmapData(width, height, transparent, fillColor);
			sizedBitmapData.draw(bitmapDrawable, matrix, null, null, null, smooth);

			return sizedBitmapData;
		}

		// Get correct scale. Inspired from code in Apache Flex (license Apache 2.0) 
		public static function getSizeByScaleMode(maxWidth:int, maxHeight:int, 
												width:int, height:int, 
												scaleMode:String="letterbox",
												dpi:Number=NaN):Matrix {

			var aspectRatio:String = (maxWidth < maxHeight) ? "portrait" : "landscape";
			var orientation:String = aspectRatio;

			var matrix:Matrix = new Matrix();

			var scaleX:Number = 1;
			var scaleY:Number = 1;

			switch(scaleMode) {
				case "zoom":
					scaleX = Math.max( maxWidth / width, maxHeight / height);
					scaleY = scaleX;
					break;

				case "letterbox":
					scaleX = Math.min( maxWidth / width, maxHeight / height);
					scaleY = scaleX;
					break;

				case "stretch":
					scaleX = maxWidth / width;
					scaleY = maxHeight / height;
					break;
			}

			if (scaleX != 1 || scaleY != 0) {
				width *= scaleX;
				height *= scaleY;
				matrix.scale(scaleX, scaleY);
			}

			matrix.translate(-width / 2, -height / 2);

			matrix.translate(maxWidth / 2, maxHeight / 2);

			return matrix;
		}
	}
}