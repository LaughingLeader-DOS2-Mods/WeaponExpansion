package
{
	import LS_Classes.larHealthbar;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import LS_Classes.tooltipHelper;

	public dynamic class MasteryBar extends larHealthbar
	{
		public var node_rank1:MovieClip;
		public var node_rank2:MovieClip;
		public var node_rank3:MovieClip;
		public var node_rank4:MovieClip;

		public var barBG_mc:MovieClip;

		//public var nodes:Array.<MovieClip>;
		public var nodes:Array;

		public function MasteryBar()
		{
			super();
			addFrameScript(0,this.frame1);

			//nodes = new <MovieClip>[node_rank1,node_rank2,node_rank3,node_rank4,];
			nodes = new Array();
		}

		function frame1() : *
		{
			stop();
		}

		public function setRankTooltipText(rank:int, text:String) : *
		{
			var node:MovieClip = this.nodes[rank-1];
			if (node != null)
			{
				node.tooltip = text;
			}
		}

		public function createRankNodes(currentRank:int, maxRank:int) : *
		{
			var maxWidth:Number = this.barBG_mc.width;
			var startX:Number = this.barBG_mc.x;

			var i:int = 0;
			var max:int = nodes.length - 1;
			while (i < maxRank)
			{
				var node:MasteryBarRankNode = null;

				if (i < maxRank-1)
				{
					node = new MasteryBarRankNode();
					addChild(node);
					nodes.push(node);
				}
				else
				{
					node = new MasteryBarRankNodeEnd();
					addChild(node);
					nodes.push(node);
				}

				node.y = 8.0;

				if (i < maxRank-1)
				{
					var nodeBarPercentage:Number = Registry.RankNodePositions[i+1];
					node.x = (startX + (maxWidth * nodeBarPercentage));
				}
				else
				{
					node.x = (startX + maxWidth);
				}

				if (currentRank > 0)
				{
					node.setUnlocked(currentRank >= i+1);
				}
				else
				{
					node.setUnlocked(false);
				}
				i = i + 1;
			}
		}

		public function positionRankNodes(targetRank:int) : *
		{
			var maxWidth:Number = this.barBG_mc.width;
			var startX:Number = this.barBG_mc.x;

			var i:int = 0;
			var max:int = nodes.length - 1;
			while (i < nodes.length)
			{
				var node:MovieClip = this.nodes[i];
				if (node != null)
				{
					if (i < max)
					{
						var nodeBarPercentage:Number = Registry.RankNodePositions[i+1];
						node.x = (startX + (maxWidth * nodeBarPercentage));
					}
					else
					{
						node.x = (startX + maxWidth);
					}

					node.y = 8.0;
					
					if (targetRank > 0)
					{
						node.setUnlocked(targetRank >= i+1);
					}
					else
					{
						node.setUnlocked(false);
					}
				}
				
				i = i + 1;
			}
		}
	}
}