package desc
{
	import flash.text.TextField;
	import flash.display.MovieClip;
	
	public dynamic class DescriptionText extends MovieClip
	{
		public var content_txt:TextField;

		public function DescriptionText()
		{
			super();
		}

		public function setText(text:String):*
		{
			content_txt.htmlText = text;
			content_txt.height = content_txt.textHeight;
		}
	}
}