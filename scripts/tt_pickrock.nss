void main()
{


effect eEffect;
object oAttacker = GetLastAttacker();
object oWeapon = GetLastWeaponUsed(oAttacker);
int nInt;
int nRockdmg  = GetLocalInt(OBJECT_SELF, "Rockdmg");





    if(GetTag(oWeapon) == "tt_holditem_pick")
    {
       SetPlotFlag(OBJECT_SELF, FALSE);

       if (GetHasFeat(FEAT_STONECUNNING, oAttacker))
       {
            if (GetIsSkillSuccessful(oAttacker, SKILL_CRAFT_TRAP, 8))
            {
                 //eEffect = EffectDamage(Random(10)+5, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_NORMAL);
                 SendMessageToPC(oAttacker, "With cunning expertise you chip away at the rocks that block your path");
            }

            else
            {
                 nInt = GetObjectType(oAttacker);
                 if (nInt != OBJECT_TYPE_WAYPOINT) ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_CHUNK_STONE_MEDIUM), oAttacker);
                 else ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_CHUNK_STONE_MEDIUM), GetLocation(oAttacker));
                 effect eKnockdown;
                 eKnockdown = EffectKnockdown();
                 eEffect = EffectDamage(Random(nRockdmg)+1, DAMAGE_TYPE_BLUDGEONING, DAMAGE_POWER_NORMAL);

                 ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffect, oAttacker);
                 ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockdown, oAttacker, 5.0f);

                 SendMessageToPC(oAttacker, "Despite your skill, you fail to clear a path and instead cause loose debris to dislodge, falling on you!");
            }

       }

       else
       {
            if (GetIsSkillSuccessful(oAttacker, SKILL_CRAFT_TRAP, 14))
            {
                 //eEffect = EffectDamage(Random(20)+10, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_NORMAL);
                 SendMessageToPC(oAttacker, "You manage to chip away at the rocks that block your path!");
            }

            else
            {
                 nInt = GetObjectType(oAttacker);
                 if (nInt != OBJECT_TYPE_WAYPOINT) ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_CHUNK_STONE_MEDIUM), oAttacker);
                 else ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_CHUNK_STONE_MEDIUM), GetLocation(oAttacker));
                 effect eKnockdown;
                 eKnockdown = EffectKnockdown();
                 eEffect = EffectDamage(Random(nRockdmg)+8, DAMAGE_TYPE_BLUDGEONING, DAMAGE_POWER_NORMAL);

                 ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffect, oAttacker);
                 ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockdown, oAttacker, 5.0f);

                 SendMessageToPC(oAttacker, "Your lack of skill has caused you to dislodge loose debris, falling on you as you fail to clear a path.");
            }
       }

    }


    else
    {
         SetPlotFlag(OBJECT_SELF, TRUE);
         SendMessageToPC(oAttacker, "You need a pick to clear a path!");
    }

}







