//::///////////////////////////////////////////////
//:: _door_userdef
//:://////////////////////////////////////////////
/*
    intended for use in a doors userdef
*/
//:://////////////////////////////////////////////
//:: Created By: henesua (2016 jan 5)
//:: Modified:
//:://////////////////////////////////////////////



void main()
{
    int nUser       = GetUserDefinedEventNumber();

    if(nUser == EVENT_HEARTBEAT ) //HEARTBEAT
    {

    }
    else if(nUser == EVENT_DIALOGUE) // ON DIALOGUE
    {
        // Initialize Event Vars
        object oShouter = GetLocalObject(OBJECT_SELF, "USERD_LAST_SHOUTER");
        int nMatch      = GetLocalInt(OBJECT_SELF, "USERD_LISTEN_PATTERN_NUMBER");

        // Garbage Collection
        DeleteLocalObject(OBJECT_SELF, "USERD_LAST_SHOUTER");
        DeleteLocalInt(OBJECT_SELF, "USERD_LISTEN_PATTERN_NUMBER");
    }
    else if(nUser == EVENT_ATTACKED) // ATTACKED
    {
        // Initialize Event Vars
        object oAttacker= GetLocalObject(OBJECT_SELF, "USERD_ATTACKER");

        // Garbage Collection
        DeleteLocalObject(OBJECT_SELF, "USERD_ATTACKER");
    }
    else if(nUser == EVENT_SPELL_CAST_AT) // SPELL CAST AT
    {
        // Initialize Event Vars
        int nSpellID    = GetLocalInt(OBJECT_SELF, "USERD_LASTSPELL");
        object oCaster  = GetLocalObject(OBJECT_SELF, "USERD_LASTSPELL_CASTER");
        int bHarmful    = GetLocalInt(OBJECT_SELF, "USERD_LASTSPELL_HARMFUL");

        // Garbage Collection
        DeleteLocalInt(OBJECT_SELF, "USERD_LASTSPELL");
        DeleteLocalObject(OBJECT_SELF, "USERD_LASTSPELL_CASTER");
        DeleteLocalInt(OBJECT_SELF, "USERD_LASTSPELL_HARMFUL");
    }
    else if(nUser == EVENT_DAMAGED) // DAMAGED
    {
        // Initialize Event Vars
        object oDamager = GetLocalObject(OBJECT_SELF, "USERD_DAMAGER");
        int nDamage     = GetLocalInt(OBJECT_SELF, "USERD_DAMAGE");

        // Garbage Collection
        DeleteLocalObject(OBJECT_SELF, "USERD_DAMAGER");
        DeleteLocalInt(OBJECT_SELF, "USERD_DAMAGE");
    }
    else if(nUser == EVENT_DISTURBED) // DISTURBED
    {
        // Initialize Event Vars
        object oDisturbed   = GetLocalObject(OBJECT_SELF, "USERD_LAST_DISTURBED");

        // Garbage Collection
        DeleteLocalObject(OBJECT_SELF, "USERD_LAST_DISTURBED");
    }

}
