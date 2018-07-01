/*
void main()
{
    // If the last spell cast was lesser spell breach.

  int nSpellId = GetLastSpell();

  if (nSpellId == SPELL_GREATER_SPELL_BREACH ||
      nSpellId == SPELL_LESSER_SPELL_BREACH ||
    {
        // Destroy the placeable.
        object oPlaceable = GetObjectByTag("vfx_nethward");
        SetPlotFlag(oPlaceable, FALSE);
        DestroyObject(oPlaceable);

        // Unlock and open the door.
        object oDoor = GetObjectByTag("nethaud_en");
        SetLocked(oDoor, FALSE);
        AssignCommand(oDoor, ActionOpenDoor(oDoor));
    }
}
*/




void main()
{
  int nSpellId = GetLastSpell();

  if (nSpellId == SPELL_GREATER_SPELL_BREACH ||
      nSpellId == SPELL_LESSER_SPELL_BREACH)

  {
      SpeakString("*Its ward breached, the door opens and gives enty to the halls behind.*");

      object oDoor = GetObjectByTag("nethaud_en");
      object oPlaceable = GetObjectByTag("tt_vfx_wardring_v");
      //location loc = GetLocation(OBJECT_SELF);

      ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_DISPEL), oPlaceable);
      DestroyObject(oPlaceable);
      AssignCommand(oDoor, DelayCommand(0.5, SetLocked(oDoor, FALSE)));
      AssignCommand(oDoor, DelayCommand(2.0, ActionPlayAnimation(ANIMATION_DOOR_OPEN1)));

      AssignCommand(oDoor, DelayCommand(15.0, ActionPlayAnimation(ANIMATION_DOOR_CLOSE)));
      AssignCommand(oDoor, DelayCommand(16.0, SetLocked(oDoor, TRUE)));


      SetPlotFlag(OBJECT_SELF, FALSE);
//    DestroyObject(OBJECT_SELF);
  }
}



/*

object oPC = GetLastUsedBy();

if (!GetIsPC(oPC)) return;

object oTarget;
oTarget = GetObjectByTag("ward");

//Visual effects can't be applied to waypoints, so if it is a WP
//the VFX will be applied to the WP's location instead

int nInt;
nInt = GetObjectType(oTarget);

if (nInt != OBJECT_TYPE_WAYPOINT) ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_DISPEL), oTarget);
else ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_DISPEL), GetLocation(oTarget));

}
 */
