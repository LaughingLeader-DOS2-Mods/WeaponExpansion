package LS_Classes
{
	public class controllerHelper
	{
		
		public static const BTN_B:uint = 1;
		
		public static const BTN_A:uint = 2;
		
		public static const BTN_X:uint = 3;
		
		public static const BTN_Y:uint = 4;
		
		public static const BTN_LT:uint = 5;
		
		public static const BTN_RT:uint = 6;
		
		public static const BTN_StickLeft:uint = 7;
		
		public static const BTN_StickRight:uint = 8;
		
		public static const BTN_StickLeft_up:uint = 9;
		
		public static const BTN_StickLeft_down:uint = 10;
		
		public static const BTN_StickLeft_left:uint = 11;
		
		public static const BTN_StickLeft_right:uint = 12;
		
		public static const BTN_StickLeft_horiz:uint = 13;
		
		public static const BTN_StickLeft_vert:uint = 14;
		
		public static const BTN_StickRight_up:uint = 15;
		
		public static const BTN_StickRight_down:uint = 16;
		
		public static const BTN_StickRight_left:uint = 17;
		
		public static const BTN_StickRight_right:uint = 18;
		
		public static const BTN_StickRight_horiz:uint = 19;
		
		public static const BTN_StickRight_vert:uint = 20;
		
		public static const BTN_DPad_up:uint = 21;
		
		public static const BTN_DPad_down:uint = 22;
		
		public static const BTN_DPad_left:uint = 23;
		
		public static const BTN_DPad_right:uint = 24;
		
		public static const BTN_DPad_horiz:uint = 25;
		
		public static const BTN_DPad_vert:uint = 26;
		
		public static const BTN_Back:uint = 27;
		
		public static const BTN_Start:uint = 28;
		
		public static const BTN_StickLeft_press:uint = 29;
		
		public static const BTN_StickRight_press:uint = 30;
		
		public static const BTN_LB:uint = 31;
		
		public static const BTN_RB:uint = 32;
		 
		
		public function controllerHelper()
		{
			super();
		}
		
		public static function getIconClassName(param1:uint, param2:Boolean = false) : String
		{
			var _loc3_:String = "";
			switch(param1)
			{
				case BTN_B:
					if(param2)
					{
						_loc3_ = "iconBigCircle";
					}
					else
					{
						_loc3_ = "iconCircle";
					}
					break;
				case BTN_A:
					if(param2)
					{
						_loc3_ = "iconBigCross";
					}
					else
					{
						_loc3_ = "iconCross";
					}
					break;
				case BTN_X:
					_loc3_ = "iconSquare";
					break;
				case BTN_Y:
					_loc3_ = "iconTriangle";
					break;
				case BTN_LT:
					_loc3_ = "iconLT";
					break;
				case BTN_RT:
					_loc3_ = "iconRT";
					break;
				case BTN_StickLeft:
					_loc3_ = "iconStickLeft";
					break;
				case BTN_StickRight:
					_loc3_ = "iconStickRight";
					break;
				case BTN_StickLeft_up:
					_loc3_ = "iconStickLeft_up";
					break;
				case BTN_StickLeft_down:
					_loc3_ = "iconStickLeft_down";
					break;
				case BTN_StickLeft_left:
					_loc3_ = "iconStickLeft_left";
					break;
				case BTN_StickLeft_right:
					_loc3_ = "iconStickLeft_right";
					break;
				case BTN_StickLeft_horiz:
					_loc3_ = "iconStickLeft_horiz";
					break;
				case BTN_StickLeft_vert:
					_loc3_ = "iconStickLeft_vert";
					break;
				case BTN_StickRight_up:
					_loc3_ = "iconStickRight_up";
					break;
				case BTN_StickRight_down:
					_loc3_ = "iconStickRight_down";
					break;
				case BTN_StickRight_left:
					_loc3_ = "iconStickRight_left";
					break;
				case BTN_StickRight_right:
					_loc3_ = "iconStickRight_right";
					break;
				case BTN_StickRight_horiz:
					_loc3_ = "iconStickRight_horiz";
					break;
				case BTN_StickRight_vert:
					_loc3_ = "iconStickRight_vert";
					break;
				case BTN_DPad_up:
					_loc3_ = "iconDpad_up";
					break;
				case BTN_DPad_down:
					_loc3_ = "iconDpad_down";
					break;
				case BTN_DPad_left:
					_loc3_ = "iconDpad_left";
					break;
				case BTN_DPad_right:
					_loc3_ = "iconDpad_right";
					break;
				case BTN_DPad_horiz:
					_loc3_ = "iconDpad_horiz";
					break;
				case BTN_DPad_vert:
					_loc3_ = "iconDpad_vert";
					break;
				case BTN_Back:
					_loc3_ = "iconBack";
					break;
				case BTN_Start:
					_loc3_ = "iconStart";
					break;
				case BTN_StickLeft_press:
					_loc3_ = "iconStickLeft_press";
					break;
				case BTN_StickRight_press:
					_loc3_ = "iconStickRight_press";
					break;
				case BTN_LB:
					_loc3_ = "iconLB";
					break;
				case BTN_RB:
					_loc3_ = "iconRB";
			}
			return _loc3_;
		}
		
		public static function getIconHLClassName(param1:uint, param2:Boolean = false) : String
		{
			var _loc3_:String = "";
			switch(param1)
			{
				case BTN_LT:
					_loc3_ = "iconLTHL";
					break;
				case BTN_RT:
					_loc3_ = "iconRTHL";
			}
			return _loc3_;
		}
	}
}
