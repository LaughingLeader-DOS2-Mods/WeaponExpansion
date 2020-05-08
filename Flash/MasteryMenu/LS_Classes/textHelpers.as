package LS_Classes
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import flash.utils.getDefinitionByName;
	
	public class textHelpers
	{
		 
		
		public function textHelpers()
		{
			super();
		}
		
		public static function smallCaps(param1:TextField, param2:Number = 7, param3:Boolean = false, param4:String = "") : void
		{
			var _loc12_:Object = null;
			var _loc13_:Number = NaN;
			var _loc14_:String = null;
			var _loc15_:Array = null;
			var _loc16_:Number = NaN;
			var _loc17_:Number = NaN;
			var _loc18_:String = null;
			var _loc19_:String = null;
			var _loc5_:String = "";
			var _loc6_:TextFormat = param1.getTextFormat();
			var _loc7_:Number = Number(_loc6_.size);
			var _loc8_:Number = _loc7_ - param2;
			var _loc9_:String = param1.htmlText;
			if(param4 != "")
			{
				_loc9_ = param4;
			}
			var _loc10_:Array = getFullTags(_loc9_);
			if(_loc10_.length == 0)
			{
				_loc12_ = new Object();
				_loc12_.tagStr = "";
				_loc12_.charPos = 0;
				_loc12_.tagContent = _loc9_;
				_loc10_.push(_loc12_);
			}
			var _loc11_:Number = 0;
			while(_loc11_ < _loc10_.length)
			{
				_loc13_ = _loc9_.length - 1;
				if(_loc11_ + 1 != _loc10_.length)
				{
					_loc13_ = _loc10_[_loc11_ + 1].charPos;
				}
				_loc14_ = _loc10_[_loc11_].tagContent;
				_loc15_ = new Array(_loc14_);
				if(param3)
				{
					_loc15_ = _loc14_.split(" ");
				}
				_loc5_ = _loc5_ + ("" + _loc10_[_loc11_].tagStr);
				_loc16_ = 0;
				while(_loc16_ < _loc15_.length)
				{
					if(_loc15_[_loc16_].length > 0)
					{
						_loc17_ = Number(_loc15_[_loc16_]);
						if(isNaN(_loc17_))
						{
							_loc18_ = _loc15_[_loc16_].charAt(0).toUpperCase();
							_loc19_ = _loc15_[_loc16_].slice(1).toUpperCase();
							_loc5_ = _loc5_ + (_loc18_ + "<font size=\'" + _loc8_ + "\'>" + _loc19_ + "</font>");
						}
						else
						{
							_loc5_ = _loc5_ + _loc17_;
						}
						if(param3)
						{
							_loc5_ = _loc5_ + " ";
						}
					}
					_loc16_++;
				}
				_loc11_++;
			}
			param1.htmlText = _loc5_;
		}
		
		public static function capTextFieldWidth(param1:TextField, param2:uint) : Boolean
		{
			var _loc3_:Rectangle = null;
			var _loc4_:uint = 0;
			var _loc5_:String = null;
			if(param1.textWidth > param2)
			{
				_loc4_ = 0;
				while(_loc4_ < param1.length)
				{
					_loc3_ = param1.getCharBoundaries(_loc4_);
					if(_loc3_.left > param2)
					{
						_loc5_ = param1.htmlText.slice(0,_loc4_);
						_loc5_ = _loc5_ + "...";
						param1.htmlText = _loc5_;
						return true;
					}
					_loc4_++;
				}
			}
			return false;
		}
		
		public static function toUpperCase(param1:String) : String
		{
			var _loc2_:Array = getFullTags(param1);
			if(_loc2_.length == 0)
			{
				return param1.toUpperCase();
			}
			var _loc3_:String = "";
			var _loc4_:Number = 0;
			while(_loc4_ < _loc2_.length)
			{
				_loc3_ = _loc3_ + ("" + _loc2_[_loc4_].tagStr + _loc2_[_loc4_].tagContent.toUpperCase());
				_loc4_++;
			}
			return _loc3_;
		}
		
		public static function cleanUpTextFieldDecoration(param1:Event) : *
		{
			var _loc4_:MovieClip = null;
			var _loc2_:TextField = param1.currentTarget as TextField;
			var _loc3_:MovieClip = _loc2_.parent as MovieClip;
			if(_loc3_)
			{
				if(_loc3_[_loc2_.name + "Deco"] != null)
				{
					_loc4_ = _loc3_[_loc2_.name + "Deco"];
					if(_loc4_)
					{
						_loc4_.graphics.clear();
					}
					_loc2_.removeEventListener(Event.REMOVED_FROM_STAGE,cleanUpTextFieldDecoration);
				}
			}
		}
		
		public static function setFormattedText(param1:TextField, param2:String, param3:String = "$Title_Bold", param4:String = "$Title_Italic") : void
		{
			var _loc16_:Number = NaN;
			var _loc17_:Number = NaN;
			var _loc18_:uint = 0;
			var _loc19_:TextLineMetrics = null;
			var _loc20_:int = 0;
			var _loc21_:int = 0;
			var _loc22_:Rectangle = null;
			var _loc23_:Rectangle = null;
			var _loc24_:Number = NaN;
			var _loc25_:Number = NaN;
			var _loc26_:int = 0;
			var _loc27_:TextFormat = null;
			var _loc28_:uint = 0;
			var _loc29_:Number = NaN;
			var _loc5_:Class = getDefinitionByName(param3) as Class;
			var _loc6_:Class = getDefinitionByName(param4) as Class;
			var _loc7_:Font = new _loc5_();
			var _loc8_:Font = new _loc6_();
			var _loc9_:TextFormat = param1.getTextFormat();
			var _loc10_:MovieClip = param1.parent as MovieClip;
			_loc9_.font = _loc8_.fontName;
			var _loc11_:TextFormat = param1.getTextFormat();
			_loc11_.font = _loc7_.fontName;
			param1.htmlText = param2;
			var _loc12_:MovieClip = null;
			if(_loc10_[param1.name + "Deco"] != null)
			{
				_loc12_ = _loc10_[param1.name + "Deco"];
				if(_loc12_)
				{
					_loc12_.graphics.clear();
				}
				param1.removeEventListener(Event.REMOVED_FROM_STAGE,cleanUpTextFieldDecoration);
			}
			var _loc13_:Array = getTags(param2);
			var _loc14_:int = 0;
			var _loc15_:uint = 0;
			while(_loc15_ < _loc13_.length)
			{
				switch(_loc13_[_loc15_].tagStr)
				{
					case "<s>":
						_loc14_ = findNextTag("</s>",_loc15_,_loc13_);
						if(_loc14_ > 0 && _loc14_ < _loc13_.length)
						{
							_loc16_ = param1.getLineIndexOfChar(_loc13_[_loc15_].charPos);
							_loc17_ = param1.getLineIndexOfChar(_loc13_[_loc14_].charPos);
							if(_loc17_ < 0)
							{
								_loc17_ = param1.numLines - 1;
							}
							if(_loc16_ >= 0 && _loc17_ >= 0)
							{
								_loc18_ = _loc16_;
								while(_loc18_ <= _loc17_)
								{
									if(_loc12_ == null)
									{
										_loc12_ = _loc10_[param1.name + "Deco"] = new MovieClip();
										_loc10_.addChild(_loc12_);
										_loc12_.x = param1.x;
										_loc12_.y = param1.y;
										param1.addEventListener(Event.REMOVED_FROM_STAGE,cleanUpTextFieldDecoration);
									}
									_loc19_ = param1.getLineMetrics(_loc18_);
									_loc20_ = param1.getLineOffset(_loc18_);
									_loc21_ = _loc20_ + param1.getLineLength(_loc18_);
									if(_loc20_ < _loc13_[_loc15_].charPos)
									{
										_loc20_ = _loc13_[_loc15_].charPos;
									}
									if(_loc21_ > _loc13_[_loc14_].charPos)
									{
										_loc21_ = _loc13_[_loc14_].charPos;
									}
									_loc22_ = param1.getCharBoundaries(_loc20_);
									_loc23_ = param1.getCharBoundaries(_loc21_ - 1);
									if(_loc22_)
									{
										_loc24_ = Boolean(_loc23_)?Number(_loc23_.right):Number(_loc22_.right);
										_loc25_ = _loc22_.left;
										_loc26_ = _loc19_.ascent * 0.8 + _loc22_.top;
										_loc27_ = param1.getTextFormat(_loc13_[_loc15_].charPos,_loc13_[_loc14_].charPos);
										if(_loc27_.color == null)
										{
											_loc27_ = param1.getTextFormat(_loc13_[_loc15_].charPos,_loc13_[_loc15_].charPos + 1);
										}
										_loc28_ = new uint(_loc27_.color);
										_loc29_ = new Number(_loc27_.size);
										_loc12_.graphics.lineStyle(Math.ceil(_loc29_ * 0.08),_loc28_);
										_loc12_.graphics.moveTo(_loc25_,_loc26_);
										_loc12_.graphics.lineTo(_loc24_,_loc26_);
									}
									_loc18_++;
								}
							}
						}
						break;
					case "<u>":
						_loc14_ = findNextTag("</u>",_loc15_,_loc13_);
						if(_loc14_ > 0 && _loc14_ < _loc13_.length)
						{
							_loc16_ = param1.getLineIndexOfChar(_loc13_[_loc15_].charPos);
							_loc17_ = param1.getLineIndexOfChar(_loc13_[_loc14_].charPos);
							if(_loc17_ < 0)
							{
								_loc17_ = param1.numLines - 1;
							}
							if(_loc16_ >= 0 && _loc17_ >= 0)
							{
								_loc18_ = _loc16_;
								while(_loc18_ <= _loc17_)
								{
									if(_loc12_ == null)
									{
										_loc12_ = _loc10_[param1.name + "Deco"] = new MovieClip();
										_loc10_.addChild(_loc12_);
										_loc12_.x = param1.x;
										_loc12_.y = param1.y;
										param1.addEventListener(Event.REMOVED_FROM_STAGE,cleanUpTextFieldDecoration);
									}
									_loc19_ = param1.getLineMetrics(_loc18_);
									_loc20_ = param1.getLineOffset(_loc18_);
									_loc21_ = _loc20_ + param1.getLineLength(_loc18_);
									if(_loc20_ < _loc13_[_loc15_].charPos)
									{
										_loc20_ = _loc13_[_loc15_].charPos;
									}
									if(_loc21_ > _loc13_[_loc14_].charPos)
									{
										_loc21_ = _loc13_[_loc14_].charPos;
									}
									_loc22_ = param1.getCharBoundaries(_loc20_);
									if(_loc22_)
									{
										_loc23_ = param1.getCharBoundaries(_loc21_ - 1);
										if(_loc23_)
										{
											_loc23_ = param1.getCharBoundaries(_loc21_ - 2);
										}
										_loc24_ = Boolean(_loc23_)?Number(_loc23_.right):Number(_loc22_.right);
										_loc25_ = _loc22_.left;
										_loc27_ = param1.getTextFormat(_loc13_[_loc15_].charPos,_loc13_[_loc14_].charPos);
										_loc28_ = new uint(_loc27_.color);
										_loc29_ = new Number(_loc27_.size);
										_loc26_ = _loc19_.ascent + _loc19_.descent * 0.04 * _loc29_ + _loc22_.top;
										_loc12_.graphics.lineStyle(Math.ceil(_loc29_ * 0.08),_loc28_);
										_loc12_.graphics.moveTo(_loc25_,_loc26_);
										_loc12_.graphics.lineTo(_loc24_,_loc26_);
									}
									_loc18_++;
								}
							}
						}
						break;
					case "<b>":
						_loc14_ = findNextTag("</b>",_loc15_,_loc13_);
						if(_loc14_ > 0 && _loc14_ < _loc13_.length)
						{
							param1.setTextFormat(_loc11_,_loc13_[_loc15_].charPos,_loc13_[_loc14_].charPos);
						}
						break;
					case "<i>":
						_loc14_ = findNextTag("</i>",_loc15_,_loc13_);
						if(_loc14_ > 0 && _loc14_ < _loc13_.length)
						{
							param1.setTextFormat(_loc9_,_loc13_[_loc15_].charPos,_loc13_[_loc14_].charPos);
						}
				}
				_loc15_++;
			}
		}
		
		private static function findNextTag(param1:String, param2:uint, param3:Array) : int
		{
			var _loc4_:uint = param2;
			while(_loc4_ < param3.length)
			{
				if(param3[_loc4_].tagStr == param1)
				{
					return _loc4_;
				}
				_loc4_++;
			}
			return -1;
		}
		
		private static function getFullTags(param1:String) : Array
		{
			var _loc5_:Object = null;
			var _loc2_:Array = new Array();
			var _loc3_:int = 0;
			var _loc4_:int = param1.indexOf("<",_loc3_);
			while(_loc4_ != -1)
			{
				_loc3_ = _loc4_;
				_loc4_ = param1.indexOf(">",_loc3_);
				_loc5_ = new Object();
				_loc5_.tagStr = param1.substring(_loc3_,_loc4_ + 1);
				_loc5_.charPos = _loc3_;
				_loc2_.push(_loc5_);
				_loc3_ = _loc4_;
				_loc4_ = param1.indexOf("<",_loc3_);
				if(_loc3_ == -1 && _loc4_ == -1 || _loc3_ >= param1.length - 1)
				{
					_loc5_.tagContent = "";
				}
				else if(_loc4_ == -1)
				{
					_loc5_.tagContent = param1.substring(_loc3_ + 1);
				}
				else
				{
					_loc5_.tagContent = param1.substring(_loc3_ + 1,_loc4_);
				}
			}
			return _loc2_;
		}
		
		private static function getTags(param1:String) : Array
		{
			var _loc6_:Object = null;
			var _loc2_:Array = new Array();
			var _loc3_:int = 0;
			var _loc4_:int = param1.indexOf("<",_loc3_);
			var _loc5_:int = 0;
			while(_loc4_ != -1)
			{
				_loc3_ = _loc4_;
				_loc4_ = param1.indexOf(">",_loc3_);
				_loc6_ = new Object();
				_loc6_.tagStr = param1.substr(_loc3_,_loc4_ - _loc3_ + 1);
				_loc6_.charPos = _loc3_ - _loc5_;
				_loc2_.push(_loc6_);
				_loc5_ = _loc5_ + _loc6_.tagStr.length;
				_loc3_ = _loc4_;
				_loc4_ = param1.indexOf("<",_loc3_);
			}
			return _loc2_;
		}
		
		public static function trim(param1:String) : String
		{
			var _loc2_:Number = 0;
			while(param1.charAt(_loc2_) == " ")
			{
				_loc2_ = _loc2_ + 1;
			}
			param1 = param1.substring(_loc2_);
			var _loc3_:Number = param1.length;
			_loc3_ = _loc3_ - 1;
			while(param1.charAt(_loc3_) == " ")
			{
				_loc3_ = _loc3_ - 1;
			}
			param1 = param1.substring(0,_loc3_ + 1);
			return param1;
		}
		
		public static function getLongestWordLength(param1:TextField) : Number
		{
			var _loc3_:Boolean = false;
			var _loc4_:Boolean = false;
			var _loc5_:String = null;
			var _loc6_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc8_:Number = NaN;
			var _loc9_:Boolean = false;
			var _loc10_:Rectangle = null;
			var _loc11_:Rectangle = null;
			var _loc12_:Number = NaN;
			var _loc13_:Number = NaN;
			var _loc2_:Number = 0;
			if(param1.text.length > 0)
			{
				_loc3_ = param1.multiline;
				_loc4_ = param1.wordWrap;
				_loc5_ = param1.autoSize;
				param1.multiline = false;
				param1.autoSize = TextFieldAutoSize.LEFT;
				_loc6_ = 0;
				_loc7_ = 0;
				_loc8_ = 0;
				_loc9_ = false;
				while(_loc6_ != -1)
				{
					_loc7_ = _loc6_;
					_loc6_ = param1.text.indexOf(" ",_loc7_ + 1);
					if(_loc6_ == -1)
					{
						_loc6_ = param1.text.length;
						_loc9_ = true;
					}
					if(_loc6_ != -1 && _loc7_ != -1)
					{
						_loc10_ = param1.getCharBoundaries(_loc6_ - 1);
						if(_loc10_)
						{
							_loc11_ = param1.getCharBoundaries(_loc7_);
							if(_loc11_)
							{
								_loc12_ = _loc10_.right;
								_loc13_ = _loc11_.right;
								if(_loc7_ == 0)
								{
									_loc13_ = _loc11_.left;
								}
								_loc8_ = _loc12_ - _loc13_;
								if(_loc8_ > _loc2_)
								{
									_loc2_ = _loc8_;
								}
							}
						}
					}
					if(_loc9_)
					{
						_loc6_ = -1;
					}
				}
				if(_loc2_ == 0)
				{
					_loc2_ = param1.textWidth;
				}
				param1.multiline = _loc3_;
				param1.wordWrap = _loc4_;
				param1.autoSize = _loc5_;
			}
			return Math.ceil(_loc2_);
		}
		
		public static function firstLetterUpperCase(param1:String) : String
		{
			var _loc4_:* = null;
			var _loc2_:Array = param1.split(" ");
			var _loc3_:Array = [];
			for(_loc4_ in _loc2_)
			{
				_loc3_.push(_loc2_[_loc4_].charAt(0).toUpperCase() + _loc2_[_loc4_].slice(1));
			}
			return _loc3_.join(" ");
		}
		
		public static function getSelectionLengthOfText(param1:TextField, param2:Number, param3:Number) : Number
		{
			var _loc4_:Number = textHelpers.getCharIndexAtPoint(param1,param2,param3);
			var _loc5_:Number = Math.max(param1.selectionEndIndex,param1.selectionBeginIndex);
			var _loc6_:Number = Math.min(param1.selectionEndIndex,param1.selectionBeginIndex);
			if(_loc5_ < _loc4_ || _loc4_ < _loc6_)
			{
				param1.setSelection(_loc4_,_loc4_);
			}
			return Math.abs(param1.selectionEndIndex - param1.selectionBeginIndex);
		}
		
		public static function getCharIndexAtPoint(param1:TextField, param2:Number, param3:Number) : Number
		{
			var _loc9_:Rectangle = null;
			var _loc10_:Number = NaN;
			var _loc11_:Number = NaN;
			var _loc4_:Number = 0;
			var _loc5_:Number = param1.text.length;
			var _loc6_:Number = -1;
			var _loc7_:Boolean = false;
			var _loc8_:Number = 0;
			while(_loc8_ < _loc5_)
			{
				_loc9_ = param1.getCharBoundaries(_loc8_);
				if(_loc9_)
				{
					_loc10_ = _loc9_.y + _loc9_.height;
					if(_loc6_ > 0 && _loc10_ > _loc6_)
					{
						_loc7_ = true;
						break;
					}
					if(_loc10_ > param3)
					{
						_loc6_ = _loc10_;
						if(_loc9_.x > param2)
						{
							_loc7_ = true;
							_loc11_ = _loc9_.x + _loc9_.width / 2;
							if(param2 > _loc11_)
							{
								_loc4_++;
							}
							break;
						}
					}
				}
				_loc4_ = _loc8_;
				_loc8_++;
			}
			return !!_loc7_?Number(_loc4_):Number(_loc5_);
		}
		
		public static function makeInputFieldModal(param1:TextField, param2:Boolean = true) : *
		{
			if(param2)
			{
				param1.addEventListener(FocusEvent.FOCUS_IN,onFocusInModalInputField);
				param1.addEventListener(FocusEvent.FOCUS_OUT,onFocusOutModalInputField);
			}
			else
			{
				param1.removeEventListener(FocusEvent.FOCUS_IN,onFocusInModalInputField);
				param1.removeEventListener(FocusEvent.FOCUS_OUT,onFocusOutModalInputField);
				if(param1.selectionBeginIndex != -1)
				{
					ExternalInterface.call("inputFocusLost");
				}
			}
		}
		
		public static function onFocusInModalInputField(param1:FocusEvent) : *
		{
			var _loc2_:TextField = null;
			if(param1.target is TextField)
			{
				_loc2_ = param1.target as TextField;
				if(_loc2_.type == TextFieldType.INPUT)
				{
					_loc2_.removeEventListener(FocusEvent.FOCUS_IN,onFocusInModalInputField);
					_loc2_.addEventListener(FocusEvent.FOCUS_OUT,onFocusOutModalInputField);
					ExternalInterface.call("inputFocus");
				}
			}
		}
		
		public static function onFocusOutModalInputField(param1:FocusEvent) : *
		{
			var _loc2_:TextField = null;
			if(param1.target is TextField)
			{
				_loc2_ = param1.target as TextField;
				if(_loc2_.type == TextFieldType.INPUT)
				{
					_loc2_.addEventListener(FocusEvent.FOCUS_IN,onFocusInModalInputField);
					_loc2_.removeEventListener(FocusEvent.FOCUS_OUT,onFocusOutModalInputField);
					ExternalInterface.call("inputFocusLost");
				}
			}
		}
		
		public static function adjustFontSize(param1:TextField, param2:Number, param3:Number) : *
		{
			var _loc5_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc4_:TextFormat = param1.getTextFormat();
			if(Number(_loc4_.size) != param2)
			{
				_loc4_.size = param2;
				param1.setTextFormat(_loc4_);
			}
			if(param1.textWidth > param1.width)
			{
				_loc5_ = param1.width / param1.textWidth;
				_loc6_ = Math.floor(param2 * _loc5_);
				if(_loc6_ >= param3)
				{
					_loc4_.size = _loc6_;
					param1.setTextFormat(_loc4_);
				}
				else
				{
					_loc4_.size = param3;
					param1.setTextFormat(_loc4_);
					capTextFieldWidth(param1,param1.width);
				}
			}
		}
	}
}
