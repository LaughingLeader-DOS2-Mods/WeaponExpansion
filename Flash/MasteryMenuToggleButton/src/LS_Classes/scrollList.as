package LS_Classes
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	
	public class scrollList extends listDisplay
	{
		 
		
		public var m_scrollbar_mc:scrollbar;
		
		public var m_bottomAligned:Boolean = false;
		
		public var m_allowAutoScroll:Boolean = true;
		
		private var m_SBSpacing:Number = 10;
		
		private var m_mouseWheelWhenOverEnabled:Boolean = false;
		
		private var m_mouseWheelEnabled:Boolean = false;
		
		private var m_ScrollHeight:Number = 0;
		
		public var m_allowKeepIntoView:Boolean = true;
		
		public var m_TextGlowOffset:Number = 3;
		
		private var m_dragAutoScroll:Boolean = false;
		
		public var m_dragAutoScrollDistance:Number = 100;
		
		public var m_dragAutoScrollMod:Number = 0.2;
		
		private var m_bgTile1_mc:MovieClip = null;
		
		private var m_bgTile2_mc:MovieClip = null;
		
		public function scrollList(param1:String = "down_id", param2:String = "up_id", param3:String = "handle_id", param4:String = "scrollBg_id", param5:String = "", param6:String = "")
		{
			this.m_scrollbar_mc = new scrollbar(param1,param2,param3,param4,param5,param6);
			super();
			this.m_scrollbar_mc.visible = false;
			this.addChild(this.m_scrollbar_mc);
			this.m_scrollbar_mc.addEventListener(Event.CHANGE,this.updateBGPos);
		}
		
		public function get frameHit() : MovieClip
		{
			return scrollHit_mc;
		}
		
		public function set dragAutoScroll(param1:Boolean) : void
		{
			if(this.m_dragAutoScroll != param1)
			{
				if(param1)
				{
					this.addEventListener(MouseEvent.ROLL_OUT,this.disableDragAutoScroll);
					this.addEventListener(MouseEvent.ROLL_OVER,this.enableDragAutoScroll);
				}
				else
				{
					this.removeEventListener(MouseEvent.ROLL_OUT,this.disableDragAutoScroll);
					this.removeEventListener(MouseEvent.ROLL_OVER,this.enableDragAutoScroll);
				}
				this.m_dragAutoScroll = param1;
			}
		}
		
		private function disableDragAutoScroll(param1:MouseEvent) : *
		{
			this.removeEventListener(Event.ENTER_FRAME,this.onDragAutoScrollMove);
		}
		
		private function enableDragAutoScroll(param1:MouseEvent) : *
		{
			this.addEventListener(Event.ENTER_FRAME,this.onDragAutoScrollMove);
		}
		
		private function onDragAutoScrollMove(param1:Event) : *
		{
			var _loc2_:Number = NaN;
			if(root != null && (root as MovieClip).isDragging)
			{
				_loc2_ = 0;
				if(this.mouseY > 0 && this.mouseY < this.m_dragAutoScrollDistance)
				{
					_loc2_ = this.m_dragAutoScrollDistance - this.mouseY;
					this.m_scrollbar_mc.adjustScrollHandle(-_loc2_ * this.m_dragAutoScrollMod);
				}
				else if(this.mouseY > m_height - this.m_dragAutoScrollDistance && this.mouseY < m_height)
				{
					_loc2_ = this.mouseY - (m_height - this.m_dragAutoScrollDistance);
					this.m_scrollbar_mc.adjustScrollHandle(_loc2_ * this.m_dragAutoScrollMod);
				}
			}
		}
		
		public function get dragAutoScroll() : Boolean
		{
			return this.m_dragAutoScroll;
		}
		
		override public function set TOP_SPACING(param1:Number) : *
		{
			this.m_scrollbar_mc.m_extraSpacing = param1 * 2;
			super.TOP_SPACING = param1;
		}
		
		public function set setTileableBG(param1:String) : *
		{
			var _loc2_:Class = getDefinitionByName(param1) as Class;
			this.m_bgTile1_mc = new _loc2_();
			this.m_bgTile2_mc = new _loc2_();
			this.m_bgTile1_mc.id = 1;
			this.m_bgTile2_mc.id = 2;
			containerBG_mc.addChild(this.m_bgTile1_mc);
			containerBG_mc.addChild(this.m_bgTile2_mc);
			this.m_bgTile1_mc.y = 0;
			this.m_bgTile2_mc.y = this.m_bgTile1_mc.y + this.m_bgTile1_mc.height;
		}
		
		private function updateBGPos(param1:Event) : *
		{
			var _loc2_:MovieClip = null;
			var _loc3_:MovieClip = null;
			containerBG_mc.scrollRect = containerContent_mc.scrollRect;
			if(this.m_bgTile1_mc && this.m_bgTile2_mc)
			{
				_loc2_ = this.topBgTile;
				_loc3_ = this.bottomBgTile;
				if(_loc3_.y < this.m_scrollbar_mc.scrolledY)
				{
					_loc2_.y = _loc3_.y + _loc3_.height;
				}
				else if(_loc3_.y > this.m_scrollbar_mc.scrolledY + height)
				{
					_loc3_.y = _loc2_.y - _loc3_.height;
				}
			}
			dispatchEvent(new Event(Event.CHANGE));
			this.cullMcsToFrame();
		}
		
		private function get topBgTile() : MovieClip
		{
			if(this.m_bgTile1_mc.y > this.m_bgTile2_mc.y)
			{
				return this.m_bgTile2_mc;
			}
			return this.m_bgTile1_mc;
		}
		
		private function get bottomBgTile() : MovieClip
		{
			if(this.m_bgTile1_mc.y > this.m_bgTile2_mc.y)
			{
				return this.m_bgTile1_mc;
			}
			return this.m_bgTile2_mc;
		}
		
		private function cullMcsToFrame() : *
		{
			var _loc2_:MovieClip = null;
			var _loc1_:uint = 0;
			while(_loc1_ < content_array.length)
			{
				_loc2_ = content_array[_loc1_];
				if(_loc2_ && _loc2_.elementInView && _loc2_.elementInView is Function)
				{
					if(_loc2_.y + getElementHeight(_loc2_) - this.m_TextGlowOffset > this.m_scrollbar_mc.scrolledY && _loc2_.y + this.m_TextGlowOffset <= this.m_scrollbar_mc.scrolledY + height)
					{
						_loc2_.elementInView(_loc2_.visible);
					}
					else
					{
						_loc2_.elementInView(false);
					}
				}
				_loc1_++;
			}
		}
		
		public function get mouseWheelWhenOverEnabled() : Boolean
		{
			return this.m_mouseWheelWhenOverEnabled;
		}
		
		public function get scrolledY() : Number
		{
			return this.m_scrollbar_mc.scrolledY;
		}
		
		public function set mouseWheelWhenOverEnabled(param1:Boolean) : *
		{
			if(this.m_mouseWheelWhenOverEnabled != param1)
			{
				this.m_mouseWheelWhenOverEnabled = param1;
				if(this.m_mouseWheelWhenOverEnabled)
				{
					this.addEventListener(MouseEvent.ROLL_OUT,this.disableMouseWheelOnOut);
					this.addEventListener(MouseEvent.ROLL_OVER,this.enableMouseWheelOnOver);
				}
				else
				{
					this.removeEventListener(MouseEvent.ROLL_OUT,this.disableMouseWheelOnOut);
					this.removeEventListener(MouseEvent.ROLL_OVER,this.enableMouseWheelOnOver);
				}
			}
		}
		
		override public function selectMC(param1:MovieClip, param2:Boolean = false) : *
		{
			var _loc4_:MovieClip = null;
			var _loc5_:Number = NaN;
			var _loc3_:Boolean = true;
			if(param1 && m_CurrentSelection && param1.list_pos < m_CurrentSelection.list_pos)
			{
				_loc3_ = false;
			}
			super.selectMC(param1,param2);
			if(this.m_scrollbar_mc.visible && this.m_allowKeepIntoView)
			{
				_loc4_ = getFirstVisible();
				if(m_CurrentSelection == _loc4_)
				{
					this.m_scrollbar_mc.scrollTo(0,this.m_scrollbar_mc.m_animateScrolling);
				}
				else
				{
					_loc5_ = getElementHeight(m_CurrentSelection);
					this.m_scrollbar_mc.scrollIntoView(m_CurrentSelection.y,_loc5_);
				}
			}
		}
		
		override public function clearElements() : *
		{
			super.clearElements();
			this.resetScroll();
			this.checkScrollBar();
		}
		
		public function resetScroll() : *
		{
			if(this.m_scrollbar_mc)
			{
				this.m_scrollbar_mc.resetHandle();
			}
		}
		
		override public function selectByOffset(param1:Number, param2:Boolean = false) : Boolean
		{
			var _loc4_:* = undefined;
			var _loc5_:MovieClip = null;
			var _loc6_:Number = NaN;
			var _loc3_:Boolean = false;
			if(param2)
			{
				return super.selectByOffset(param1);
			}
			param1 = param1 + TOP_SPACING;
			param1 = param1 + this.m_scrollbar_mc.scrolledY;
			_loc4_ = 0;
			while(_loc4_ < content_array.length)
			{
				_loc5_ = content_array[_loc4_];
				if(_loc5_ && _loc5_.visible)
				{
					_loc6_ = getElementHeight(_loc5_);
					if(_loc5_.y <= param1 && _loc5_.y + _loc6_ > param1)
					{
						_loc3_ = true;
						this.selectMC(_loc5_);
						break;
					}
				}
				_loc4_++;
			}
			return _loc3_;
		}
		
		public function get mouseWheelEnabled() : Boolean
		{
			return this.m_mouseWheelEnabled;
		}
		
		public function set mouseWheelEnabled(param1:Boolean) : *
		{
			if(this.m_mouseWheelEnabled != param1)
			{
				this.m_mouseWheelEnabled = param1;
				this.m_scrollbar_mc.mouseWheelEnabled = param1;
			}
		}
		
		private function disableMouseWheelOnOut(param1:MouseEvent) : *
		{
			this.m_scrollbar_mc.mouseWheelEnabled = false;
		}
		
		private function enableMouseWheelOnOver(param1:MouseEvent) : *
		{
			this.m_scrollbar_mc.mouseWheelEnabled = true;
		}
		
		public function checkScrollBar() : *
		{
			if(this.m_allowAutoScroll)
			{
				this.m_scrollbar_mc.scrollTo(this.m_scrollbar_mc.m_scrolledY);
			}
			this.m_scrollbar_mc.m_contentFrameHeight = height;
			this.m_scrollbar_mc.m_contentHeight = this.m_ScrollHeight;
			this.m_scrollbar_mc.scrollbarVisible();
		}
		
		override public function setFrameWidth(param1:Number) : *
		{
			width = param1;
			this.calculateScrollRect();
		}
		
		override public function setFrame(param1:Number, param2:Number) : *
		{
			width = param1;
			height = param2;
			this.calculateScrollRect();
		}
		
		public function setFrameHeight(param1:Number) : *
		{
			height = param1;
			this.calculateScrollRect();
		}
		
		private function calculateScrollRect() : *
		{
			containerContent_mc.scrollRect = new Rectangle(0,0,width,height);
			this.m_scrollbar_mc.x = this.m_SBSpacing + width;
			this.m_scrollbar_mc.addContent(containerContent_mc);
			this.checkScrollBar();
			updateScrollHit();
		}
		
		override public function positionElements() : *
		{
			if(content_array.length == 0)
			{
				return;
			}
			if(m_NeedsSorting && m_SortOnFieldName && content_array && content_array.length > 1)
			{
				content_array.sortOn(m_SortOnFieldName,m_SortOnOptions);
			}
			var _loc1_:Number = TOP_SPACING;
			var _loc2_:uint = 0;
			while(_loc2_ < content_array.length)
			{
				content_array[_loc2_].list_pos = _loc2_;
				content_array[_loc2_].y = _loc1_;
				content_array[_loc2_].x = SIDE_SPACING;
				if(content_array[_loc2_].visible)
				{
					_loc1_ = _loc1_ + (getElementHeight(content_array[_loc2_]) + EL_SPACING);
				}
				_loc2_++;
			}
			this.m_ScrollHeight = _loc1_ - EL_SPACING;
			this.checkScrollBar();
			if(this.m_bottomAligned)
			{
				this.m_scrollbar_mc.alignContentToBottom();
			}
			this.cullMcsToFrame();
		}
		
		public function set scrollbarSpacing(param1:Number) : *
		{
			this.m_SBSpacing = param1;
			this.m_scrollbar_mc.x = width + this.m_SBSpacing + this.m_scrollbar_mc.width;
		}
		
		public function set SB_SPACING(param1:Number) : *
		{
			this.m_SBSpacing = param1;
			this.m_scrollbar_mc.x = width + this.m_SBSpacing + this.m_scrollbar_mc.width;
		}
		
		public function get SB_SPACING() : Number
		{
			return this.m_SBSpacing;
		}
		
		public function get scrollbarSpacing() : Number
		{
			return this.SB_SPACING;
		}
	}
}
