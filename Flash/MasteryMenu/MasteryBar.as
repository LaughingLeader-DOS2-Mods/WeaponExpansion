package
{
	import LS_Classes.larHealthbar;
	import flash.display.MovieClip;
	import masteryMenu.MainTimeline;
	
	public dynamic class MasteryBar extends larHealthbar
	{
		public var node_rank1:MovieClip;
		public var node_rank2:MovieClip;
		public var node_rank3:MovieClip;
		public var node_rank4:MovieClip;

		public var barBG_mc:MovieClip;

		public function MasteryBar()
		{
			super();
			addFrameScript(0,this.frame1);
		}

		function frame1() : *
		{
			this.stop();
		}

		public function setupRankNodes(targetRank:uint, rank1Text:String, rank2Text:String, rank3Text:String, rank4Text:String) : *
		{
			this.node_rank1.setTooltip(rank1Text);
			this.node_rank2.setTooltip(rank2Text);
			this.node_rank3.setTooltip(rank3Text);
			this.node_rank4.setTooltip(rank4Text);

			var maxWidth:Number = this.barBG_mc.width;
			var startX:Number = this.barBG_mc.x;

			this.node_rank1.x = (startX + (maxWidth * MainTimeline.rankNodePositions[1]));
			this.node_rank2.x = (startX + (maxWidth * MainTimeline.rankNodePositions[2]));
			this.node_rank3.x = (startX + (maxWidth * MainTimeline.rankNodePositions[3]));
			this.node_rank4.x = (startX + maxWidth);

			//trace(this.node_rank1.x, this.node_rank2.x, this.node_rank3.x, this.node_rank4.x);
			//trace(startX, maxWidth);
			//trace(MainTimeline.rankNodePositions[1], MainTimeline.rankNodePositions[2], MainTimeline.rankNodePositions[3]);

			if (targetRank > 0)
			{
				this.node_rank1.setUnlocked(targetRank >= 1);
				this.node_rank2.setUnlocked(targetRank >= 2);
				this.node_rank3.setUnlocked(targetRank >= 3);
				this.node_rank4.setUnlocked(targetRank >= 4);
			}
			else
			{
				this.node_rank1.setUnlocked(false);
				this.node_rank2.setUnlocked(false);
				this.node_rank3.setUnlocked(false);
				this.node_rank4.setUnlocked(false);
			}
		}
	}
}