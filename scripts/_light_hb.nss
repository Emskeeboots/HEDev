//::///////////////////////////////////////////////
//:: _light_hb
//:://////////////////////////////////////////////
/*
    placeable HeartBeat

    a placeable light which is consumable and possibly takeable [see: _plc_take]
*/
//:://////////////////////////////////////////////
//:: Created: henesua (2016 jan 1)
//:: Modified:
//:://////////////////////////////////////////////

#include "_inc_light"

void main()
{
    object oArea    = GetArea(OBJECT_SELF);
    if (GetLocalInt(OBJECT_SELF, "NO_HB_IF_NO_PCS") && !GetLocalInt(oArea, "AREA_PC_COUNT")) // skip if no pcs in area
        return;

    // If this is not an empty lantern
    if(!GetLocalInt(OBJECT_SELF, "LIGHTABLE_LANTERN_EMPTY"))
    {
        int nTicksLit       = GetLocalInt(OBJECT_SELF,"LIGHTABLE_BURNED_TICKS");
        string sLightType   = GetLocalString(OBJECT_SELF,"LIGHTABLE_TYPE");
        // Check the time lit vs total allowed burntime...
        // For a candle, destroy and recompute static lighting.
        if(nTicksLit >= MAX_CANDLE_HB && sLightType == "candle")
        {
            AssignCommand(oArea, DelayCommand(2.4, RecomputeStaticLighting(oArea)) );
            object oPair    = GetLocalObject(OBJECT_SELF, "PAIRED");
            object oSource  = GetLocalObject(OBJECT_SELF, "LIGHT_OBJECT");
            SetLocalInt(oSource, "NW_L_AMION", 0);
            DestroyObject(oPair);
            DestroyObject(OBJECT_SELF);
        }
        // For a lantern, remove light effect, change description, and recompute static lighting
        else if(nTicksLit >= MAX_LANTERN_HB && sLightType=="lantern")
        {
            SetPlaceableIllumination(OBJECT_SELF, FALSE);
            SetLocalInt(OBJECT_SELF, "LIGHTABLE_LANTERN_EMPTY", TRUE);
            object oSource  = GetLocalObject(OBJECT_SELF, "LIGHT_OBJECT");
            SetLocalInt(oSource, "NW_L_AMION", 0);

            effect eEffect = GetFirstEffect(OBJECT_SELF);
            while ( GetIsEffectValid(eEffect) )
            {
                if ( GetEffectType(eEffect)==EFFECT_TYPE_VISUALEFFECT )
                    RemoveEffect(OBJECT_SELF, eEffect); // remove light

                //Next effect on the list...
                eEffect = GetNextEffect(OBJECT_SELF);
            }
            SetDescription(OBJECT_SELF, GetDescription(OBJECT_SELF, TRUE)+" The reservoir is empty.");
            AssignCommand(oArea, DelayCommand(2.4, RecomputeStaticLighting(oArea)) );
        }
        // For a torch, destroy and recompute static lighting.
        else if(nTicksLit >= MAX_TORCH_HB && sLightType == "torch")
        {
            AssignCommand(oArea, DelayCommand(2.4, RecomputeStaticLighting(oArea)) );
            object oPair    = GetLocalObject(OBJECT_SELF, "PAIRED");
            object oSource  = GetLocalObject(OBJECT_SELF, "LIGHT_OBJECT");
            SetLocalInt(oSource, "NW_L_AMION", 0);
            DestroyObject(oPair);
            DestroyObject(OBJECT_SELF);
        }
        // Otherwise, increment the time the light object has been lit.
        else
        {
            SetLocalInt(OBJECT_SELF,"LIGHTABLE_BURNED_TICKS",++nTicksLit);
            string sNewDescription = GetDescription(OBJECT_SELF, TRUE);
            float fTorchRemainder;
            if (sLightType == "candle")
            {
                fTorchRemainder = IntToFloat(MAX_CANDLE_HB-nTicksLit)/MAX_CANDLE_HB ;

                if (fTorchRemainder > 0.9 || nTicksLit == 1)
                {
                     sNewDescription += " This candle is fresh.";
                }
                else if (fTorchRemainder > 0.75)
                {
                     sNewDescription += " This candle is mostly fresh.";
                }
                else if (fTorchRemainder > 0.60)
                {
                     sNewDescription += " More than half of this candle remains.";
                }
                else if (fTorchRemainder > 0.45)
                {
                     sNewDescription += " Only half of this candle remains.";
                }
                else if (fTorchRemainder > 0.35)
                {
                     sNewDescription += " More than half of this candle is spent.";
                }
                else if (fTorchRemainder > 0.20)
                {
                     sNewDescription += " Only a third of this candle's life remains unspent.";
                }
                else if (fTorchRemainder > 0.05)
                {
                     sNewDescription += " All that remains of this candle is a short stub. Its life is running out.";
                }
                else
                {
                     sNewDescription += " This candle has been reduced to a wick in candle drippings. It has maybe a few minutes of life left.";
                }
            }
            else if (sLightType == "lantern")
            {
                fTorchRemainder = IntToFloat(MAX_LANTERN_HB-nTicksLit)/MAX_LANTERN_HB ;
                if (fTorchRemainder > 0.9 || nTicksLit == 1)
                {
                     sNewDescription += " The reservoir seems full.";
                }
                else if (fTorchRemainder > 0.65)
                {
                     sNewDescription += " The reservoir is mostly full.";
                }
                else if (fTorchRemainder > 0.45)
                {
                     sNewDescription += " The reservoir sloshes when you shake it, perhaps half full.";
                }
                else if (fTorchRemainder > 0.20)
                {
                     sNewDescription += " The reservoir has less than half of the oil remaining.";
                }
                else if (fTorchRemainder > 0.05)
                {
                     sNewDescription += " The reservoir has only a small amount of oil left.";
                }
                else
                {
                     sNewDescription += " The reservoir is almost empty. It has maybe a few minutes of life left.";
                }
            }
            else if (sLightType == "torch")
            {
                fTorchRemainder = IntToFloat(MAX_TORCH_HB-nTicksLit)/MAX_TORCH_HB ;
                if (fTorchRemainder > 0.9 || nTicksLit == 1)
                {
                     sNewDescription += " This torch has been used.";
                }
                else if (fTorchRemainder > 0.45)
                {
                     sNewDescription += " This torch is well used.";
                }
                else if (fTorchRemainder > 0.20)
                {
                     sNewDescription += " This torch is blackened from use.";
                }
                else if (fTorchRemainder > 0.05)
                {
                     sNewDescription += " This torch is nearly charred through.";
                }
                else
                {
                     sNewDescription += " This torch is charred. It has maybe a few minutes of life left.";
                }
            }
            SetDescription(OBJECT_SELF, sNewDescription);
        }
    }
}
