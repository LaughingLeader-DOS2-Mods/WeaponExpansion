package LS_Classes
{
	import fl.motion.easing.Quartic;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	public class listDisplay extends MovieClip
	{
		public var content_array:Array;
		
		public var scrollHit_mc:MovieClip;
		
		public var container_mc:MovieClip;
		
		public var containerBG_mc:MovieClip;
		
		public var containerContent_mc:MovieClip;
		
		public var EL_SPACING:Number = 4;
		
		public var m_topSpacing:Number = 0;
		
		public var m_sideSpacing:Number = 0;
		
		public var m_cyclic:Boolean = false;
		
		public var m_customElementWidth:Number = -1;
		
		public var m_customElementHeight:Number = -1;
		
		public var m_forceDepthReorder:Boolean = false;
		
		public var m_CurrentSelection:MovieClip = null;
		
		public var idInc:uint = 0;
		
		protected var m_hasScrollRect:Boolean = false;
		
		public var OnSelectionChanged:Function = null;
		
		public var m_AlphaTweenFunc:Function;
		
		public var m_PositionTweenFunc:Function;
		
		protected var m_tweeningMcs:uint = 0;
		
		private var m_visibleLength:Number = -1;
		
		protected var m_NeedsSorting:Boolean = false;
		
		protected var m_SortOnFieldName:Object = null;
		
		protected var m_SortOnOptions:Object = null;
		
		protected var m_positionInvisibleElements:Boolean = false;
		
		protected var m_height:Number = -1;
		
		protected var m_width:Number = -1;
		
		public var m_myInterlinie:Number = 0;
		
		public function listDisplay()
		{
			this.content_array = new Array();
			this.scrollHit_mc = new MovieClip();
			this.container_mc = new MovieClip();
			this.containerBG_mc = new MovieClip();
			this.containerContent_mc = new MovieClip();
			this.m_AlphaTweenFunc = Quartic.easeIn;
			this.m_PositionTweenFunc = Quartic.easeOut;
			super();
			this.addChild(this.scrollHit_mc);
			this.scrollHit_mc.alpha = 0;
			this.addChild(this.container_mc);
			this.container_mc.addChild(this.containerBG_mc);
			this.container_mc.addChild(this.containerContent_mc);
			this.container_mc.x = 0;
		}
		
		override public function get width() : Number
		{
			if(this.m_width == -1)
			{
				return super.width;
			}
			return this.m_width;
		}
		
		override public function get height() : Number
		{
			if(this.m_height == -1)
			{
				return super.height;
			}
			return this.m_height;
		}
		
		public function get visibleHeight() : Number
		{
			var _loc1_:Number = 0;
			var _loc2_:MovieClip = this.getLastVisible(false);
			if(_loc2_)
			{
				_loc1_ = this.getElementHeight(_loc2_) + _loc2_.y;
			}
			return _loc1_;
		}
		
		override public function set width(param1:Number) : void
		{
			this.m_width = param1;
			this.updateScrollHit();
		}
		
		override public function set height(param1:Number) : void
		{
			this.m_height = param1;
			this.updateScrollHit();
		}
		
		public function get length() : Number
		{
			return this.content_array.length;
		}
		
		public function get visibleLength() : Number
		{
			if(this.m_visibleLength == -1)
			{
				return this.length;
			}
			return this.m_visibleLength;
		}
		
		public function setFrameWidth(param1:Number) : *
		{
			this.setFrame(param1,this.container_mc.height);
		}
		
		public function setFrame(param1:Number, param2:Number) : *
		{
			this.m_width = param1;
			this.m_height = param2;
			this.updateScrollHit();
			this.container_mc.scrollRect = new Rectangle(0,0,param1,param2);
			this.m_hasScrollRect = true;
		}
		
		protected function updateScrollHit() : *
		{
			var scrollSprite:Sprite = null;
			if(this.scrollHit_mc.numChildren == 0)
			{
				scrollSprite = new Sprite();
				scrollSprite.graphics.lineStyle(1,16777215);
				scrollSprite.graphics.beginFill(16777215);
				scrollSprite.graphics.drawRect(0,0,100,100);
				scrollSprite.graphics.endFill();
				this.scrollHit_mc.addChild(scrollSprite);
			}
			this.scrollHit_mc.width = this.width;
			this.scrollHit_mc.height = this.height;
		}
		
		public function getCurrentMovieClip() : MovieClip
		{
			return this.m_CurrentSelection;
		}
		
		public function get currentSelection() : Number
		{
			if(this.m_CurrentSelection)
			{
				return this.m_CurrentSelection.list_pos;
			}
			return -1;
		}
		
		public function get canPositionInvisibleElements() : Boolean
		{
			return this.m_positionInvisibleElements;
		}
		
		public function set canPositionInvisibleElements(b:Boolean) : *
		{
			if(this.m_positionInvisibleElements != b)
			{
				this.m_positionInvisibleElements = b;
				this.positionElements();
			}
		}
		
		public function getElement(index:Number) : MovieClip
		{
			if(index >= 0 && index < this.content_array.length)
			{
				return this.content_array[index];
			}
			return null;
		}
		
		public function getAt(index:Number) : MovieClip
		{
			if(index >= 0 && index < this.content_array.length)
			{
				return this.content_array[index];
			}
			return null;
		}
		
		public function getElementByListID(index:Number) : MovieClip
		{
			if(index == -1)
			{
				return null;
			}
			var i:uint = 0;
			while(i < this.content_array.length)
			{
				if(this.content_array[i] && this.content_array[i].hasOwnProperty("list_id") && this.content_array[i].list_id == index)
				{
					this.content_array[i].list_pos = i;
					return this.content_array[i];
				}
				i++;
			}
			return null;
		}
		
		public function selectLastElement() : *
		{
			if(this.content_array.length > 0)
			{
				this.select(this.content_array.length - 1,false,false);
			}
		}
		
		public function isLastElement(param1:MovieClip) : Boolean
		{
			if(this.content_array.length > 0)
			{
				return param1 == this.getLastElement(false,false);
			}
			return false;
		}
		
		public function isFirstElement(param1:MovieClip) : Boolean
		{
			if(this.content_array.length > 0)
			{
				return param1 == this.getFirstElement(false,false);
			}
			return false;
		}
		
		public function getElementByNumber(param1:String, param2:Number) : MovieClip
		{
			var _loc4_:MovieClip = null;
			var _loc3_:uint = 0;
			while(_loc3_ < this.content_array.length)
			{
				_loc4_ = this.content_array[_loc3_];
				if(_loc4_ && _loc4_[param1] == param2)
				{
					_loc4_.list_pos = _loc3_;
					return _loc4_;
				}
				_loc3_++;
			}
			return null;
		}
		
		public function getElementByBool(param1:String, param2:Boolean) : MovieClip
		{
			var _loc4_:MovieClip = null;
			var _loc3_:uint = 0;
			while(_loc3_ < this.content_array.length)
			{
				_loc4_ = this.content_array[_loc3_];
				if(_loc4_ && _loc4_[param1] == param2)
				{
					_loc4_.list_pos = _loc3_;
					return _loc4_;
				}
				_loc3_++;
			}
			return null;
		}
		
		public function selectByOffset(param1:Number, param2:Boolean = true) : Boolean
		{
			var _loc5_:MovieClip = null;
			var _loc6_:Number = NaN;
			var _loc3_:Boolean = false;
			param1 = param1 + this.TOP_SPACING;
			var _loc4_:uint = 0;
			while(_loc4_ < this.content_array.length)
			{
				_loc5_ = this.content_array[_loc4_];
				if(_loc5_ && _loc5_.visible)
				{
					_loc6_ = this.getElementHeight(_loc5_);
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
		
		public function getElementByString(param1:String, param2:String) : MovieClip
		{
			var _loc4_:MovieClip = null;
			var _loc3_:uint = 0;
			while(_loc3_ < this.content_array.length)
			{
				_loc4_ = this.content_array[_loc3_];
				if(_loc4_ && _loc4_[param1] == param2)
				{
					_loc4_.list_pos = _loc3_;
					return _loc4_;
				}
				_loc3_++;
			}
			return null;
		}
		
		protected function INTSort() : *
		{
			if(this.m_SortOnFieldName && this.content_array && this.content_array.length > 1)
			{
				this.content_array.sortOn(this.m_SortOnFieldName,this.m_SortOnOptions);
			}
		}
		
		public function cleanUpElements() : *
		{
			var _loc2_:MovieClip = null;
			var _loc1_:uint = 0;
			while(_loc1_ < this.content_array.length)
			{
				_loc2_ = this.content_array[_loc1_];
				if(_loc2_)
				{
					if(_loc2_.isUpdated)
					{
						_loc2_.isUpdated = false;
						_loc1_++;
					}
					else
					{
						this.removeElement(_loc1_,false);
					}
				}
				else
				{
					_loc1_++;
				}
			}
			if(this.content_array.length > 0)
			{
				this.positionElements();
			}
			else
			{
				this.m_visibleLength = -1;
			}
		}
		
		public function positionElements() : *
		{
			if(this.content_array.length < 1)
			{
				return;
			}
			if(this.m_NeedsSorting)
			{
				this.INTSort();
			}
			var _loc1_:Number = this.m_topSpacing;
			this.m_visibleLength = 0;
			var _loc2_:uint = 0;
			while(_loc2_ < this.content_array.length)
			{
				if(this.content_array[_loc2_].visible || this.canPositionInvisibleElements)
				{
					this.content_array[_loc2_].list_pos = _loc2_;
					this.content_array[_loc2_].y = _loc1_;
					this.content_array[_loc2_].tweenToY = _loc1_;
					if(this.content_array[_loc2_].INTUpd4PosEl != null)
					{
						this.content_array[_loc2_].INTUpd4PosEl();
					}
					_loc1_ = _loc1_ + (this.getElementHeight(this.content_array[_loc2_]) + this.EL_SPACING);
					if(this.m_sideSpacing != 0)
					{
						this.content_array[_loc2_].x = this.SIDE_SPACING;
					}
					if(this.content_array[_loc2_].visible)
					{
						this.m_visibleLength++;
					}
				}
				_loc2_++;
			}
			if(this.m_NeedsSorting)
			{
				this.m_NeedsSorting = false;
				dispatchEvent(new Event("listSorted"));
			}
		}
		
		public function getElementWidth(param1:MovieClip) : Number
		{
			var _loc2_:Number = param1.width;
			if(param1.widthOverride != undefined && !isNaN(param1.widthOverride))
			{
				_loc2_ = param1.widthOverride;
			}
			else if(this.m_customElementWidth != -1)
			{
				_loc2_ = this.m_customElementWidth;
			}
			return _loc2_;
		}
		
		public function getElementHeight(param1:MovieClip) : Number
		{
			var _loc2_:Number = param1.height;
			if(param1.heightOverride != undefined && !isNaN(param1.heightOverride))
			{
				_loc2_ = param1.heightOverride;
			}
			else if(this.m_customElementHeight != -1)
			{
				_loc2_ = this.m_customElementHeight;
			}
			return _loc2_;
		}
		
		public function getContentHeight() : Number
		{
			var _loc3_:MovieClip = null;
			var _loc1_:uint = 0;
			var _loc2_:int = 0;
			for each(_loc3_ in this.content_array)
			{
				if(_loc3_ && _loc3_.visible)
				{
					_loc1_ = _loc1_ + (this.getElementHeight(_loc3_) + _loc2_);
					_loc2_ = this.EL_SPACING;
				}
			}
			return _loc1_;
		}
		
		protected function reOrderDepths() : *
		{
			var _loc1_:int = 0;
			if(this.m_forceDepthReorder)
			{
				_loc1_ = this.content_array.length - 1;
				while(_loc1_ >= 0)
				{
					this.containerContent_mc.addChild(this.content_array[_loc1_]);
					_loc1_--;
				}
			}
		}
		
		public function moveElementsToPosition(param1:Number = 0.8, param2:Boolean = false) : *
		{
			var _loc4_:Object = null;
			var _loc6_:MovieClip = null;
			if(this.content_array.length < 1)
			{
				return;
			}
			var _loc3_:Number = 0;
			this.m_tweeningMcs = 0;
			dispatchEvent(new Event("listMoveStart"));
			var _loc5_:uint = 0;
			while(_loc5_ < this.content_array.length)
			{
				this.m_tweeningMcs++;
				_loc6_ = this.content_array[_loc5_];
				_loc6_.tweening = true;
				_loc6_.tweenToY = _loc3_;
				this.stopElementMCPosTweens(_loc6_);
				_loc6_.list_tweenY = new larTween(_loc6_,"y",this.m_PositionTweenFunc,NaN,_loc3_,param1,this.removeTweenState,_loc6_.list_id);
				if(param2 || this.m_sideSpacing != 0)
				{
					_loc6_.list_tweenX = new larTween(_loc6_,"x",this.m_PositionTweenFunc,NaN,this.m_sideSpacing,param1);
				}
				_loc3_ = _loc3_ + (this.getElementHeight(_loc6_) + this.EL_SPACING);
				_loc5_++;
			}
		}
		
		protected function removeTweenState(param1:uint) : *
		{
			var _loc2_:MovieClip = this.getElementByNumber("list_id",param1);
			this.m_tweeningMcs--;
			if(this.m_tweeningMcs == 0)
			{
				dispatchEvent(new Event("listMoveStop"));
			}
			_loc2_.dispatchEvent(new Event("elementMoveStop"));
			_loc2_.tweening = false;
		}
		
		public function moveElementToPosition(param1:Number, param2:Number) : Boolean
		{
			var _loc3_:DisplayObject = null;
			if(param1 >= 0 && param2 >= 0)
			{
				_loc3_ = this.content_array[param1];
				this.content_array.splice(param1,1);
				this.content_array.splice(param2,0,_loc3_);
				this.resetListPos();
				return true;
			}
			return false;
		}
		
		public function moveElementToBack(param1:Number) : *
		{
			var _loc2_:DisplayObject = null;
			if(param1 >= 0 && param1 < this.content_array.length)
			{
				_loc2_ = this.content_array[param1];
				if(_loc2_)
				{
					this.content_array.splice(param1,1);
					this.content_array.push(_loc2_);
					this.resetListPos();
				}
			}
		}
		
		public function onRemovedFromStage(param1:Event) : *
		{
			var _loc2_:MovieClip = param1.currentTarget as MovieClip;
			if(_loc2_)
			{
				this.stopElementMCTweens(_loc2_);
				_loc2_.removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
			}
		}
		
		public function addElement(param1:DisplayObject, param2:Boolean = true, param3:Boolean = true) : *
		{
			var _loc4_:MovieClip = param1 as MovieClip;
			this.containerContent_mc.addChild(param1);
			_loc4_.list_pos = this.content_array.length;
			this.content_array.push(_loc4_);
			param1.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
			_loc4_.list_id = this.idInc++;
			if(_loc4_.deselectElement)
			{
				_loc4_.deselectElement();
			}
			_loc4_.selectable = param3;
			_loc4_.m_filteredObject = false;
			this.m_NeedsSorting = true;
			this.reOrderDepths();
			_loc4_.ownerList = this;
			if(param2)
			{
				this.positionElements();
			}
		}
		
		public function addElementOnPosition(param1:DisplayObject, param2:uint, param3:Boolean = true, param4:Boolean = true) : *
		{
			var _loc5_:MovieClip = param1 as MovieClip;
			if(_loc5_.deselectElement)
			{
				_loc5_.deselectElement();
			}
			this.containerContent_mc.addChild(param1);
			_loc5_.list_id = this.idInc;
			this.idInc++;
			_loc5_.selectable = param4;
			this.content_array.splice(param2,0,_loc5_);
			this.m_NeedsSorting = true;
			this.reOrderDepths();
			this.resetListPos();
			if(param3)
			{
				this.positionElements();
			}
		}
		
		public function addElementToFront(param1:DisplayObject, param2:Boolean = true) : *
		{
			this.containerContent_mc.addChild(param1);
			this.content_array.unshift(param1 as MovieClip);
			(param1 as MovieClip).list_id = ++this.idInc;
			this.resetListPos();
			if(param2)
			{
				this.positionElements();
			}
		}
		
		public function resetListPos() : *
		{
			var _loc1_:uint = 0;
			while(_loc1_ < this.content_array.length)
			{
				this.content_array[_loc1_].list_pos = _loc1_;
				_loc1_++;
			}
		}
		
		public function stopElementTweens(param1:Number) : *
		{
			if(param1 >= 0 && param1 < this.content_array.length)
			{
				this.stopElementMCTweens(this.content_array[param1]);
			}
		}
		
		protected function stopElementMCTweens(param1:MovieClip) : *
		{
			if(param1)
			{
				this.stopElementMCPosTweens(param1);
				this.stopElementMCAlphaTweens(param1);
				this.stopElementMCScaleTweens(param1);
				param1.tweening = false;
			}
		}
		
		protected function stopElementMCScaleTweens(param1:MovieClip) : *
		{
			if(param1)
			{
				if(param1.list_tweenScaleX)
				{
					param1.list_tweenScaleX.stop();
				}
				if(param1.list_tweenScaleY)
				{
					param1.list_tweenScaleY.stop();
				}
			}
		}
		
		private function stopElementMCAlphaTweens(param1:MovieClip) : *
		{
			if(param1)
			{
				if(param1.list_tweenAlpha)
				{
					param1.list_tweenAlpha.stop();
				}
			}
		}
		
		protected function stopElementMCPosTweens(param1:MovieClip) : *
		{
			if(param1)
			{
				if(param1.list_tweenX)
				{
					param1.list_tweenX.stop();
				}
				if(param1.list_tweenY)
				{
					param1.list_tweenY.stop();
				}
			}
		}
		
		public function fadeOutAndRemoveElement(param1:Number, param2:Number, param3:Number, param4:Boolean = true, param5:Boolean = false) : *
		{
			var _element:MovieClip = null;
			var pos:Number = param1;
			var fadeTime:Number = param2;
			var delay:Number = param3;
			var update:Boolean = param4;
			var removeElementBefore:Boolean = param5;
			if(pos >= 0 && pos < this.content_array.length)
			{
				_element = this.content_array[pos];
				if(_element)
				{
					_element.tweenDelay = new Timer(delay * 1000,1);
					_element.tweenDelay.addEventListener(TimerEvent.TIMER_COMPLETE,function():*
					{
						stopElementMCAlphaTweens(_element);
						_element.list_tweenAlpha = new larTween(_element,"alpha",m_AlphaTweenFunc,_element.alpha,0,fadeTime);
						if(removeElementBefore)
						{
							_element.list_tweenAlpha.m_FinishCallback = removeChildAfterFade;
							_element.list_tweenAlpha.m_FinishCallbackParams = [_element];
							content_array.splice(pos,1);
						}
						else
						{
							_element.list_tweenAlpha.m_FinishCallback = removeElement;
							_element.list_tweenAlpha.m_FinishCallbackParams = [pos,true,true,0.1];
						}
					});
				}
			}
		}
		
		private function removeChildAfterFade(param1:MovieClip) : *
		{
			this.containerContent_mc.removeChild(param1);
		}
		
		public function removeElement(param1:Number, param2:Boolean = true, param3:Boolean = false, param4:Number = 0.3) : *
		{
			var _loc5_:MovieClip = null;
			var _loc6_:Number = NaN;
			var _loc7_:MovieClip = null;
			if(param1 >= 0 && param1 < this.content_array.length)
			{
				_loc5_ = this.content_array[param1];
				if(_loc5_)
				{
					this.stopElementMCTweens(_loc5_);
					_loc7_ = _loc5_.parent as MovieClip;
					if(_loc7_)
					{
						_loc7_.removeChild(_loc5_);
					}
				}
				this.content_array.splice(param1,1);
				_loc6_ = this.currentSelection;
				if(param1 == _loc6_ && this.content_array.length > 0)
				{
					if(_loc6_ > 0)
					{
						this.m_CurrentSelection = this.content_array[_loc6_ - 1];
					}
					else
					{
						this.m_CurrentSelection = this.content_array[0];
					}
					if(this.OnSelectionChanged != null)
					{
						this.OnSelectionChanged();
					}
				}
				else if(this.content_array.length == 0)
				{
					this.m_CurrentSelection = null;
				}
				this.resetListPos();
				if(param2)
				{
					if(param3)
					{
						this.moveElementsToPosition(param4);
					}
					else
					{
						this.positionElements();
					}
				}
			}
			dispatchEvent(new Event("elementRemoved"));
		}
		
		public function removeElementByListId(param1:Number, param2:Boolean = true) : Boolean
		{
			var _loc3_:uint = 0;
			while(_loc3_ < this.content_array.length)
			{
				if(this.content_array[_loc3_].list_id == param1)
				{
					this.removeElement(_loc3_,param2);
					return true;
				}
				_loc3_++;
			}
			return false;
		}
		
		public function clearElements() : *
		{
			var _loc2_:MovieClip = null;
			var _loc1_:uint = 0;
			while(_loc1_ < this.content_array.length)
			{
				if(this.content_array[_loc1_])
				{
					_loc2_ = this.content_array[_loc1_];
					this.stopElementMCTweens(_loc2_);
					this.containerContent_mc.removeChild(this.content_array[_loc1_]);
				}
				_loc1_++;
			}
			this.content_array = new Array();
			this.idInc = 0;
			this.m_CurrentSelection = null;
			this.m_visibleLength = -1;
		}
		
		public function set elementSpacing(param1:Number) : *
		{
			this.EL_SPACING = param1;
			this.positionElements();
		}
		
		public function get elementSpacing() : Number
		{
			return this.EL_SPACING;
		}
		
		public function set TOP_SPACING(param1:Number) : *
		{
			this.m_topSpacing = param1;
			this.positionElements();
		}
		
		public function get TOP_SPACING() : Number
		{
			return this.m_topSpacing;
		}
		
		public function set SIDE_SPACING(param1:Number) : *
		{
			this.m_sideSpacing = param1;
			this.positionElements();
		}
		
		public function get SIDE_SPACING() : Number
		{
			return this.m_sideSpacing;
		}
		
		public function get size() : Number
		{
			return this.content_array.length;
		}
		
		public function next() : *
		{
			var _loc1_:Number = NaN;
			if(this.visibleLength > 1)
			{
				_loc1_ = this.currentSelection;
				if(this.currentSelection <= 0)
				{
					_loc1_ = 0;
				}
				if(!this.m_CurrentSelection || this.m_CurrentSelection.INTSelectNext == null || !this.m_CurrentSelection.INTSelectNext())
				{
					this.select(_loc1_ + 1,false,true);
				}
			}
		}
		
		public function previous() : *
		{
			if(this.visibleLength > 1 && (!this.m_CurrentSelection || this.m_CurrentSelection.INTSelectPrevious == null || !this.m_CurrentSelection.INTSelectPrevious()))
			{
				this.select(this.currentSelection - 1,false,false);
			}
		}
		
		public function getPreviousVisibleElement() : MovieClip
		{
			var _loc1_:int = 0;
			if(this.currentSelection > 0)
			{
				_loc1_ = this.currentSelection - 1;
				while(_loc1_ >= 0)
				{
					if(this.content_array[_loc1_] && this.content_array[_loc1_].visible)
					{
						return this.content_array[_loc1_];
					}
					_loc1_--;
				}
			}
			return null;
		}
		
		public function selectByListID(param1:Number) : *
		{
			var _loc2_:MovieClip = this.getElementByListID(param1);
			this.selectMC(_loc2_);
		}
		
		public function selectMC(param1:MovieClip, param2:Boolean = false) : *
		{
			if(this.m_CurrentSelection != param1 || param2)
			{
				if(this.m_CurrentSelection)
				{
					if(this.m_CurrentSelection.deselectElement)
					{
						this.m_CurrentSelection.deselectElement();
					}
					if(this.m_CurrentSelection.INTDeselect)
					{
						this.m_CurrentSelection.INTDeselect();
					}
				}
				if(param1)
				{
					this.m_CurrentSelection = param1;
					dispatchEvent(new Event(Event.CHANGE));
					if(this.OnSelectionChanged != null)
					{
						this.OnSelectionChanged();
					}
					if(param1.selectElement)
					{
						param1.selectElement();
					}
				}
				else
				{
					this.m_CurrentSelection = null;
				}
			}
		}
		
		public function clearSelection() : *
		{
			if(this.currentSelection != -1)
			{
				if(this.m_CurrentSelection)
				{
					if(this.m_CurrentSelection.deselectElement)
					{
						this.m_CurrentSelection.deselectElement();
					}
					if(this.m_CurrentSelection.INTDeselect)
					{
						this.m_CurrentSelection.INTDeselect();
					}
				}
				this.m_CurrentSelection = null;
			}
		}
		
		public function select(param1:Number, param2:Boolean = false, param3:Boolean = true) : *
		{
			var _loc4_:MovieClip = null;
			if(this.visibleLength <= 1 && this.m_CurrentSelection && this.m_CurrentSelection.visible && !(this.currentSelection == param1 && param2))
			{
				return;
			}
			if(this.m_cyclic)
			{
				if(param1 < 0)
				{
					param1 = this.content_array.length - 1;
				}
				else if(param1 >= this.content_array.length)
				{
					param1 = 0;
				}
			}
			else if(param1 < 0 || param1 >= this.content_array.length)
			{
				return;
			}
			if(this.currentSelection != param1 || param2)
			{
				_loc4_ = this.content_array[param1];
				if(_loc4_)
				{
					if(_loc4_.visible && _loc4_.selectable)
					{
						this.selectMC(_loc4_,param2);
						if(!param3 && _loc4_.INTSelectLast != null && _loc4_.INTSelectLast())
						{
							if(_loc4_.deselectElement)
							{
								_loc4_.deselectElement();
							}
						}
					}
					else if(param3)
					{
						this.select(param1 + 1,param2,param3);
					}
					else
					{
						this.select(param1 - 1,param2,param3);
					}
				}
			}
		}
		
		public function filterShowAll() : *
		{
			var _loc1_:uint = 0;
			while(_loc1_ < this.content_array.length)
			{
				this.content_array[_loc1_].visible = true;
				this.content_array[_loc1_].m_filteredObject = false;
				_loc1_++;
			}
			this.m_visibleLength = -1;
		}
		
		public function filterHideAll() : *
		{
			var _loc1_:uint = 0;
			while(_loc1_ < this.content_array.length)
			{
				this.content_array[_loc1_].visible = false;
				this.content_array[_loc1_].m_filteredObject = false;
				_loc1_++;
			}
			this.m_visibleLength = -1;
		}
		
		public function filterHideBoolean(param1:String, param2:Boolean) : *
		{
			var _loc3_:Number = 0;
			var _loc4_:uint = 0;
			while(_loc4_ < this.content_array.length)
			{
				if(this.content_array[_loc4_][param1] && this.content_array[_loc4_][param1] == param2)
				{
					this.content_array[_loc4_].visible = false;
					this.content_array[_loc4_].m_filteredObject = true;
				}
				if(this.content_array[_loc4_].visible)
				{
					_loc3_++;
				}
				_loc4_++;
			}
			this.m_visibleLength = _loc3_;
		}
		
		public function filterShowBoolean(param1:String, param2:Boolean, param3:Boolean = true) : *
		{
			var _loc4_:Number = 0;
			var _loc5_:uint = 0;
			while(_loc5_ < this.content_array.length)
			{
				if(this.content_array[_loc5_][param1])
				{
					if(this.content_array[_loc5_][param1] == param2)
					{
						this.content_array[_loc5_].visible = true;
					}
					else if(param3)
					{
						this.content_array[_loc5_].visible = false;
					}
				}
				if(this.content_array[_loc5_].visible)
				{
					_loc4_++;
				}
				_loc5_++;
			}
			this.m_visibleLength = _loc4_;
		}
		
		public function filterBySubString(param1:String, param2:String) : *
		{
			var _loc3_:Number = 0;
			var _loc4_:uint = 0;
			while(_loc4_ < this.content_array.length)
			{
				if(!this.content_array[_loc4_].m_filteredObject && (param2 == "" || this.content_array[_loc4_][param1].toLowerCase().indexOf(param2.toLowerCase()) != -1))
				{
					this.content_array[_loc4_].visible = true;
					this.content_array[_loc4_].m_filteredObject = false;
				}
				else
				{
					this.content_array[_loc4_].visible = false;
					this.content_array[_loc4_].m_filteredObject = true;
				}
				if(this.content_array[_loc4_].visible)
				{
					_loc3_++;
				}
				_loc4_++;
			}
			this.m_visibleLength = _loc3_;
		}
		
		public function filterShowType(param1:String, param2:Object, param3:Boolean = true) : *
		{
			var _loc4_:Number = 0;
			var _loc5_:uint = 0;
			while(_loc5_ < this.content_array.length)
			{
				if(this.content_array[_loc5_][param1] != null && this.content_array[_loc5_][param1] == param2)
				{
					this.content_array[_loc5_].visible = true;
					this.content_array[_loc5_].m_filteredObject = false;
				}
				else if(param3)
				{
					this.content_array[_loc5_].visible = false;
					this.content_array[_loc5_].m_filteredObject = true;
				}
				if(this.content_array[_loc5_].visible)
				{
					_loc4_++;
				}
				_loc5_++;
			}
			this.m_visibleLength = _loc4_;
		}
		
		public function filterHideType(param1:String, param2:Object) : *
		{
			var _loc3_:Number = 0;
			var _loc4_:uint = 0;
			while(_loc4_ < this.content_array.length)
			{
				if(this.content_array[_loc4_][param1] != null && this.content_array[_loc4_][param1] == param2)
				{
					this.content_array[_loc4_].visible = false;
					this.content_array[_loc4_].m_filteredObject = true;
				}
				if(this.content_array[_loc4_].visible)
				{
					_loc3_++;
				}
				_loc4_++;
			}
			this.m_visibleLength = _loc3_;
		}
		
		public function filterType(param1:String, param2:Object) : *
		{
			var _loc3_:Number = 0;
			var _loc4_:uint = 0;
			while(_loc4_ < this.content_array.length)
			{
				if(!(this.content_array[_loc4_][param1] != null && this.content_array[_loc4_][param1] == param2))
				{
					this.content_array[_loc4_].visible = false;
				}
				if(this.content_array[_loc4_].visible)
				{
					_loc3_++;
				}
				_loc4_++;
			}
			this.m_visibleLength = _loc3_;
		}
		
		public function getFirstElement(param1:Boolean = true, param2:Boolean = true) : MovieClip
		{
			var _loc3_:uint = 0;
			while(_loc3_ < this.content_array.length)
			{
				if(this.content_array[_loc3_])
				{
					if(!(param1 && !this.content_array[_loc3_].visible))
					{
						if(!(param2 && this.content_array[_loc3_].selectable == false))
						{
							return this.content_array[_loc3_];
						}
					}
				}
				_loc3_++;
			}
			return null;
		}
		
		public function getFirstVisible(param1:Boolean = true) : MovieClip
		{
			return this.getFirstElement(true,param1);
		}
		
		public function getLastElement(param1:Boolean = true, param2:Boolean = true) : MovieClip
		{
			var _loc3_:int = this.content_array.length - 1;
			while(_loc3_ >= 0)
			{
				if(this.content_array[_loc3_])
				{
					if(!(param1 && !this.content_array[_loc3_].visible))
					{
						if(!(param2 && this.content_array[_loc3_].selectable == false))
						{
							return this.content_array[_loc3_];
						}
					}
				}
				_loc3_--;
			}
			return null;
		}
		
		public function getLastVisible(param1:Boolean = true) : MovieClip
		{
			return this.getLastElement(true,param1);
		}
		
		public function selectFirstVisible(param1:Boolean = false) : *
		{
			var _loc2_:MovieClip = this.getFirstVisible();
			if(_loc2_)
			{
				this.selectMC(_loc2_,param1);
			}
		}
		
		public function sortOn(param1:Object, param2:Object = null, param3:Boolean = true) : *
		{
			this.m_SortOnFieldName = param1;
			this.m_SortOnOptions = param2;
			if(this.content_array && this.content_array.length > 1)
			{
				this.content_array.sortOn(this.m_SortOnFieldName,this.m_SortOnOptions);
				if(param3)
				{
					this.positionElements();
				}
				else
				{
					this.resetListPos();
				}
				dispatchEvent(new Event("listSorted"));
			}
		}
		
		public function redoSort() : *
		{
			this.m_NeedsSorting = true;
		}
		
		public function sortOnce(param1:Object, param2:Object = null, param3:Boolean = true) : *
		{
			if(this.content_array && this.content_array.length > 1)
			{
				this.content_array.sortOn(param1,param2);
				if(param3)
				{
					this.positionElements();
				}
				else
				{
					this.resetListPos();
				}
				dispatchEvent(new Event("listSorted"));
			}
		}
		
		public function cursorLeft() : *
		{
		}
		
		public function cursorRight() : *
		{
		}
		
		public function cursorUp() : *
		{
			this.previous();
		}
		
		public function cursorDown() : *
		{
			this.next();
		}
		
		public function cursorAccept() : *
		{
			if(this.m_CurrentSelection && this.m_CurrentSelection.onClick != null)
			{
				this.m_CurrentSelection.onClick();
			}
		}
	}
}
