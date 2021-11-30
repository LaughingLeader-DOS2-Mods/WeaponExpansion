package LS_Classes
{
	import fl.motion.easing.Linear;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
	public class scrollbar extends MovieClip
	{
		 
		
		public var SND_Over:String = "UI_Generic_Over";
		
		public var SND_Click:String = "UI_Generic_Click";
		
		public var SND_Release:String = "";
		
		public var m_down_mc:MovieClip;
		
		public var m_up_mc:MovieClip;
		
		public var m_FFdown_mc:MovieClip = null;
		
		public var m_FFup_mc:MovieClip = null;
		
		public var m_handle_mc:MovieClip;
		
		public var m_bg_mc:MovieClip;
		
		public var m_scrolledY:Number = 0;
		
		public var m_scrollWheelMod:Number = 1;
		
		public var m_extraSpacing:Number = 0;
		
		public var m_positionButtons:Boolean = true;
		
		public var m_hideWhenDisabled:Boolean = true;
		
		public var m_animateScrolling:Boolean = false;
		
		public var m_normaliseScrolling:Boolean = false;
		
		public var m_contentFrameHeight:Number = -1;
		
		public var m_contentHeight:Number = -1;
		
		public var m_scrollingFunction:Function = null;
		
		public var m_contentSizeDisc:Number = 0;
		
		public var m_initialScrollDelay:Number = 300;
		
		public var m_minScrollDelay:Number = 50;
		
		public var m_scrollMultiplier:Number = 0.55;
		
		public var m_autoScrollFasterDelay:Number = 1800;
		
		public var m_allowScrollAcceleration:Boolean = true;
		
		public var m_autoScrollDefaultMultiplier:Number = 4;
		
		public var m_autoScrollFasterMultiplier:Number = 3;
		
		public var m_tweenY:Number = 0;
		
		public var m_scrollOverShoot:Number = 0;
		
		public var m_SCROLLSPEED:Number = 10;
		
		public var m_NormalizeValue:Number = -1;
		
		public var m_DisabledAlpha:Number = 0.3;
		
		public var m_FullSizeBG:Boolean = false;
		
		public var m_CanDisableBG:Boolean = false;
		
		private var m_noContent:Boolean = false;
		
		protected var m_disabled:Boolean = false;
		
		protected var m_content_mc:DisplayObject;
		
		private var m_last_Y:Number = 0;
		
		protected var m_scrollerDiff:Number = 0;
		
		private var m_scaleBG:Boolean = false;
		
		private var m_customPaneHeight:Number = -1;
		
		private var m_handleResizable:Boolean = false;
		
		private var m_ffUpH:Number = 0;
		
		private var m_ffDownH:Number = 0;
		
		private var m_isAutoScrolling:Boolean = false;
		
		private var m_currentScrollDelay:Number = 200;
		
		protected var m_currentScrollDown:Boolean = true;
		
		private var m_autoScrollStartTime:Number = 0;
		
		private var m_autoScrollPrevTime:Number = 0;
		
		protected var m_mouseWheelEnabled:Boolean = false;
		
		private var m_hasWheelListener:Boolean = false;
		
		private var m_CustomStage:Stage = null;
		
		private var m_scrollLength:Number = 0;
		
		private var m_scrollAnimToY:Number = 0;
		
		private var m_scrollWheelPrevious:Number = 0;
		
		private var m_scrollWheelStepSize:Number = 0;
		
		private var m_scrollWheelTimer:Timer;
		
		private const m_scrollWheelAcceleration:Number = 0.5;
		
		private var m_movementTimeline:larTween;
		
		private var m_frameHit_mc:MovieClip;
		
		public function scrollbar(param1:String = "LS_Symbols.down_id", param2:String = "LS_Symbols.up_id", param3:String = "LS_Symbols.handle_id", param4:String = "LS_Symbols.scrollBg_id", param5:String = "", param6:String = "")
		{
			var _loc13_:Class = null;
			var _loc14_:Class = null;
			this.m_scrollWheelTimer = new Timer(100);
			super();
			this.m_tweenY = 0;
			var _loc7_:Class = param1 == ""?MovieClip:getDefinitionByName(param1) as Class;
			var _loc8_:Class = param2 == ""?MovieClip:getDefinitionByName(param2) as Class;
			var _loc9_:Class = getDefinitionByName(param3) as Class;
			var _loc10_:Class = getDefinitionByName(param4) as Class;
			this.m_down_mc = new _loc7_();
			this.m_up_mc = new _loc8_();
			this.m_handle_mc = new _loc9_();
			this.m_bg_mc = new _loc10_();
			this.m_scrollWheelTimer.addEventListener(TimerEvent.TIMER,this.onScrollWheelTimer);
			addChild(this.m_bg_mc);
			this.m_frameHit_mc = new MovieClip();
			var _loc11_:Sprite = new Sprite();
			_loc11_.graphics.lineStyle(0,16777215);
			_loc11_.graphics.beginFill(16777215);
			_loc11_.graphics.drawRect(0,0,10,10);
			_loc11_.graphics.endFill();
			this.m_frameHit_mc.addChild(_loc11_);
			_loc11_.alpha = 0;
			addChild(this.m_frameHit_mc);
			addChild(this.m_handle_mc);
			addChild(this.m_up_mc);
			addChild(this.m_down_mc);
			var _loc12_:Number = this.m_bg_mc.width;
			if(_loc12_ < this.m_up_mc.width)
			{
				_loc12_ = this.m_up_mc.width;
			}
			if(_loc12_ < this.m_down_mc.width)
			{
				_loc12_ = this.m_down_mc.width;
			}
			if(_loc12_ < this.m_handle_mc.width)
			{
				_loc12_ = this.m_handle_mc.width;
			}
			this.m_bg_mc.x = Math.round((_loc12_ - this.m_bg_mc.width) * 0.5);
			this.m_up_mc.x = Math.round((_loc12_ - this.m_up_mc.width) * 0.5);
			this.m_down_mc.x = Math.round((_loc12_ - this.m_down_mc.width) * 0.5);
			this.m_handle_mc.x = Math.round((_loc12_ - this.m_handle_mc.width) * 0.5);
			this.m_frameHit_mc.width = _loc12_;
			if(param5 != "")
			{
				_loc13_ = getDefinitionByName(param5) as Class;
				this.m_FFdown_mc = new _loc13_();
				addChild(this.m_FFdown_mc);
				this.m_FFdown_mc.addEventListener("mouseUp",this.onUp);
				this.m_FFdown_mc.addEventListener("mouseDown",this.ffDownDown);
				this.m_FFdown_mc.addEventListener("mouseOut",this.onOut);
				this.m_FFdown_mc.addEventListener("mouseOver",this.onOver);
				this.m_FFdown_mc.x = Math.round((_loc12_ - this.m_FFdown_mc.width) * 0.5);
				this.m_ffDownH = this.m_FFdown_mc.height;
			}
			if(param6 != "")
			{
				_loc14_ = getDefinitionByName(param6) as Class;
				this.m_FFup_mc = new _loc14_();
				addChild(this.m_FFup_mc);
				this.m_FFup_mc.addEventListener("mouseUp",this.onUp);
				this.m_FFup_mc.addEventListener("mouseDown",this.ffUpDown);
				this.m_FFup_mc.addEventListener("mouseOut",this.onOut);
				this.m_FFup_mc.addEventListener("mouseOver",this.onOver);
				this.m_FFup_mc.x = Math.round((_loc12_ - this.m_FFup_mc.width) * 0.5);
				this.m_ffUpH = this.m_FFup_mc.height;
			}
			this.m_down_mc.addEventListener("mouseDown",this.downDown);
			this.m_down_mc.addEventListener("mouseOut",this.onOut);
			this.m_down_mc.addEventListener("mouseOver",this.onOver);
			this.m_down_mc.addEventListener("mouseUp",this.onUp);
			this.m_up_mc.addEventListener("mouseDown",this.upDown);
			this.m_up_mc.addEventListener("mouseOver",this.onOver);
			this.m_up_mc.addEventListener("mouseOut",this.onOut);
			this.m_up_mc.addEventListener("mouseUp",this.onUp);
			this.m_handle_mc.addEventListener("mouseOut",this.onOut);
			this.m_handle_mc.addEventListener("mouseDown",this.handlePressed);
			this.m_handle_mc.addEventListener("mouseOver",this.onOver);
			this.m_frameHit_mc.addEventListener("mouseDown",this.bgDown);
			this.setScrollDiff();
		}
		
		public function setHandle(param1:Class) : *
		{
			removeChild(this.m_handle_mc);
			this.m_handle_mc = new param1();
			addChild(this.m_handle_mc);
			this.m_handle_mc.addEventListener("mouseOut",this.onOut);
			this.m_handle_mc.addEventListener("mouseDown",this.handlePressed);
			this.m_handle_mc.addEventListener("mouseOver",this.onOver);
			this.setScrollDiff();
		}
		
		private function setScrollDiff() : void
		{
			this.m_scrollerDiff = this.m_down_mc.y - (this.m_up_mc.y + this.m_up_mc.height) - this.m_handle_mc.height;
			this.m_frameHit_mc.height = Math.max(this.m_scrollerDiff + this.m_handle_mc.height,1);
			this.m_frameHit_mc.y = this.m_up_mc.y + this.m_up_mc.height;
		}
		
		public function addContent(param1:DisplayObject) : void
		{
			if(this.m_movementTimeline)
			{
				this.m_movementTimeline.stop();
				if(this.m_movementTimeline.onComplete != null)
				{
					this.m_movementTimeline.onComplete = null;
				}
			}
			this.m_content_mc = param1;
			this.m_noContent = false;
			if(this.m_content_mc && this.m_content_mc.scrollRect)
			{
				this.setLength(this.m_content_mc.scrollRect.height);
			}
			else
			{
				ExternalInterface.call("UIAssert","LS_Classes.scrollbar addContent done for a movieclip without scrollRect");
			}
		}
		
		public function noContent() : *
		{
			this.m_content_mc = null;
			this.m_noContent = true;
			this.m_disabled = false;
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
				if(this.m_mouseWheelEnabled)
				{
					if(this.m_CustomStage)
					{
						this.m_CustomStage.addEventListener(MouseEvent.MOUSE_WHEEL,this.handleMouseWheel);
					}
					else if(this.stage)
					{
						this.stage.addEventListener(MouseEvent.MOUSE_WHEEL,this.handleMouseWheel);
						this.m_CustomStage = this.stage;
					}
				}
				else if(this.m_CustomStage)
				{
					this.m_CustomStage.removeEventListener(MouseEvent.MOUSE_WHEEL,this.handleMouseWheel);
				}
				else if(this.stage)
				{
					this.stage.removeEventListener(MouseEvent.MOUSE_WHEEL,this.handleMouseWheel);
				}
				else
				{
					ExternalInterface.call("UIAssert","mouseWheelEnabled in scrollbar class is missing not working, missing stage");
				}
			}
		}
		
		public function get content() : DisplayObject
		{
			return this.m_content_mc;
		}
		
		public function position() : void
		{
			if(this.m_content_mc && this.m_content_mc.scrollRect)
			{
				this.x = this.m_content_mc.x + this.m_content_mc.scrollRect.width;
				this.y = this.m_content_mc.y;
			}
		}
		
		public function set customPaneHeight(param1:Number) : *
		{
			this.m_customPaneHeight = param1;
			if(param1 < this.m_scrolledY)
			{
				this.adjustScrollHandle(param1);
			}
		}
		
		public function get customPaneHeight() : *
		{
			return this.m_customPaneHeight;
		}
		
		public function disableCustomPaneHeight() : *
		{
			this.m_customPaneHeight = -1;
		}
		
		public function get handleResize() : Boolean
		{
			return this.m_handleResizable;
		}
		
		public function set handleResize(param1:Boolean) : *
		{
			this.m_handleResizable = param1;
			if(param1 && this.m_content_mc && this.m_content_mc.scrollRect)
			{
				this.setLength(this.m_content_mc.scrollRect.height);
			}
		}
		
		public function set ScaleBG(param1:Boolean) : *
		{
			this.m_scaleBG = param1;
			if(param1)
			{
				if(this.m_content_mc)
				{
					this.setLength(!!this.m_FullSizeBG?Number(this.m_down_mc.y - this.m_up_mc.y + this.m_down_mc.height):Number(this.m_down_mc.y - this.m_up_mc.y - this.m_up_mc.height));
				}
				else if(this.m_scrollLength > 0)
				{
					this.m_bg_mc.height = this.m_scrollLength;
				}
			}
			else
			{
				this.m_bg_mc.scaleY = 1;
			}
		}
		
		public function resetContentPosition() : void
		{
			var _loc1_:Rectangle = null;
			var _loc2_:Number = NaN;
			if(this.m_content_mc)
			{
				_loc1_ = this.m_content_mc.scrollRect;
				if(_loc1_)
				{
					_loc2_ = this.getContDiff();
					if(_loc2_ < 0)
					{
						_loc2_ = 0;
					}
					this.m_scrolledY = _loc1_.y = (this.m_handle_mc.y - (this.m_up_mc.height + this.m_up_mc.y)) / this.m_scrollerDiff * _loc2_;
					this.m_content_mc.scrollRect = _loc1_;
					dispatchEvent(new Event(Event.CHANGE));
				}
			}
		}
		
		public function addCustomStage(param1:Stage) : *
		{
			this.m_CustomStage = param1;
		}
		
		public function isContentAtBottom() : Boolean
		{
			return Boolean(this.m_scrolledY == this.getContDiff() || this.getContDiff() <= 0);
		}
		
		public function alignContentToBottom() : void
		{
			this.scrollTo(this.getContDiff());
		}
		
		public function resetHandle() : void
		{
			this.scrollTo(0);
		}
		
		public function canScroll() : Boolean
		{
			return Boolean(this.getContDiff() > 0);
		}
		
		public function resetHandleToBottom() : void
		{
			this.scrollTo(this.getContDiff());
		}
		
		public function scrollbarVisible() : *
		{
			var _loc1_:Number = NaN;
			var _loc2_:Rectangle = null;
			if(this.m_content_mc)
			{
				_loc1_ = this.m_content_mc.transform.pixelBounds.height / this.m_content_mc.transform.concatenatedMatrix.d + this.m_extraSpacing;
				if(this.m_customPaneHeight != -1)
				{
					_loc1_ = this.m_customPaneHeight;
				}
				else if(this.m_contentHeight != -1)
				{
					_loc1_ = this.m_contentHeight + this.m_extraSpacing;
				}
				_loc2_ = this.m_content_mc.scrollRect;
				if(_loc2_)
				{
					if(_loc1_ > this.getFrameHeight() + this.m_contentSizeDisc)
					{
						if(this.m_hideWhenDisabled)
						{
							this.visible = true;
						}
						else
						{
							this.visible = true;
							this.setDisabled(false);
						}
						this.m_disabled = false;
						this.scrollTo(this.m_scrolledY);
					}
					else
					{
						if(this.m_hideWhenDisabled)
						{
							this.visible = false;
						}
						else
						{
							this.visible = true;
							this.setDisabled(true);
						}
						this.m_disabled = true;
						_loc2_.y = 0;
						this.m_scrolledY = 0;
						this.m_content_mc.scrollRect = _loc2_;
						dispatchEvent(new Event(Event.CHANGE));
					}
				}
			}
			else
			{
				this.visible = this.m_noContent;
			}
		}
		
		private function setDisabled(param1:Boolean) : *
		{
			this.INTSetMCDisabled(this.m_down_mc,param1);
			this.INTSetMCDisabled(this.m_up_mc,param1);
			this.INTSetMCDisabled(this.m_FFdown_mc,param1);
			this.INTSetMCDisabled(this.m_FFup_mc,param1);
			this.INTSetMCDisabled(this.m_handle_mc,param1);
			if(this.m_CanDisableBG)
			{
				this.INTSetMCDisabled(this.m_bg_mc,param1);
			}
			if(param1)
			{
				this.m_handle_mc.y = this.m_up_mc.y + this.m_up_mc.height;
			}
		}
		
		private function INTSetMCDisabled(param1:MovieClip, param2:Boolean) : *
		{
			var _loc3_:Number = NaN;
			if(param1)
			{
				if(param1.disabled_mc)
				{
					param1.disabled_mc.visible = param2;
				}
				else
				{
					_loc3_ = 1;
					if(param2)
					{
						_loc3_ = this.m_DisabledAlpha;
					}
					param1.alpha = _loc3_;
				}
			}
		}
		
		public function set disabled(param1:Boolean) : void
		{
			this.m_disabled = param1;
		}
		
		public function get disabled() : Boolean
		{
			return this.m_disabled;
		}
		
		public function set scrolledY(param1:Number) : void
		{
			this.m_tweenY = this.m_scrollAnimToY = param1;
			this.INTScrolledY(param1);
		}
		
		private function INTScrolledY(param1:Number) : void
		{
			var _loc3_:Number = NaN;
			var _loc2_:Rectangle = new Rectangle();
			if(this.m_content_mc && this.m_content_mc.scrollRect)
			{
				_loc2_ = this.m_content_mc.scrollRect;
			}
			if(_loc2_)
			{
				_loc2_.y = this.m_scrolledY = param1;
				_loc3_ = 0;
				if(this.getContDiff() > 0)
				{
					_loc3_ = this.m_scrolledY * this.m_scrollerDiff / this.getContDiff();
				}
				if(_loc3_ < 0)
				{
					_loc3_ = 0;
				}
				this.m_handle_mc.y = _loc3_ + this.m_up_mc.y + this.m_up_mc.height;
				if(this.m_handle_mc.y > this.m_down_mc.y - this.m_handle_mc.height)
				{
					this.m_handle_mc.y = this.m_down_mc.y - this.m_handle_mc.height;
				}
				if(this.m_content_mc)
				{
					this.m_content_mc.scrollRect = _loc2_;
				}
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		public function get scrolledY() : Number
		{
			return Math.round(this.m_scrolledY);
		}
		
		public function scrollToPercent(param1:Number, param2:Boolean) : void
		{
			if(param1 > 1)
			{
				param1 = 1;
			}
			var _loc3_:uint = Math.round(param1 * 1000);
			param1 = _loc3_ * 0.001;
			this.scrollTo(Math.round(this.getContDiff() * param1),param2);
		}
		
		protected function getContDiff() : Number
		{
			if(this.m_noContent)
			{
				return this.m_scrollLength - this.m_handle_mc.height;
			}
			var _loc1_:Number = 0;
			if(this.m_customPaneHeight != -1)
			{
				_loc1_ = this.m_customPaneHeight;
			}
			else if(this.m_contentHeight != -1)
			{
				_loc1_ = this.m_contentHeight + this.m_extraSpacing;
			}
			else if(this.m_content_mc)
			{
				if(this.m_content_mc.transform)
				{
					_loc1_ = this.m_content_mc.transform.pixelBounds.height / this.m_content_mc.transform.concatenatedMatrix.d + this.m_extraSpacing;
				}
				else
				{
					_loc1_ = this.m_content_mc.height + this.m_extraSpacing;
				}
			}
			var _loc2_:Number = this.getFrameHeight();
			return Math.round(_loc1_ - _loc2_);
		}
		
		private function getFrameHeight() : Number
		{
			var _loc2_:Rectangle = null;
			var _loc1_:Number = 0;
			if(this.m_contentFrameHeight != -1)
			{
				_loc1_ = this.m_contentFrameHeight;
			}
			else if(this.m_content_mc)
			{
				_loc2_ = this.m_content_mc.scrollRect;
				if(_loc2_)
				{
					_loc1_ = _loc2_.height;
				}
			}
			return _loc1_;
		}
		
		public function scrollToFit(param1:Boolean = false) : *
		{
			var _loc2_:Rectangle = null;
			if(this.m_content_mc.scrollRect != null)
			{
				_loc2_ = this.m_content_mc.scrollRect;
				if(this.m_scrolledY <= 0)
				{
					this.scrollTo(0,!!param1?Boolean(false):Boolean(this.m_animateScrolling));
				}
				else if(this.m_scrolledY > this.getContDiff())
				{
					this.scrollTo(this.getContDiff(),!!param1?Boolean(false):Boolean(this.m_animateScrolling));
				}
			}
		}
		
		public function scrollIntoView(param1:Number, param2:Number, param3:Boolean = false) : *
		{
			var _loc4_:Number = NaN;
			var _loc5_:Number = NaN;
			if(this.m_scrolledY >= param1 - this.m_scrollOverShoot)
			{
				this.scrollTo(param1 - this.m_scrollOverShoot,this.m_animateScrolling && !param3);
			}
			else
			{
				_loc4_ = this.getFrameHeight();
				_loc5_ = param1 + param2 + this.m_scrollOverShoot - _loc4_;
				if(_loc4_ > param2)
				{
					if(this.m_scrolledY < _loc5_)
					{
						this.scrollTo(_loc5_,this.m_animateScrolling && !param3);
					}
				}
				else if(param1 + this.m_scrollOverShoot >= this.m_scrolledY + _loc4_)
				{
					this.scrollTo(param1,this.m_animateScrolling && !param3);
				}
			}
		}
		
		public function scrollTo(param1:Number, param2:Boolean = false, param3:Boolean = false) : Boolean
		{
			var _loc6_:Number = NaN;
			var _loc7_:Number = NaN;
			if(this.m_disabled || !this.m_noContent && (!this.m_content_mc || this.m_content_mc.scrollRect == null))
			{
				return false;
			}
			var _loc4_:Number = param1;
			var _loc5_:Number = this.getContDiff();
			if(_loc5_ < 0)
			{
				_loc5_ = 0;
			}
			if(_loc4_ <= 0)
			{
				_loc4_ = 0;
			}
			else
			{
				_loc6_ = this.m_NormalizeValue == -1?Number(this.m_SCROLLSPEED):Number(this.m_NormalizeValue);
				if(this.scrolledY < _loc4_ && _loc4_ > _loc5_ - _loc6_ * 0.1)
				{
					_loc4_ = _loc5_;
					param3 = false;
					if(this.m_scrollAnimToY == _loc4_ || this.scrolledY == _loc4_)
					{
						return false;
					}
				}
				if(param3)
				{
					_loc4_ = Math.round(_loc4_ / _loc6_) * _loc6_;
				}
			}
			if(param2)
			{
				this.m_tweenY = this.m_scrolledY;
				if(this.m_movementTimeline)
				{
					this.m_movementTimeline.stop();
					if(this.m_movementTimeline.onComplete != null)
					{
						this.m_movementTimeline.onComplete = null;
					}
				}
				_loc7_ = this.m_currentScrollDelay * 0.001;
				this.m_movementTimeline = new larTween(this,"m_tweenY",Linear.easeNone,this.m_tweenY,_loc4_,_loc7_,this.INTMoveDone);
				this.m_movementTimeline.onUpdate = this.INTUpdatePos;
			}
			else
			{
				this.scrolledY = _loc4_;
			}
			this.m_scrollAnimToY = Math.round(_loc4_);
			return true;
		}
		
		private function INTUpdatePos() : void
		{
			this.INTScrolledY(this.m_tweenY);
			if(this.m_scrollingFunction != null)
			{
				this.m_scrollingFunction();
			}
		}
		
		private function INTMoveDone() : void
		{
			if(this.m_movementTimeline)
			{
				this.m_movementTimeline.onComplete = null;
			}
			this.INTScrolledY(this.m_scrollAnimToY);
			this.scrollbarVisible();
		}
		
		public function setLength(param1:Number) : void
		{
			if(this.m_positionButtons)
			{
				this.m_up_mc.y = this.m_ffUpH;
				if(this.m_FFdown_mc)
				{
					this.m_FFdown_mc.y = param1 - this.m_FFdown_mc.height;
				}
				this.m_down_mc.y = param1 - this.m_down_mc.height - this.m_ffDownH;
				if(this.m_scaleBG)
				{
					this.m_bg_mc.height = param1 - (!this.m_FullSizeBG?this.m_down_mc.height + this.m_up_mc.height:0);
					if(this.m_FFup_mc)
					{
						this.m_bg_mc.y = this.m_FFup_mc.y + (!this.m_FullSizeBG?this.m_FFup_mc.height:0);
					}
					else
					{
						this.m_bg_mc.y = this.m_up_mc.y + (!this.m_FullSizeBG?this.m_up_mc.height:0);
					}
				}
				if(param1 < 90)
				{
					this.m_handle_mc.visible = false;
				}
				else
				{
					this.m_handle_mc.visible = true;
				}
				this.setScrollDiff();
			}
			this.m_scrollAnimToY = this.scrolledY = this.m_scrolledY;
			this.m_scrollLength = param1;
		}
		
		public function adjustScrollHandle(param1:Number, param2:Boolean = false, param3:Boolean = false) : Boolean
		{
			return this.scrollTo(this.m_scrollAnimToY + param1,param2,param3);
		}
		
		protected function handleMouseWheel(param1:MouseEvent) : void
		{
			if(!this.m_disabled)
			{
				if(param1.delta > 0 && this.m_scrollWheelPrevious < 0 || param1.delta < 0 && this.m_scrollWheelPrevious > 0)
				{
					this.m_scrollWheelStepSize = 0;
				}
				this.m_scrollWheelPrevious = param1.delta;
				this.m_scrollWheelStepSize = this.m_scrollWheelStepSize + this.m_scrollWheelPrevious * this.m_scrollWheelAcceleration;
				if(this.m_scrollWheelStepSize > 0 && this.m_scrollWheelStepSize < 1)
				{
					this.m_scrollWheelStepSize = 1;
				}
				else if(this.m_scrollWheelStepSize < 0 && this.m_scrollWheelStepSize > -1)
				{
					this.m_scrollWheelStepSize = -1;
				}
				this.adjustScrollHandle(this.m_scrollWheelStepSize * -(this.m_scrollWheelMod * this.m_SCROLLSPEED),this.m_animateScrolling,true);
				this.m_scrollWheelTimer.reset();
				this.m_scrollWheelTimer.start();
			}
		}
		
		private function onScrollWheelTimer(param1:TimerEvent) : void
		{
			this.m_scrollWheelStepSize = this.m_scrollWheelStepSize - this.m_scrollWheelPrevious * this.m_scrollWheelAcceleration;
			if(this.m_scrollWheelStepSize == 0)
			{
				this.m_scrollWheelStepSize = 0;
				this.m_scrollWheelTimer.stop();
			}
		}
		
		private function handlePressed(param1:Event) : *
		{
			if(!this.m_disabled)
			{
				ExternalInterface.call("PlaySound",this.SND_Click);
				this.m_handle_mc.gotoAndStop(3);
				this.m_last_Y = mouseY - this.m_handle_mc.y;
				stage.addEventListener("mouseUp",this.handleReleased);
				stage.addEventListener("mouseMove",this.handleMove);
			}
		}
		
		private function handleReleased(param1:Event) : *
		{
			var _loc2_:Number = NaN;
			if(!this.m_disabled)
			{
				ExternalInterface.call("PlaySound",this.SND_Release);
				this.m_handle_mc.gotoAndStop(1);
				stage.removeEventListener("mouseUp",this.handleReleased);
				stage.removeEventListener("mouseMove",this.handleMove);
				_loc2_ = this.m_NormalizeValue != -1?Number(this.m_NormalizeValue):Number(this.m_SCROLLSPEED);
				this.scrolledY = Math.round(this.m_scrolledY / _loc2_) * _loc2_;
			}
		}
		
		private function handleMove(param1:Event) : *
		{
			var _loc2_:Rectangle = null;
			var _loc3_:Number = NaN;
			if(!this.m_disabled)
			{
				_loc2_ = this.m_content_mc.scrollRect;
				if(_loc2_)
				{
					_loc3_ = this.getContDiff();
					if(this.mouseY - this.m_last_Y < this.m_up_mc.y + this.m_up_mc.height)
					{
						this.m_handle_mc.y = this.m_up_mc.y + this.m_up_mc.height;
						_loc2_.y = 0;
					}
					else if(this.mouseY - this.m_last_Y >= this.m_scrollerDiff + (this.m_up_mc.y + this.m_up_mc.height))
					{
						this.m_handle_mc.y = this.m_scrollerDiff + (this.m_up_mc.y + this.m_up_mc.height);
						_loc2_.y = _loc3_;
					}
					else
					{
						this.m_handle_mc.y = this.mouseY - this.m_last_Y;
						_loc2_.y = (this.m_handle_mc.y - (this.m_up_mc.y + this.m_up_mc.height)) * (_loc3_ / this.m_scrollerDiff);
					}
					this.m_tweenY = this.m_scrolledY = _loc2_.y;
					this.m_content_mc.scrollRect = _loc2_;
					dispatchEvent(new Event(Event.CHANGE));
				}
			}
		}
		
		private function upDown(param1:Event) : *
		{
			if(!this.m_disabled)
			{
				ExternalInterface.call("PlaySound",this.SND_Click);
				this.m_up_mc.gotoAndStop(3);
				this.startAutoScroll(false);
			}
		}
		
		private function downDown(param1:Event) : *
		{
			if(!this.m_disabled)
			{
				ExternalInterface.call("PlaySound",this.SND_Click);
				this.m_down_mc.gotoAndStop(3);
				this.startAutoScroll(true);
			}
		}
		
		public function scrollUp() : *
		{
			this.adjustScrollHandle(-this.m_SCROLLSPEED,this.m_animateScrolling,this.m_normaliseScrolling);
		}
		
		public function scrollDown() : *
		{
			this.adjustScrollHandle(this.m_SCROLLSPEED,this.m_animateScrolling,this.m_normaliseScrolling);
		}
		
		private function ffDownDown(param1:Event) : *
		{
			if(!this.m_disabled)
			{
				ExternalInterface.call("PlaySound",this.SND_Click);
				this.scrollTo(this.getContDiff(),this.m_animateScrolling);
				this.m_FFdown_mc.gotoAndStop(3);
			}
		}
		
		private function ffUpDown(param1:Event) : *
		{
			if(!this.m_disabled)
			{
				ExternalInterface.call("PlaySound",this.SND_Click);
				this.scrollTo(0,this.m_animateScrolling);
				this.m_FFup_mc.gotoAndStop(3);
			}
		}
		
		function onOver(param1:Event) : *
		{
			var _loc2_:MovieClip = param1.currentTarget as MovieClip;
			if(!this.m_disabled)
			{
				ExternalInterface.call("PlaySound",this.SND_Over);
				_loc2_.gotoAndStop(2);
			}
		}
		
		function onOut(param1:Event) : *
		{
			var _loc2_:MovieClip = param1.currentTarget as MovieClip;
			if(!this.m_disabled)
			{
				_loc2_.gotoAndStop(1);
				if(_loc2_ != this.m_handle_mc)
				{
					this.m_currentScrollDown = false;
					this.stopAutoScroll();
				}
			}
		}
		
		private function onUp(param1:Event) : *
		{
			if(!this.m_disabled)
			{
				ExternalInterface.call("PlaySound",this.SND_Release);
				param1.currentTarget.gotoAndStop(1);
			}
			this.stopAutoScroll();
		}
		
		public function startAutoScroll(param1:Boolean) : *
		{
			var _loc2_:Date = null;
			if(!this.m_isAutoScrolling)
			{
				this.m_currentScrollDown = param1;
				this.m_currentScrollDelay = 0;
				_loc2_ = new Date();
				this.m_autoScrollPrevTime = this.m_autoScrollStartTime = _loc2_.getTime();
				addEventListener(Event.ENTER_FRAME,this.onAutoScrolling);
				this.m_isAutoScrolling = true;
			}
		}
		
		private function onAutoScrolling(param1:Event) : *
		{
			var _loc5_:Number = NaN;
			var _loc2_:Number = new Date().getTime();
			var _loc3_:Number = this.m_autoScrollDefaultMultiplier;
			var _loc4_:Number = _loc2_ - this.m_autoScrollPrevTime;
			if(this.m_allowScrollAcceleration && this.m_autoScrollStartTime + this.m_autoScrollFasterDelay < _loc2_)
			{
				_loc3_ = _loc3_ * this.m_autoScrollFasterMultiplier;
			}
			if(_loc4_ > 0)
			{
				_loc5_ = (!!this.m_currentScrollDown?this.m_SCROLLSPEED:-this.m_SCROLLSPEED) * _loc3_ * (_loc4_ / 1000);
				if(!this.adjustScrollHandle(_loc5_,false,false))
				{
					this.stopAutoScroll();
				}
				this.m_autoScrollPrevTime = _loc2_;
			}
		}
		
		public function stopAutoScroll() : *
		{
			var _loc1_:Number = NaN;
			if(this.m_isAutoScrolling)
			{
				this.m_currentScrollDelay = this.m_initialScrollDelay;
				removeEventListener(Event.ENTER_FRAME,this.onAutoScrolling);
				this.m_isAutoScrolling = false;
				if(this.m_normaliseScrolling)
				{
					_loc1_ = 0;
					if(this.m_scrollAnimToY > this.getContDiff() - this.m_SCROLLSPEED * 0.3)
					{
						_loc1_ = this.getContDiff();
					}
					else
					{
						_loc1_ = Math.round(this.m_scrollAnimToY / this.m_SCROLLSPEED) * this.m_SCROLLSPEED;
					}
					if(_loc1_ != this.m_scrolledY)
					{
						this.scrollTo(_loc1_);
					}
				}
			}
		}
		
		private function bgDown(param1:Event) : *
		{
			if(!this.m_disabled)
			{
				ExternalInterface.call("PlaySound",this.SND_Click);
				this.scrollToPercent((this.mouseY - (this.m_up_mc.y + this.m_up_mc.height)) / this.m_scrollerDiff,this.m_animateScrolling);
			}
		}
	}
}
