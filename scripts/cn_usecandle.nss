void main()
{
    // Handle activation and deactivation
    string sCandleState = "STATE";
    string sCandleStateCorrect = "CORRECT";

    if (GetLocalInt(OBJECT_SELF, "STATE") == 1)
    {
        AssignCommand(OBJECT_SELF, ActionPlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE));
        SetLocalInt(OBJECT_SELF, "STATE", 0);
    }
    else
    {
        AssignCommand(OBJECT_SELF, ActionPlayAnimation(ANIMATION_PLACEABLE_ACTIVATE));
        SetLocalInt(OBJECT_SELF, "STATE", 1);
    }


    // Handle door
    string sDoorTagRef = "cn_pzldoor001";
    object oDoor = GetObjectByTag(sDoorTagRef);

    // Handle checking candles
    int i = 0;
    object oCandle = GetObjectByTag(GetTag(OBJECT_SELF), i);
    while (GetIsObjectValid(oCandle))
    {
        i++;

        if (GetLocalInt(oCandle, sCandleState) == GetLocalInt(oCandle, sCandleStateCorrect))
        {
            // Candle correct, continue
            if (i >= 12)
            {
                if (GetLocked(oDoor))
                {
                    DelayCommand(2.0, ExecuteScript("cn_pzldoor001", OBJECT_SELF));
                }
            }

            // On to the next candle
            oCandle = GetObjectByTag(GetTag(OBJECT_SELF), i);
        }

        else
        {
            // One of the candles was incorrect, break loop
            return;
        }
    }

}
