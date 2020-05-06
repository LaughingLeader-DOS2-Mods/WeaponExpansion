package  {
	
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	
	public class MainTimeline extends MovieClip {
		
		public var iconTest:MovieClip;
		
		public function MainTimeline() {
			super();
			addFrameScript(0,this.frame1);
		}

		// private function DrawSpriteIndex( displayBitmap:Bitmap, spriteSheet:Bitmap, spriteIndex:int ):void {
		// 	var spriteW:int = 64;
		// 	var spriteH:int = 64;
		// 	var sheetW:int = 32;

		// 	displayBitmap.bitmapData.copyPixels(spriteSheet.bitmapData, 
		// 		new Rectangle( (spriteIndex % sheetW) * spriteW, Math.floor(spriteIndex / sheetW) * spriteH, 32, 32),
		// 		new Point(0,0)
		// 		);
		// }

		//[Embed(source="Ability_Skill_Status_Icons.png")]
		//private var skillIcons:Class;
		
		internal function frame1() : *
		{
			var iconSheet = new Ability_Skill_Status_Icons();
			iconTest.setIcon(iconSheet, 10);
			
			trace("Set icon?");
			trace(iconSheet);

			//var iconBitmap = new Bitmap(iconSheet);
			//addChild(iconBitmap);
			//iconSheet.draw(this);

			//var image:Bitmap = new Bitmap(new Ability_Skill_Status_Icons());
			//addChild(image);
		}
	}
	
}
