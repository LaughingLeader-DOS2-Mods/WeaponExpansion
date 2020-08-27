package fl.motion
{
	import flash.geom.ColorTransform;
	
	public class Color extends ColorTransform
	{
		 
		
		private var _tintColor:Number = 0;
		
		private var _tintMultiplier:Number = 0;
		
		public function Color(param1:Number = 1.0, param2:Number = 1.0, param3:Number = 1.0, param4:Number = 1.0, param5:Number = 0, param6:Number = 0, param7:Number = 0, param8:Number = 0)
		{
			super(param1,param2,param3,param4,param5,param6,param7,param8);
		}
		
		public static function fromXML(param1:XML) : Color
		{
			return Color(new Color().parseXML(param1));
		}
		
		public static function interpolateTransform(param1:ColorTransform, param2:ColorTransform, param3:Number) : ColorTransform
		{
			var val4:Number = 1 - param3;
			var val5:ColorTransform = new ColorTransform(param1.redMultiplier * val4 + param2.redMultiplier * param3,param1.greenMultiplier * val4 + param2.greenMultiplier * param3,param1.blueMultiplier * val4 + param2.blueMultiplier * param3,param1.alphaMultiplier * val4 + param2.alphaMultiplier * param3,param1.redOffset * val4 + param2.redOffset * param3,param1.greenOffset * val4 + param2.greenOffset * param3,param1.blueOffset * val4 + param2.blueOffset * param3,param1.alphaOffset * val4 + param2.alphaOffset * param3);
			return val5;
		}
		
		public static function interpolateColor(param1:uint, param2:uint, param3:Number) : uint
		{
			var val4:Number = 1 - param3;
			var val5:uint = param1 >> 24 & 255;
			var val6:uint = param1 >> 16 & 255;
			var val7:uint = param1 >> 8 & 255;
			var val8:uint = param1 & 255;
			var val9:uint = param2 >> 24 & 255;
			var val10:uint = param2 >> 16 & 255;
			var val11:uint = param2 >> 8 & 255;
			var val12:uint = param2 & 255;
			var val13:uint = val5 * val4 + val9 * param3;
			var val14:uint = val6 * val4 + val10 * param3;
			var val15:uint = val7 * val4 + val11 * param3;
			var val16:uint = val8 * val4 + val12 * param3;
			var val17:uint = val13 << 24 | val14 << 16 | val15 << 8 | val16;
			return val17;
		}
		
		public function get brightness() : Number
		{
			return !!this.redOffset?Number(1 - this.redMultiplier):Number(this.redMultiplier - 1);
		}
		
		public function set brightness(param1:Number) : void
		{
			if(param1 > 1)
			{
				param1 = 1;
			}
			else if(param1 < -1)
			{
				param1 = -1;
			}
			var val2:Number = 1 - Math.abs(param1);
			var val3:Number = 0;
			if(param1 > 0)
			{
				val3 = param1 * 255;
			}
			this.redMultiplier = this.greenMultiplier = this.blueMultiplier = val2;
			this.redOffset = this.greenOffset = this.blueOffset = val3;
		}
		
		public function setTint(param1:uint, param2:Number) : void
		{
			this._tintColor = param1;
			this._tintMultiplier = param2;
			this.redMultiplier = this.greenMultiplier = this.blueMultiplier = 1 - param2;
			var val3:uint = param1 >> 16 & 255;
			var val4:uint = param1 >> 8 & 255;
			var val5:uint = param1 & 255;
			this.redOffset = Math.round(val3 * param2);
			this.greenOffset = Math.round(val4 * param2);
			this.blueOffset = Math.round(val5 * param2);
		}
		
		public function get tintColor() : uint
		{
			return this._tintColor;
		}
		
		public function set tintColor(param1:uint) : void
		{
			this.setTint(param1,this.tintMultiplier);
		}
		
		private function deriveTintColor() : uint
		{
			var val1:Number = 1 / this.tintMultiplier;
			var val2:uint = Math.round(this.redOffset * val1);
			var val3:uint = Math.round(this.greenOffset * val1);
			var val4:uint = Math.round(this.blueOffset * val1);
			var val5:uint = val2 << 16 | val3 << 8 | val4;
			return val5;
		}
		
		public function get tintMultiplier() : Number
		{
			return this._tintMultiplier;
		}
		
		public function set tintMultiplier(param1:Number) : void
		{
			this.setTint(this.tintColor,param1);
		}
		
		private function parseXML(param1:XML = null) : Color
		{
			var val3:XML = null;
			var val4:String = null;
			var val5:uint = 0;
			if(!param1)
			{
				return this;
			}
			var val2:XML = param1.elements()[0];
			if(!val2)
			{
				return this;
			}
			for each(val3 in val2.attributes())
			{
				val4 = val3.localName();
				if(val4 == "tintColor")
				{
					val5 = Number(val3.toString()) as uint;
					this.tintColor = val5;
				}
				else
				{
					this[val4] = Number(val3.toString());
				}
			}
			return this;
		}
	}
}
