
//wraith death - check the tag of the dieing monster against the bosses in question.
//Check distance between tomb tag and dieing object, and play the required animation & set variables accordingly.
void WraithDeath(int nMaxDist);

//Checks to see if the door variable has changed... If it hasn't after 1 minute, we reset it to 0
//void CheckDoorStatus(object oDoor, int nValue);




/*
void CheckDoorStatus(object oDoor, int nValue)
{
    if(GetLocalInt(oDoor, "wraith_count")==nValue){
        SetLocalInt(oDoor, "wraith_count", 0);
        AssignCommand(oDoor, ActionCloseDoor(oDoor));
    }
}
*/
void WraithDeath(int nMaxDist)
{
    //get dieing object.
    object oSelf = OBJECT_SELF;
    string sTag = GetTag(oSelf);

    //Check which wraith has died.
    object oTomb;
    //Grab set our tomb based on said tag.
    if(sTag == "Brc_bossWRAITHranged")
    {
        oTomb = GetNearestObjectByTag("tomb_gray");
    }
    else if(sTag == "Brc_bossWRAITH")
    {
        oTomb = GetNearestObjectByTag("tomb_black");
    }
    else if(sTag == "Brc_bossWRAITHmelee")
    {
        oTomb = GetNearestObjectByTag("tomb_white");
    }

    //Get distance as an integet
    int nDist = FloatToInt(GetDistanceBetween(OBJECT_SELF, oTomb));

    //If they are inside their area, we want to play the VFX and set the door variable.
    if(nDist <= nMaxDist)
    {
        //Do death effect
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(GetLocalInt(oSelf, "death_vfx")), GetLocation(oSelf));

        //Grab the door
        object oDoor = GetNearestObjectByTag("tt_cryptbossdoor");
        //Increment the variable on the door
        SetLocalInt(oDoor, "wraith_count", GetLocalInt(oDoor, "wraith_count")+1);
//        DelayCommand(15.0, CheckDoorStatus(oDoor, GetLocalInt(oDoor, "wraith_count")));
        //If it's 3, open the door and set the door to
        if(GetLocalInt(oDoor, "wraith_count")==3)
        {
            AssignCommand(oDoor, ActionOpenDoor(oDoor));
        }
    }
    else
    {

    }
}
