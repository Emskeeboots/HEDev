//::///////////////////////////////////////////////
//:: _inc_terrain
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created : henesua (2016 aug 2)
//:://////////////////////////////////////////////

// INCLUDES
#include "_inc_spells"
#include "_inc_util"  // creature routines
#include "_inc_light"


// globals -------------------------
const int ROUND_DUR = 6;
float fROUND_DUR    = IntToFloat(ROUND_DUR);

// DECLARATIONS

// - [FILE: _inc_terrain]
void EnterUnderwaterZone(object creature, object zone_source, object zone_tracker);
// - [FILE: _inc_terrain]
void ExitUnderwaterZone(object creature, object zone_source, object zone_tracker);
// - [FILE: _inc_terrain]
void UnderwaterApplyEffects(object creature, int feedback_verbose=FALSE);
// - [FILE: _inc_terrain]
object GetZoneTracker(object zone_source);
// - [FILE: _inc_terrain]
void TerrainRemoveEffects(object creature, object terrain=OBJECT_SELF, int effect_type=-1);
// - [FILE: _inc_terrain]
void TerrainSetFootsteps(object oCreature, int nFeetType=FOOTSTEP_TYPE_HOOF_LARGE);
// - [FILE: _inc_terrain]
void RestoreFootsteps(object oCreature);

// IMPLEMENTATION --------------------

void EnterUnderwaterZone(object creature, object zone_source, object zone_tracker)
{
    // set the ID of the underwater zone on the creature (to mark being in this zone)
    string underwater_id= ObjectToString(zone_tracker);
    SetLocalString(creature, "UNDERWATER_ID", underwater_id);

    if( GetAreaFromLocation(GetLocation(creature))==OBJECT_INVALID )
    {
        if(MODULE_DEBUG_MODE){SendMessageToPC(creature, "Delay Enter Caller("+ObjectToString(zone_source)+") - Tracker("+ObjectToString(zone_tracker)+")" );}
        DelayCommand(1.5,EnterUnderwaterZone(creature, zone_source, zone_tracker));
    }
    else
    {
        // debug string entry
        if(MODULE_DEBUG_MODE){SendMessageToPC(creature, "Enter Caller("+ObjectToString(zone_source)+") - Tracker("+ObjectToString(zone_tracker)+")" );}


        // if this character has gaseous form, paralyze them
        if(GetHasSpellEffect(SPELL_GASEOUS_FORM,creature))
        {
            effect paralyze = EffectCutsceneParalyze();
            AssignCommand(  creature,
                            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, paralyze, creature, 12.0+IntToFloat(d6()))
                         );
            FloatingTextStringOnCreature(RED+"The gaseous one is having difficulty in the water.",creature);
        }

        // forbidden items are destroyed now
        object item_left    = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, creature);
        if(     GetItemHasItemProperty(item_left, ITEM_PROPERTY_LIGHT)
            &&  GetBaseItemType(item_left)==BASE_ITEM_TORCH
            &&  !GetHasSpellEffect(SPELL_CONTINUAL_FLAME, item_left)
          )
        {
            PCLostLight(creature, item_left);
            SendMessageToPC(creature, RED+"The "+GetName(item_left)+" is ruined underwater!");
            DestroyObject(item_left);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_BUBBLES), creature, 3.0);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(1677), creature);
        }

        // initialize entry phenotype
        if(!CreatureGetIsAquatic(creature))
        {
            int appearance_type = GetAppearanceType(creature);
            if(     appearance_type<=6
                ||( appearance_type==474 || appearance_type==475)
                ||(appearance_type>=1281 && appearance_type<=1296)
              )
            {
                if(GetPhenoType(creature)!=PHENOTYPE_FLYING)
                {
                    //DelayCommand(2.0, SetCameraMode(creature, CAMERA_MODE_TOP_DOWN));
                    DelayCommand(1.0, SetPhenoType(PHENOTYPE_FLYING, creature));
                    //DelayCommand(2.0, SetCameraMode(creature, CAMERA_MODE_TOP_DOWN));
                }
            }
        }

        TerrainSetFootsteps(creature, FOOTSTEP_TYPE_SHARK);
        // unequip torches, candles etc....

        AssignCommand(zone_tracker, UnderwaterApplyEffects(creature, TRUE));
    }
}

void ExitUnderwaterZone(object creature, object zone_source, object zone_tracker )
{
    // debug string exit
    if(MODULE_DEBUG_MODE){SendMessageToPC(creature, "Exit Caller("+ObjectToString(zone_source)+") - Tracker("+ObjectToString(zone_tracker)+")" );}

    string zone_id  = ObjectToString(zone_tracker);
    if(!GetLocalInt(creature,"EXITTED_"+zone_id))
    {
        SetLocalInt(creature,"EXITTED_"+zone_id, TRUE);
        // clean up
        if(GetLocalString(creature, "UNDERWATER_ID")==zone_id)
            DeleteLocalString(creature, "UNDERWATER_ID");


        // remove effects
        TerrainRemoveEffects(creature, zone_tracker);
        DeleteLocalInt(creature,"UNDERWATER_EFFECTS");
    }

    if( GetAreaFromLocation(GetLocation(creature))==OBJECT_INVALID )
    {
        if(MODULE_DEBUG_MODE){SendMessageToPC(creature, "Delay Exit Caller("+ObjectToString(zone_source)+") - Tracker("+ObjectToString(zone_tracker)+")" );}
        DelayCommand(1.5,ExitUnderwaterZone(creature, zone_source, zone_tracker));
    }
    else
    {
        DeleteLocalInt(creature,"EXITTED_"+zone_id);

        if(GetLocalString(creature, "UNDERWATER_ID")=="")
        {
            if(MODULE_DEBUG_MODE){ SendMessageToPC(creature,"EXITING WATER"); }
            string puddle_ref   = "nw_plc_puddle"+IntToString(d2());

            // restore phenotype
            SetCameraMode(creature, CAMERA_MODE_TOP_DOWN);
            SetPhenoType(CreatureGetNaturalPhenoType(creature), creature);
            RestoreFootsteps(creature);
            SetCameraMode(creature, CAMERA_MODE_TOP_DOWN);

            // not until we can be assured we are no longer underwater is this cleared
            DeleteLocalInt(creature,"HOLDING_BREATH_ROUNDS");

            object puddle   = CreateObject(OBJECT_TYPE_PLACEABLE,puddle_ref,GetLocation(creature));
            string water_sound= "as_na_splash"+IntToString(d2());
            DelayCommand(0.1, AssignCommand(puddle, PlaySound(water_sound) ) );
            DestroyObject(puddle, 60.0);
        }
    }
}

void UnderwaterApplyEffects(object creature, int feedback_verbose=FALSE)
{
    // OBJECT_SELF is the zone_tracker object

    string underwater_id  = ObjectToString(OBJECT_SELF);
    if(GetLocalString(creature, "UNDERWATER_ID")!=underwater_id)
        return;

    if(GetIsDead(creature))
    {
        //DelayCommand(fROUND_DUR, UnderwaterApplyEffects(creature,feedback_verbose) );
        SendMessageToPC(creature,RED+"You have drowned!");
        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDeath(),creature);
        return;
    }
    else if( GetAreaFromLocation(GetLocation(creature))==OBJECT_INVALID )
    {
        if(MODULE_DEBUG_MODE){SendMessageToPC(creature, "Delay Underwater Effects("+ObjectToString(OBJECT_SELF)+")");}
        DelayCommand(1.5, UnderwaterApplyEffects(creature, feedback_verbose) );
    }
    // APPLYING UNDERWATER EFFECTS HERE ----------------------------------------
    else
    {
        int racial_type = GetRacialType(creature);

        int breathes    = (     racial_type!=RACIAL_TYPE_UNDEAD
                            &&  racial_type!=RACIAL_TYPE_OOZE
                            &&  racial_type!=RACIAL_TYPE_CONSTRUCT
                            &&  !GetLocalInt(OBJECT_SELF,"UNDERWATER_BREATHABLE")
                           );
        // bubble vfx
        if(     breathes
            && !GetHasSpellEffect(SPELL_AIR_BUBBLE, creature)
           )
        {
            float delay = IntToFloat(Random(20))/10.0;
            float dur   = 2.5+IntToFloat(Random(18))/10.0;;

            DelayCommand( delay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY,SupernaturalEffect(EffectVisualEffect(VFX_DUR_BUBBLES)),creature, dur ));
        }


        int water_impact    = GetLocalInt(creature,"UNDERWATER_EFFECTS");
        // NOT AQUATIC ---------------------------------------------------------
        if(!CreatureGetIsAquatic(creature))
        {
            // impacted movement?
            if(water_impact & IMPACT_MOVEMENT)
            {
                if(     CreatureGetIsIncorporeal(creature)
                    ||  GetHasSpellEffect(SPELL_FREEDOM_OF_MOVEMENT, creature)
                  )
                {
                    // remove speed impact
                    TerrainRemoveEffects(creature, OBJECT_SELF, EFFECT_TYPE_MOVEMENT_SPEED_DECREASE);

                    water_impact -= IMPACT_MOVEMENT;
                }
                else
                {
                    location last   = GetLocalLocation(creature, "SWIM_LAST");
                    location this   = GetLocation(creature);
                    if(     last==this
                        &&  !GetIsInCombat(creature)
                      )
                    {
                        water_impact -= IMPACT_MOVEMENT;
                        // remove speed impact from staying in place for a round
                        TerrainRemoveEffects(creature, OBJECT_SELF, EFFECT_TYPE_MOVEMENT_SPEED_DECREASE);
                    }
                    else
                    {
                        SetLocalLocation(creature, "SWIM_LAST",this);
                    }
                }
            }
            else
            {
                if(     !CreatureGetIsIncorporeal(creature)
                    &&  !GetHasSpellEffect(SPELL_FREEDOM_OF_MOVEMENT, creature)
                  )
                {
                    if(!GetIsSkillSuccessful(creature,SKILL_SWIM,10))
                    {
                        SetLocalLocation(creature, "SWIM_LAST",GetLocation(creature));
                        // apply speed impact
                        int percent     = 50;
                        effect slowed   = EffectMovementSpeedDecrease(percent);
                               slowed   = EffectLinkEffects(slowed,EffectSavingThrowDecrease(SAVING_THROW_REFLEX,3));
                               slowed   = EffectLinkEffects(slowed,EffectACDecrease(3));
                               slowed   = SupernaturalEffect(slowed);
                               slowed   = ExtraordinaryEffect(slowed);
                        ApplyEffectToObject(DURATION_TYPE_PERMANENT,slowed,creature);
                        water_impact += IMPACT_MOVEMENT;
                    }
                }
            }

            // impacted breathing? .............................................
            int rounds_breath_held  = GetLocalInt(creature,"HOLDING_BREATH_ROUNDS");
            if(!breathes)
            { // this creature does not breathe so it does not matter
                rounds_breath_held = 0;
                if(water_impact & IMPACT_BREATHING)
                    water_impact -= IMPACT_BREATHING;
            }
            else if(water_impact & IMPACT_BREATHING)
            { // breathing previously impacted
                if(     GetHasSpellEffect(SPELL_AIR_BUBBLE, creature)
                    ||  GetHasSpellEffect(SPELL_WATER_BREATHING, creature)
                    ||  GetHasFeat(FEAT_WATER_BREATHING, creature)
                  )
                {
                    // take a breath
                    rounds_breath_held = 0;
                    water_impact -= IMPACT_BREATHING;

                    SendMessageToPC(creature,DMBLUE+"You can breathe!");
                }
                else
                {
                    // hold breath
                    //rounds_breath_held++;
                    // time to take damage?
                    int rounds_left = GetAbilityScore(creature,ABILITY_CONSTITUTION)-rounds_breath_held++;
                    if(rounds_left<1)
                    {
                    // DROWNING ------------------------------------------------
                        SendMessageToPC(creature,RED+"You are drowning!");
                        int damage  = GetMaxHitPoints(creature)/3;
                        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDamage(damage), creature);

                        int struggle_dc = 18;
                        if(GetSkillRank(SKILL_SWIM,creature)>=5)
                            struggle_dc -= 2;
                        if(GetSkillRank(SKILL_CONCENTRATION,creature)>=5)
                            struggle_dc -= 2;
                        if(GetSkillRank(SKILL_DISCIPLINE,creature)>=5)
                            struggle_dc -= 2;

                        if(!FortitudeSave(creature,struggle_dc,SAVING_THROW_TYPE_PARALYSE))
                            ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectParalyze(), creature, fROUND_DUR);
                    // END DROWNING --------------------------------------------
                    }
                    else
                    {
                        SendMessageToPC(creature,PALEBLUE+IntToString(rounds_left*6)+DMBLUE+" seconds remaining of air in your lungs.");
                    }
                }
            }
            else
            { // just having breath checked now
                if(     GetHasSpellEffect(SPELL_AIR_BUBBLE, creature)
                    ||  GetHasSpellEffect(SPELL_WATER_BREATHING, creature)
                    ||  GetHasFeat(FEAT_WATER_BREATHING, creature)
                  )
                {
                    rounds_breath_held = 0;
                }
                else
                {
                    // must start holding breath
                    //rounds_breath_held++;
                    water_impact += IMPACT_BREATHING;
                    int rounds_left = GetAbilityScore(creature,ABILITY_CONSTITUTION)-rounds_breath_held++;
                    SendMessageToPC(creature,DMBLUE+"You are holding your breath and can remain doing so for another "+PALEBLUE+IntToString(rounds_left*ROUND_DUR)+DMBLUE+" seconds.");
                }
            }
            SetLocalInt(creature,"HOLDING_BREATH_ROUNDS",rounds_breath_held);
            // end breathing .......................................................

            // impacted speech?
            if(GetLocalInt(OBJECT_SELF,"UNDERWATER_BREATHABLE"))
            {
                if(water_impact & IMPACT_SPEECH)
                {
                    water_impact -= IMPACT_SPEECH;
                    SendMessageToPC(creature,DMBLUE+"You can speak here!");
                }
            }
            else if(water_impact & IMPACT_SPEECH)
            { // breathing previously impacted
                if( GetHasSpellEffect(SPELL_AIR_BUBBLE, creature) )
                {
                    water_impact -= IMPACT_SPEECH;
                    SendMessageToPC(creature,DMBLUE+"You can speak now!");
                }
            }
            else
            {
                if( !GetHasSpellEffect(SPELL_AIR_BUBBLE, creature) )
                {
                    water_impact += IMPACT_SPEECH;
                    SendMessageToPC(creature,RED+"You are unable to speak clearly underwater!");
                }
            }

            SetLocalInt(creature,"UNDERWATER_EFFECTS", water_impact);
        }
        // AQUATIC -------------------
        else
        {
            DeleteLocalInt(creature,"HOLDING_BREATH_ROUNDS");
            DeleteLocalInt(creature,"UNDERWATER_EFFECTS");
            if(water_impact)
                TerrainRemoveEffects(creature, OBJECT_SELF);
        }


        // this function iterates (executing on zone_tracker).
        DelayCommand(fROUND_DUR, UnderwaterApplyEffects(creature,feedback_verbose) );
    }
}

object GetZoneTracker(object zone_source)
{
    object zone_tracker = GetLocalObject(zone_source,"ZONE_TRACKER");
    if(!GetIsObjectValid(zone_tracker))
    {
        location zone_loc   = GetLocation(zone_source);
        if(!GetIsObjectValid(GetAreaFromLocation(zone_loc)) )
            zone_loc    = Location(zone_source,Vector(), 0.0);
        //if(!GetIsObjectValid(GetAreaFromLocation(zone_loc)) )
            //zone_loc    = GetLocation(GetWaypointByTag("utility_location"));
        zone_tracker        = CreateObject(OBJECT_TYPE_PLACEABLE,"plc_invisobj",zone_loc);
        SetPlotFlag(zone_tracker,TRUE);
        SetName(zone_tracker,GetName(zone_source));

        SetLocalObject(zone_source,"ZONE_TRACKER", zone_tracker);
    }
    return zone_tracker;
}

void TerrainRemoveEffects(object creature, object terrain=OBJECT_SELF, int effect_type=-1)
{
    // remove effects applied by terrain
    effect eEffect = GetFirstEffect(creature);
    if(effect_type == -1)
    {
        while(GetIsEffectValid(eEffect))
        {
            if( GetEffectCreator(eEffect) == terrain )
                RemoveEffect(creature,eEffect);

            eEffect = GetNextEffect(creature);
        }
    }
    else
    {
        while(GetIsEffectValid(eEffect))
        {
            if(     GetEffectCreator(eEffect) == terrain
                &&  GetEffectType(eEffect) == effect_type
              )
            {
                RemoveEffect(creature,eEffect);
            }
            eEffect = GetNextEffect(creature);
        }
    }
}

void TerrainSetFootsteps(object oCreature, int nFeetType=FOOTSTEP_TYPE_HOOF_LARGE)
{
 int nFeet      = GetFootstepType(oCreature);
 if(    nFeet == FOOTSTEP_TYPE_INVALID
    ||  nFeet == FOOTSTEP_TYPE_FEATHER_WING
    ||  nFeet == FOOTSTEP_TYPE_LEATHER_WING
    ||  (nFeet >= 13 && nFeet <= 16)
    ||  nFeet == 18
    ||  nFeet == 19
    ||  (nFeet > 20 && nFeet <30)
   )
    return;

 int nDefault   = GetLocalInt(oCreature, "FOOTSTEP_DEFAULT");
 if(!nDefault && nFeet<30){nDefault = nFeet;}
 // Set new footsteps
 int nFootstepType   = (30*nFeetType)+nDefault;

    SetFootstepType(nFootstepType, oCreature);
}

void RestoreFootsteps(object oCreature)
{
 if (!GetIsObjectValid(oCreature) || GetFootstepType(oCreature) == FOOTSTEP_TYPE_INVALID )
    return;

 SetFootstepType(FOOTSTEP_TYPE_DEFAULT, oCreature);
 int nFeet  = GetFootstepType(oCreature);
 SetLocalInt(oCreature, "FOOTSTEP_DEFAULT", nFeet);
}

//void main(){}
