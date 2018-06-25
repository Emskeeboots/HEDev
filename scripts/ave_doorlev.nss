//Written by Ave
//Set a local string named ave_lev_door on the placeable. The value inside that
//field should be the tag of the door. This causes the placeable to lock/unlock the door
void main()
{
    object oLever=OBJECT_SELF;
    object oDoor=GetObjectByTag(GetLocalString(oLever,"ave_lev_door"));
    if(GetLocked(oDoor))
    {
        DelayCommand(0.0,SetLocked(oDoor,FALSE));
    }
    else
    {
        SetLocked(oDoor,TRUE);
    }
}
