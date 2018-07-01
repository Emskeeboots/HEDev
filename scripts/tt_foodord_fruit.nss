void main()
{
    int nActive = GetLocalInt (OBJECT_SELF,"order_fruit");
    object oArea = OBJECT_SELF;


if (nActive == 0)
{
    object oPC = GetPCSpeaker();
    if (GetGold(oPC) >= 100)
        {
        int iVFX        = GetLocalInt(OBJECT_SELF,"food_vfx");

        AssignCommand(oPC, TakeGoldFromCreature(100, oPC, TRUE));


        string sFoodLoc1  = GetLocalString(OBJECT_SELF,"food_location_1"); //Wine 1
        string sFoodLoc2  = GetLocalString(OBJECT_SELF,"food_location_2"); //Wine 2
        string sFoodLoc3  = GetLocalString(OBJECT_SELF,"food_location_3"); //Stew 1
        string sFoodLoc4  = GetLocalString(OBJECT_SELF,"food_location_4"); //Stew 2
        string sFoodLoc5  = GetLocalString(OBJECT_SELF,"food_location_5"); //Pheasant
        string sFoodLoc6  = GetLocalString(OBJECT_SELF,"food_location_6"); //Fruits
        string sFoodLoc7  = GetLocalString(OBJECT_SELF,"food_location_7"); //Cheese
        string sFoodLoc8  = GetLocalString(OBJECT_SELF,"food_location_8"); //Bread
        string sFoodLoc9  = GetLocalString(OBJECT_SELF,"food_location_9"); //Ale 1
        string sFoodLoc10  = GetLocalString(OBJECT_SELF,"food_location_10"); //Ale 2

        string sFoodSpawn1 = GetLocalString(OBJECT_SELF,"food_resref_1"); //Wine
        string sFoodSpawn2 = GetLocalString(OBJECT_SELF,"food_resref_2"); //Stew
        string sFoodSpawn3 = GetLocalString(OBJECT_SELF,"food_resref_3"); //Bread
        string sFoodSpawn4 = GetLocalString(OBJECT_SELF,"food_resref_4"); //Cheese
        string sFoodSpawn5 = GetLocalString(OBJECT_SELF,"food_resref_5"); //Ale
        string sFoodSpawn6 = GetLocalString(OBJECT_SELF,"food_resref_6"); //Fruit
        string sFoodSpawn7 = GetLocalString(OBJECT_SELF,"food_resref_7"); //Pheasant

        location lTarget1;
        location lTarget2;
        location lTarget3;
        location lTarget4;
        location lTarget5;
        location lTarget6;
        location lTarget7;
        location lTarget8;
        location lTarget9;
        location lTarget10;

        lTarget1 = GetLocation(GetObjectByTag(sFoodLoc1));
        lTarget2 = GetLocation(GetObjectByTag(sFoodLoc2));
        lTarget3 = GetLocation(GetObjectByTag(sFoodLoc3));
        lTarget4 = GetLocation(GetObjectByTag(sFoodLoc4));
        lTarget5 = GetLocation(GetObjectByTag(sFoodLoc5));
        lTarget6 = GetLocation(GetObjectByTag(sFoodLoc6));
        lTarget7 = GetLocation(GetObjectByTag(sFoodLoc7));
        lTarget8 = GetLocation(GetObjectByTag(sFoodLoc8));
        lTarget9 = GetLocation(GetObjectByTag(sFoodLoc9));
        lTarget10 = GetLocation(GetObjectByTag(sFoodLoc10));

        CreateObject(OBJECT_TYPE_PLACEABLE,sFoodSpawn6,lTarget6,TRUE);
//        CreateObject(OBJECT_TYPE_PLACEABLE,sFoodSpawn2,lTarget2,TRUE);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(iVFX),lTarget1);
//        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(iVFX),lTarget2);
        }
    else
        {
        object oPC = GetLastUsedBy();
        SendMessageToPC(oPC, "No gold no food!");
        }
    SetLocalInt(OBJECT_SELF,"order_fruit", 1);
    DelayCommand(2400.0, SetLocalInt(OBJECT_SELF, "order_fruit", 0));
    object oObject = GetFirstObjectInArea(oArea);
        while(GetIsObjectValid(oObject))
            {
             // Destroy any objects tagged "DESTROY"
             if(GetTag(oObject) == "tt_foods")
             {
                 DelayCommand(2400.0, DestroyObject(oObject));
             }
                 oObject = GetNextObjectInArea(oArea);
            }




 /*
    DelayCommand(20.0, SetLocalInt(OBJECT_SELF, "order_wine", 0));
//  DelayCommand(20.0, DestroyObject(OBJECT_TYPE_PLACEABLE, sFoodSpawn1));

    object oTarget;
    oTarget = GetNearestObjectByTag("CODI_CUP_6");
    DelayCommand(20.0, DestroyObject(oTarget, 0.0));
    DelayCommand(20.0, DestroyObject(oTarget, 0.0));

*/

}
else if (nActive == 1)
{
object oPC = GetLastUsedBy();
SendMessageToPC(oPC, "You have already ordered this!");

}
}




   /*



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

*/
