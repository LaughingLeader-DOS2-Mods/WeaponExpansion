package menu.symbols
{
	import flash.display.MovieClip;

	public dynamic class MasteryBarNodeCrystal extends MovieClip
	{

		public function MasteryBarNodeCrystal()
		{
			super();
			addFrameScript(0,this.frame1);
		}

		internal function frame1() : void
		{
			this.stop();
		}
	}
}