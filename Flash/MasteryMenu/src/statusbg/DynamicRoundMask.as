package statusbg
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public dynamic class DynamicRoundMask extends MovieClip
	{
		public var oldBA:Number;
		
		public var oldEA:Number;
		
		public function DynamicRoundMask()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function drawWedge(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:uint = 0, param7:Number = 1.0) : *
		{
			var _loc17_:* = undefined;
			var _loc18_:* = undefined;
			var _loc8_:Number = Math.PI / 180;
			if(param4 == this.oldBA && param5 == this.oldEA)
			{
				return;
			}
			this.oldBA = param4;
			this.oldEA = param5;
			var _loc9_:Sprite = this.getChildByName("myPie") as Sprite;
			if(_loc9_ != null)
			{
				this.removeChild(_loc9_);
			}
			var _loc10_:Sprite = new Sprite();
			_loc10_.name = "myPie";
			_loc10_.graphics.lineStyle(2,param6,0);
			_loc10_.graphics.beginFill(param6,param7);
			if(param5 < param4)
			{
				param5 = param5 + 360;
			}
			var _loc11_:Number = Math.ceil((param5 - param4) / 45);
			if(_loc11_ == 0)
			{
				return;
			}
			var _loc12_:int = 0;
			var _loc13_:Number = (param5 - param4) / _loc11_ * _loc8_;
			var _loc14_:Number = param3 / Math.cos(_loc13_ / 2);
			var _loc15_:Number = param4 * _loc8_;
			var _loc16_:Number = _loc15_ - _loc13_ / 2;
			_loc10_.graphics.moveTo(param1,param2);
			_loc10_.graphics.lineTo(param1 + param3 * Math.cos(_loc15_),param2 + param3 * Math.sin(_loc15_));
			_loc12_ = 0;
			while(_loc12_ < _loc11_)
			{
				_loc15_ = _loc15_ + _loc13_;
				_loc16_ = _loc16_ + _loc13_;
				_loc17_ = param3 * Math.cos(_loc15_);
				_loc18_ = param3 * Math.sin(_loc15_);
				_loc10_.graphics.lineTo(param1 + _loc17_,param2 + _loc18_);
				_loc12_++;
			}
			_loc10_.graphics.lineTo(param1,param2);
			_loc10_.graphics.endFill();
			this.addChild(_loc10_);
		}
		
		function frame1() : *
		{
			this.oldBA = -1;
			this.oldEA = -1;
		}
	}
}
