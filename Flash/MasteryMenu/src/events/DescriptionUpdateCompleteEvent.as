package events
{
	import flash.events.Event;

	public class DescriptionUpdateCompleteEvent extends Event
	{
		public static const ID:String = "DescriptionUpdateComplete";
		public var totalMasteryBonuses:uint = 0;
		public var totalDisabledBonuses:uint = 0;
		public var totalEnabledBonuses:uint = 0;

		public function DescriptionUpdateCompleteEvent(bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(ID, bubbles, cancelable);
		}
	}
}