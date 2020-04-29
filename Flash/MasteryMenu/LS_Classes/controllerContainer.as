package LS_Classes
{
	import fl.motion.easing.Linear;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	
	public class controllerContainer extends horizontalList
	{
		 
		
		public var centerButtons:Boolean = false;
		
		public var alignLeft:Boolean = false;
		
		public var buttonhintContY:int = -1;
		
		public var centerPanelPosX:int = -1;
		
		public var leftPanelPosX:int = -1;
		
		public var buttonhintFrameWidth:int = -1;
		
		public var bounceTreshHold:int = 50;
		
		public var bounceInterval:Number = 1.5;
		
		public var bounceTime:Number = 50;
		
		private var m_BounceAmount:int = -1;
		
		private var m_BounceTween:larTween = null;
		
		public var m_CurrBounce:Number = 0;
		
		public var containerMaxWidth:uint = 0;
		
		public function controllerContainer()
		{
			super();
		}
		
		public function addBtnHint(id:Number, hintText:String, iconId:Number, maxTextWidth:Number = 110, buttonState:* = true) : MovieClip
		{
			var buttonElement:MovieClip = getElementByNumber("id",id);
			if(!buttonElement)
			{
				buttonElement = new controllerBtnElement();
				buttonElement.id = id;
				buttonElement.setBtnHintState(buttonState);
				addElement(buttonElement);
			}
			if(buttonElement)
			{
				buttonElement.setBtnHint(hintText,iconId,maxTextWidth,buttonState);
				if(this.containerMaxWidth > 0)
				{
					this.recalculateButtonsWidth();
				}
				this.recenterTabs();
			}
			else
			{
				ExternalInterface.call("UIAssert","addBtnHint failed again because the flash exporter is CRAP");
			}
			return buttonElement;
		}
		
		public function recenterTabs() : *
		{
			if(this.buttonhintContY != -1 && this.centerPanelPosX != -1 && this.leftPanelPosX != -1 && this.buttonhintFrameWidth != -1)
			{
				this.bounceButtonHints();
			}
			else if(this.centerButtons)
			{
				container_mc.x = -Math.round(container_mc.width * 0.5);
			}
			else if(this.alignLeft)
			{
				container_mc.x = 0;
			}
			else
			{
				container_mc.x = -Math.round(container_mc.width);
			}
		}
		
		public function clearBtnHints() : *
		{
			clearElements();
		}
		
		private function bounceButtonHints() : *
		{
			if(this.buttonhintContY != -1 && this.centerPanelPosX != -1 && this.leftPanelPosX != -1 && this.buttonhintFrameWidth != -1)
			{
				if(this.width < this.buttonhintFrameWidth + this.bounceTreshHold)
				{
					this.x = this.centerPanelPosX - this.width / 2;
					if(this.m_BounceTween)
					{
						this.m_BounceTween.stop();
						this.m_BounceTween = null;
						this.m_BounceAmount = -1;
						this.y = this.buttonhintContY;
						this.scrollRect = null;
					}
				}
				else
				{
					this.x = this.leftPanelPosX;
					this.y = this.buttonhintContY - this.height / 2;
					this.scrollRect = new Rectangle(0,-this.height / 2,this.buttonhintFrameWidth,this.height);
					this.m_BounceAmount = this.width - this.buttonhintFrameWidth;
					this.m_CurrBounce = 0;
					this.bounceRight();
				}
			}
		}
		
		private function bounceLeft() : *
		{
			if(this.m_BounceTween)
			{
				this.m_BounceTween.stop();
				this.m_BounceTween = null;
			}
			this.m_BounceTween = new larTween(this,"m_CurrBounce",Linear.easeNone,this.m_BounceAmount,0,this.bounceTime * this.m_BounceAmount / 1000,this.bounceRight,null,this.bounceInterval);
			this.m_BounceTween.onUpdate = this.bounceButtonHint;
		}
		
		private function bounceRight() : *
		{
			if(this.m_BounceTween)
			{
				this.m_BounceTween.stop();
				this.m_BounceTween = null;
			}
			this.m_BounceTween = new larTween(this,"m_CurrBounce",Linear.easeNone,0,this.m_BounceAmount,this.bounceTime * this.m_BounceAmount / 1000,this.bounceLeft,null,this.bounceInterval);
			this.m_BounceTween.onUpdate = this.bounceButtonHint;
		}
		
		private function bounceButtonHint() : *
		{
			this.scrollRect = new Rectangle(this.m_CurrBounce,-this.height / 2,this.buttonhintFrameWidth,this.height);
		}
		
		private function recalculateButtonsWidth() : *
		{
			var _loc4_:* = undefined;
			var _loc5_:* = undefined;
			var _loc1_:int = content_array.length;
			var _loc2_:int = Math.ceil((this.containerMaxWidth - (_loc1_ - 1) * EL_SPACING) / _loc1_);
			var _loc3_:int = 0;
			for each(_loc4_ in content_array)
			{
				_loc3_ = _loc3_ + _loc4_.getTextWidth();
			}
			if(this.containerMaxWidth - _loc3_ > 0)
			{
				_loc2_ = _loc2_ + Math.ceil((this.containerMaxWidth - _loc3_) / _loc1_);
			}
			for each(_loc5_ in content_array)
			{
				_loc5_.setBtnHint(_loc5_.text_txt.htmlText,_loc5_.iconId,_loc2_,_loc5_.btnEnabled);
			}
			positionElements();
		}
	}
}
