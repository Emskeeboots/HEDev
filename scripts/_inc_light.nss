// _inc_light.nss


#include "_inc_constants"
#include "_inc_utils"

// LIGHT SYSTEM ----------------------------------------------------------------
const string LIGHT_COLOR    = "LIGHT_COLOR";
const string LIGHT_VALUE    = "LIGHT_VALUE";

// used in _mod_heartbeat , do_oilflask
/*
    Taken from KMDS light system

    You may modify the time a torch or lantern will stay lit by setting the
    global integers MAX_TORCH_HB, MAX_CANDLE_HB, MAX_LANTERN_HB to however many module HBs
    you wish them to burn.  The system defaults are the pnp values given in D&D
    3rd ed.
*/
const string TORCHHASBURNTOUT   = "Your torch has burned out.";
const string CANDLEHASBURNTOUT  = "Your candle has expired.";
const string LANTERNISEMPTY     = "Your lantern is out of oil.";
const string REFILL             = "You have refueled the lantern.";
const string ALREADYFULL        = "The Lantern is already full.";
const string MOVECLOSER         = "Move closer to refuel the lantern, you are too far away.";
const string FULLREFILL         = "You have fully refueled the lantern and still have some oil in your flask.";
const string FULLREFILLLOSEFLASK= "You have fully refueled the lantern using all the oil in your flask.";
const string PARTIALREFILL      = "You have partially refueled the lantern with the remaining oil in your flask.";
const string NOTVALIDTARGET     = "You can't use your oilflask on that object.";
// First number in equation represents hours of burn time. Actual time is measured in module hearbeats in _mod_heartbeat
int nRLMinutes = GetLocalInt(GetModule(), "IGMINUTES_PER_RLMINUTE");
int MAX_TORCH_HB    = 1     *(60/nRLMinutes)*10;
int MAX_CANDLE_HB   = 1     *(60/nRLMinutes)*10;
int MAX_LANTERN_HB  = 6     *(60/nRLMinutes)*10;
// Returns a light VFX using two local vars - LIGHT_COLOR and LIGHT_BRIGHTNESS - [FILE: _inc_util]
int GetLightColor(object oLight=OBJECT_SELF);
// Initializes consumable lightsources. - [FILE: _inc_util]
// see equip module event
void InitializeTorch(object oItem, string sType);
// Returns the brightness of the brightest wielded light - [FILE: _inc_util]
int GetBrightestLightWielded(object oPC, object oSkipped);
// oPC is able to light oSconce - [FILE: _inc_util]
int PCCanLight(object oSconce, object oPC);
// PC's light is destroyed or loses light property. Reset light flags - [FILE: _inc_util]
void PCLostLight(object oPC, object oLostLight);// ................ LIGHT ......................................................


int GetLightColor(object oLight=OBJECT_SELF)
{
    string sColor   = GetStringUpperCase(GetLocalString(oLight,LIGHT_VALUE));
    int nBrightness = GetLocalInt(oLight, LIGHT_VALUE);

    int nColor      = VFX_DUR_LIGHT_YELLOW_15; // default color

    if(sColor == "BLUE")
    {
        switch(nBrightness)
        {
            case 1: return VFX_DUR_LIGHT_BLUE_5; break;
            case 2: return VFX_DUR_LIGHT_BLUE_10; break;
            case 3: return VFX_DUR_LIGHT_BLUE_15; break;
            case 4: return VFX_DUR_LIGHT_BLUE_20; break;
            default: return VFX_DUR_LIGHT_BLUE_15; break;
        }
    }
    else if(sColor == "GREY")
    {
        switch(nBrightness)
        {
            case 1: return VFX_DUR_LIGHT_GREY_5; break;
            case 2: return VFX_DUR_LIGHT_GREY_10; break;
            case 3: return VFX_DUR_LIGHT_GREY_15; break;
            case 4: return VFX_DUR_LIGHT_GREY_20; break;
            default: return VFX_DUR_LIGHT_GREY_15; break;
        }
    }
    else if(sColor == "ORANGE")
    {
        switch(nBrightness)
        {
            case 1: return VFX_DUR_LIGHT_ORANGE_5; break;
            case 2: return VFX_DUR_LIGHT_ORANGE_10; break;
            case 3: return VFX_DUR_LIGHT_ORANGE_15; break;
            case 4: return VFX_DUR_LIGHT_ORANGE_20; break;
            default: return VFX_DUR_LIGHT_ORANGE_15; break;
        }
    }
    else if(sColor == "PURPLE")
    {
        switch(nBrightness)
        {
            case 1: return VFX_DUR_LIGHT_PURPLE_5; break;
            case 2: return VFX_DUR_LIGHT_PURPLE_10; break;
            case 3: return VFX_DUR_LIGHT_PURPLE_15; break;
            case 4: return VFX_DUR_LIGHT_PURPLE_20; break;
            default: return VFX_DUR_LIGHT_PURPLE_15; break;
        }
    }
    else if(sColor == "RED")
    {
        switch(nBrightness)
        {
            case 1: return VFX_DUR_LIGHT_RED_5; break;
            case 2: return VFX_DUR_LIGHT_RED_10; break;
            case 3: return VFX_DUR_LIGHT_RED_15; break;
            case 4: return VFX_DUR_LIGHT_RED_20; break;
            default: return VFX_DUR_LIGHT_RED_15; break;
        }
    }
    else if(sColor == "WHITE")
    {
        switch(nBrightness)
        {
            case 1: return VFX_DUR_LIGHT_WHITE_5; break;
            case 2: return VFX_DUR_LIGHT_WHITE_10; break;
            case 3: return VFX_DUR_LIGHT_WHITE_15; break;
            case 4: return VFX_DUR_LIGHT_WHITE_20; break;
            default: return VFX_DUR_LIGHT_WHITE_15; break;
        }
    }

    return nColor;
}

void InitializeTorch(object oItem, string sType)
{
    if(GetLocalInt(oItem,"CONTINUAL_FLAME"))
    {

        return;
    }
    if(sType=="nw_it_torch001"){ sType = "torch"; }
    int nPos = FindSubString(sType, "_");
    if(nPos!=-1){ sType = GetStringLeft(sType, nPos); }

    SetLocalInt(oItem, "LIGHTABLE" , TRUE);
    SetLocalString(oItem,"LIGHTABLE_TYPE" , sType);
}

int GetBrightestLightWielded(object oPC, object oSkipped)
{
    object oItem;
    int nSlot;
    int iLightBrightness = 0;

    if( IPGetHasItemPropertyOnCharacter(oPC, ITEM_PROPERTY_LIGHT) )
    {
        // Cycle through all equipped items looking for the value of the brightest light property
        for (nSlot=0; nSlot<NUM_INVENTORY_SLOTS; nSlot++)
        {
            oItem          =   GetItemInSlot(nSlot, oPC);
            if (oItem != oSkipped)
            {
                itemproperty ip =   GetFirstItemProperty(oItem);
                while ( GetIsItemPropertyValid(ip) )
                {
                 if ( GetItemPropertyType(ip) == ITEM_PROPERTY_LIGHT )
                 {
                    if( iLightBrightness < GetItemPropertyCostTableValue(ip) )
                    {
                     iLightBrightness = GetItemPropertyCostTableValue(ip);
                    }
                 }
                //Next itemproperty on the list...
                ip = GetNextItemProperty(oItem);
                }
            }
        }
    }

    return iLightBrightness;
}

int PCCanLight(object oSconce, object oPC)
{
    if(GetLocalInt(oSconce, "LIGHT_FIRE"))
    {
        if(     GetIsObjectValid(GetItemPossessedBy(oPC, "flintsteel"))
            ||  GetIsWieldingFlame(oPC)
          )
        {
            return TRUE;
        }
        else
        {
            SendMessageToPC(oPC, RED+"You need "+YELLOW+"flint and steel"+RED+" or an equipped open flame ("+YELLOW+"torch"+RED+","+YELLOW+" flaming sword"+RED+", etc...) to light the "+YELLOW+GetName(oSconce)+RED+".");
            return FALSE;
        }
    }
    else
        return TRUE;
}

//When PC's light was destroyed, adjust their light flag.
void PCLostLight(object oPC, object oLostLight)
{
    int iLightBrightness = GetBrightestLightWielded(oPC, oLostLight);

    if(GetLocalInt(oPC, LIGHT_VALUE)>iLightBrightness)
        SetLocalInt(oPC, LIGHT_VALUE,iLightBrightness);
}
