
void main()
{

object oPC = GetLastUsedBy();

if (GetLocalInt(OBJECT_SELF, "firetrap")== 0)

        {
        string sTarTag  = GetLocalString(OBJECT_SELF,"wfire_tag");
        string sVipTag  = GetLocalString(OBJECT_SELF,"spitter_tag");

        object oCaster;
        oCaster = GetObjectByTag(sVipTag);

        //    location lTarget = GetLocation(GetWaypointByTag("wfire_001_dest"));

        location lTarget;
        if(sTarTag!="")
            lTarget     = GetLocation(GetObjectByTag(sTarTag));


        AssignCommand(oCaster, ActionCastSpellAtLocation(SPELL_FIREBALL, lTarget, METAMAGIC_NONE, TRUE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
        SetLocalInt(OBJECT_SELF, "firetrap", 1);
        DelayCommand(5.0, SetLocalInt(OBJECT_SELF, "firetrap", 0));
        }

else if (GetLocalInt(OBJECT_SELF, "firetrap")== 1)

        {
              //SendMessageToPC(oPC, "The flames are recharging!");
              ActionSpeakString("The flames are recharging!");
        }

}



