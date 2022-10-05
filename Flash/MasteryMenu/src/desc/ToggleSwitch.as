package desc
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	
	public dynamic class ToggleSwitch extends MovieClip
	{
		public var bonusID:String = "";
		private var _enabled:Boolean = true;

		public function setEnabled(b:Boolean, fireExternalCall:Boolean = true):void
		{
			var last:Boolean = this._enabled;
			this._enabled = b;
			if(b)
			{
				this.gotoAndStop("on");
			}
			else
			{
				this.gotoAndStop("off");
			}
			if(fireExternalCall)
			{
				Registry.call("LLWEAPONEX_MasteryMenu_SetBonusEnabled", bonusID, b);
			}
		}

		public function get bonusEnabled():Boolean
		{
			return _enabled;
		}
		
		public function set bonusEnabled(b:Boolean):void
		{
			this.setEnabled(b);
		}

		public function ToggleSwitch()
		{
			super();
			this.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			this.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
			this.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
			this.addFrameScript(0,this.frame1);
		}

		public function onOut(e:MouseEvent):void
		{
			this.removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
		}
		
		public function onOver(e:MouseEvent):void
		{
			Registry.call("PlaySound","UI_Generic_Over");
		}
		
		public function onUp(e:MouseEvent):void
		{
			this.removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			Registry.call("PlaySound","UI_Generic_Click");
			this.setEnabled(!this.bonusEnabled, true);
		}
		
		public function onDown(e:MouseEvent):void
		{
			this.addEventListener(MouseEvent.MOUSE_UP,this.onUp);
		}

		internal function frame1():void
		{
			this.stop();
		}
	}
}