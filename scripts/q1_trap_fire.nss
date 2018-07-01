//::///////////////////////////////////////////////
//:: Trapporium Trap Execution
//:: q1_Trap_Fire.nss
//:://////////////////////////////////////////////
/*
    Place in the OnTrapTriggered Event of a trapped door or
    placeable object.

    Executes the effects of the triggered trap

*/
//:://////////////////////////////////////////////
//:: Created By: Lacero
//:: Created On:
//:://////////////////////////////////////////////

#include "q_inc_traps"

#include "_inc_constants"
#include "_inc_util"

void SnareTrap(object oPC)
{
    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");
    int nDC=25;
    object oPC = GetEnteringObject();
    if(GetTrapDetectedBy(OBJECT_SELF, oPC))
        nDC =10;

    PlayVoiceChat(VOICE_CHAT_PAIN1,oPC);
    effect eHold = EffectMovementSpeedDecrease(99);
    AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eHold,oPC,RoundsToSeconds(2)));
}

void SwingingSpikeTrap(object oPC)
{
    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");
    int nDC =20;
    int nDamage, nN;
    object oTriggerer = GetEnteringObject();

    nDamage = TrapSave(oTriggerer, nDC, d6(2));
    if(nDamage>0)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oTriggerer);
        AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_PIERCING), oTriggerer));
    }

    object oPC = GetNearestObject(OBJECT_TYPE_CREATURE, oTriggerer);
    while(GetIsObjectValid(oPC)&&(GetDistanceBetween(oTriggerer,oPC)<2.0))
    {
        nDamage = d6(2);

        nDamage = TrapSave(oPC, nDC, nDamage);

        if(nDamage>0)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oPC);
            AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_BLUDGEONING, DAMAGE_POWER_NORMAL), oPC));
        }

        nN++;
        oPC = GetNearestObject(OBJECT_TYPE_CREATURE, oTriggerer, nN);
    }
}

void TripWireTrap(object oPC)
{
    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");
    int nDC=25;
    object oPC = GetEnteringObject();
    if(GetTrapDetectedBy(OBJECT_SELF, oPC))
        nDC =10;

    PlayVoiceChat(VOICE_CHAT_PAIN1,oPC);
    AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectKnockdown(),oPC,3.0));
}

void CrushingWallTrap(object oPC)
{
    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");
    int nDC = 15;
    int nTot = 0;
    int nN, nDamage;
    object oPC = GetEnteringObject();
    for(nN=0;nN<4;nN++)
    {
        nDamage = d4(2);

        nDamage = TrapSave(oPC, nDC, nDamage);

        if(nDamage>0)
            AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_BLUDGEONING), oPC));

        nTot+=nDamage;
    }
    if(nTot>0)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oPC);
        AssignCommand(oPC,PlaySound("cb_ht_metblleth2"));
        PlayVoiceChat(VOICE_CHAT_PAIN1,oPC);
    }
    else
       AssignCommand(oPC,PlaySound("cb_sw_blunt2"));
}

void RazorWireTrap(object oPC)
{
    int nDC=25;
    int nDamage = d6(2);
    if(GetTrapDetectedBy(OBJECT_SELF, oPC))
        nDC =10;

    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");
    nDamage = TrapSave(oPC, nDC, nDamage);

    if(nDamage>0)
    {
        PlayVoiceChat(VOICE_CHAT_PAIN1,oPC);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_REG_RED), oPC);
        AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_SLASHING, DAMAGE_POWER_NORMAL), oPC));
        if(nDamage>6)
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectMovementSpeedDecrease(80), oPC, 30.0f);
    }
}

void RollingRockTrap(object oTrap)
{
    AssignCommand(oTrap,PlaySound("as_na_rockcavlg1"));

    int nDC=25;
    int nDamage = d6(2);
    location lEnd;
    vector vVector,vOrigin, vAngle;
    float fFacing;
    object oArea;

    lEnd = GetLocation(oTrap);
    fFacing = GetFacingFromLocation(lEnd);
    vVector = GetPositionFromLocation(lEnd);
    vAngle = AngleToVector(fFacing);
    oArea = GetAreaFromLocation(lEnd);
    lEnd = Location(oArea,Vector(vVector.x+(-20.0*vAngle.x),vVector.y+(-20.0*vAngle.y),vVector.z),-fFacing);

    vOrigin = Vector(vVector.x+(-24.0*vAngle.x),vVector.y+(-24.0*vAngle.y),vVector.z);

    object oPC = GetFirstObjectInShape(SHAPE_SPELLCYLINDER,24.5,lEnd,FALSE,OBJECT_TYPE_CREATURE,vOrigin);
    while(GetIsObjectValid(oPC))
    {
        nDamage = TrapSave(oPC, nDC, nDamage);

        if(nDamage>0)
        {
            DelayCommand(1.5,RollingRockHitPC(oPC,nDamage));
        }
        oPC = GetNextObjectInShape(SHAPE_SPELLCYLINDER,24.5,lEnd,FALSE,OBJECT_TYPE_CREATURE,vOrigin);
    }
}

void WallBladeTrap(object oPC)
{
    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");

    int nDC = 15;
    int nTot = 0;
    int nN, nDamage;
    for(nN=0;nN<4;nN++)
    {
        nDamage = d4(2);

        nDamage = TrapSave(oPC, nDC, nDamage);

        if(nDamage>0)
            AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_PIERCING, DAMAGE_POWER_NORMAL), oPC));

        nTot+=nDamage;
    }
    if(nTot>0)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oPC);
        AssignCommand(oPC,PlaySound("cb_ht_metblleth2"));
        PlayVoiceChat(VOICE_CHAT_PAIN1,oPC);
    }
    else
       AssignCommand(oPC,PlaySound("cb_sw_blade2"));
}


void FallingBricksTrap(object oTrap)
{
    int nDC = 15;
    object oPC = GetNearestObject(OBJECT_TYPE_CREATURE, oTrap);
    AssignCommand(oPC, PlaySound("as_na_rockfallg1"));//cb_bu_stonelg
    int nDamage,nN;
    while(GetIsObjectValid(oPC)&&(GetDistanceBetween(oTrap,oPC)<2.0))
    {
        nDamage = d6(2);

        nDamage = TrapSave(oPC, nDC, nDamage);

        if(nDamage>0)
        {
            DelayCommand(1.1,FallingBrickHitPC(oPC,nDamage));
        }

        nN++;
        oPC = GetNearestObject(OBJECT_TYPE_CREATURE, oTrap, nN);
    }
}

void SwingingRockTrap(object oTriggerer)
{
    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");
    int nDC =20;
    int nDamage, nN;

    nDamage = TrapSave(oTriggerer, nDC, d6(2));
    if(nDamage>0)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oTriggerer);
        AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_BLUDGEONING, DAMAGE_POWER_NORMAL), oTriggerer));
    }

    object oPC = GetNearestObject(OBJECT_TYPE_CREATURE, oTriggerer);
    while(GetIsObjectValid(oPC)&&(GetDistanceBetween(oTriggerer,oPC)<2.0))
    {
        nDamage = d6(2);

        nDamage = TrapSave(oPC, nDC, nDamage);

        if(nDamage>0)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oPC);
            AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_BLUDGEONING, DAMAGE_POWER_NORMAL), oPC));
        }

        nN++;
        oPC = GetNearestObject(OBJECT_TYPE_CREATURE, oTriggerer, nN);
    }
}

void SwingingBladeTrap(object oTriggerer)
{
    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");
    int nDC =20;
    int nDamage, nN;

    nDamage = TrapSave(oTriggerer, nDC, d12(1));
    if(nDamage>0)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oTriggerer);
        AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_SLASHING, DAMAGE_POWER_NORMAL), oTriggerer));
    }

    object oPC = GetNearestObject(OBJECT_TYPE_CREATURE, oTriggerer);
    while(GetIsObjectValid(oPC)&&(GetDistanceBetween(oTriggerer,oPC)<2.0))
    {
        nDamage = d12(1);

        nDamage = TrapSave(oPC, nDC, nDamage);

        if(nDamage>0)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect( VFX_COM_BLOOD_CRT_RED), oPC);
            AssignCommand(oTrap,ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_SLASHING, DAMAGE_POWER_NORMAL), oPC));
        }

        nN++;
        oPC = GetNearestObject(OBJECT_TYPE_CREATURE, oTriggerer, nN);
    }
}

void FloodTrap(object oPC)
{
    object oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");
    AssignCommand(oTrap, PlaySound("al_na_fountainlg"));

    object oArea        = GetArea(oTrap);
    string sWaterArea   = GetLocalString(OBJECT_SELF,"TRAP_FLOOD_EXTENTS_TAG");
    object oWaterArea;
    if(sWaterArea!="")
    {
        oWaterArea = GetNearestObjectByTag(sWaterArea,oTrap);
        if(GetArea(oWaterArea)!=oArea)
            oWaterArea=OBJECT_INVALID;
        else
            SetLocalObject(oWaterArea,"TRAP_FLOOD",OBJECT_SELF);
    }

    location lWater;
    float fFace = GetFacing(oTrap);
    vector v    = GetPosition(oTrap);
    vector w    = VectorNormalize(AngleToVector(fFace))*4.0;

    lWater = Location(oArea,Vector(v.x+w.x,v.y+w.y,v.z),fFace);

    object oDoor = GetNearestObject(OBJECT_TYPE_DOOR);
    AssignCommand(oDoor,ActionCloseDoor(oDoor));
    AssignCommand(oDoor,SetLocked(oDoor,TRUE));

    object oPC = GetFirstObjectInShape(SHAPE_CUBE,12.0,lWater,TRUE);
    while(GetIsObjectValid(oPC))
    {
        if(GetLocalInt(oPC,"DROWNING"))
            DeleteLocalInt(oPC,"DROWNING");
        else
        {
            //AlterFootsteps(oPC);
            if(!CreatureGetIsAquatic(oPC))
            {
                ApplyEffectToObject(DURATION_TYPE_PERMANENT,EffectSlow(),oPC);
                DelayCommand(6.0,Drown(oPC,oWaterArea));
            }
        }
        oPC = GetNextObjectInShape(SHAPE_CUBE,12.0,lWater,TRUE);
    }
}

void main()
{
    if(MODULE_DEBUG_MODE)
        SendMessageToPC(GetFirstPC(),"EX: q1_trap_fire");

    string sTrapType = GetStringLeft(GetTag(OBJECT_SELF),7);
    if(GetLocalInt(OBJECT_SELF,"TRP_TRIGGERED")&&(sTrapType!="RWFTrap"))
        return;

    SetLocalInt(OBJECT_SELF,"TRP_TRIGGERED",1);


    object oTrap;

    if((sTrapType!="RPFTrap")&&(GetLocalInt(OBJECT_SELF,"TRP_PLCBL_SHOW")==0))
    {
        string sPcbl;
        if(sTrapType=="MPFTrap")
            sPcbl = "metalpitpcbl";
        if(sTrapType=="RWFTrap")
            sPcbl = "razorwirepcbl";
        if(sTrapType=="RRFTrap")
            sPcbl = "rollingrockpcbl";
        if(sTrapType=="WSFTrap")
            sPcbl = "wallbladepcbl";
        if(sTrapType=="FBFTrap")
            sPcbl = "fallingbrickpcbl";
        if(sTrapType=="SRFTrap")
            sPcbl = "swingingrockpcbl";
        if(sTrapType=="SBFTrap")
            sPcbl = "swingbladepcbl";
        if(sTrapType=="WBFTrap")
            sPcbl = "whirlbladepcbl";
        if(sTrapType=="FlFTrap")
            sPcbl = "floodpcbl";
        if(sTrapType=="SNFTrapVG")
            sPcbl = "snaretrapgpcbl";
        if(sTrapType=="SNFTrapV")
            sPcbl = "snaretrapvpcbl";
        if(sTrapType=="SNFTrapR")
            sPcbl = "snaretraprpcbl";
        if(sTrapType=="SSFTrap")
            sPcbl = "swininspikepcbl";
        if(sTrapType=="TWFTrapVG")
            sPcbl = "tripwiregpcbl";
        if(sTrapType=="TWFTrapV")
            sPcbl = "tripwirevpcbl";
        if(sTrapType=="TWFTrapR")
            sPcbl = "tripwirerpcbl";
        if(sTrapType=="CWFTrap")
            sPcbl = "crushingwallpcbl";

        location lPlcbl = GetLocalLocation(OBJECT_SELF,"TRP_PLCBL_LOC");
        SetLocalInt(OBJECT_SELF,"TRP_PLCBL_SHOW",1);
        oTrap = CreateObject(OBJECT_TYPE_PLACEABLE,sPcbl,lPlcbl);
        SetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ",oTrap);
        SetLocalObject(oTrap,"TRP_TRIGGER_OBJ",OBJECT_SELF);

    if(MODULE_DEBUG_MODE)
        SendMessageToPC(GetFirstPC(),"Trap Created("+ObjectToString(oTrap)+") "+GetName(oTrap));
    }
    else
        oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");


    if(sTrapType=="RPFTrap")
    {
        TrapPlayAnim(oTrap);
        ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,EffectAreaOfEffect(38),GetLocation(oTrap),HoursToSeconds(200));
        return;
    }
    else if(sTrapType=="MPFTrap")
    {
        AssignCommand(oTrap,DelayCommand(1.0,TrapPlayAnim(oTrap)));
        ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,EffectAreaOfEffect(39),GetLocation(oTrap),HoursToSeconds(200));
        return;
    }
    else if(sTrapType=="WBFTrap")
    {
        AssignCommand(oTrap,DelayCommand(1.0,TrapPlayAnim(oTrap)));
        ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,EffectAreaOfEffect(40),GetLocation(oTrap),120.0);
        DelayCommand(120.0, ResetWhirlingBlades());
        return;
    }

    AssignCommand(oTrap,DelayCommand(1.0,TrapPlayAnim(oTrap)));

    int nDC;
    int nDamage;
    object oPC = GetEnteringObject();

    if(sTrapType=="RWFTrap")
    {
        RazorWireTrap(oPC);
        return;
    }
    else if(sTrapType=="RRFTrap")
    {
        RollingRockTrap(oTrap);
        return;
    }
    else if(sTrapType=="WSFTrap")
    {
        WallBladeTrap(oPC);
        return;
    }
    else if(sTrapType=="FBFTrap")
    {
        FallingBricksTrap(oTrap);
        return;
    }
    else if(sTrapType=="SRFTrap")
    {
        SwingingRockTrap(oPC);
        return;
    }
    else if(sTrapType=="SBFTrap")
    {
        SwingingBladeTrap(oPC);
        return;
    }
    else if(sTrapType=="FlFTrap")
    {
        FloodTrap(oPC);
        return;
    }
    else if(sTrapType=="SNFTrapVG")
    {
        SnareTrap(oPC);
        return;
    }
    else if(sTrapType=="SSFTrap")
    {
        SwingingSpikeTrap(oPC);
        return;
    }
    else if(sTrapType=="TWFTrapVG")
    {
        TripWireTrap(oPC);
        return;
    }
    else if(sTrapType=="CWFTrap")
    {
        CrushingWallTrap(oPC);
        return;
    }
}
