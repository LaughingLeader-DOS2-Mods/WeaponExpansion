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
		
		public static function setFormattedText(textField:TextField, text:String, boldClassName:String = "$Title_Bold", italicClassName:String = "$Title_Italic") : void
		{
			var lineIndex1:Number = NaN;
			var lineIndex2:Number = NaN;
			var lineIndex3:uint = 0;
			var lineMetrics:TextLineMetrics = null;
			var lineOffset:int = 0;
			var lineOffsetEnd:int = 0;
			var charBounds:Rectangle = null;
			var charBounds2:Rectangle = null;
			var lineToRight:Number = NaN;
			var leftPos:Number = NaN;
			var rightPos:int = 0;
			var posFormatter:TextFormat = null;
			var formatColor:uint = 0;
			var formatSize:Number = NaN;
			var boldClass:Class = getDefinitionByName(boldClassName) as Class;
			var italicClass:Class = getDefinitionByName(italicClassName) as Class;
			var boldFont:Font = new boldClass();
			var italicFont:Font = new italicClass();
			var italicFormatter:TextFormat = textField.getTextFormat();
			var parentMC:MovieClip = textField.parent as MovieClip;
			italicFormatter.font = italicFont.fontName;
			var boldFormatter:TextFormat = textField.getTextFormat();
			boldFormatter.font = boldFont.fontName;
			textField.htmlText = text;
			var decoMC:MovieClip = null;
			if(parentMC[textField.name + "Deco"] != null)
			{
				decoMC = parentMC[textField.name + "Deco"];
				if(decoMC)
				{
					decoMC.graphics.clear();
				}
				textField.removeEventListener(Event.REMOVED_FROM_STAGE,cleanUpTextFieldDecoration);
			}
			var textTagsArr:Array = getTags(text);
			var tagIndex1:int = 0;
			var tagIter1:uint = 0;
			while(tagIter1 < textTagsArr.length)
			{
				switch(textTagsArr[tagIter1].tagStr)
				{
					case "<s>":
						tagIndex1 = findNextTag("</s>",tagIter1,textTagsArr);
						if(tagIndex1 > 0 && tagIndex1 < textTagsArr.length)
						{
							lineIndex1 = textField.getLineIndexOfChar(textTagsArr[tagIter1].charPos);
							lineIndex2 = textField.getLineIndexOfChar(textTagsArr[tagIndex1].charPos);
							if(lineIndex2 < 0)
							{
								lineIndex2 = textField.numLines - 1;
							}
							if(lineIndex1 >= 0 && lineIndex2 >= 0)
							{
								lineIndex3 = lineIndex1;
								while(lineIndex3 <= lineIndex2)
								{
									if(decoMC == null)
									{
										decoMC = parentMC[textField.name + "Deco"] = new MovieClip();
										parentMC.addChild(decoMC);
										decoMC.x = textField.x;
										decoMC.y = textField.y;
										textField.addEventListener(Event.REMOVED_FROM_STAGE,cleanUpTextFieldDecoration);
									}
									lineMetrics = textField.getLineMetrics(lineIndex3);
									lineOffset = textField.getLineOffset(lineIndex3);
									lineOffsetEnd = lineOffset + textField.getLineLength(lineIndex3);
									if(lineOffset < textTagsArr[tagIter1].charPos)
									{
										lineOffset = textTagsArr[tagIter1].charPos;
									}
									if(lineOffsetEnd > textTagsArr[tagIndex1].charPos)
									{
										lineOffsetEnd = textTagsArr[tagIndex1].charPos;
									}
									charBounds = textField.getCharBoundaries(lineOffset);
									charBounds2 = textField.getCharBoundaries(lineOffsetEnd - 1);
									if(charBounds)
									{
										lineToRight = Boolean(charBounds2)?Number(charBounds2.right):Number(charBounds.right);
										leftPos = charBounds.left;
										rightPos = lineMetrics.ascent * 0.8 + charBounds.top;
										posFormatter = textField.getTextFormat(textTagsArr[tagIter1].charPos,textTagsArr[tagIndex1].charPos);
										if(posFormatter.color == null)
										{
											posFormatter = textField.getTextFormat(textTagsArr[tagIter1].charPos,textTagsArr[tagIter1].charPos + 1);
										}
										formatColor = new uint(posFormatter.color);
										formatSize = new Number(posFormatter.size);
										decoMC.graphics.lineStyle(Math.ceil(formatSize * 0.08),formatColor);
										decoMC.graphics.moveTo(leftPos,rightPos);
										decoMC.graphics.lineTo(lineToRight,rightPos);
									}
									lineIndex3++;
								}
							}
						}
						break;
					case "<u>":
						tagIndex1 = findNextTag("</u>",tagIter1,textTagsArr);
						if(tagIndex1 > 0 && tagIndex1 < textTagsArr.length)
						{
							lineIndex1 = textField.getLineIndexOfChar(textTagsArr[tagIter1].charPos);
							lineIndex2 = textField.getLineIndexOfChar(textTagsArr[tagIndex1].charPos);
							if(lineIndex2 < 0)
							{
								lineIndex2 = textField.numLines - 1;
							}
							if(lineIndex1 >= 0 && lineIndex2 >= 0)
							{
								lineIndex3 = lineIndex1;
								while(lineIndex3 <= lineIndex2)
								{
									if(decoMC == null)
									{
										decoMC = parentMC[textField.name + "Deco"] = new MovieClip();
										parentMC.addChild(decoMC);
										decoMC.x = textField.x;
										decoMC.y = textField.y;
										textField.addEventListener(Event.REMOVED_FROM_STAGE,cleanUpTextFieldDecoration);
									}
									lineMetrics = textField.getLineMetrics(lineIndex3);
									lineOffset = textField.getLineOffset(lineIndex3);
									lineOffsetEnd = lineOffset + textField.getLineLength(lineIndex3);
									if(lineOffset < textTagsArr[tagIter1].charPos)
									{
										lineOffset = textTagsArr[tagIter1].charPos;
									}
									if(lineOffsetEnd > textTagsArr[tagIndex1].charPos)
									{
										lineOffsetEnd = textTagsArr[tagIndex1].charPos;
									}
									charBounds = textField.getCharBoundaries(lineOffset);
									if(charBounds)
									{
										charBounds2 = textField.getCharBoundaries(lineOffsetEnd - 1);
										if(charBounds2)
										{
											charBounds2 = textField.getCharBoundaries(lineOffsetEnd - 2);
										}
										lineToRight = Boolean(charBounds2)?Number(charBounds2.right):Number(charBounds.right);
										leftPos = charBounds.left;
										posFormatter = textField.getTextFormat(textTagsArr[tagIter1].charPos,textTagsArr[tagIndex1].charPos);
										formatColor = new uint(posFormatter.color);
										formatSize = new Number(posFormatter.size);
										rightPos = lineMetrics.ascent + lineMetrics.descent * 0.04 * formatSize + charBounds.top;
										decoMC.graphics.lineStyle(Math.ceil(formatSize * 0.08),formatColor);
										decoMC.graphics.moveTo(leftPos,rightPos);
										decoMC.graphics.lineTo(lineToRight,rightPos);
									}
									lineIndex3++;
								}
							}
						}
						break;
					case "<b>":
						tagIndex1 = findNextTag("</b>",tagIter1,textTagsArr);
						if(tagIndex1 > 0 && tagIndex1 < textTagsArr.length)
						{
							textField.setTextFormat(boldFormatter,textTagsArr[tagIter1].charPos,textTagsArr[tagIndex1].charPos);
						}
						break;
					case "<i>":
						tagIndex1 = findNextTag("</i>",tagIter1,textTagsArr);
						if(tagIndex1 > 0 && tagIndex1 < textTagsArr.length)
						{
							textField.setTextFormat(italicFormatter,textTagsArr[tagIter1].charPos,textTagsArr[tagIndex1].charPos);
						}
				}
				tagIter1++;
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
