void ResetDoor(object oDoor)
{
AssignCommand(oDoor, ActionPlayAnimation(ANIMATION_DOOR_CLOSE));
SetLocked(oDoor, TRUE);
}

void main()
{
    string sCandleState = "STATE";
    object oDoor = GetObjectByTag("cn_pzldoor001");
    int i = 0; // First instance
    object oCandle = GetObjectByTag("cn_candle", i);

    AssignCommand(OBJECT_SELF, ActionPlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE));
    AssignCommand(OBJECT_SELF, ActionPlayAnimation(ANIMATION_PLACEABLE_ACTIVATE));

    if (GetLocked(oDoor))
    {
        while (GetIsObjectValid(oCandle))
        {
            AssignCommand(oCandle, ActionPlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE));
            SetLocalInt(oCandle, sCandleState, 0);

            i++; // Next instance
            oCandle = GetObjectByTag("cn_candle", i); // And get it
        }


    AssignCommand(OBJECT_SELF, ActionPlayAnimation(ANIMATION_PLACEABLE_ACTIVATE));
    SetLocked(oDoor, FALSE);
    AssignCommand(oDoor, ActionPlayAnimation(ANIMATION_DOOR_OPEN1));
    AssignCommand(oDoor, SpeakString("The door opens and draws any light from candles."));
    DelayCommand(30.0, ResetDoor(oDoor));
    }

    else
    {
    AssignCommand(OBJECT_SELF, SpeakString("Pulling the lever seems to result in nothing."));
    }

}
