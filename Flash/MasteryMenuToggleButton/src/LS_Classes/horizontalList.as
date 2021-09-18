package LS_Classes
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class horizontalList extends listDisplay
	{
		 
		
		public var rightSided:Boolean = true;
		
		public var m_MaxWidth:int = -1;
		
		public var m_MaxRowElements:int = -1;
		
		public var m_RowSpacing:int = 0;
		
		public var m_CenterHolders:Boolean = false;
		
		public var m_RowHeight:Number = -1;
		
		private var m_holderArray:Array;
		
		public function horizontalList()
		{
			this.m_holderArray = new Array();
			super();
		}
		
		override public function positionElements() : *
		{
			var _loc7_:Number = NaN;
			var _loc8_:int = 0;
			if(content_array.length < 1)
			{
				return;
			}
			if(m_NeedsSorting && m_SortOnFieldName && content_array && content_array.length > 1)
			{
				content_array.sortOn(m_SortOnFieldName,m_SortOnOptions);
				m_NeedsSorting = false;
			}
			var _loc1_:Number = 0;
			var _loc2_:uint = 0;
			var _loc3_:uint = 1;
			var _loc4_:uint = content_array.length;
			var _loc5_:MovieClip = null;
			var _loc6_:uint = 0;
			while(_loc6_ < _loc4_)
			{
				if(content_array[_loc6_].visible || canPositionInvisibleElements)
				{
					if(this.rightSided)
					{
						content_array[_loc6_].x = _loc1_;
						content_array[_loc6_].tweenToX = _loc1_;
						_loc1_ = _loc1_ + Math.round(getElementWidth(content_array[_loc6_]) + EL_SPACING);
					}
					else
					{
						_loc7_ = getElementWidth(content_array[_loc6_]);
						content_array[_loc6_].x = _loc1_ - _loc7_;
						content_array[_loc6_].tweenToX = _loc1_ - _loc7_;
						_loc1_ = _loc1_ - Math.round(_loc7_ + EL_SPACING);
					}
					if(this.m_MaxWidth > 0)
					{
						_loc8_ = content_array[_loc6_].x + content_array[_loc6_].width;
						if(_loc8_ > this.m_MaxWidth)
						{
							content_array[_loc6_].x = 0;
							_loc2_++;
							_loc1_ = Math.round(getElementWidth(content_array[_loc6_]) + EL_SPACING);
						}
						_loc5_ = this.createNewRowHolderWhenNeeded(_loc2_);
						_loc5_.addChild(content_array[_loc6_]);
						_loc5_.overrideWidth = content_array[_loc6_].x + getElementWidth(content_array[_loc6_]);
					}
					else if(this.m_MaxRowElements > 0)
					{
						if(_loc3_ > this.m_MaxRowElements)
						{
							_loc3_ = 1;
							content_array[_loc6_].x = 0;
							_loc2_++;
							_loc1_ = Math.round(getElementWidth(content_array[_loc6_]) + EL_SPACING);
						}
						_loc5_ = this.createNewRowHolderWhenNeeded(_loc2_);
						_loc5_.addChild(content_array[_loc6_]);
						_loc5_.overrideWidth = content_array[_loc6_].x + getElementWidth(content_array[_loc6_]);
						_loc3_++;
					}
				}
				else
				{
					content_array[_loc6_].x = 0;
				}
				_loc6_++;
			}
			this.cleanupUnusedRowHolders(_loc2_);
			this.centerHolders();
		}
		
		private function centerHolders() : void
		{
			var _loc1_:uint = 0;
			var _loc2_:MovieClip = null;
			if(this.m_CenterHolders)
			{
				_loc1_ = 0;
				while(_loc1_ < this.m_holderArray.length)
				{
					_loc2_ = this.m_holderArray[_loc1_];
					_loc2_.x = -Math.round(_loc2_.overrideWidth * 0.5);
					_loc1_++;
				}
			}
		}
		
		private function createNewRowHolderWhenNeeded(param1:Number) : MovieClip
		{
			var _loc2_:MovieClip = null;
			var _loc3_:MovieClip = null;
			if(this.m_holderArray.length <= param1)
			{
				_loc2_ = new MovieClip();
				containerContent_mc.addChild(_loc2_);
				if(this.m_holderArray.length > 0)
				{
					_loc3_ = this.m_holderArray[this.m_holderArray.length - 1];
					if(_loc3_)
					{
						if(this.m_RowHeight == -1)
						{
							_loc2_.y = _loc3_.y + _loc3_.height + this.m_RowSpacing;
						}
						else
						{
							_loc2_.y = _loc3_.y + this.m_RowHeight + this.m_RowSpacing;
						}
					}
				}
				this.m_holderArray.push(_loc2_);
				return _loc2_;
			}
			return this.m_holderArray[param1];
		}
		
		private function cleanupUnusedRowHolders(param1:Number) : *
		{
			var _loc2_:uint = param1 + 1;
			while(this.m_holderArray.length > _loc2_)
			{
				containerContent_mc.removeChild(this.m_holderArray[_loc2_]);
				this.m_holderArray.splice(_loc2_,1);
			}
		}
		
		override public function moveElementsToPosition(param1:Number = 0.8, param2:Boolean = false) : *
		{
			var _loc8_:Object = null;
			var _loc10_:MovieClip = null;
			var _loc11_:Number = NaN;
			var _loc12_:int = 0;
			if(content_array.length < 1)
			{
				return;
			}
			var _loc3_:Number = 0;
			var _loc4_:uint = 0;
			var _loc5_:uint = 1;
			var _loc6_:MovieClip = null;
			m_tweeningMcs = 0;
			dispatchEvent(new Event("listMoveStart"));
			var _loc7_:uint = content_array.length;
			var _loc9_:uint = 0;
			while(_loc9_ < _loc7_)
			{
				_loc10_ = content_array[_loc9_];
				if(_loc10_)
				{
					if(this.rightSided)
					{
						m_tweeningMcs++;
						_loc10_.tweening = true;
						_loc10_.tweenToX = _loc3_;
						_loc3_ = _loc3_ + Math.round(getElementWidth(content_array[_loc9_]) + EL_SPACING);
					}
					else
					{
						m_tweeningMcs++;
						_loc10_.tweening = true;
						_loc11_ = getElementWidth(content_array[_loc9_]);
						_loc10_.tweenToX = _loc3_ - _loc11_;
						_loc3_ = _loc3_ - Math.round(_loc11_ + EL_SPACING);
					}
					stopElementMCPosTweens(_loc10_);
					if(param2)
					{
						_loc10_.list_tweenY = new larTween(_loc10_,"y",m_PositionTweenFunc,_loc10_.y,0,param1);
					}
					_loc10_.list_tweenX = new larTween(_loc10_,"x",m_PositionTweenFunc,_loc10_.x,_loc10_.tweenToX,param1,removeTweenState,_loc10_.list_id);
					if(this.m_MaxWidth > 0)
					{
						_loc12_ = content_array[_loc9_].x + content_array[_loc9_].width;
						if(_loc12_ > this.m_MaxWidth)
						{
							content_array[_loc9_].tweenToX = 0;
							_loc4_++;
							_loc3_ = Math.round(getElementWidth(content_array[_loc9_]) + EL_SPACING);
						}
						_loc6_ = this.createNewRowHolderWhenNeeded(_loc4_);
						_loc6_.addChild(content_array[_loc9_]);
						_loc6_.overrideWidth = content_array[_loc9_].tweenToX + getElementWidth(content_array[_loc9_]);
					}
					else if(this.m_MaxRowElements > 0)
					{
						if(_loc5_ > this.m_MaxRowElements)
						{
							_loc5_ = 1;
							content_array[_loc9_].x = 0;
							_loc4_++;
							_loc3_ = Math.round(getElementWidth(content_array[_loc9_]) + EL_SPACING);
						}
						_loc6_ = this.createNewRowHolderWhenNeeded(_loc4_);
						_loc6_.addChild(content_array[_loc9_]);
						_loc6_.overrideWidth = content_array[_loc9_].tweenToX + getElementWidth(content_array[_loc9_]);
						_loc5_++;
					}
				}
				_loc9_++;
			}
			this.cleanupUnusedRowHolders(_loc4_);
		}
		
		public function getContainerWidth() : Number
		{
			var _loc1_:Number = 0;
			var _loc2_:MovieClip = getLastVisible();
			if(_loc2_)
			{
				if(this.rightSided)
				{
					return _loc2_.x + getElementWidth(_loc2_);
				}
				return -_loc2_.x;
			}
			return 0;
		}
	}
}
