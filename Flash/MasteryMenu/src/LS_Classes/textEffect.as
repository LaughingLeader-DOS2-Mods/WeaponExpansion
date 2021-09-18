package LS_Classes
{
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	
	public class textEffect
	{
		 
		
		public function textEffect()
		{
			super();
		}
		
		public static function createStrokeFilter(param1:uint, param2:Number, param3:Number = 1.0, param4:uint = 1, param5:uint = 2) : Array
		{
			var val8:DropShadowFilter = null;
			var val9:DropShadowFilter = null;
			var val10:Number = NaN;
			var val11:Number = NaN;
			var val12:Number = NaN;
			var val13:DropShadowFilter = null;
			var val6:Array = new Array();
			var val7:Number = 0;
			if(param5 <= 2)
			{
				val8 = new DropShadowFilter(param2,45,param1,param3,val7,val7,param4,BitmapFilterQuality.LOW,false,false,false);
				val9 = new DropShadowFilter(param2,135,param1,param3,val7,val7,param4,BitmapFilterQuality.LOW,false,false,false);
				val6.push(val8);
				val6.push(val9);
			}
			else
			{
				val10 = 45;
				val11 = 360 / param5;
				val12 = 0;
				while(val12 < param5)
				{
					val13 = new DropShadowFilter(param2,val10,param1,param3,val7,val7,param4,BitmapFilterQuality.LOW,false,false,false);
					val6.push(val13);
					val10 = val10 + val11;
					val12++;
				}
			}
			return val6;
		}
	}
}
