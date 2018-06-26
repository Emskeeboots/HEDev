//::///////////////////////////////////////////////
//:: _dlg_atone
//:://////////////////////////////////////////////
/*
    Z-Dialog Script for the Atonement Spell

*/
//:://////////////////////////////////////////////
//:: Created:   Henesua(2013 sept 17)
//:: Modified:
//:://////////////////////////////////////////////

#include "zdlg_include_i"

//#include "x3_inc_skin"
#include "_inc_constants"
#include "_inc_deity"
#include "_inc_xp"

// Constants
const string PAGE_START     = "atone_start";
const string PAGE_YES       = "atone_yes";
const string PAGE_NO        = "atone_no";
const string PAGE_ATONED    = "atoned";


// DECLARATIONS
// custom

string GetCrimes(object oPC);

string AtonePaladin(object oPC, object oPriest);

string AtoneMonk(object oPC, object oPriest);

string AtoneCleric(object oPC, object oPriest);

string AtoneDruid(object oPC, object oPriest);

string Realignment(object oPC, object oPriest);

// Zdlg
void Init();
void PageInit();
void CleanUp();
void HandleSelection();

// IMPLEMENTATION
// custom ----------------------------------------------------------------------
string GetCrimes(object oPC)
{
    int nDeity  = GetDeityIndex(oPC);

    string sCrimes;
    switch(nDeity)
    {
        case  0: sCrimes = "";
                    break; // Undevoted
        case  1: sCrimes = "Have you resolved to restore your balance with Nature?";
                    break; // Nature
        case  2: sCrimes = "Do you seek The Mystery?";
                    break; // The Mystery
        case  3:
                    //break; // The Faith (general)
        case  4:
                    //break; // The Faith (apriana)
        case  5:
                    //break; // The Faith (aurelia)
        case  6:
                    //break; // The Faith (barnabus)
        case  7:
                    //break; // The Faith (cagli)
        case  8:
                    //break; // The Faith (cosm)
        case  9:
                    //break; // The Faith (cyriacus)
        case 10:
                    //break; // The Faith (kester)
        case 11:
                    //break; // The Faith (kilili)
        case 12:
                    //break; // The Faith (maia)
        case 13:
                    //break; // The Faith (orcus)
        case 14: sCrimes = "Do you atone for your lapse of Faith?";
                    break; // The Faith (veneros)
        case 15: sCrimes = "Do you atone for your transgressions against the gods?";
                    break; // Polytheist(general)
        case 16: sCrimes = "Do you atone for your moral imbalance?";
                    break; // Polytheist(true neutral)
        case 17: sCrimes = "Do you atone for your evil acts?";
                    break; // Polytheist(neutral good)
        case 18: sCrimes = "Do you atone for your good acts?";
                    break; // Polytheist(neutral evil)
        case 19: sCrimes = "Do you atone for your lawful acts?";
                    break; // Polytheist(chaotic neutral)
        case 20: sCrimes = "Do you atone for your unlawful acts?";
                    break; // Polytheist(lawful neutral)
        case 21: sCrimes = "Do you atone for your oppressive acts?";
                    break; // Polytheist(chaotic good)
        case 22: sCrimes = "Do you atone for your destructive acts?";
                    break; // Polytheist(lawful good)
        case 23: sCrimes = "Do you atone for your rebelious acts?";
                    break; // Polytheist(lawful evil)
        case 24: sCrimes = "Do you atone for your crusade against evil?";
                    break; // Polytheist(chaotic evil)
        case 25: sCrimes = "Do you atone for abusing Apriana's grace?";
                    break; // Polytheist(apriana)
        case 26: sCrimes = "Do you atone for hiding Aurelia's light?";
                    break; // Polytheist(aurelia)
        case 27: sCrimes = "Do you atone for your weakness in carrying out Barnabus's will?";
                    break; // Polytheist(barnabus)
        case 28: sCrimes = "Do you atone for ignoring Cagli's teachings?";
                    break; // Polytheist(cagli)
        case 29: sCrimes = "Do you atone for mishandling Cosm's power?";
                    break; // Polytheist(cosm)
        case 30: sCrimes = "Do you atone for straying from Cyriacus's teachings?";
                    break; // Polytheist(cyriacus)
        case 31: sCrimes = "Do you atone for straying from Kester's path?";
                    break; // Polytheist(kester)
        case 32: sCrimes = "Do you atone for ignoring Kilili's teachings?";
                    break; // Polytheist(kilili)
        case 33: sCrimes = "Do you atone for abusing Maia's tenets?";
                    break; // Polytheist(maia)
        case 34: sCrimes = "Do you atone for wasting Orcus's gifts?";
                    break; // Polytheist(orcus)
        case 35: sCrimes = "Do you atone for wasting Veneros's knowledge?";
                    break; // Polytheist(veneros)

        default: sCrimes = "Do you atone for abusing the tenets of "+GetDeity(oPC)+"?";
                    break; // default
    }

    return sCrimes;
}

string AtonePaladin(object oPC, object oPriest)
{
    string sAtone   = "Proceed with honor, dignity, valor, and righteousness.";

    DeleteLocalInt(oPC, "restrict_class_paladin");
    DeleteSkinInt(oPC, "restrict_class_paladin");

    effect eVis1    = EffectVisualEffect(VFX_IMP_PULSE_HOLY);
    effect eVis2    = EffectVisualEffect(VFX_FNF_STRIKE_HOLY);
    effect eVis3    = EffectVisualEffect(VFX_IMP_HEAD_HOLY);

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis1, oPC);
    DelayCommand(1.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oPC));
    DelayCommand(3.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis3, oPC));

    AdjustAlignment(oPC, ALIGNMENT_GOOD, 100, FALSE);
    AdjustAlignment(oPC, ALIGNMENT_LAWFUL, 100, FALSE);
    //SetXP(oPriest, GetXP(oPriest)-500);
    XPPenalty(oPC, 500, RED+"Casting of Atone has cost you 500 XP!");
    return sAtone;
}

string AtoneMonk(object oPC, object oPriest)
{
    string sAtone   = "Walk the path.";

    DeleteLocalInt(oPC, "restrict_class_monk");
    DeleteSkinInt(oPC, "restrict_class_monk");

    effect eVis1    = EffectVisualEffect(VFX_IMP_PULSE_HOLY_SILENT);
    effect eVis3    = EffectVisualEffect(VFX_IMP_HEAD_MIND);

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis1, oPC);
    DelayCommand(2.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis3, oPC));

    AdjustAlignment(oPC, ALIGNMENT_LAWFUL, 100, FALSE);
    //SetXP(oPriest, GetXP(oPriest)-500);
    XPPenalty(oPC, 500, RED+"Casting of Atone has cost you 500 XP!");
    return sAtone;
}

string AtoneCleric(object oPC, object oPriest)
{
    string sAtone   = "Do not forget your responsibilities.";

    int nDeity      = GetDeityIndex(oPC);
    DeleteLocalInt(oPC, "restrict_class_cleric");
    DeleteSkinInt(oPC, "restrict_class_cleric");
    int nAlignGE, nAlignLC;

    if(CheckClericAlignment(oPriest,nDeity))
    {
        nAlignGE    = GetAlignmentGoodEvil(oPriest);
        nAlignLC    = GetAlignmentLawChaos(oPriest);
    }
    else
    {
        nAlignGE    = GetDeityAlignmentGE(nDeity);
        nAlignLC    = GetDeityAlignmentLC(nDeity);

        if(GetHasFeat(FEAT_GOOD_DOMAIN_POWER, oPriest))
            nAlignGE = ALIGNMENT_GOOD;
        else if(GetHasFeat(FEAT_EVIL_DOMAIN_POWER, oPriest))
            nAlignGE = ALIGNMENT_EVIL;
        if(GetHasFeat(FEAT_LAW_DOMAIN_POWER, oPriest))
            nAlignLC = ALIGNMENT_LAWFUL;
        else if(GetHasFeat(FEAT_CHAOS_DOMAIN_POWER, oPriest))
            nAlignLC = ALIGNMENT_CHAOTIC;
    }

    int nVis1, nVis2, nVis3;

    if(nAlignGE==ALIGNMENT_GOOD)
    {
        nVis1 = VFX_IMP_PULSE_HOLY;
        nVis2 = VFX_FNF_STRIKE_HOLY;
        nVis3 = VFX_IMP_HEAD_HOLY;
    }
    else if(nAlignGE==ALIGNMENT_EVIL)
    {
        nVis1 = VFX_IMP_EVIL_HELP;
        nVis2 = VFX_FNF_DEMON_HAND;
        nVis3 = VFX_IMP_HEAD_EVIL;
    }
    else
    {
        nVis1 = VFX_IMP_PDK_GENERIC_PULSE;
        nVis2 = VFX_FNF_SOUND_BURST_SILENT;
        nVis3 = VFX_IMP_HEAD_ODD;

        if(GetHasFeat(FEAT_FIRE_DOMAIN_POWER, oPriest))
            nVis1 = VFX_IMP_PULSE_FIRE;
        else if(GetHasFeat(FEAT_WATER_DOMAIN_POWER, oPriest))
            nVis1 = VFX_IMP_PULSE_WATER;
        if(GetHasFeat(FEAT_AIR_DOMAIN_POWER, oPriest))
            nVis2 = VFX_IMP_PULSE_WIND;
        else if(GetHasFeat(FEAT_EARTH_DOMAIN_POWER, oPriest))
            nVis2 = VFX_IMP_PULSE_NATURE;
        if(GetHasFeat(FEAT_MAGIC_DOMAIN_POWER, oPriest))
            nVis3 = VFX_IMP_HEAD_ELECTRICITY;
        else if(GetHasFeat(FEAT_KNOWLEDGE_DOMAIN_POWER, oPriest))
            nVis3 = VFX_IMP_HEAD_MIND;
    }

    effect eVis1    = EffectVisualEffect(nVis1);
    effect eVis2    = EffectVisualEffect(nVis2);
    effect eVis3    = EffectVisualEffect(nVis3);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis1, oPC);
    DelayCommand(1.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oPC));
    DelayCommand(3.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis3, oPC));


    AdjustAlignment(oPC, nAlignGE, 100, FALSE);
    AdjustAlignment(oPC, nAlignLC, 100, FALSE);
    if(nAlignLC==ALIGNMENT_NEUTRAL && nAlignGE!=ALIGNMENT_NEUTRAL)
        AdjustAlignment(oPC, nAlignGE, 100, FALSE);

    //SetXP(oPriest, GetXP(oPriest)-500);
    XPPenalty(oPC, 500, RED+"Casting of Atone has cost you 500 XP!");
    return sAtone;
}

string AtoneDruid(object oPC, object oPriest)
{
    string sAtone   = "Protect the natural balance.";

    DeleteLocalInt(oPC, "restrict_class_druid");
    DeleteSkinInt(oPC, "restrict_class_druid");

    effect eVis1    = EffectVisualEffect(VFX_IMP_PULSE_NATURE);
    effect eVis2    = EffectVisualEffect(VFX_FNF_NATURES_BALANCE);
    effect eVis3    = EffectVisualEffect(VFX_IMP_HEAD_NATURE);

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis1, oPC);
    DelayCommand(1.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oPC));
    DelayCommand(3.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis3, oPC));

    AdjustAlignment(oPC, ALIGNMENT_NEUTRAL, 100, FALSE);
    //SetXP(oPriest, GetXP(oPriest)-500);
    XPPenalty(oPC, 500, RED+"Casting of Atone has cost you 500 XP!");
    return sAtone;
}

string Realignment(object oPC, object oPriest)
{
    string sAtone   = "Hold true to your new found moral fiber.";

    int nDeity      = GetDeityIndex(oPC);

    int nAlignGE, nAlignLC;

    if(CheckClericAlignment(oPriest,nDeity))
    {
        nAlignGE    = GetAlignmentGoodEvil(oPriest);
        nAlignLC    = GetAlignmentLawChaos(oPriest);
    }
    else
    {
        nAlignGE    = GetDeityAlignmentGE(nDeity);
        nAlignLC    = GetDeityAlignmentLC(nDeity);

        if(GetHasFeat(FEAT_GOOD_DOMAIN_POWER, oPriest))
            nAlignGE = ALIGNMENT_GOOD;
        else if(GetHasFeat(FEAT_EVIL_DOMAIN_POWER, oPriest))
            nAlignGE = ALIGNMENT_EVIL;
        if(GetHasFeat(FEAT_LAW_DOMAIN_POWER, oPriest))
            nAlignLC = ALIGNMENT_LAWFUL;
        else if(GetHasFeat(FEAT_CHAOS_DOMAIN_POWER, oPriest))
            nAlignLC = ALIGNMENT_CHAOTIC;
    }

    int nVis1, nVis2, nVis3;

    if(nAlignGE==ALIGNMENT_GOOD)
    {
        nVis1 = VFX_IMP_PULSE_HOLY;
        nVis2 = VFX_FNF_STRIKE_HOLY;
        nVis3 = VFX_IMP_HEAD_HOLY;
    }
    else if(nAlignGE==ALIGNMENT_EVIL)
    {
        nVis1 = VFX_IMP_EVIL_HELP;
        nVis2 = VFX_FNF_DEMON_HAND;
        nVis3 = VFX_IMP_HEAD_EVIL;
    }
    else
    {
        nVis1 = VFX_IMP_PDK_GENERIC_PULSE;
        nVis2 = VFX_FNF_SOUND_BURST_SILENT;
        nVis3 = VFX_IMP_HEAD_ODD;

        if(GetHasFeat(FEAT_FIRE_DOMAIN_POWER, oPriest))
            nVis1 = VFX_IMP_PULSE_FIRE;
        else if(GetHasFeat(FEAT_WATER_DOMAIN_POWER, oPriest))
            nVis1 = VFX_IMP_PULSE_WATER;
        if(GetHasFeat(FEAT_AIR_DOMAIN_POWER, oPriest))
            nVis2 = VFX_IMP_PULSE_WIND;
        else if(GetHasFeat(FEAT_EARTH_DOMAIN_POWER, oPriest))
            nVis2 = VFX_IMP_PULSE_NATURE;
        if(GetHasFeat(FEAT_MAGIC_DOMAIN_POWER, oPriest))
            nVis3 = VFX_IMP_HEAD_ELECTRICITY;
        else if(GetHasFeat(FEAT_KNOWLEDGE_DOMAIN_POWER, oPriest))
            nVis3 = VFX_IMP_HEAD_MIND;
    }

    effect eVis1    = EffectVisualEffect(nVis1);
    effect eVis2    = EffectVisualEffect(nVis2);
    effect eVis3    = EffectVisualEffect(nVis3);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis1, oPC);
    DelayCommand(1.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oPC));
    DelayCommand(3.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis3, oPC));

    AdjustAlignment(oPC, nAlignGE, 100, FALSE);
    AdjustAlignment(oPC, nAlignLC, 100, FALSE);
    if(nAlignLC==ALIGNMENT_NEUTRAL && nAlignGE!=ALIGNMENT_NEUTRAL)
        AdjustAlignment(oPC, nAlignGE, 100, FALSE);

    return sAtone;
}

// ZDLG ------------------------------------------------------------------------
void Init()
{
    object oPC          = GetPcDlgSpeaker();

    //SetLocalString(oPC, "ZDLG_END", "[Reject the Atonement.]");
    //SetShowEndSelection( TRUE );

    // General List
    if(!GetLocalInt(oPC, "IN_CONV"))
    {
        SetDlgPageString(PAGE_START);

        SetLocalInt(oPC, "IN_CONV", TRUE);
    }
}

void PageInit()
{
    string sPage    = GetDlgPageString();

    object oPC      = GetPcDlgSpeaker();
    object oHolder  = oPC;

    string sPrompt;

    // Generate fresh response list
    DeleteList( sPage, oHolder );

    object oPriest  = GetLocalObject(oPC,"ATONEMENT_CASTER");

    // Initialize prompt and responses
    // TEACHER CONVERSATION ----------------------------------------------------
    if( sPage==PAGE_START )
    {
        sPrompt = GetCrimes(oPC)
            ;

        AddStringElement( "[Yes.]", sPage, oHolder );  // ExecuteScript("aa_ex_animpray", oPC);
        AddStringElement( "[No.]", sPage, oHolder );
    }
    else if( sPage==PAGE_YES )
    {
        sPrompt = "How do you wish to atone?"
            ;

        if( GetIsSupportedPriest(oPC, CLASS_TYPE_PALADIN)
            &&(     GetLocalInt(oPC, "restrict_class_paladin") // paladin needs to atone
                ||( GetAlignmentGoodEvil(oPC)!=ALIGNMENT_GOOD && GetAlignmentLawChaos(oPC)!=ALIGNMENT_LAWFUL )// paladin immoral
              )
          )
            AddStringElement( "[Resume your responsibilities as a Paladin.]", sPage, oHolder );

        if( GetIsSupportedPriest(oPC, CLASS_TYPE_MONK)
            &&(     GetLocalInt(oPC, "restrict_class_monk")// monk needs to atone
                ||  GetAlignmentLawChaos(oPC)!=ALIGNMENT_LAWFUL// monk immoral
              )
          )
            AddStringElement( "[Resume your practice as a Monk.]", sPage, oHolder );

        if( GetIsSupportedPriest(oPC, CLASS_TYPE_DRUID)
            &&(     GetLocalInt(oPC, "restrict_class_druid")// druid needs to atone
                ||( GetAlignmentLawChaos(oPC)!=ALIGNMENT_NEUTRAL && GetAlignmentGoodEvil(oPC)!=ALIGNMENT_NEUTRAL)// druid immoral
              )
          )
            AddStringElement( "[Resume your responsibilities as a Druid.]", sPage, oHolder );

        if( GetIsSupportedPriest(oPC, CLASS_TYPE_CLERIC)
            &&(     GetLocalInt(oPC, "restrict_class_cleric")// cleric needs to atone
                ||  !CheckClericAlignment(oPC, GetDeityIndex(oPC))// cleric immoral
              )
          )
            AddStringElement( "[Resume your responsibilites as a Cleric.]", sPage, oHolder );

        AddStringElement( "[Realign your moral fiber according to the guidance of "+GetName(oPriest)+".]", sPage, oHolder );

    }
    else if( sPage==PAGE_NO )
    {
        sPrompt = "Then there is nothing further to discuss."
            ;

        AddStringElement( "[End.]", sPage, oHolder );
    }
    else if( sPage==PAGE_ATONED )
    {
        sPrompt = GetLocalString(oPC, "ATONEMENT_MESSAGE")
            ;

        AddStringElement( "[End.]", sPage, oHolder );
    }


    // Set Prompt and Response List ............................................
    SetDlgPrompt( sPrompt );
    SetDlgResponseList( sPage, oHolder );
}

void CleanUp()
{
    object oPC = GetPcDlgSpeaker();
    DeleteLocalInt(oPC, "IN_CONV");

    DeleteLocalObject(oPC, "ATONEMENT_CASTER");
    DeleteLocalString(oPC, "ATONEMENT_MESSAGE");
}

void HandleSelection()
{
  object oPC    = GetPcDlgSpeaker();
  object oHolder= oPC;
  string sPage  = GetDlgPageString();
  int nSelect   = GetDlgSelection();
  string sSelect= GetStringElement( nSelect, sPage, oPC);

  object oPriest   = GetLocalObject(oPC, "ATONEMENT_CASTER");


    if(sSelect=="[Yes.]")
    {
        ExecuteScript("aa_ex_animpray", oPC);
        SetDlgPageString(PAGE_YES);
    }
    else if(sSelect=="[No.]")
    {
        SetDlgPageString(PAGE_NO);
    }
    else if(FindSubString(sSelect," as a Paladin.]")!=-1)
    {
        SetLocalString(oPC, "ATONEMENT_MESSAGE", AtonePaladin(oPC, oPriest));
        SetDlgPageString(PAGE_ATONED);
    }
    else if(FindSubString(sSelect," as a Monk.]")!=-1)
    {
        SetLocalString(oPC, "ATONEMENT_MESSAGE", AtoneMonk(oPC, oPriest));
        SetDlgPageString(PAGE_ATONED);
    }
    else if(FindSubString(sSelect," as a Cleric.]")!=-1)
    {
        SetLocalString(oPC, "ATONEMENT_MESSAGE", AtoneCleric(oPC, oPriest));
        SetDlgPageString(PAGE_ATONED);
    }
    else if(FindSubString(sSelect," as a Druid.]")!=-1)
    {
        SetLocalString(oPC, "ATONEMENT_MESSAGE", AtoneDruid(oPC, oPriest));
        SetDlgPageString(PAGE_ATONED);
    }
    else if(FindSubString(sSelect,"[Realign your moral fiber according to the guidance of ")!=-1)
    {
        SetLocalString(oPC, "ATONEMENT_MESSAGE", Realignment(oPC, oPriest));
        SetDlgPageString(PAGE_ATONED);
    }
    else if(sSelect=="[End.]")
    {
        EndDlg();
    }
}

// MAIN ------------------------------------------------------------------------
void main()
{
    object oSelf    = OBJECT_SELF;

    int iEvent = GetDlgEventType();
    switch( iEvent )
    {
        case DLG_INIT:
            Init();
        break;
        case DLG_PAGE_INIT:
            PageInit();
        break;
        case DLG_SELECTION:
            HandleSelection();
        break;
        case DLG_ABORT:
        case DLG_END:
            // We do the same thing on abort or end
            CleanUp();
        break;
    }
}
