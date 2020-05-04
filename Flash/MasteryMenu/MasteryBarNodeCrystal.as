package
{
	import flash.display.MovieClip;

	public dynamic class MasteryBarNodeCrystal extends MovieClip
	{

		public function MasteryBarNodeCrystal()
		{
			super();
			addFrameScript(0,this.frame1);
		}

		function frame1() : *
		{
			this.stop();
		}
	}
}