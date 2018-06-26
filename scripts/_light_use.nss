//::///////////////////////////////////////////////
//:: _light_use
//:://////////////////////////////////////////////
/*
    Turns the placeable light on or off

    Locals
        LIGHT_FIRE int          TRUE = to light requires fire
        LIGHTABLE_TYPE string   candle, torch, lantern to define behavior or light
        LIGHT_COLOR string      green, blue, red, etc....
        LIGHT_VALUE int         1,2,3,4  - for radius of light cast x5 meters
        LIGHTABLE int           TRUE identifies the object as a candle, torch or lantern

    if using special aid behaviors
        light int               TRUE = aid verb "light" works on this object
        extinguish int          TRUE = aid verb "extinguish" works on this object
    used by some special aid behaviors
        LIGHT_REF string        resref of light to spawn
        LIGHT_X float           x vector for position of spawned light
        LIGHT_Y float           y vector for position of spawned light
        LIGHT_Z float           z vector for position of spawned light
        LIGHT_F float           facing/rotation of spawned light


*/
//:://////////////////////////////////////////////
//:: Created:  Brent (January 2002)
//:: Modified: henesua (2016 jan 1)

#include "aid_inc_global"

#include "_inc_light"

void main()
{
    // get "user"
    // used by AID - comment out if not using AID
    object oPC  = GetLocalObject(OBJECT_SELF, AID_TRIGGERING_OBJECT);
    DeleteLocalObject(OBJECT_SELF, AID_TRIGGERING_OBJECT);
    if(!GetIsObjectValid(oPC))
        oPC     = GetLastUsedBy();


    // On behavior
    if (!GetLocalInt(OBJECT_SELF,"NW_L_AMION"))
    {

        string sLightScript = GetLocalString(OBJECT_SELF, "light");
        if(sLightScript!="")
        {
            SetLocalObject(OBJECT_SELF, AID_TRIGGERING_OBJECT,oPC);
            ExecuteScript(sLightScript,OBJECT_SELF);
            return;
        }

         // Determine if Script shall continue
        if(!PCCanLight(OBJECT_SELF, oPC))
            return;

        SetLocalInt(OBJECT_SELF,"NW_L_AMION",1); // state tracking
        PlayAnimation(ANIMATION_PLACEABLE_ACTIVATE);

        // handle lights
        if(GetLocalInt(OBJECT_SELF, "LIGHTABLE"))
        {
            int nBrightness = GetLocalInt(OBJECT_SELF, LIGHT_VALUE);
            SetLocalInt(OBJECT_SELF, LIGHT_VALUE, nBrightness); // light tracking
            effect eLight   = EffectVisualEffect(GetLightColor());
            DelayCommand(0.3,AssignCommand(OBJECT_SELF, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLight, OBJECT_SELF) ));
        }

        DelayCommand(0.4,SetPlaceableIllumination(OBJECT_SELF, TRUE));
        DelayCommand(0.5,RecomputeStaticLighting(GetArea(OBJECT_SELF)));
    }
    // Off behavior
    else
    {
        /* // Special AID behavior
        string sLightScript = GetLocalString(OBJECT_SELF, "extinguish");
        if(sLightScript!="")
        {
            SetLocalObject(OBJECT_SELF, AID_TRIGGERING_OBJECT,oPC);
            ExecuteScript(sLightScript,OBJECT_SELF);
            return;
        }
        */

        SetLocalInt(OBJECT_SELF,"NW_L_AMION",0); // state tracking
        PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE);

        // handle lights
        if(GetLocalInt(OBJECT_SELF, "LIGHTABLE"))
        {
            DeleteLocalInt(OBJECT_SELF, LIGHT_VALUE); // light tracking
            // remove effects
            effect eEffect = GetFirstEffect(OBJECT_SELF);
            while (GetIsEffectValid(eEffect) == TRUE)
            {
                if(     GetEffectType(eEffect)==EFFECT_TYPE_VISUALEFFECT
                    &&  GetEffectCreator(eEffect)==OBJECT_SELF
                  )
                    DelayCommand(0.3, RemoveEffect(OBJECT_SELF, eEffect));
                eEffect = GetNextEffect(OBJECT_SELF);
            }
        }

        DelayCommand(0.4,SetPlaceableIllumination(OBJECT_SELF, FALSE));
        DelayCommand(0.9,RecomputeStaticLighting(GetArea(OBJECT_SELF)));

    }
}
