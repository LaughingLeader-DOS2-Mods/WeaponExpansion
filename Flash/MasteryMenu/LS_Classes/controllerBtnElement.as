package LS_Classes
{
	import flash.display.MovieClip;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	
	public dynamic class controllerBtnElement extends MovieClip
	{
		 
		
		public var icon_mc:controllerBtnHint;
		
		public var text_txt:TextField;
		
		public const strokeW:Number = 2.5;
		
		public var iconY:Number;
		
		public var iconId:Number;
		
		public var id:Number;
		
		public var list_pos:Number;
		
		public var list_id:Number;
		
		public var selectable:Boolean;
		
		public var m_filteredObject:Boolean;
		
		public var ownerList:MovieClip;
		
		public var btnEnabled:Boolean = true;
		
		public function controllerBtnElement()
		{
			super();
			this.icon_mc = new controllerBtnHint();
			addChild(this.icon_mc);
			this.text_txt = new TextField();
			addChild(this.text_txt);
			var _loc1_:Class = getDefinitionByName("$Title") as Class;
			var _loc2_:Font = new _loc1_();
			var _loc3_:TextFormat = this.text_txt.getTextFormat();
			_loc3_.font = _loc2_.fontName;
			_loc3_.color = 16777215;
			_loc3_.size = 24;
			_loc3_.leading = -10;
			_loc3_.align = "left";
			this.text_txt.defaultTextFormat = _loc3_;
			this.text_txt.x = 50;
			this.text_txt.autoSize = TextFieldAutoSize.LEFT;
			this.text_txt.filters = textEffect.createStrokeFilter(1050888,this.strokeW,1,1,9);
		}
		
		public function setBtnHintState(param1:Boolean) : *
		{
			this.btnEnabled = param1;
			var _loc2_:TextFormat = this.text_txt.getTextFormat();
			_loc2_.color = !!this.btnEnabled?16777215:11444117;
			this.text_txt.setTextFormat(_loc2_);
			alpha = !!this.btnEnabled?Number(1):Number(0.7);
		}
		
		public function setBtnHint(text:String, iconId:Number, maxTextWidth:Number = 200, enabled:Boolean = true) : *
		{
			this.iconId = iconId;
			this.icon_mc.setHintIcon(this.iconId);
			this.btnEnabled = enabled;
			this.text_txt.htmlText = text;
			var textWidth:Number = this.text_txt.textWidth;
			var actualTextWidth:Number = textHelpers.getLongestWordLength(this.text_txt);
			if(this.text_txt.textWidth > maxTextWidth)
			{
				textWidth = actualTextWidth > maxTextWidth?Number(actualTextWidth):Number(maxTextWidth);
				this.text_txt.multiline = true;
				this.text_txt.wordWrap = true;
			}
			else
			{
				this.text_txt.multiline = false;
				this.text_txt.wordWrap = false;
			}
			var strokePadding:Number = Math.round(this.strokeW) * 2;
			this.text_txt.width = Math.ceil(textWidth + strokePadding);
			this.text_txt.width = Math.ceil(this.text_txt.textWidth + strokePadding);
			this.text_txt.y = -Math.round(this.text_txt.textHeight * 0.5) - 2;
			this.iconY = this.icon_mc.y = -Math.round(this.icon_mc.height * 0.5);
			this.text_txt.x = this.icon_mc.x + this.icon_mc.width + 3;
			this.setBtnHintState(this.btnEnabled);
		}
		
		public function selectElement() : *
		{
		}
		
		public function deselectElement() : *
		{
		}
		
		public function getTextWidth() : Number
		{
			return this.text_txt.width;
		}
	}
}
