package desc
{
	import flash.display.MovieClip;
	
	public dynamic class StatusBackgroundAlt extends MovieClip
	{
		public var LBottom_mc:MovieClip;
		
		public var LTop_mc:MovieClip;
		
		public var RBottom_mc:MovieClip;
		
		public var RTop_mc:MovieClip;
		
		public var bottom_mc:MovieClip;
		
		public var left_mc:MovieClip;
		
		public var mid_mc:MovieClip;
		
		public var right_mc:MovieClip;
		
		public var top_mc:MovieClip;
		
		public function StatusBackgroundAlt()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function setBG(bgWidth:Number, bgHeight:Number) : *
		{
			this.mid_mc.width = this.bottom_mc.width = this.top_mc.width = bgWidth - this.RTop_mc.width - this.LTop_mc.width;
			this.mid_mc.height = this.left_mc.height = this.right_mc.height = bgHeight - this.LTop_mc.height - this.LBottom_mc.height;
			if(this.mid_mc.scaleY < 1)
			{
				this.mid_mc.scaleY = this.left_mc.scaleY = this.right_mc.scaleY = 1;
			}
			if(this.mid_mc.scaleX < 1)
			{
				this.mid_mc.scaleX = this.bottom_mc.scaleX = this.top_mc.scaleX = 1;
			}
			this.RTop_mc.x = this.top_mc.x + this.top_mc.width;
			this.right_mc.x = this.mid_mc.x + this.mid_mc.width;
			this.mid_mc.y = this.left_mc.y = this.right_mc.y = this.LTop_mc.height;
			this.RBottom_mc.x = this.bottom_mc.x + this.bottom_mc.width;
			this.LBottom_mc.y = this.bottom_mc.y = this.RBottom_mc.y = this.mid_mc.height + this.mid_mc.y;
		}
		
		internal function frame1() : *
		{

		}
	}
}
