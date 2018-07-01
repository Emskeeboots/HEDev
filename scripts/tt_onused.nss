
////////////////////////////////////////////////////////////////////////////////
//::
//:: MAGIC LEVER created by ave
//:: rewitten by henesua
/*

    SPAWNING PLACEBLES and CREATURES

    use local variables
    LEVER_SPAWN_WAYPOINT  string    --  tag of a waypoint at which creature and/or placeable and/or vfx happens
                                        if no waypoint is provided, location will be the lever
    LEVER_SPAWN_CREATURE  string    --  creature resref to spawn. if not set. no creature spawns.
    LEVER_SPAWN_PLACEABLE string    --  placeable resref to spawn. if not set. no placeable spawns.
    LEVER_SPAWN_VFX       int       --  index of visualeffects.2da. if 0, no vfx happens.


    ---script execution---
    LEVER_0_DELAY         float     -- seconds delay before script 0 executes
    LEVER_0_SCRIPT        string    -- name of script to execute
    LEVER_0_SPEAK         string    -- string for lever to speak when script executes
    LEVER_1_DELAY         float     -- seconds delay before sscript 1
    LEVER_1_SCRIPT        string    -- name of script to execute
    LEVER_1_SPEAK         string    -- string for lever to speak when script executes
    etc....



*/
////////////////////////////////////////////////////////////////////////////////


void PlaceableActivate()
{
    string sTarTag  = GetLocalString(OBJECT_SELF,"LEVER_SPAWN_WAYPOINT");
    string sBP      = GetLocalString(OBJECT_SELF,"LEVER_SPAWN_CREATURE");
    string sOP      = GetLocalString(OBJECT_SELF,"LEVER_SPAWN_PLACEABLE");
    int iVFX        = GetLocalInt(OBJECT_SELF,"LEVER_SPAWN_VFX");

    location lTarget;
    if(sTarTag!="")
        lTarget     = GetLocation(GetObjectByTag(sTarTag));
    else
        lTarget     = GetLocation(OBJECT_SELF);

    if(iVFX>0)
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(iVFX),lTarget);
    if(sBP!="")
        SetLocalObject( OBJECT_SELF, "CREATED_CREATURE",
                        CreateObject(OBJECT_TYPE_CREATURE,sBP,lTarget,TRUE)
                      );
    if(sOP!="")
        SetLocalObject( OBJECT_SELF, "CREATED_PLACEABLE",
                        CreateObject(OBJECT_TYPE_PLACEABLE,sOP,lTarget,TRUE)
                      );
    string index, speak_this;
    int nScriptCount; float delay;
    string script_name  = GetLocalString(OBJECT_SELF,"LEVER_0_SCRIPT");
    while(script_name!="")
    {
        index   = IntToString(nScriptCount);
        delay   = GetLocalFloat(OBJECT_SELF,"LEVER_"+index+"_DELAY");

        DelayCommand(   delay, ExecuteScript(script_name,OBJECT_SELF) );

        speak_this = GetLocalString(OBJECT_SELF,"LEVER_"+index+"_SPEAK");
        if(speak_this!="")
            DelayCommand(delay, ActionSpeakString(speak_this) );


        script_name = GetLocalString(OBJECT_SELF,"LEVER_"+IntToString(++nScriptCount)+"_SCRIPT");
    }
}

void PlaceableDeactivate()
{
    DestroyObject(GetLocalObject(OBJECT_SELF, "CREATED_CREATURE"));
    DestroyObject(GetLocalObject(OBJECT_SELF, "CREATED_PLACEABLE"));
}


void main()
{
    object oUser    = GetLastUsedBy();

    int nActive = GetLocalInt (OBJECT_SELF,"X2_L_PLC_ACTIVATED_STATE");
    // * Play Appropriate Animation
    if (!nActive)
    {
        ActionPlayAnimation(ANIMATION_PLACEABLE_ACTIVATE);
        PlaceableActivate();
    }
    else
    {
        ActionPlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE);
        PlaceableDeactivate();
    }
    // * Store New State
    SetLocalInt(OBJECT_SELF,"X2_L_PLC_ACTIVATED_STATE",!nActive);

    SetLocalInt(OBJECT_SELF,"Active",!nActive);

}
