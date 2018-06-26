//::///////////////////////////////////////////////
//:: Animate Knife (or Animate Weapon- higher level version)
//:: _s0_aniknife
//:://////////////////////////////////////////////
/*
    Animates a knife (or weapon) to battle for the caster
*/
//:://////////////////////////////////////////////
//:: Created: Henesua (2013 sep 15)


#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"


#include "_inc_color"
#include "_inc_spells"


void main()
{
    // Spellcast Hook Code check x2_inc_spellhook.nss to find out more
    if (!X2PreSpellCastCode())
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    // End of Spell Cast Hook

    //Declare major variables
    spellsDeclareMajorVariables();
    // prep failure message
    string fail_message;
    if(spell.Id==534)
        fail_message = RED+"FAILURE "+PINK+"You are not wielding a knife to animate.";
    else
        fail_message = RED+"FAILURE "+PINK+"You are not wielding a weapon to animate.";


    // get the targeted weapon or knife
    int nType       = GetObjectType(spell.Target);
    if(spell.Target==spell.Caster)
    {
      object oItem   = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, spell.Caster);

        int nType       = GetBaseItemType(oItem);
        if( GetIsObjectValid(oItem) &&
           (    spell.Id == 123       // animate weapon
            ||  (   spell.Id==534 &&  // animate knife
                  (
                    nType==BASE_ITEM_DAGGER
            ||      nType==BASE_ITEM_KUKRI
            ||      nType==303// sai
            ||      nType==309// assassin dagger
            ||      nType==310// katar
                  )
                )
           )
          )
            spell.Target = oItem;
        else
        {
            oItem   = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, spell.Caster);
            nType   = GetBaseItemType(oItem);
            if( GetIsObjectValid(oItem) &&
                (    spell.Id == 123
                ||  (   spell.Id==534 &&
                      (
                        nType==BASE_ITEM_DAGGER
            ||          nType==BASE_ITEM_KUKRI
            ||          nType==303// sai
            ||          nType==309// assassin dagger
            ||          nType==310// katar
                      )
                    )
                )
              )
                spell.Target = oItem;
            else
            {
                SendMessageToPC(OBJECT_SELF, fail_message);
                return;
            }
        }

    }

    // only proceed if the ultimate target is an appropriate weapon
    if(     GetObjectType(spell.Target)==OBJECT_TYPE_ITEM
        &&  !CIGetIsCraftFeatBaseItem(spell.Target)
      )
    {
        int nType   = GetBaseItemType(spell.Target);
        if( GetIsObjectValid(spell.Target) &&
            (    spell.Id == 123
            ||  (   spell.Id==534 &&
                  (
                    nType==BASE_ITEM_DAGGER
            ||      nType==BASE_ITEM_KUKRI
            ||      nType==303// sai
            ||      nType==309// assassin dagger
            ||      nType==310// katar
                  )
                )
            )
          )
        {
            if(!GetIdentified(spell.Target))
            {
                SendMessageToPC(OBJECT_SELF, RED+"FAILURE "+PINK+"Only identified items can be enchanted.");
                ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(282), GetLocation(spell.Target));  // hit elec
                return;
            }

            string sRefWeapon    = "enchweapon";

            //Declare major variables
            int nLevel      = spell.Level;
            if(nLevel<1){nLevel = 1;}
            int nDuration   = 10 * nLevel;
            if(GetMetaMagicFeat()==METAMAGIC_EXTEND)
                nDuration   = nDuration *2;   //Duration is +100%

            location lLoc   = spell.Loc;
            if(!GetIsObjectValid(GetAreaFromLocation(lLoc)))
                lLoc    = GetLocation(OBJECT_SELF);

            object oWielder = CreateObject(OBJECT_TYPE_CREATURE, sRefWeapon, lLoc);

            // give weapon (oDagger) to creature (oWielder)
            object oDagger  = CopyItem(spell.Target, oWielder, TRUE);
            SetDroppableFlag(oDagger,TRUE);
            AssignCommand(oWielder, ActionEquipItem(oDagger, INVENTORY_SLOT_RIGHTHAND));

            // apply name and desc of weapon to creature
            SetName(oWielder, GetName(oDagger));
            SetDescription(oWielder, GetName(oDagger));

            // set locals on creature
            SetLocalInt(oWielder, "ENCHANTED_WEAPON", TRUE);
            SetLocalObject(oWielder, "WEAPON", oDagger);
            SetLocalString(oWielder, "WEAPON_SOUND", "it_bladesmall");
            SetLocalInt(oWielder, "LEVEL", nLevel); // for dispel
            SetLocalObject(oWielder, "CREATOR", OBJECT_SELF); // for dispel
            SetLocalInt(oWielder, "TIMER", nDuration); // for duration

            //Apply the VFX impact
            DelayCommand(0.4,
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_TORNADO), oWielder)
                );

            if(IncrementAnimatedWeaponCount(nLevel))
            {
                AddHenchman(OBJECT_SELF, oWielder);
                //DecrementAnimatedWeaponCount(oWielder, nDuration); // nDuration is a delay in rounds
            }
            else
            {
                if(!InvisibleTrue())
                {
                    object oCaster  = OBJECT_SELF;
                    AssignCommand(oWielder, ActionDoCommand(DetermineCombatRound(oCaster)));
                }
                else
                    AssignCommand(oWielder, ActionDoCommand(DetermineCombatRound()));
            }


            int nLvlDagger  = nLevel/3;
            if(nLvlDagger<1)
                nLvlDagger  = 1;

            LevelHenchmanUpTo(oWielder, nLvlDagger);
            //SetPlotFlag(oTarget, FALSE);
            DestroyObject(spell.Target, 0.1);
        }
        else
        {
            SendMessageToPC(OBJECT_SELF, fail_message);
            return;
        }
    }
}
