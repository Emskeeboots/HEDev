//
// Spawn ObjectEffect
//
int ParseFlagValue(string sName, string sFlag, int nDigits, int nDefault);
int ParseSubFlagValue(string sName, string sFlag, int nDigits, string sSubFlag, int nSubDigits, int nDefault);
object GetChildByTag(object oSpawn, string sChildTag);
object GetChildByNumber(object oSpawn, int nChildNum);
object GetSpawnByID(int nSpawnID);
void DeactivateSpawn(object oSpawn);
void DeactivateSpawnsByTag(string sSpawnTag);
void DeactivateAllSpawns();
void DespawnChildren(object oSpawn);
void DespawnChildrenByTag(object oSpawn, string sSpawnTag);

// - [File: spawn_cfg_fxobj]
effect ObjectEffect(object oSpawn);
effect ObjectEffect(object oSpawn)
{
    // Initialize Variables
    effect eObjectEffect;

    // Initialize Values
    int nObjectEffect = GetLocalInt(oSpawn, "f_ObjectEffect");

//
// Only Make Modifications Between These Lines
// -------------------------------------------


    // ObjectEffect 00
    // Dummy ObjectEffect - Never Use
    if (nObjectEffect == 0)
    {
        return eObjectEffect;
    }
    //

    // Bard's Song
    if (nObjectEffect == 414)
    {
        eObjectEffect = EffectVisualEffect(VFX_DUR_GLOW_LIGHT_YELLOW);
    }


    if (nObjectEffect == 1)
    {
        eObjectEffect = EffectVisualEffect(VFX_DUR_DARKNESS);
    }

    if (nObjectEffect == 248)
    {
        eObjectEffect = EffectVisualEffect(VFX_DUR_ANTI_LIGHT_10);
    }

    if (nObjectEffect == 537)
    {
        eObjectEffect = EffectVisualEffect(VFX_DUR_AURA_PULSE_PURPLE_BLACK);
    }

    if (nObjectEffect == 558)
    {
        eObjectEffect = EffectVisualEffect(VFX_DUR_AURA_GREEN_DARK);
    }

    if (nObjectEffect == 232)
    {
        eObjectEffect = EffectVisualEffect(VFX_DUR_PARALYZED);
    }

    if (nObjectEffect == 14)
    {
        eObjectEffect = EffectVisualEffect(VFX_DUR_PROT_SHADOW_ARMOR);
    }
















    //


// -------------------------------------------
// Only Make Modifications Between These Lines
//

    // Return the ObjectEffect
    return eObjectEffect;
}

/*

*/
