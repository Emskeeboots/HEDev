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
        while (GetIsObjectValid(oCandle))
        {
            AssignCommand(oCandle, ActionPlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE));
            SetLocalInt(oCandle, sCandleState, 0);

            i++; // Next instance
            oCandle = GetObjectByTag("cn_candle", i); // And get it
        }
    SetLocked(oDoor, FALSE);
    AssignCommand(oDoor, ActionPlayAnimation(ANIMATION_DOOR_OPEN1));
    AssignCommand(oDoor, SpeakString("The door opens and draws the light from candles."));
    DelayCommand(120.0, ResetDoor(oDoor));

}
