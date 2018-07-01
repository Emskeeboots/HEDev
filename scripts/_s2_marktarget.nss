//::///////////////////////////////////////////////
//:: _s2_marktarget
//:://////////////////////////////////////////////
/*
    This spell is used by a familiar's "mark target" feat.



*/
//:://////////////////////////////////////////////
//:: Created:   The Magus (2013 jan 23)
//:: Modified:
//:://////////////////////////////////////////////

#include "_inc_constants"

#include "_inc_pets"
#include "_inc_util"

void MoveToFocus(location lTarget, object oTarget);

void TakeFocus(location lTarget, object oTarget);

int GetCreatureFocus(object oTarget);

void MoveToFocus(location lTarget, object oTarget)
{
    ClearAllActions();
    if(oTarget!=OBJECT_INVALID)
        ActionMoveToObject(oTarget, TRUE, 2.0);
    else
        ActionMoveToLocation(lTarget,TRUE);

    ActionDoCommand(TakeFocus(lTarget, oTarget));
}

void TakeFocus(location lTarget, object oTarget)
{
    ActionPlayAnimation(ANIMATION_LOOPING_GET_MID, 1.0, 1.5);
    object oArea    = GetAreaFromLocation(lTarget);

    // determine type of focus: creature or location
    if(GetObjectType(oTarget)==OBJECT_TYPE_CREATURE)
    {
        if(GetCreatureFocus(oTarget))
        {
            DelayCommand(   1.5,
                            SendMessageToPC(OBJECT_SELF, DMBLUE+"Target "+PALEBLUE+GetName(oTarget)+DMBLUE+" marked.")
                        );

            // typically only one focus at a time for a familiar
            if(GetIsPossessedFamiliar(OBJECT_SELF))
                FamiliarDestroyExtraSpellFocus();

            object oFocus;
            if(!GetIsPC(oTarget))
            {
                oFocus   = CreateItemOnObject(SPELLFOCUS_RESREF, OBJECT_SELF, 1, GetSpellFocusTag(2,lTarget,oTarget));
                SetLocalInt(oFocus, SPELLFOCUS_TYPE, 2);    // NPC
                SetLocalObject(oFocus, SPELLFOCUS_CREATURE, oTarget);

                // We are flagging this because:
                // getting an NPC object wouldn't work for a module played across server resets,
                // since NPCs change their object ID with each server reset
                // restoring from saved game however does work
                SetLocalInt(oFocus, SPELLFOCUS_SINGLEPPLAYER_ONLY, TRUE);
            }
            else
            {
                oFocus   = CreateItemOnObject(SPELLFOCUS_RESREF, OBJECT_SELF, 1, GetSpellFocusTag(3,lTarget,oTarget));
                SetLocalInt(oFocus, SPELLFOCUS_TYPE, 3);    // PC
                SetLocalString(oFocus, SPELLFOCUS_CREATURE, GetPCID(oTarget));
            }

            SetName(oFocus, "Spell Focus("+GetName(oTarget)+")");
        }
        else
            SendMessageToPC(OBJECT_SELF, RED+"Fail: You were unable to harvest a spell focus for "+GetName(oTarget)+".");

    }
    else if(GetIsObjectValid(oArea))
    {

        DelayCommand(   1.5,
                        SendMessageToPC(OBJECT_SELF, DMBLUE+"Target location in "+PALEBLUE+GetName(oArea)+DMBLUE+" marked.")
                    );

        // typically only one focus at a time for a familiar
        if(GetIsPossessedFamiliar(OBJECT_SELF))
            FamiliarDestroyExtraSpellFocus();

        object oFocus       = CreateItemOnObject(SPELLFOCUS_RESREF, OBJECT_SELF, 1, GetSpellFocusTag(1,lTarget));
        SetLocalInt(oFocus, SPELLFOCUS_TYPE, 1);

        StoreSpellFocusLocation(oFocus, lTarget);

        SetName(oFocus, "Spell Focus("+GetName(GetAreaFromLocation(lTarget))+")");
    }
    else
        SendMessageToPC(OBJECT_SELF, RED+"Fail: You were unable to harvest a spell focus for this target.");
}

int GetCreatureFocus(object oTarget)
{
    int bSuccess, bHostile;
    // indicate touch attack
    string sObj = ObjectToString(OBJECT_SELF);
    int bSeen   = GetObjectSeen(OBJECT_SELF, oTarget); // does the target perceive the familiar
    int nGrab   = GetLocalInt(oTarget, sObj+"GATHER_FOCUS_ATTEMPTS");

    if(bSeen)
    {
        nGrab++;

        // smart creatures will figure it out more quickly
        int nIntMod = GetAbilityModifier(ABILITY_INTELLIGENCE,oTarget);
        if(nIntMod>0)
        {
            if(!GetIsPC(oTarget))
            {
                PlayVoiceChat(VOICE_CHAT_GATTACK1,oTarget);
                TurnToFaceObject(OBJECT_SELF, oTarget);
                AssignCommand(oTarget, PlayAnimation(ANIMATION_FIREFORGET_TAUNT));
            }
            if(nGrab>1)
                bHostile    = TRUE;
        }
        else if(nGrab>(abs(nIntMod)))
        {
            if(!GetIsPC(oTarget))
            {
                PlayVoiceChat(VOICE_CHAT_GATTACK2,oTarget);
                TurnToFaceObject(OBJECT_SELF, oTarget);
                AssignCommand(oTarget, PlayAnimation(ANIMATION_FIREFORGET_TAUNT));
            }
            if(nGrab>(abs(nIntMod)+1))
                bHostile    = TRUE;
        }

        SetLocalInt(oTarget, sObj+"GATHER_FOCUS_ATTEMPTS", nGrab);
    }


    if( TouchAttackMelee(oTarget, TRUE) )
    {
        if( bSeen )
        {
            int nSpellcraftRank = GetSkillRank(SKILL_SPELLCRAFT,oTarget);
            if(nSpellcraftRank && (d20()+nSpellcraftRank)>15)
                bHostile    = TRUE;

            if(GetIsPC(oTarget))
                SendMessageToPC(oTarget,PINK+GetName(OBJECT_SELF)+" takes a hair from you.");
            else
            {
                PlayVoiceChat(VOICE_CHAT_GATTACK3,oTarget);
                TurnToFaceObject(OBJECT_SELF, oTarget);
                AssignCommand(oTarget, PlayAnimation(ANIMATION_FIREFORGET_TAUNT));
            }
        }

        bSuccess    = TRUE;
    }
    else
    {
        // miss - considered ineffectual
        bSuccess    = FALSE;
    }
    SignalEvent( oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_MARK_TARGET, bHostile));
    return bSuccess;
}

void main()
{
    object oTarget      = GetSpellTargetObject(); // creature or item
    location lTarget    = GetSpellTargetLocation();

    SetFacingPoint(GetPositionFromLocation(lTarget));

    if(GetDistanceBetweenLocations(GetLocation(OBJECT_SELF),lTarget)>2.0)
        ActionDoCommand( MoveToFocus(lTarget, oTarget) );
    else
        ActionDoCommand( TakeFocus(lTarget, oTarget) );
}
