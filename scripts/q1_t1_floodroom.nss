#include "q_inc_traps"

//#include "_inc_util"

#include "_inc_terrain"

void main()
{
    if(GetLocalInt(OBJECT_SELF,"TRP_TRIGGERED"))
        return;

    SetLocalInt(OBJECT_SELF,"TRP_TRIGGERED",1);

    object oTrap, oWaterArea;

    if(GetLocalInt(OBJECT_SELF,"TRP_PLCBL_SHOW")==0)
    {
        location lPlcbl = GetLocalLocation(OBJECT_SELF,"TRP_PLCBL_LOC");
        SetLocalInt(OBJECT_SELF,"TRP_PLCBL_SHOW",1);
        oTrap = CreateObject(OBJECT_TYPE_PLACEABLE,"floodpcbl",lPlcbl);
        SetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ",oTrap);
    }
    else
        oTrap = GetLocalObject(OBJECT_SELF,"TRP_PLCBL_OBJ");


    object oArea        = GetArea(oTrap);
    string sWaterArea   = GetLocalString(OBJECT_SELF,"TRAP_FLOOD_EXTENTS_TAG");
    if(sWaterArea!="")
    {
        oWaterArea = GetNearestObjectByTag(sWaterArea,oTrap);
        if(GetArea(oWaterArea)!=oArea)
            oWaterArea=OBJECT_INVALID;
        else
            SetLocalObject(oWaterArea,"TRAP_FLOOD",OBJECT_SELF);
    }
    DelayCommand(0.9, AssignCommand(oTrap, PlaySound("al_na_fountainlg")));
    DelayCommand(1.0,AssignCommand(oTrap, TrapPlayAnim(oTrap)));

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

        EnterUnderwaterZone(oPC, oTrap, oTrap);

        oPC = GetNextObjectInShape(SHAPE_CUBE,12.0,lWater,TRUE);
    }
}


