//::///////////////////////////////////////////////
//:: _spellhook
//:://////////////////////////////////////////////
/*
    Hills' Edge Spellhook

    Set up for use with
    The Magus' Innocuous Familiars
    Dynamic Deity and Pantheons

    this is needed for the following purposes
    - to capture spellfocus use and prep follow up spell
    - to capture hostile spells cast on the familiar (for Cast Master's Spell)
    - to capture the spell cast event (spell sharing occurs in spell cast event)

*/
//:://////////////////////////////////////////////
//:: Created:   henesua (2016 jan 1)
//:: Modified:
//:://////////////////////////////////////////////

// needed for SetModuleOverrideSpellScriptFinished
#include "x2_inc_switches"
#include "x2_inc_spellhook"
#include "x0_i0_match"

#include "_inc_constants"
#include "_inc_util"
#include "_inc_pets"
#include "_inc_spells"

// event from x2_inc_spellhook
//int X2_EVENT_CONCENTRATION_BROKEN = 12400;

void main()
{

  // MAGIC ITEMS ---------------------------------------------------------------
  object oMgItem  = GetSpellCastItem();
  if( GetIsObjectValid(oMgItem) )
  {
    if(!GetIsPC(OBJECT_SELF) || GetIsDM(OBJECT_SELF) || GetIsDMPossessed(OBJECT_SELF))
        return;// not a Player Character - skip remainder of script
  }
  else
  // BEGIN SPELLS and FEATS-----------------------------------------------------
  {
    object oMod     = GetModule();
    int nSpellClass = GetLastSpellCastClass();
    object oCaster  = OBJECT_SELF;
    int nCasterLevel= GetCasterLevel(OBJECT_SELF);
    int nSpellID    = GetSpellId();
    int nSpellLevel = StringToInt(Get2DAString("spells","Innate",nSpellID));// innate spell level
    int nMeta       = GetMetaMagicFeat();
    int nDC         = GetSpellSaveDC();
    object oTarget  = GetSpellTargetObject();
    //location lTarget= GetSpellTargetLocation();
    //string sDeity   = GetStringLowerCase(GetDeity(OBJECT_SELF));
    //int nDeity      = GetDeityIndex(OBJECT_SELF);

    int bSuccess    = TRUE;
    int bFeatMagic  = (     nSpellClass==CLASS_TYPE_INVALID
                        &&(     nSpellID==308 // turning undead
                            ||  nSpellID==313 // laying on hands
                            ||  nSpellID==316 // removing disease
                            ||  (nSpellID>=380&&nSpellID<=384) // clerical domain powers
                            ||  (nSpellID>=473&&nSpellID<=478) // prestige class magic powers
                            ||  (nSpellID>=600&&nSpellID<=614) // prestige class magic powers
                            ||  (nSpellID>=622&&nSpellID<=628) // prestige class magic powers
                           //||   (nSpellID >= 397 && nSpellID <=405)// druid wildshaping or elemshaping
                           //||   (nSpellID >= 875 && nSpellID <=880)// druid wildshaping or elemshaping
                          )
                      );
    /*
    int bEpicMagic  = ( (nSpellID<=636&&nSpellID<=640)
                      );
    */

    if(     GetTag(GetArea(OBJECT_SELF))=="tt_fugue"
       &&   !GetIsDM(OBJECT_SELF)
       &&   GetIsPC(OBJECT_SELF)
       /*
       &&   (   nSpellClass!=CLASS_TYPE_INVALID
             || bFeatMagic
             || ((nSpellID>=397&&nSpellID<=405)||(nSpellID>=875&&nSpellID<=880)) // wildshape
             || nSpellID==411 // bard song
             || nSpellID==644 // curse song
             || nSpellID==317 // summon companion
             || nSpellID==318 // summon familiar
            )
       */
      )
    {
        SendMessageToPC(OBJECT_SELF, RED+"You are powerless in the fugue!");
        SetModuleOverrideSpellScriptFinished();
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE),OBJECT_SELF,1.0);
        //bSuccess    = FALSE;
        return;
    }

    // begin spell casting exclusion - feats not checked against
    if(nSpellClass != CLASS_TYPE_INVALID)// casting a spell. feat use is not deterred.
    {
        // if the caster is concentrating on maintaining a magical effect
        if(GetLocalInt(OBJECT_SELF, "CONCENTRATION"))
        {
            SignalEvent(GetLocalObject(OBJECT_SELF,"CONCENTRATION_OBJECT"),EventUserDefined(X2_EVENT_CONCENTRATION_BROKEN));
        }

        // UNDERWATER --------------------------------------------------------------
        if(GetLocalString(OBJECT_SELF,"UNDERWATER_ID")!="")
        {
            int underwater_effects   = GetLocalInt(OBJECT_SELF,"UNDERWATER_EFFECTS");
            // impacted speech?
            if(     underwater_effects & IMPACT_SPEECH
                &&  nMeta != METAMAGIC_SILENT
                &&  GetSpellComponent("v",nSpellID)
              )
            {
                // cannot cast verbal spells when silenced
                SendMessageToPC(OBJECT_SELF, RED+"SPELL FAILURE!");
                FloatingTextStringOnCreature(RED+GetName(OBJECT_SELF)+"'s spell is garbled!", OBJECT_SELF);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE),OBJECT_SELF,1.0);
                SetModuleOverrideSpellScriptFinished();
                //bSuccess    = FALSE;
                return;
            }

            // fire spells impacted
            switch(nSpellID)
            {
                case SPELL_BURNING_HANDS:
                case SPELL_DELAYED_BLAST_FIREBALL:
                case SPELL_FIRE_STORM:
                case SPELL_FIREBALL:
                case SPELL_FLAME_ARROW:
                case SPELL_FLAME_LASH:
                case SPELL_FLAME_STRIKE:
                case SPELL_INCENDIARY_CLOUD:
                case SPELL_METEOR_SWARM:
                case SPELL_WALL_OF_FIRE:
                case 199: // aura fire
                case 219: // bolt fire
                case 232: // cone fire
                case 239: // dragon fire
                case 264: // hellhound fire breath
                case 284: // pulse fire
                case 397: // elemental shape fire
                case SPELL_FLARE:
                case SPELL_FIREBRAND:
                case SPELL_INFERNO:
                case SPELL_GRENADE_FIRE:
                case SPELL_COMBUST:
                case SPELL_FLAME_WEAPON:
                case SPELL_DARKFIRE:
                case 658: // wildshape red wyrmling
                case 665: // red wyrmling fire
                case 690: // rdd fire breath
                case 703: // on hit dark fire
                case 721: // on hit fire shield
                case 744: // grenade firebomb
                case 772: // spiral fireball
                case 797: // dragon breath fire
                case 801: // azer fire
                case 935: // elemental fire shape
                case 1019: // familiar hellhound breath
                    bSuccess    = FALSE;
                    // cannot cast fire spells under water
                    SendMessageToPC(OBJECT_SELF, RED+"SPELL FAILURE! Fire spells can not be cast underwater.");
                    FloatingTextStringOnCreature(RED+GetName(OBJECT_SELF)+"'s spell fizzles!", OBJECT_SELF);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE),OBJECT_SELF,3.0);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_BUBBLES), OBJECT_SELF, 6.0);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(1683), OBJECT_SELF);

                    SetModuleOverrideSpellScriptFinished();
                    return;
                break;
                default:
                break;
            }
            // other spells?
        }
        // END UNDERWATER ----------------------------------------------------------
        // SILENCE? ----------------------------------------------------------------
        if( (GetHasEffect(EFFECT_TYPE_SILENCE,OBJECT_SELF) || GetHasSpellEffect(SPELL_SILENCE,OBJECT_SELF))
            && nMeta != METAMAGIC_SILENT
            && GetSpellComponent("v",nSpellID)
          )
        {
            // cannot cast verbal spells when silenced
            SendMessageToPC(OBJECT_SELF, RED+"SPELL FAILURE!");
            FloatingTextStringOnCreature(RED+GetName(OBJECT_SELF)+" is silenced!", OBJECT_SELF);
            SetModuleOverrideSpellScriptFinished();
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE),OBJECT_SELF,1.0);
            //bSuccess    = FALSE;
            return;
        }
        // END SILENCE -------------------------------------------------------------
        // DEAF? ----------------------------------------------------------------
        if(     GetHasEffect(EFFECT_TYPE_DEAF,OBJECT_SELF)
            // divine caster
            && (nSpellClass == CLASS_TYPE_CLERIC || nSpellClass == CLASS_TYPE_DRUID || nSpellClass == CLASS_TYPE_PALADIN || nSpellClass == CLASS_TYPE_RANGER)
            &&  nMeta != METAMAGIC_SILENT
            &&  GetSpellComponent("v",nSpellID)

          )
        {
            int nDC = 10 + nSpellLevel;
            if(GetCurrentHitPoints(OBJECT_SELF) <= FloatToInt(IntToFloat(GetMaxHitPoints(OBJECT_SELF))*0.75))
                nDC +=2;// distracting wounds
            if(GetSkillRank(SKILL_SPELLCRAFT, OBJECT_SELF, TRUE)>=5) // benefit of education
                nDC -=2;
            if(GetSkillRank(SKILL_PERSUADE, OBJECT_SELF, TRUE)>=5)
                nDC -=2;// persuade skill synergy bonus

            // failed concentration check
            if(!GetIsSkillSuccessful(OBJECT_SELF, SKILL_CONCENTRATION, nDC))
            {
                SendMessageToPC(OBJECT_SELF, RED+"SPELL FAILURE! Your deafness hampered your pronunciation of the words of power.");
                SetModuleOverrideSpellScriptFinished();
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE),OBJECT_SELF,1.0);
                return;
            }
        }
        // END DEAF -------------------------------------------------------------
        // ENTANGLED ----------------------------------------------------
        if( (   GetHasEffect(EFFECT_TYPE_ENTANGLE,OBJECT_SELF)
            //|| GetHasEffect(EFFECT_TYPE_SLOW,OBJECT_SELF)
            //|| GetHasEffect(EFFECT_TYPE_MOVEMENT_SPEED_DECREASE,OBJECT_SELF)
            )
            && !GetHasFeat(FEAT_COMBAT_CASTING, OBJECT_SELF)
            && nMeta != METAMAGIC_STILL
            && GetSpellComponent("s",nSpellID)
          )
        {
            int nDC = 14 + nSpellLevel;
            if(nSpellClass == CLASS_TYPE_BARD || nSpellClass == CLASS_TYPE_WIZARD || nSpellClass == CLASS_TYPE_SORCERER)
            { // arcane magic is trickier
                nDC +=2;
                if(GetSkillRank(SKILL_SPELLCRAFT, OBJECT_SELF, TRUE)<5) // penalty of an inadequate education
                    nDC +=2;
            }
            if(GetCurrentHitPoints(OBJECT_SELF) <= FloatToInt(IntToFloat(GetMaxHitPoints(OBJECT_SELF))*0.75))
                nDC +=2;// distracting wounds
            if(GetSkillRank(SKILL_TUMBLE, OBJECT_SELF, TRUE)>=5)
                nDC -=2;// tumble skill synergy bonus
            if(GetSkillRank(SKILL_DISCIPLINE, OBJECT_SELF, TRUE)>=5)
                nDC -=2;// discipline skill synergy bonus

            // failed concentration check
            if(!GetIsSkillSuccessful(OBJECT_SELF, SKILL_CONCENTRATION, nDC))
            {
                SendMessageToPC(OBJECT_SELF, RED+"SPELL FAILURE! Your predicament renders concentration difficult.");
                SetModuleOverrideSpellScriptFinished();
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE),OBJECT_SELF,1.0);
                return;
            }
        }
        // END ENTANGLED / SLOWED --------------------------------------------------
    }
    // end spell casting exclusion

    // not a Player Character - skip remainder of script
    if(!GetIsPC(OBJECT_SELF) || GetIsDM(OBJECT_SELF) || GetIsDMPossessed(OBJECT_SELF))
        return;

    // RELIGIOUS CLASSES? -------------------------------------------------------
    /*
    // CLERICS -----------------------------------------------------------------
    else if( nSpellClass == CLASS_TYPE_CLERIC) // cleric spell
    {
        if( !nDeity || nDeity == 1 || !CheckClericDomains(OBJECT_SELF, nDeity)
          )
        {
            SendMessageToPC(OBJECT_SELF, RED+"SPELL FAILURE! You have lost your faith.");
            SetModuleOverrideSpellScriptFinished();
            bSuccess = FALSE;
        }
        else if ( nDeity==3 || nDeity==15 )
        {
            SendMessageToPC(OBJECT_SELF, RED+"SPELL FAILURE! Your devotion is inadequate for casting divine spells.");
            SetModuleOverrideSpellScriptFinished();
            bSuccess = FALSE;
        }
    }
    // CLERICS. PALADINS. BLACKGUARDS. turning undead
    else if(nSpellClass == CLASS_TYPE_INVALID && nSpellID == 308)
    {
        if(  // inadequate faith
            ( !nDeity || nDeity==1 || nDeity==3 || nDeity==15)
              ||
            (// all turning abiities are absent or failed
                   //   cleric-turning absent/fails
                (!GetIsClass(OBJECT_SELF,CLASS_TYPE_CLERIC)
                    || (GetIsClass(OBJECT_SELF,CLASS_TYPE_CLERIC)&&!CheckClericDomains(OBJECT_SELF, nDeity))
                )
                && //   paladin-turning absent/fails
                (!GetIsClass(OBJECT_SELF,CLASS_TYPE_PALADIN)
                    || (GetIsClass(OBJECT_SELF,CLASS_TYPE_PALADIN)&& GetAlignmentGoodEvil(OBJECT_SELF)!=ALIGNMENT_GOOD&& GetAlignmentLawChaos(OBJECT_SELF)!=ALIGNMENT_LAWFUL)
                )
                &&//    blackguard-turning absent/fails
                (!GetIsClass(OBJECT_SELF,CLASS_TYPE_BLACKGUARD)
                    || (GetIsClass(OBJECT_SELF,CLASS_TYPE_BLACKGUARD)&& GetAlignmentGoodEvil(OBJECT_SELF)!=ALIGNMENT_EVIL)
                )
             )
          )
        {
            SendMessageToPC(OBJECT_SELF, RED+"FAILURE! Your lack of conviction disrupts the divine energy.");
            SetModuleOverrideSpellScriptFinished();
            bSuccess = FALSE;
        }
        else
        {
            // bFeatMagic = TRUE; // turning should be awarded similarly to bard song - from the spellscript itself
        }

    }
    // PALADINS ----------------------------------------------------------------
    else if( (nSpellClass == CLASS_TYPE_PALADIN // paladin spell
              ||
              (nSpellClass == CLASS_TYPE_INVALID && nSpellID==313)// lay on hands
              )
                && (    // wrong god
                    (nDeity!=4 && nDeity!=5 && nDeity!=6 && nDeity!=12 && nDeity!=14)
                        ||
                        // paladin needs to atone
                    GetLocalInt(OBJECT_SELF, "restrict_class_paladin")
                        ||
                        // paladin immoral
                    (GetAlignmentGoodEvil(OBJECT_SELF)!=ALIGNMENT_GOOD&&GetAlignmentLawChaos(OBJECT_SELF)!=ALIGNMENT_LAWFUL)
                   )
           )
    {
        SendMessageToPC(OBJECT_SELF, RED+"FAILURE! You lack adequate faith and devotion.");
        SetModuleOverrideSpellScriptFinished();
        bSuccess = FALSE;
    }
    // RANGERS -----------------------------------------------------------------
    else if( nSpellClass == CLASS_TYPE_RANGER // ranger spell
            && !nDeity
                //&& sDeity == "undevoted"
           )
    {
        SendMessageToPC(OBJECT_SELF, RED+"SPELL FAILURE! You have lost your faith.");
        SetModuleOverrideSpellScriptFinished();
        bSuccess = FALSE;
    }
    */
    // DRUIDS ------------------------------------------------------------------

    else if(    nSpellClass == CLASS_TYPE_DRUID // druid spell
            || (nSpellClass == CLASS_TYPE_INVALID
                && (    (nSpellID >= 397 && nSpellID <=405)// druid wildshaping or elemshaping
                    ||  (nSpellID >= 875 && nSpellID <=880))
               )
            )
    {
        /*
        if(     nDeity!=1
            || (GetAlignmentGoodEvil(OBJECT_SELF)!=ALIGNMENT_NEUTRAL && GetAlignmentGoodEvil(OBJECT_SELF)!=ALIGNMENT_NEUTRAL)
          )
        {
            SendMessageToPC(OBJECT_SELF, RED+"FAILURE! You are out of balance with Nature.");
            SetModuleOverrideSpellScriptFinished();
            bSuccess = FALSE;
        }
        else
        */
        {
         // TABOO CHECK --------------------------------------------------------
         object oEquipment;
         int nSlot;
         int nIt = 1;

         // check item slots
         while (nIt<=3)
         {
            if(nIt==1)
                nSlot = INVENTORY_SLOT_CHEST;
            else if (nIt==2)
                nSlot = INVENTORY_SLOT_HEAD;
            else if (nIt==3)
                nSlot = INVENTORY_SLOT_LEFTHAND;

            // check item material validity
            oEquipment = GetItemInSlot(nSlot, OBJECT_SELF);
            if(GetIsObjectValid(oEquipment)&&  GetItemHasItemProperty(oEquipment, ITEM_PROPERTY_MATERIAL))
            {
              // look for forbidden metals on druid's worn equipment (shields, helmets, armor)
              itemproperty IP = GetFirstItemProperty(oEquipment);
              int nMaterial;
              while(GetIsItemPropertyValid(IP))
              {
                if(GetItemPropertyType(IP)==ITEM_PROPERTY_MATERIAL)
                {
                    nMaterial=GetItemPropertyCostTableValue(IP);
                    if( nMaterial<=6)
                    {
                        SendMessageToPC(OBJECT_SELF, RED+"FAILURE! Your metal armor disrupted the natural magic.");
                        SetModuleOverrideSpellScriptFinished();
                        bSuccess = FALSE;
                        break;
                    }
                }
                IP = GetNextItemProperty(oEquipment);
              } // end loop through item properties for druid
            } // end material validity check
          ++nIt; // iterate item slot
         } // get next item to check for druid
        }
    } // END DRUIDS ------------------------------------------------------------

      // General check for all pantheon based restrictions (except druid metal) 
      // This makes most of the above code obsolete but we need to enhance it
      // for the paladin deity restriction - this should be done in the deity selection
      // code to just prevent it.
        // Check for divine casters being in favor or not
        SetLocalInt(oCaster, "deity_tmp_op", 4);
        spell_debug("Deity system hook called");
        if (ExecuteScriptAndReturnInt("deity_do_op",oCaster)) {
                string sMsg = GetLocalString(oCaster, "spell_hook_message");
                if (sMsg != "")
                        FloatingTextStringOnCreature(sMsg, oCaster);
                //SetModuleOverrideSpellScriptFinished();
                DeleteLocalString(oCaster, "spell_hook_message");
                spell_debug("Deity system disallowed spell");
                //return;
        }
        DeleteLocalInt(oCaster, "deity_tmp_op");


    // END RELIGIOUS CLASSES ---------------------------------------------------
    // Successful? (spells and special abilities/feats)
    if(bSuccess)
    {
        if(nSpellClass != CLASS_TYPE_INVALID || bFeatMagic)// SPELL?
        {
            object oMod     = GetModule();
            object oTarget  = GetSpellTargetObject();
            // set locals to track spell/feat in other scripts
            SetLocalObject(oMod, "SPELLLAST_CASTER", OBJECT_SELF);
            SetLocalInt(OBJECT_SELF, "SPELLLAST_CASTER_LEVEL", nCasterLevel);
            SetLocalInt(OBJECT_SELF, "SPELLLAST_ID", nSpellID);
            SetLocalInt(OBJECT_SELF, "SPELLLAST_LEVEL", nSpellLevel);
            //SetLocalInt(OBJECT_SELF, "SPELLLAST_CLASS", nSpellClass);
            //SetLocalInt(OBJECT_SELF, "SPELLLAST_DC", nDC);
            SetLocalInt(OBJECT_SELF, "SPELLLAST_META", nMeta);
            SetLocalObject(OBJECT_SELF, "SPELLLAST_TARGET", oTarget);

            string sRange;

            // SPELLFOCUS HOOK -------------------------------------------------
            if(     GetObjectType(oTarget)==OBJECT_TYPE_ITEM
                &&  GetLocalInt(oTarget, SPELLFOCUS_TYPE)
              )
            {
                if(GetIsSpellFocusSuccessful(oTarget, nSpellID))
                {
                    SetLocalInt(OBJECT_SELF, SPELLFOCUS_USE, TRUE);
                    SetLocalObject(OBJECT_SELF, SPELLFOCUS_OBJECT, oTarget);
                }
            }
            // END SPELLFOCUS HOOK ---------------------------------------------
            // FAMILIAR HOOK ---------------------------------------------------
            // determine if target is the master's familiar and spell is hostile
            // and if so do not continue with normal spell cast
            else if(    GetLocalInt(OBJECT_SELF, HAS_PET)
                    &&  oTarget!=OBJECT_INVALID

                    // Only one of the following should be used. See FamiliarSpawnEvent(object oMaster)
                    //&&  oTarget==GetAssociate(ASSOCIATE_TYPE_FAMILIAR) // more_efficient_familiar
                    &&  oTarget==GetLocalObject(OBJECT_SELF, FAMILIAR) // more_flexible_familiar
                    &&  Get2DAString("spells","HostileSetting",nSpellID)=="1"
                    &&  nSpellID!=SPELL_BIND_FAMILIAR
                   )
            {
                // get the familiar's hide.
                // we apply a feat for casting stored spells to the familiar's hide
                object oHide    = GetItemInSlot(INVENTORY_SLOT_CARMOUR,oTarget);

                // clear hide of spell storing feats
                int nIPFeat     = GetLocalInt(oTarget, "FAMILIAR_SPELL_PROPERTY");
                if(nIPFeat)
                    RemoveMasterSpellsFromFamiliarHide(oHide, nIPFeat, oTarget);

                // load up the familiar with spell data
                if(sRange=="T")     {nIPFeat=IPFEAT_FAMILIAR_SPELL_TOUCH;}
                else if(sRange=="S"){nIPFeat=IPFEAT_FAMILIAR_SPELL_SHORT;}
                else if(sRange=="M"){nIPFeat=IPFEAT_FAMILIAR_SPELL_MEDIUM;}
                else if(sRange=="L"){nIPFeat=IPFEAT_FAMILIAR_SPELL_LONG;}
                SetLocalInt(oTarget, "FAMILIAR_SPELL_PROPERTY", nIPFeat);
                SetLocalInt(oTarget, "FAMILIAR_SPELL_ID", nSpellID);
                SetLocalInt(oTarget, "FAMILIAR_SPELL_LEVEL", nCasterLevel);
                SetLocalInt(oTarget, "FAMILIAR_SPELL_DC", nDC);
                SetLocalInt(oTarget, "FAMILIAR_SPELL_META", nMeta);

                // add the appropriate spell storing feat to the familiar
                AddItemProperty(    DURATION_TYPE_PERMANENT,
                                    ItemPropertyBonusFeat(nIPFeat),
                                    oHide
                                );
                // VFX so that it looks like a stored spell
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HOLY_AID), oTarget);
                // Feedback to Spell Caster
                string sSpell   = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpellID)));
                SendMessageToPC(OBJECT_SELF, DMBLUE+"Spell Storing. "+PALEBLUE+sSpell+DMBLUE+" stored on "+GetName(oTarget)+".");
                SetModuleOverrideSpellScriptFinished();
            }
            // END FAMILIAR HOOK -----------------------------------------------

            // SPELL CAST SUCCESSFULLY
            // PCs have a user event for spell casting of XP awards
            // and TELL everyone what spell the PC cast
            // also handle Share Spell
            SignalEvent(oMod, EventUserDefined(EVENT_SPELLCAST)); // spellcast event in _mod_userdef
        }
        else // FEAT
        {
            // NON MAGICAL FEAT USED SUCCESSFULLY

        }

        spell_debug("Calling tb_spell_router - X2_L_BLOCK_LAST_SPELL = " + IntToString(GetLocalInt(oCaster, "X2_L_BLOCK_LAST_SPELL")), oCaster);
        ExecuteScript("tb_spell_router", oCaster);
        spell_debug("Back from router - X2_L_BLOCK_LAST_SPELL = " + IntToString(GetLocalInt(oCaster, "X2_L_BLOCK_LAST_SPELL")), oCaster);


    }
  }// END SPELLS and FEATS -----------------------------------------------------
}
