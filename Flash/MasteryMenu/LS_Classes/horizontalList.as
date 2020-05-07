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
			var elWidth:Number = NaN;
			var contentElementWidth:int = 0;
			if(content_array.length < 1)
			{
				return;
			}
			if(m_NeedsSorting && m_SortOnFieldName && content_array && content_array.length > 1)
			{
				content_array.sortOn(m_SortOnFieldName,m_SortOnOptions);
				m_NeedsSorting = false;
			}
			var objX:Number = 0;
			var rowIndex:uint = 0;
			var colIndex:uint = 1;
			var length:uint = content_array.length;
			var rowHolder:MovieClip = null;
			var index:uint = 0;
			while(index < length)
			{
				if(content_array[index].visible || canPositionInvisibleElements)
				{
					if(this.rightSided)
					{
						content_array[index].x = objX;
						content_array[index].tweenToX = objX;
						objX = objX + Math.round(getElementWidth(content_array[index]) + EL_SPACING);
					}
					else
					{
						elWidth = getElementWidth(content_array[index]);
						content_array[index].x = objX - elWidth;
						content_array[index].tweenToX = objX - elWidth;
						objX = objX - Math.round(elWidth + EL_SPACING);
					}
					if(this.m_MaxWidth > 0)
					{
						contentElementWidth = content_array[index].x + content_array[index].width;
						if(contentElementWidth > this.m_MaxWidth)
						{
							content_array[index].x = 0;
							rowIndex++;
							objX = Math.round(getElementWidth(content_array[index]) + EL_SPACING);
						}
						rowHolder = this.createNewRowHolderWhenNeeded(rowIndex);
						rowHolder.addChild(content_array[index]);
						rowHolder.overrideWidth = content_array[index].x + getElementWidth(content_array[index]);
					}
					else if(this.m_MaxRowElements > 0)
					{
						if(colIndex > this.m_MaxRowElements)
						{
							colIndex = 1;
							content_array[index].x = 0;
							rowIndex++;
							objX = Math.round(getElementWidth(content_array[index]) + EL_SPACING);
						}
						rowHolder = this.createNewRowHolderWhenNeeded(rowIndex);
						rowHolder.addChild(content_array[index]);
						rowHolder.overrideWidth = content_array[index].x + getElementWidth(content_array[index]);
						colIndex++;
					}
				}
				else
				{
					content_array[index].x = 0;
				}
				index++;
			}
			this.cleanupUnusedRowHolders(rowIndex);
			this.centerHolders();
		}
		
		private function centerHolders() : void
		{
			var index:uint = 0;
			var obj:MovieClip = null;
			if(this.m_CenterHolders)
			{
				index = 0;
				while(index < this.m_holderArray.length)
				{
					obj = this.m_holderArray[index];
					obj.x = -Math.round(obj.overrideWidth * 0.5);
					index++;
				}
			}
		}
		
		private function createNewRowHolderWhenNeeded(index:Number) : MovieClip
		{
			var rowHolder:MovieClip = null;
			var previousRowHolder:MovieClip = null;
			if(this.m_holderArray.length <= index)
			{
				rowHolder = new MovieClip();
				containerContent_mc.addChild(rowHolder);
				if(this.m_holderArray.length > 0)
				{
					previousRowHolder = this.m_holderArray[this.m_holderArray.length - 1];
					if(previousRowHolder)
					{
						if(this.m_RowHeight == -1)
						{
							rowHolder.y = previousRowHolder.y + previousRowHolder.height + this.m_RowSpacing;
						}
						else
						{
							rowHolder.y = previousRowHolder.y + this.m_RowHeight + this.m_RowSpacing;
						}
					}
				}
				this.m_holderArray.push(rowHolder);
				return rowHolder;
			}
			return this.m_holderArray[index];
		}
		
		private function cleanupUnusedRowHolders(targetIndex:Number) : *
		{
			var i:uint = targetIndex + 1;
			while(this.m_holderArray.length > i)
			{
				containerContent_mc.removeChild(this.m_holderArray[i]);
				this.m_holderArray.splice(i,1);
			}
		}
		
		override public function moveElementsToPosition(pos:Number = 0.8, tweenY:Boolean = false) : *
		{
			var obj:MovieClip = null;
			var elWidth:Number = NaN;
			var colWidth:int = 0;
			if(content_array.length < 1)
			{
				return;
			}
			var targetX:Number = 0;
			var rowIndex:uint = 0;
			var colIndex:uint = 1;
			var rowHolder:MovieClip = null;
			m_tweeningMcs = 0;
			dispatchEvent(new Event("listMoveStart"));
			var length:uint = content_array.length;
			var index:uint = 0;
			while(index < length)
			{
				obj = content_array[index];
				if(obj)
				{
					if(this.rightSided)
					{
						m_tweeningMcs++;
						obj.tweening = true;
						obj.tweenToX = targetX;
						targetX = targetX + Math.round(getElementWidth(content_array[index]) + EL_SPACING);
					}
					else
					{
						m_tweeningMcs++;
						obj.tweening = true;
						elWidth = getElementWidth(content_array[index]);
						obj.tweenToX = targetX - elWidth;
						targetX = targetX - Math.round(elWidth + EL_SPACING);
					}
					stopElementMCPosTweens(obj);
					if(tweenY)
					{
						obj.list_tweenY = new larTween(obj,"y",m_PositionTweenFunc,obj.y,0,pos);
					}
					obj.list_tweenX = new larTween(obj,"x",m_PositionTweenFunc,obj.x,obj.tweenToX,pos,removeTweenState,obj.list_id);
					if(this.m_MaxWidth > 0)
					{
						colWidth = content_array[index].x + content_array[index].width;
						if(colWidth > this.m_MaxWidth)
						{
							content_array[index].tweenToX = 0;
							rowIndex++;
							targetX = Math.round(getElementWidth(content_array[index]) + EL_SPACING);
						}
						rowHolder = this.createNewRowHolderWhenNeeded(rowIndex);
						rowHolder.addChild(content_array[index]);
						rowHolder.overrideWidth = content_array[index].tweenToX + getElementWidth(content_array[index]);
					}
					else if(this.m_MaxRowElements > 0)
					{
						if(colIndex > this.m_MaxRowElements)
						{
							colIndex = 1;
							content_array[index].x = 0;
							rowIndex++;
							targetX = Math.round(getElementWidth(content_array[index]) + EL_SPACING);
						}
						rowHolder = this.createNewRowHolderWhenNeeded(rowIndex);
						rowHolder.addChild(content_array[index]);
						rowHolder.overrideWidth = content_array[index].tweenToX + getElementWidth(content_array[index]);
						colIndex++;
					}
				}
				index++;
			}
			this.cleanupUnusedRowHolders(rowIndex);
		}
		
		public function getContainerWidth() : Number
		{
			var obj:MovieClip = getLastVisible();
			if(obj)
			{
				if(this.rightSided)
				{
					return obj.x + getElementWidth(obj);
				}
				return -obj.x;
			}
			return 0;
		}
	}
}
