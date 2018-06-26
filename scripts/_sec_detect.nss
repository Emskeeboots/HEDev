//::///////////////////////////////////////////////
//:: _sec_detect
//:://////////////////////////////////////////////
/*
    Use: OnEnter event of a trigger

Local String
    SECRET_DOOR  resref of placeable to use for secret door
    SECRET_DOOR_PAIRED tag of detect trigger at destination (if supplied, both doors will be found when one is used)

Local Int
    SECRET          a flag indicating that this object is SECRET
    SECRET_NATURE   a flag indicating that this is a natural resource easily identified by a druidand others with wildcraft
    SECRET_SKILL    index of the skill used in detection
    SECRET_SKILL_DC challenge rating for detection

Local Float
    SECRET_RESET    seconds until the item resets. If 1.0 or less, no reset.

Secret Doors can be locked
    SECRET_LOCK              - int  locked/unlocked
    SECRET_LOCK_DC           - difficulty to pick lock
    SECRET_LOCK_KEY          - string  key tag
    SECRET_LOCK_KEY_REQUIRED - int yes/no
*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2014 jan 30)
//:: Modified:
//:://////////////////////////////////////////////


#include "x0_i0_secret"

void main()
{
    object oEntered     = GetEnteringObject();
    SetLocalInt(    OBJECT_SELF,
                    "PC_COUNT",
                    GetLocalInt(OBJECT_SELF,"PC_COUNT")+1
               );

    // if using an AOE
    object oTarget  = GetLocalObject(OBJECT_SELF,"SECRET_AOE_TARGET");
    if(!GetIsObjectValid(oTarget))
        oTarget=OBJECT_SELF;

    if (GetIsSecretItemRevealed()) {return;}


    int bSuccess;
    // nature secrets do not require checks for certain classes.................
    if(     GetLocalInt(oTarget,"SECRET_NATURE")
        &&(     GetLevelByClass(CLASS_TYPE_DRUID,oEntered)
            ||( GetLevelByClass(CLASS_TYPE_RANGER,oEntered)&&GetHasSpellEffect(SPELL_ONE_WITH_THE_LAND,oEntered) )
          )
      )
    {
        SetLocalInt(oEntered, sFoundPrefix+ObjectToString(oTarget), TRUE);
        string sMsg = GetLocalString(oTarget, "SECRET_DISCOVERY_MESSAGE");
        SendMessageToPC(oEntered, DoColorize("("+GetName(oTarget)+") "+sMsg, TRUE));
        bSuccess    = TRUE;
    }
    // typical detect mode response.............................................
    else if(    GetDetectMode(oEntered)==DETECT_MODE_ACTIVE
            &&  SecretGetCreatureDetects(oEntered,oTarget)
           )
    {
        bSuccess    = TRUE;
    }


    if(bSuccess)
    {
        SetLocalObject(oTarget,"SECRET_DETECTOR",oEntered);
        SignalEvent(oTarget, EventUserDefined(EVENT_SECRET_DETECTED));
    }
}
