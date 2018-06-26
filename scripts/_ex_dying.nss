//::///////////////////////////////////////////////
//:: _ex_dying
//:://////////////////////////////////////////////
/*
    Called by Script: _mod_dying

    This script handles bleeding when players are dying.
    Dying is when the character is between 0 and -9 hit points.
    -10 and below is death.

    This bleeding system is a modified version of
        Tom Banjo's tb_mod_ondying

    Thanks to original work by:
        John Hawkins aka Tom_Banjo (April 20, 2005)
*/
//:://////////////////////////////////////////////
//:: Created : henesua (2015 dec 19)
//:://////////////////////////////////////////////

#include "_inc_death"

// GLOBALS
object oKiller  = GetLocalObject(OBJECT_SELF, "KILLER");
float fDelay;

// Declare functions
void CreateBloodstain(string sBlood);
// PC bleeds each round until dead or stabilized
void Bleed();
//Determine if PC stabilizes
int Stabilized();

void CreateBloodstain(string sBlood)
{
    object oBlood = CreateObject(OBJECT_TYPE_PLACEABLE,sBlood,GetLocation(OBJECT_SELF),TRUE);
    DestroyObject(oBlood, fDelay);
}

void Bleed()
{
    effect eEffect;
    effect eViz;

    if ( Stabilized() )
    {
        eEffect = EffectHeal(1);
    }
    else
    {
        eViz    = EffectVisualEffect(VFX_COM_BLOOD_REG_RED);
        eEffect = EffectLinkEffects(eViz,EffectDamage(1, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_ENERGY));
    }

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffect, OBJECT_SELF);
}

int Stabilized()
{
    if ( GetCurrentHitPoints(OBJECT_SELF) <= -10 )
        return FALSE;

    if (GetLocalInt(OBJECT_SELF, "PC_STABILIZED"))
        return TRUE;


    int iDC     = GetLocalInt(OBJECT_SELF, "iPCDC") + 1;
    SetLocalInt(OBJECT_SELF, "iPCDC", iDC);
    int iRoll   = d20();

    if( (iRoll + GetStabilizeBonus(OBJECT_SELF)) >= iDC || iRoll == 20 )
    {

        FloatingTextStringOnCreature(" ", OBJECT_SELF, FALSE);
        FloatingTextStringOnCreature(RED+GetName(OBJECT_SELF)+"'s condition has stabilized.", OBJECT_SELF, FALSE);
        FloatingTextStringOnCreature(" ", OBJECT_SELF, FALSE);

        //DropItems(OBJECT_SELF); //do not drop items when we stabilize
        SetLocalInt(OBJECT_SELF, "PC_STABILIZED", TRUE);
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

void main()
{
    int iStabilize = GetStabilizeBonus(OBJECT_SELF);
    int bStable = GetLocalInt(OBJECT_SELF, "PC_STABILIZED");
    if (bStable) {
        if(iStabilize > 0)
            fDelay = 3.0;   // faster healing
        else if (iStabilize < 0)
            fDelay = 9.0;  // slower healing
        else
            fDelay = 6.0;   // normal healing
    }
    else
    {
        if(iStabilize < 0)
            fDelay = 4.5;   // faster bleeding
        else if (iStabilize > 0)
            fDelay = 9.0;  // slower bleeding
        else
            fDelay = 6.0;   // normal bleeding
    }

    // First we need to check if we've been healed or anything. 
    int iHP = GetCurrentHitPoints(OBJECT_SELF);
    deathDebug("_ex_dying: " + GetName(OBJECT_SELF) + " cur HP = " +IntToString(iHP) + " stable = " + IntToString(bStable));
    if (iHP < 1 && iHP > -10) {
         // Bleed or heal.
         Bleed();
    }

    // Get hitpoints again since they may have been changed by Bleed().
    iHP = GetCurrentHitPoints(OBJECT_SELF);
    string sPC_bloodstain; //resref of bloodstain
    int iVoice; // index of voice chat
    deathDebug("_ex_dying: " + GetName(OBJECT_SELF) + " cur HP now = " +IntToString(iHP) + " stable = " + IntToString(bStable));
    if (iHP<= -10)
    {
        // Dead
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), OBJECT_SELF);
        // Garbage collection

        DeleteLocalInt(OBJECT_SELF, "PC_STABILIZED");
        DeleteLocalInt(OBJECT_SELF, "DYING_WORDS");
        return;
    }
    else if (iHP <=-8)
    {
        iVoice = VOICE_CHAT_NEARDEATH;
        sPC_bloodstain = "bleed5";
    }
    else if (iHP <=-6)
    {
        iVoice = VOICE_CHAT_HEALME;
        sPC_bloodstain = "bleed4";
    }
    else if (iHP <=-4)
    {
        switch (d4())
        {
            case 1:
            iVoice = VOICE_CHAT_PAIN1;
            break;
            case 2:
            iVoice = VOICE_CHAT_PAIN2;
            break;
            case 3:
            iVoice = VOICE_CHAT_PAIN3;
            break;
            case 4:
            iVoice = VOICE_CHAT_HELP;
            break;
            default:
            iVoice = VOICE_CHAT_PAIN3;
            break;
        }
        sPC_bloodstain = "bleed3";
    }
    else if (iHP <=-2)
    {
        switch (d4())
        {
            case 1:
            iVoice = VOICE_CHAT_PAIN1;
            break;
            case 2:
            iVoice = VOICE_CHAT_PAIN2;
            break;
            case 3:
            iVoice = VOICE_CHAT_PAIN3;
            break;
            case 4:
            iVoice = VOICE_CHAT_HEALME;
            break;
            default:
            iVoice = VOICE_CHAT_PAIN2;
            break;
        }
        sPC_bloodstain = "bleed2";
    }
    else if (iHP <=0)
    {
        switch (d4())
        {
            case 1:
            iVoice = VOICE_CHAT_PAIN1;
            break;
            case 2:
            iVoice = VOICE_CHAT_PAIN2;
            break;
            case 3:
            iVoice = VOICE_CHAT_PAIN3;
            break;
            case 4:
            iVoice = VOICE_CHAT_CUSS;
            break;
            default:
            iVoice = VOICE_CHAT_PAIN1;
            break;
        }
        sPC_bloodstain = "bleed1";
    } else {
        // Conscious
        deathDebug("_ex_dying: " + GetName(OBJECT_SELF) + " : regaining conciousness - done bleeding."); 
        SendMessageToPC(OBJECT_SELF, " ");
        SendMessageToPC(OBJECT_SELF, WHITE+"You have regained consciousness.");
        SendMessageToPC(OBJECT_SELF, " ");
        switch (d3())
        {
            case 1:
	    case 2:
            iVoice = VOICE_CHAT_LAUGH;
            break;
            //case 2:
            //iVoice = VOICE_CHAT_HEALME;
            //break;
            case 3:
            iVoice = VOICE_CHAT_CHEER;
            break;
            default:
            iVoice = VOICE_CHAT_LAUGH;
            break;
        }
        PlayVoiceChat(iVoice, OBJECT_SELF);
        // Garbage collection
        DeleteLocalObject(OBJECT_SELF,"KILLER");
        DeleteLocalString(OBJECT_SELF, "KILLER_ID");
        DeleteLocalString(OBJECT_SELF, "KILLER_NAME");
        DeleteLocalInt(OBJECT_SELF, "PC_STABILIZED");
        DeleteLocalInt(OBJECT_SELF, "DYING_WORDS");
	AssignCommand(OBJECT_SELF, ClearAllActions());
	if (!GetCommandable()) {
		deathDebug("_ex_dying: " + GetName(OBJECT_SELF) + " not commandable...");
		//SetCommandable(TRUE);
		//ClearAllActions();
	}
        return;
    }

    if(!GetLocalInt(OBJECT_SELF, "PC_STABILIZED") && !GetLocalInt(OBJECT_SELF, "DYING_WORDS")) {
        PlayVoiceChat(iVoice, OBJECT_SELF);
        SetLocalInt(OBJECT_SELF, "DYING_WORDS", TRUE);
    } else {
        DeleteLocalInt(OBJECT_SELF, "DYING_WORDS");
    }

    DelayCommand(0.1, CreateBloodstain(sPC_bloodstain));
    AssignCommand(OBJECT_SELF, ClearAllActions());
    // Iterate if not yet dead - but only if less that 1 HP still too.
    int nCur = GetCurrentHitPoints(OBJECT_SELF);
    if(nCur > -10 && nCur < 1) {
        deathDebug("_ex_dying: " +GetName(OBJECT_SELF) + " rescheduled for " + FloatToString(fDelay));
        DelayCommand(fDelay, ExecuteScript("_ex_dying", OBJECT_SELF));
    }
}
