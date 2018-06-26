/*
 void main()
{
    object oPlayer = GetLastUsedBy ();
    object oChair;
    if (GetIsPC (oPlayer))
    {
        oChair = GetNearestObjectByTag ("Chair", oPlayer, 0);
        if (GetIsObjectValid(oChair) && !GetIsObjectValid (GetSittingCreature (oChair)))
        {
            AssignCommand (oPlayer, ActionSit (oChair));
        }
    }
}

*/

void main()
{
    if (! GetIsObjectValid(GetSittingCreature(OBJECT_SELF)))
    {
        object oSelf = OBJECT_SELF;

        AssignCommand(GetLastUsedBy(), ActionSit(oSelf));
    }
}

