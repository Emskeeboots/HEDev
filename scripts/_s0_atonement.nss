//::///////////////////////////////////////////////
//:: _s0_atonement
//:://////////////////////////////////////////////
/*
    Atonement

    Caster must have 500 XP to spare
    Caster and target must share religion
        - Get Deity index for caster
        - Get Deity Index of target

    Determine what the target is atoning for? handle in conversation

    Monk    - Might need atonement if advancement is blocked.
    Paladin - only changes to lawful good - must follow specific religions
    Cleric  -
    Druid   - must be Nature
    Ranger  - can be any religion, but need not atone

    Need to know class of target
    Need to know alignment of Caster

    Target gets choice in dialog

*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2013 sept 17)
//:: Modified:
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"

#include "_inc_spells"
#include "_inc_xp"
#include "_inc_deity"



void main()
{
    if ( !GetIsObjectValid(OBJECT_SELF) )
    {
        WriteTimestampedLogEntry("ERR: _s0_atonement - invalid caster");
        return;
    }

    // Spellcast Hook Code Added 2003-06-23 by GeorgZ
    // check x2_inc_spellhook.nss to find out more
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
    if (!X2PreSpellCastCode()){return;}

    //Declare major variables
    spellsDeclareMajorVariables();

    // even if the spell fails on grounds of religious incompatibilty... lets signal the event
    SignalEvent(spell.Target, EventSpellCastAt(OBJECT_SELF, SPELL_ATONEMENT, FALSE));

    int nDeityCaster    = GetDeityIndex(OBJECT_SELF);
    int nDeityTarget    = GetDeityIndex(spell.Target);
    int nParentCaster   = GetDeityParent(nDeityCaster);
    int nParentTarget   = GetDeityParent(nDeityTarget);
    int bRelClass       = GetHasReligiousClass(spell.Target);

    if(     nDeityCaster==nDeityTarget
        ||  (!bRelClass && nParentCaster==nParentTarget)
      )
    {
        // Two cases result in a successful casting:
        // religions of target and caster are the same
        // or target shares parent religion with the caster, but is a non-religious class so this doesn't matter anyway...
    }
    else if (nDeityCaster!=nDeityTarget)
    {
        // Spell fails.
        SendMessageToPC(OBJECT_SELF, RED+"SPELL FAILURE! "+GetName(spell.Target)+" does not share your beliefs.");
        return;
    }

    int nXPCost     = 500;
    int nNewXP      = GetXP(OBJECT_SELF) - nXPCost;
    int nShort      = XPGetPCNeedsToLevel(OBJECT_SELF, FALSE)-nNewXP;
    if(nShort<0 || nNewXP<0)
    {
        // Spell fails.
        SendMessageToPC(OBJECT_SELF, RED+"SPELL FAILURE! This spell costs 500XP which you can not spare.");
        return;
    }

    if(     GetLocalInt(spell.Target, "IN_CONV")
        ||  IsInConversation(spell.Target)
      )
    {
        SendMessageToPC(OBJECT_SELF, " ");
        SendMessageToPC(OBJECT_SELF, PINK+GetName(spell.Target)+" is presently occupied. Try later.");
        return;
    }

    if(GetIsPC(spell.Target))
    {
        SetLocalObject(spell.Target,"ATONEMENT_CASTER",OBJECT_SELF);

        // Initialize Conversation
        string sDialog  = "_dlg_atone";
        int nGreet      = FALSE;
        int nPrivate    = FALSE;
        int nZoom       = TRUE;

        StartDlg( OBJECT_SELF, OBJECT_SELF, sDialog, nPrivate, nGreet, nZoom);
    }
    else
    {
        // NPC targeted... what to do?
        SendMessageToPC(OBJECT_SELF, " ");
        SendMessageToPC(OBJECT_SELF, RED+"FAILED: Only player characters may be atoned (until we expand this feature).");
    }
}
