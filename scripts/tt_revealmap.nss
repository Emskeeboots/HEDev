void main()
{
   object oPlayer = GetEnteringObject();
   if (GetIsObjectValid(oPlayer) && GetIsPC(oPlayer))
   {
      // As this is firing in the Area's own events, we explore this
      // area's area. GetArea() might not always work, but this is fine anyway
      object oArea = OBJECT_SELF;
      ExploreAreaForPlayer(oArea, oPlayer);
   }
}
