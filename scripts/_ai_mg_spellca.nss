//::///////////////////////////////////////////////
//:: _ai_mg_spellca
//:://////////////////////////////////////////////
/*
    Default AI for magically created creatures
        see: v2_ai_mg_userdef

    On Spell Cast At script

 */
//:://////////////////////////////////////////////
//:: Created: Henesua (2013 sept 21)
//:://////////////////////////////////////////////

#include "nw_i0_generic"

void main()
{
    // Send the user-defined event as appropriate
    if(GetSpawnInCondition(NW_FLAG_SPELL_CAST_AT_EVENT))
    {
        object oCaster  = GetLastSpellCaster();
        int bHarmful    = GetLastSpellHarmful();
        int nSpellID    = GetLastSpell();

        SetLocalInt(OBJECT_SELF, "USERD_LASTSPELL", nSpellID);
        SetLocalObject(OBJECT_SELF, "USERD_LASTSPELL_CASTER", oCaster);
        SetLocalInt(OBJECT_SELF, "USERD_LASTSPELL_HARMFUL", bHarmful);
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_SPELL_CAST_AT));
    }
}
