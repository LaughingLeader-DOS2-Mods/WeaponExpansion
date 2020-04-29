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
		
		public static function getIconClassName(buttonId:uint, showBig:Boolean = false) : String
		{
			var iconName:String = "";
			switch(buttonId)
			{
				case BTN_B:
					if(showBig)
					{
						iconName = "iconBigCircle";
					}
					else
					{
						iconName = "iconCircle";
					}
					break;
				case BTN_A:
					if(showBig)
					{
						iconName = "iconBigCross";
					}
					else
					{
						iconName = "iconCross";
					}
					break;
				case BTN_X:
					iconName = "iconSquare";
					break;
				case BTN_Y:
					iconName = "iconTriangle";
					break;
				case BTN_LT:
					iconName = "iconLT";
					break;
				case BTN_RT:
					iconName = "iconRT";
					break;
				case BTN_StickLeft:
					iconName = "iconStickLeft";
					break;
				case BTN_StickRight:
					iconName = "iconStickRight";
					break;
				case BTN_StickLeft_up:
					iconName = "iconStickLeft_up";
					break;
				case BTN_StickLeft_down:
					iconName = "iconStickLeft_down";
					break;
				case BTN_StickLeft_left:
					iconName = "iconStickLeft_left";
					break;
				case BTN_StickLeft_right:
					iconName = "iconStickLeft_right";
					break;
				case BTN_StickLeft_horiz:
					iconName = "iconStickLeft_horiz";
					break;
				case BTN_StickLeft_vert:
					iconName = "iconStickLeft_vert";
					break;
				case BTN_StickRight_up:
					iconName = "iconStickRight_up";
					break;
				case BTN_StickRight_down:
					iconName = "iconStickRight_down";
					break;
				case BTN_StickRight_left:
					iconName = "iconStickRight_left";
					break;
				case BTN_StickRight_right:
					iconName = "iconStickRight_right";
					break;
				case BTN_StickRight_horiz:
					iconName = "iconStickRight_horiz";
					break;
				case BTN_StickRight_vert:
					iconName = "iconStickRight_vert";
					break;
				case BTN_DPad_up:
					iconName = "iconDpad_up";
					break;
				case BTN_DPad_down:
					iconName = "iconDpad_down";
					break;
				case BTN_DPad_left:
					iconName = "iconDpad_left";
					break;
				case BTN_DPad_right:
					iconName = "iconDpad_right";
					break;
				case BTN_DPad_horiz:
					iconName = "iconDpad_horiz";
					break;
				case BTN_DPad_vert:
					iconName = "iconDpad_vert";
					break;
				case BTN_Back:
					iconName = "iconBack";
					break;
				case BTN_Start:
					iconName = "iconStart";
					break;
				case BTN_StickLeft_press:
					iconName = "iconStickLeft_press";
					break;
				case BTN_StickRight_press:
					iconName = "iconStickRight_press";
					break;
				case BTN_LB:
					iconName = "iconLB";
					break;
				case BTN_RB:
					iconName = "iconRB";
			}
			return iconName;
		}
		
		public static function getIconHLClassName(buttonId:uint, showBig:Boolean = false) : String
		{
			var iconName:String = "";
			switch(buttonId)
			{
				case BTN_LT:
					iconName = "iconLTHL";
					break;
				case BTN_RT:
					iconName = "iconRTHL";
			}
			return iconName;
		}
	}
}
