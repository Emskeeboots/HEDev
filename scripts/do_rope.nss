//::///////////////////////////////////////////////
//:: do_rope
//:://////////////////////////////////////////////
/*
    script for using rope
*/
//:://////////////////////////////////////////////
//:: Created By: The Magus (2012 mar 18)
//:: Modified:
//:://////////////////////////////////////////////

#include "x2_inc_switches"

#include "_inc_constants"

object CreateRope(location lLoc, object oDest, string sRef)
{
    // top
    object oRope    = CreateObject(OBJECT_TYPE_PLACEABLE, sRef, lLoc);
    SetLocalObject(oRope, "MOVE_DESTINATION_OBJECT", oDest);
    return oRope;
}

location GetRopeLocation(object oTarget)
{
    float xLoc  = GetLocalFloat(oTarget, "ROPE_X");
    float yLoc  = GetLocalFloat(oTarget, "ROPE_Y");
    float zLoc  = GetLocalFloat(oTarget, "ROPE_Z");

    if(xLoc==0.0 && yLoc==0.0 && zLoc==0.0)
    {
        return GetLocation(oTarget);
    }
    else
    {
        float fLoc  = GetLocalFloat(oTarget, "ROPE_F")+90.0;
        return Location(GetArea(oTarget),Vector(xLoc,yLoc,zLoc),fLoc);
    }
}

void main()
{
 if (GetUserDefinedItemEventNumber() ==X2_ITEM_EVENT_ACTIVATE)
 {
    object oPC      = GetItemActivator();
    int bSuccess;
    object oRope    = GetItemActivated();
    object oTarget  = GetItemActivatedTarget();
    if( GetLocalInt(oTarget, "ROPED") )
    {
        SendMessageToPC(oPC, RED+"The "+GetName(oTarget)+" does not need any more rope." );
        return;
    }
    object oRopeTop, oRopeBottom;
    int nFall, nDC;
    string failMsg;
    string sTag     = GetTag(oTarget);
    int nLen        = GetLocalInt(oRope,"ROPE_LENGTH");
    int nRopeMagic  = GetLocalInt(oRope,"ROPE_MAGIC"); // all magic ropes can be retrieved at bottom
                                                       // if we want different properties, we can store as bit flags in this integer
    int bTop        = GetLocalInt(oTarget,"MOVE_TOP");
    int primeSkill  = GetLocalInt(oTarget,"MOVE_SKILL");
    int bClimb      = GetLocalInt(oTarget,"climb");
    if(!nLen || nLen>=50){nLen  = 15;}

    if( sTag=="sinkhole" || sTag=="hole" )
    {
        object oHole= GetLocalObject(oTarget, "HOLE");
        if(!GetIsObjectValid(oHole))
            oHole = oTarget;
        object oDest= GetWaypointByTag(GetLocalString(oHole, "MOVE_DESTINATION"));
        nFall   = GetLocalInt(oHole, "MOVE_HEIGHT"); // perhaps calculate drop relative to rope length
        // ROPE TOP
        string sRef1= GetLocalString(oHole, "ROPE_REF");
        if(sRef1==""){sRef1="rope_drop";}
        oRopeTop = CreateRope(GetRopeLocation(oHole), oDest, sRef1);

        // ROPE BOTTOM
        if(nFall>nLen)
        {
            SendMessageToPC(oPC, PINK+"The "+GetName(oRope)+" ("+YELLOW+IntToString(nLen)+PINK+" meters) does not appear to reach the bottom.");
        }
        else
        {
            string sRef2= "rope_bottom";
            oRopeBottom  = CreateRope(GetLocation(oDest), oRopeTop, sRef2);
        }
        // PC ACTIONS
        AssignCommand(oPC, ActionMoveToObject(oRopeTop, TRUE));
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW,1.0, 3.0));

        bSuccess   = TRUE;
    }
    else if(bTop)
    {
        // PC ACTIONS
        AssignCommand(oPC, ActionMoveToObject(oTarget, TRUE));
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW,1.0, 3.0));

        string sTagDest = GetLocalString(oTarget, "ROPE_DESTINATION");
               nFall    = GetLocalInt(oTarget, "ROPE_HEIGHT");

        // Climbs down  or Moves which result in falls
        if(primeSkill==1 || GetLocalInt(oTarget,"MOVE_FALL"))
        {
            if(sTagDest=="")
                sTagDest    = GetLocalString(oTarget, "MOVE_DESTINATION");
            if(!nFall)
                nFall       = GetLocalInt(oTarget, "MOVE_HEIGHT");
        }
        else if(primeSkill==4 && !GetLocalInt(oTarget,"MOVE_VERTICAL"))
        {
            if(sTagDest=="")
                sTagDest    = GetLocalString(oTarget, "MOVE_FAIL");
            if(!nFall)
                nFall       = GetLocalInt(oTarget, "MOVE_FAIL_HEIGHT");
        }

        if(!nFall)
            nFall       = 15; // equivalent of 50'
        object oDest    = GetWaypointByTag(sTagDest);

        if(GetIsObjectValid(oDest))
        {
            // ROPE TOP
            string sRef1= GetLocalString(oTarget, "ROPE_REF");
            if(sRef1==""){sRef1="rope_top";}
            oRopeTop = CreateRope( GetRopeLocation(oTarget), oDest, sRef1);
            // ROPE BOTTOM
            if(nFall>nLen)
            {
                SendMessageToPC(oPC, PINK+"The "+GetName(oRope)+" ("+YELLOW+IntToString(nLen)+PINK+" meters) does not appear to reach the bottom.");
            }
            else
            {
                string sRef2= "rope_bottom";
                oRopeBottom  = CreateRope(GetLocation(oDest), oRopeTop, sRef2);
            }

            bSuccess   = TRUE;
        }
        else
        {
            failMsg = "Nothing appears reachable by rope from here.";
        }
    }

    if(bSuccess)
    {
        // initialize rope data
        // each rope points to the climbing object
        SetLocalObject(oRopeTop, "MOVE_OBJECT", oTarget);
        SetLocalInt(oTarget, "ROPE_LENGTH", nLen);
        SetLocalInt(oTarget, "ROPE_MAGIC", nRopeMagic);
        if(nFall<=nLen)
            SetLocalObject(oRopeBottom, "MOVE_OBJECT", oTarget);
        // climbing object is flagged
        SetLocalInt(oTarget, "ROPED", TRUE);
        // each rope points to the other
        if(nFall<=nLen)
        {
            SetLocalObject(oRopeTop, "PAIRED", oRopeBottom);
            SetLocalObject(oRopeBottom, "PAIRED", oRopeTop);
        }
        // type of move ability used
        SetLocalInt(oRopeTop, "MOVE_SKILL", 1);
        if(nFall<=nLen)
            SetLocalInt(oRopeBottom, "MOVE_SKILL", 1);
        // set top of climb flag
        SetLocalInt(oRopeTop, "MOVE_TOP", TRUE);
        // record rope resref for later taking
        SetLocalString(oRopeTop, "ROPE_ITEM", GetResRef(oRope));
        if(nFall<=nLen)
            SetLocalString(oRopeBottom, "ROPE_ITEM", GetResRef(oRope));
        // distance of fall
        SetLocalInt(oRopeTop, "MOVE_HEIGHT", nFall);
        if(nFall<=nLen)
            SetLocalInt(oRopeBottom, "MOVE_HEIGHT", nFall);

        // destroy used object
        DestroyObject(oRope,1.0f);
    }
    else
    {
        if(failMsg=="")
            failMsg = "Inappropriate use of rope.";
        SendMessageToPC(oPC, RED+failMsg );
    }
 }
}
