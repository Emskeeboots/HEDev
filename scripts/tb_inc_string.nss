// tb_inc_string
// string parsing, coloring and token replacing code.
// Helper routines for dynamic dialogs
// by meaglyn
#include "tb_inc_token"
#include "tb_inc_color"

// For month and day names and moon phase
#include "tb_inc_calendar"

// TODO find this value once all the tokens are in
const int STRING_TOKEN_MAXLEN  = 24;

const string CONV_COLOR_DEFAULT = TEXT_COLOR_WHITE;
const string CONV_COLOR_ACTION  = TEXT_COLOR_GREEN;
const string CONV_COLOR_PROMPT  = TEXT_COLOR_CYAN;  // for [end], [continue]  etc.
const string CONV_COLOR_FAIL    = TEXT_COLOR_RED;
const string CONV_COLOR_SUCCESS = TEXT_COLOR_GREEN;

struct parser {
    string sTok;
    int nLen;
};

// return the right of the string from start to the end
string GetStringRest(string sIn, int nStart) {
    return GetStringRight(sIn, GetStringLength(sIn) - nStart);
}

string GetCapitalizedString(string sIn) {
    string sFirst = GetSubString(sIn, 0,1);
    string sRest =  GetStringRight(sIn, GetStringLength(sIn) -1);

    return GetStringUpperCase(sFirst) + sRest;
}

// Return a "cooked" version of the given string. Cooking involved replacing
// supported tokens with their real in game values.
// Does not work for custom tokens.
// oTarget is generally the PCSpeaker, the one who's gender or race etc is used.
string tbCookString(string sString, object oTarget);

// Cook sString and color the entire thing the given color
// Color may be one of the define in this include or one of the larger range in
// tb_inc_color
string tbColorAndCook(string sString, object oTarget, string sColor = CONV_COLOR_DEFAULT);

// cook sString and wrap it in [] and color the whole thing CONV_COLOR_ACTION
string tbActionString(string sString, object oTarget);

// cook sString and prepend "[<sKill>] " colored with CONV_COLOR_ACTION.
// If nSkill != -1 lookup the skill name (ignoring sSkill)
// if nSkill == -1, use given sSkill string
string tbSkillChkString(string sString, object oTarget, int nSkill = -1, string sSkill = "");

// cook sString and prepend "[Failure] " colored with CONV_COLOR_FAIL.
string tbFailString(string sString, object oTarget);

// cook sString and prepend "[Success] " colored with CONV_COLOR_SUCCESS.
string tbSuccessString(string sString, object oTarget);

// "[Continue] " colored with CONV_COLOR_PROMPT.
string tbContinueString() ;

// "[End Dlg] " colored with CONV_COLOR_PROMPT.
string tbEndString() ;

// Get a name for the given skill
string tbGetSkillName(int nSkill);

// Remove leading and trailing spaces from the given string
string tbTrim(string sString);

// Parse the given hex string to integer. NWN supports only signed ints so
// this may return positive or negative values.
// String does not need to start with 0x (or 0X) but it can.
// Only supports upto 8 hex digits not counting 0x prefix.
int HexStringToInt(string sHex);

/*
  Supported Tokens:

  // Game/global tokens
  day/night  Day/Night
  quarter    Quarter      (morning,afternoon,evening,night)
  year
  month
  day
  hour    numerical hour 1 - 12
  hour24  numerical hour 0 - 23
  hourap  numerical hour with AM or PM after it e.g.  2AM, 7PM
  time    full 24 hour time e.g.  22:15:04
  timeap  hours and minutes with am/pm e.g. 6:30AM, 8Pm

  // Name tokens
  playername      all the names are as written.
  name   PC speaker's fullname
  fullname   same as name
  firstname  guess as to the PC's first name (everything before the first space in getName())
  lastname   guess of the PC's last name (everything after the first space in GetName())

  // PC Gender tokens
  bitch/bastard   Bitch/Bastard   Based on the PC's Gender
  boy/girl        Boy/Girl
  sir/madam       Sir/Madam
  man/woman       Man/Woman
  brother/sister  Brother/Sister
  he/she          He/She
  his/hers        His/Hers
  his/her         His/Her
  lad/lass        Lad/lass
  laddie/lassie   Laddie/lassie
  rake/whore      Rake/Whore
  knave/wench     Knave/Wench
  cad/harlot      Cad/Harlot
  lord/lady
  male/female
  master/mistress
  mister/missus

  // PC character traits
  class          Class  classes Classes for plural (i.e. ranger or rangers) - Based on the PC
  deity          PC's deity
  alignment     Alignment  PC's alignment (caps first word only)
  good/evil     Good/Evil  - "good" "evil" or "neutral"
  law/chaos     Law/Chaos    "lawful", "chaotic" or "neutral"
  level                          PC's total level
  race          Race,races,Races PC's race  this is the name and plural: Half-elf, half-elves
  raceadj       race as adjective : Half-elven
  subrace       Subrace, subraces, Subraces

  // NPC tokens
  npcname       GetName() of the NPC conversation owner
  npcman/woman  gender of NPC conversation owner
  npcfirst      guess at npcs first name
  npclast       guess at last name
  gold          name of NPC's default currency (or "gold" if coin system is disabled)

  // Variable based tokens
  // variable name should be < 20 characters long
  // NOTE - these should not contain tokens.
  // (Lower case works for these as well)
  SVAR/varname   returns the value of the string variable "varname" on the PC
  SVARN/varname  returns the value of the string variable "varname" on the NPC
  NVAR/varname   returns the string of the int variable "varname" on the PC
  NVARN/varname  returns the string of the int variable "varname" on the NPC

  // Color tokens
  c_colorname       short colorname from tb_inc_color
  /c                end color marker.

  // Month, Day names and moon phases. Requires tb_inc_calendar see below
  tbmonth  The world specific name for the current month
  tbday    the world specific name for the current day of the week
  tbnday   the world specific name of the current day of the month (e.g. second Towerday)  
  phase   or Phase   lowercase or capital name for the current moon phase
           "it is a <phase> moon."  --> "it is a new moon."
  season or Season  - winter,spring,summer or fall...

 */
string GetStringToken(string sToken, object oTarget, object oNPC = OBJECT_SELF);

// Returns the name of oPC, surrounded by color tokens, so the color of
// the name is the lighter blue often used in NWN game engine messages.
string GetNamePCColor(object oPC);

// Returns the name of oNPC, surrounded by color tokens, so the color of
// the name is the shade of purple often used in NWN game engine messages.
string GetNameNPCColor(object oNPC);

//-------------------------------
// Tokens for month name, day name and moon phase
// These require tb_inc_calendar. If you don't have that
// remove the comment markers from the return  "<UNRECOGNIZEDTOKEN>"; lines
// and place them in front of the other return line in each of these.
// And comment out the #include "tb_inc_calendar" above.
string dlgTokenMonthName() {
        //return "<UNRECOGNIZEDTOKEN>";
    return tbGetMonthName();
}

string dlgTokenDayName(int bMonth = FALSE) {
    //return "<UNRECOGNIZEDTOKEN>";
        if (bMonth) {
                return tbGetDayOfMonthString();
        }
        return tbGetDayOfWeekString();
}

string dlgTokenMoonPhase(int bLower = TRUE) {
      //return "<UNRECOGNIZEDTOKEN>";
    return tbGetMoonPhaseStr(bLower);
}
string dlgTokenSeason(int bLower = TRUE) {
      //return "<UNRECOGNIZEDTOKEN>";
    return tbCalendarGetSeason(GetCalendarMonth(), bLower);
}

string dlgTokenMoneyName(object oNPC, int bPlural = FALSE) {
        return "gold";
}

//--------------------------------

//----------------------------------------------------------------------
// Cook sString and color the entire thing the given color
// Color may be one of the define in this include or one of the larger range in
// tb_inc_color
string tbColorAndCook(string sString, object oTarget, string sColor = CONV_COLOR_DEFAULT) {
    if (sString == "")
        return sString;

    return ColorString(tbCookString(sString, oTarget), sColor);
}

// cook sString and wrap it in [] and color the whole thing CONV_COLOR_ACTION
string tbActionString(string sString, object oTarget) {
    if (sString == "")
        return ColorString("[]", CONV_COLOR_ACTION);

    return ColorString( "[" + tbCookString(sString, oTarget) + "]", CONV_COLOR_ACTION);
}

// cook sString and prepend "[<sKill>] " colored with CONV_COLOR_ACTION.
// If nSkill != -1 lookup the skill name (ignoring sSkill)
// if nSkill == -1, use given sSkill string
string tbSkillChkString(string sString,  object oTarget, int nSkill = -1, string sSkill = "") {
    if (nSkill != -1)
        sSkill = tbGetSkillName(nSkill);

    return ColorString( "[" + sSkill + "]", CONV_COLOR_ACTION) + " " + tbCookString(sString, oTarget);
}

// cook sString and prepend "[Failure] " colored with CONV_COLOR_FAIL.
string tbFailString(string sString, object oTarget) {
    return ColorString( "[Failure]", CONV_COLOR_FAIL) + " " + tbCookString(sString, oTarget);
}

// cook sString and prepend "[Success] " colored with CONV_COLOR_SUCCESS.
string tbSuccessString(string sString, object oTarget) {
    return ColorString( "[Success]", CONV_COLOR_SUCCESS) + " " +  tbCookString(sString, oTarget);
}

// "[Continue] " colored with CONV_COLOR_PROMPT.
string tbContinueString() {
    return ColorString( "[Continue]", CONV_COLOR_PROMPT);
}

// "[End Dlg] " colored with CONV_COLOR_PROMPT.
string tbEndString() {
    return ColorString( "End Dialog", CONV_COLOR_PROMPT);
}


// Remove leading and trailing spaces from the given string
string tbTrim(string sString) {
  if (sString == "") return sString;

  while((sString != "") && (GetStringLeft(sString, 1) == " ")){
    sString = GetStringRight(sString, GetStringLength(sString) -1);
  }
   while((sString != "") && (GetStringRight(sString, 1) == " ")){
    sString = GetStringLeft(sString, GetStringLength(sString) -1);
  }

    return sString;
}

// Get a name for the given skill\
// Borrowed this from PRR.
string tbGetSkillName(int nSkill){
   switch (nSkill){
        case SKILL_ANIMAL_EMPATHY:   return "Animal Empathy";
        case SKILL_APPRAISE:         return "Appraise";
        case SKILL_BLUFF:            return "Bluff";
        case SKILL_CONCENTRATION:    return "Concentration";
        case SKILL_CRAFT_ARMOR:      return "Craft Armor";
        case SKILL_CRAFT_TRAP:       return "Craft Trap";
        case SKILL_CRAFT_WEAPON:     return "Craft Weapon";
        case SKILL_DISABLE_TRAP:     return "Disable Trap";
        case SKILL_DISCIPLINE:       return "Discipline";
        case SKILL_HEAL:             return "Heal";
        case SKILL_HIDE:             return "Hide";
        case SKILL_INTIMIDATE:       return "Intimidate";
        case SKILL_LISTEN:           return "Listen";
        case SKILL_LORE:             return "Lore";
        case SKILL_MOVE_SILENTLY:    return "Move Silently";
        case SKILL_OPEN_LOCK:        return "Open Lock";
        case SKILL_PARRY:            return "Parry";
        case SKILL_PERFORM:          return "Perform";
        case SKILL_PERSUADE:         return "Persuade";
        case SKILL_PICK_POCKET:      return "Pick Pocket";
        case SKILL_RIDE:             return "Ride";
        case SKILL_SEARCH:           return "Search";
        case SKILL_SET_TRAP:         return "Set Trap";
        case SKILL_SPELLCRAFT:       return "Spellcraft";
        case SKILL_SPOT:             return "Spot";
        case SKILL_TAUNT:            return "Taunt";
        case SKILL_TUMBLE:           return "Tumble";
        case SKILL_USE_MAGIC_DEVICE: return "Use Magic Device";
        // Added simulated skills
        case 128:                    return "Balance";        // SKILL_S_BALANCE
        case 129:                    return "Creature Lore";  // SKILL_S_CREATURE_LORE
        case 130:                    return "Survival";       // SKILL_S_SURVIVAL
        case 131:                    return "Appraise Value"; // SKILL_S_APPRAISE_VALUE
        case 132:                    return "Herbalism";      // SKILL_S_HERBALISM
        case 133:                    return "Cursed Lore";    // SKILL_S_CURSED_LORE
        case 135:                    return "Climbing";       // SKILL_S_CLIMB
        case 136:                    return "Swimming";       // SKILL_S_SWIM
        // add these missing ones (137- 142) if needed - not likely.
        case 143:                    return "Tracking";       // SKILL_S_TRACKING
        case 144:                    return "Poison Lore";    // SKILL_S_POISON_LORE
        case 145:                    return "Disease Lore";   // SKILL_S_DISEASE_LORE
        case 146:                    return "Cooking";        // SKILL_S_COOKING
        case 147:                    return "Fishing";        // SKILL_S_FISHING
    }
    return "Unknown";
}

// Return the <cxxx> color token for the given "c_colorname" string
// return "<c_colorname>" if colorname is invalid.
/* Supported color names are :
 * c_red, c_green, c_grey, c_blue, c_black, c_cyan, c_magenta, c_yellow, c_white, c_orange
 *  c_dark_red, c_dark_green, c_dark_grey, c_dark_blue, c_dark_cyan, c_dark_magenta, c_dark_yellow, c_dark_orange
 *
 * This is used in a string like this   "Hello <c_blue>blue</c> <lad/lass>"
 * Resulting in a cooked string like    "Hello <c  ?>blue</c> lad"
 * Which will display the word blue in blue when used in places that support colorizing.
 */
string dlgColorToken(string sToken) {
    if (GetStringLeft(sToken, 2) != "c_")
        return "<" + sToken + ">";

    string sLower =  GetStringLowerCase(sToken);
    string sCol = GetStringRest(sLower, 2);
    if (GetSubString(sCol, 0,5) == "dark_") {
        sCol = GetStringRest(sCol, 5);
        string sChar = GetSubString(sCol, 0,1);
        if (sChar == "r") {
            if (sCol == "red")
                return MkColorString(TEXT_COLOR_DARK_RED);
        }
        else if  (sChar == "g") {
            if (sCol == "grey")
                return MkColorString(TEXT_COLOR_DARK_GREY);
            if (sCol == "green")
                return MkColorString(TEXT_COLOR_DARK_GREEN);
        }
        else if  (sChar == "b") {
            if (sCol == "blue")
                return MkColorString(TEXT_COLOR_DARK_BLUE);
        }
        else if  (sChar == "c") {
            if (sCol == "cyan")
                return MkColorString(TEXT_COLOR_DARK_CYAN);
        }
        else if  (sChar == "m") {
            if (sCol == "magenta")
                return MkColorString(TEXT_COLOR_DARK_MAGENTA);
        }
        else if  (sChar == "y") {
            if (sCol == "yellow")
                return MkColorString(TEXT_COLOR_DARK_YELLOW);
        }
        else if  (sChar == "o") {
            if (sCol == "orange")
                return MkColorString(TEXT_COLOR_DARK_ORANGE);
        }

    } else {
        string sChar = GetSubString(sCol, 0,1);
        if (sChar == "r") {
            if (sCol == "red")
                return MkColorString(TEXT_COLOR_RED);
        }
        else if  (sChar == "g") {
            if (sCol == "grey")
                return MkColorString(TEXT_COLOR_GREY);
            if (sCol == "green")
                return MkColorString(TEXT_COLOR_GREEN);
        }
        else if  (sChar == "b") {
            if (sCol == "blue")
                return MkColorString(TEXT_COLOR_BLUE);
            if (sCol == "black")
                return MkColorString(TEXT_COLOR_BLACK);
        }
        else if  (sChar == "c") {
            if (sCol == "cyan")
                return MkColorString(TEXT_COLOR_CYAN);
        }
        else if  (sChar == "m") {
            if (sCol == "magenta")
                return MkColorString(TEXT_COLOR_MAGENTA);
        }
        else if  (sChar == "y") {
            if (sCol == "yellow")
                return MkColorString(TEXT_COLOR_YELLOW);
        }
        else if  (sChar == "w") {
            if (sCol == "white")
                return MkColorString(TEXT_COLOR_WHITE);
        }
        else if  (sChar == "o") {
            if (sCol == "orange")
                return MkColorString(TEXT_COLOR_ORANGE);
        }
    }
    return "<" + sToken + ">";
}

/*
  Do the actual string replacement.
  See comments on the prototype as to which tokens are supported
 */
string GetStringToken(string sToken, object oTarget, object oNPC = OBJECT_SELF) {
    if (sToken == "")
        return "";

    // First divide the search space roughly in half by checking for a "/" token
    int nSlash = FindSubString(sToken, "/");
    string sFirst = GetSubString(sToken, 0,1);
    string sLower = GetStringLowerCase(sFirst);
    int bIsLower = (sLower == sFirst);
    string sOrig = sToken;
    sToken = GetStringLowerCase(sToken);

    //SendMessageToPC(GetFirstPC(), "GetStringToken : " + sToken);
    // These are the ones with no "/"
    if (nSlash == -1) {
        // a - l
        if (sLower == "a" || sLower == "c" || sLower == "d") {
            // align(ment) or Align(ment)
            if (sLower == "a") {
                if (GetSubString(sToken, 1,4) == "lign") {
                    return dlgTokenAlignment(oTarget, bIsLower);
                }
            }
            // class, classes
            else if (sLower == "c") {
            if (GetSubString(sToken, 1, 1) == "_") {

                return dlgColorToken(sToken);
            }
            if (GetSubString(sToken, 1,4) == "lass") {
                if (GetStringRight(sToken,2) == "es")
                    return dlgTokenClass(oTarget, TRUE, bIsLower);
                else
                    return dlgTokenClass(oTarget, FALSE, bIsLower);
            }
            }
            // Day or Deity
            else if (sLower == "d") {
                if (GetSubString(sToken, 1,2) == "ay")
                    return dlgTokenDay();
                else if (GetSubString(sToken, 1,4) == "eity")
                    return dlgTokenDeity(oTarget);
            }
        } else  if (sLower == "f" || sLower == "g" || sLower == "h" || sLower == "l") {
            // firstname or fullname
                if (sLower == "f") {
                    if (GetSubString(sToken, 1,7) == "ullname")
                        return  dlgTokenFullName(oTarget);
                    else if (GetSubString(sToken, 1,8) == "irstname")
                        return dlgTokenFirstName(oTarget);
                }
                if (sLower == "g") {
                    if (GetSubString(sToken, 1,4) == "olds")
                        return  dlgTokenMoneyName(oNPC, TRUE);
                    else
                        return dlgTokenMoneyName(oNPC);
                }
                // hour, hour24, hourap
                else if (sLower == "h") {
                    if (GetSubString(sToken, 1,3) == "our") {
                    //SendMessageToPC(oTarget, "token" + sToken + " string right = " +  GetStringRight(sToken,2));
                        if (GetStringRight(sToken,2) == "24")
                            return dlgTokenHour(TRUE, FALSE);
                        else if (GetStringRight(sToken,2) == "ap")
                            return dlgTokenHour(FALSE, TRUE);
                        else
                            return dlgTokenHour(FALSE, FALSE);
                    }
                }
                // lastname or level
                else if (sLower == "l") {
                    if (GetSubString(sToken, 1,4) == "evel") {
                        return dlgTokenLevel(oTarget);
                    } else if (GetSubString(sToken, 1,7) == "astname") {
                        return dlgTokenLastName(oTarget);
                    }
                }
            // m - y
        } else if (sLower == "m" || sLower == "n" || sLower == "p" || sLower == "q") {
                // month
                if (sLower == "m") {
                    if (GetSubString(sToken, 1,4) == "onth") {
                        return dlgTokenMonth();
                    }
                }
                // name
                else if (sLower == "n") {
            if (GetSubString(sToken, 1,3) == "ame") {
                return dlgTokenFullName(oTarget);
                    }
            // npc names
            else if (GetSubString(sToken, 1,2) == "pc") {
                if(GetSubString(sToken, 3,4) == "name") {
                    return dlgTokenFullName(oNPC);
                } else if(GetSubString(sToken, 3,5) == "first") {
                    return dlgTokenFirstName(oNPC);
                } else if(GetSubString(sToken, 3,4) == "last") {
                    return dlgTokenLastName(oNPC);
                }
            }
        }
                // playername
                else if (sLower == "p") {
                    if (GetSubString(sToken, 1,9) == "layername") {
                        return dlgTokenPlayerName(oTarget);
                    }
            else if (GetSubString(sToken, 1,4) == "hase") {
                        return dlgTokenMoonPhase(bIsLower);
                    }
                }
                // quarter
                else if (sLower == "q") {
                    if (GetSubString(sToken, 1,6) == "uarter")
                        return  dlgTokenQuarterDay(bIsLower);
                }
        } else if (sLower == "r" || sLower == "s" || sLower == "t" || sLower == "y") {
                // race or races
                if (sLower == "r") {
            if (GetSubString(sToken, 1,3) == "ace") {
                if (GetStringRight(sToken,2) == "es")
                    return dlgTokenRace(oTarget, TRUE, bIsLower);
                else if (GetStringRight(sToken,3) == "adj")
                    return dlgTokenRaceAdj(oTarget, bIsLower);
                else
                    return dlgTokenRace(oTarget, FALSE, bIsLower);
            }
                }
                // subrace
                else if (sLower == "s") {
                    if (GetSubString(sToken, 1,6) == "ubrace")
                        return dlgTokenSubRace(oTarget);
                    if (GetSubString(sToken, 1,5) == "eason")
                        return dlgTokenSeason(bIsLower); 
                    if (GetSubString(sToken, 1,10) == "tartaction")
                        return MkColorString(CONV_COLOR_ACTION);
                }
        // time
        else if (sLower == "t") {
            if (GetSubString(sToken, 1,3) == "ime") {
                if (GetStringRight(sToken, 2) == "ap")
                    return dlgTokenTime(TRUE);
                else
                    return dlgTokenTime(FALSE);
            }
        else if (GetSubString(sToken, 1,6) == "bmonth") {
            return dlgTokenMonthName();
        } else if  (GetSubString(sToken, 1,4) == "bday") {
            return dlgTokenDayName();
        } else if  (GetSubString(sToken, 1,5) == "bnday") {
            return dlgTokenDayName(TRUE);
        }
    }

                // year
                else if (sLower == "y") {
                    if (GetSubString(sToken, 1,3) == "ear")
                        return dlgTokenYear();
                }
        }
        // End no slash tokens
    } else if (nSlash == 0) {
        // We're just returning the token with <>s here but
        // it's better to catch it explicitly than rely on the error path
        if (sToken == "/c" || sToken == "/start")
            return "</c>";
    }  else {
        // a - h
        if (sLower == "b" || sLower == "c" || sLower == "d" || sLower == "g" || sLower == "h") {
            // bitch/bastard, boy/girl, brother/sister
            // these can be shortened to "bitch/" in practice
            if (sLower == "b") {
                if (GetSubString(sToken, 1, 5) == "itch/")
                    return dlgTokenBitchBastard(oTarget, bIsLower);
                else if (GetSubString(sToken, 1, 3) == "oy/")
                    return dlgTokenBoyGirl(oTarget, bIsLower);
                else if (GetSubString(sToken, 1, 7) == "rother/")
                    return dlgTokenBrotherSister(oTarget, bIsLower);
            }
              // cad/harlot
            else if (sLower == "c") {
                if (GetSubString(sToken, 1, 3) == "ad/")
                    return dlgTokenCadHarlot(oTarget, bIsLower);
            }
            // day/night
            else if (sLower == "d") {
                if (GetSubString(sToken, 1, 3) == "ay/")
                    return dlgTokenDayNight(bIsLower);
            }
            // good/evil
            else if (sLower == "g") {
                if (GetSubString(sToken, 1, 4) == "ood/")
                    return dlgTokenGoodEvil(oTarget, bIsLower);
            }
            // he/she, his/hers
            else if (sLower == "h") {
                if (GetSubString(sToken, 1, 2) == "e/")
                    return dlgTokenHeShe(oTarget, bIsLower);
                else if (GetSubString(sToken, 1, 3) == "is/")
                    if (GetStringRight(sToken, 2) == "rs")
                        return dlgTokenHisHers(oTarget, bIsLower);
                    else
                        return dlgTokenHisHer(oTarget, bIsLower);
            }
        } else if (sLower == "k" || sLower == "l") {
                // k and l

                if (sLower == "k") {
                        if (GetSubString(sToken, 1, 4) == "nave/")
                            return dlgTokenKnaveWench(oTarget, bIsLower);
                }

                // lad/lass, lord/lady, law/chaos
                else if (sLower == "l") {
                if (GetSubString(sToken, 1, 3) == "ad/")
                    return dlgTokenLadLass(oTarget, bIsLower);
                if (GetSubString(sToken, 1, 6) == "addie/")
                    return dlgTokenLaddieLassie(oTarget, bIsLower);
                else if (GetSubString(sToken, 1, 4) == "ord/")
                    return dlgTokenLordLady(oTarget, bIsLower);
                else if (GetSubString(sToken, 1, 3) == "aw/")
                    return dlgTokenLawfulChaotic(oTarget, bIsLower);
            }
        } else  if (sLower == "m" || sLower == "n" || sLower == "r" ||  sLower == "s") {
            // m,n,r and s

            // male/female, man/woman, master/mistress, mister/missus
            if (sLower == "m") {
                if (GetSubString(sToken, 1, 3) == "an/")
                    return dlgTokenManWoman(oTarget, bIsLower);
                else if (GetSubString(sToken, 1, 4) == "ale/")
                    return dlgTokenMaleFemale(oTarget, bIsLower);
                else if (GetSubString(sToken, 1, 6) == "aster/")
                    return dlgTokenMasterMistress(oTarget, bIsLower);
                else if (GetSubString(sToken, 1, 6) == "ister/")
                    return dlgTokenMisterMissus(oTarget, bIsLower);
            }
            // npcman/woman
            else if (sLower == "n") {
                if (GetSubString(sToken, 1, 6) == "pcman/")
                    return dlgTokenManWoman(oNPC, bIsLower);
                else if (GetSubString(sToken, 1, 4) == "var/") {
                    string sRest = GetStringRest(sToken, nSlash + 1);
                    return IntToString(GetLocalInt(oTarget, sRest));
                }
                else if (GetSubString(sToken, 1, 5) == "varn/") {
                    string sRest = GetStringRest(sToken, nSlash + 1);
                    return IntToString(GetLocalInt(oNPC, sRest));
                }
            }
            // rake/whore
            else if (sLower == "r") {
                if (GetSubString(sToken, 1, 4) == "ake/")
                    return dlgTokenRakeWhore(oTarget, bIsLower);
            }
            // sir/madam
            else if (sLower == "s") {
                if (GetSubString(sToken, 1, 3) == "ir/")
                    return dlgTokenSirMadam(oTarget, bIsLower);
                else if (GetSubString(sToken, 1, 4) == "var/") {
                    string sRest = GetStringRest(sToken, nSlash + 1);
                    return GetLocalString(oTarget, sRest);
                }
                else if (GetSubString(sToken, 1, 5) == "varn/") {
                    string sRest = GetStringRest(sToken, nSlash + 1);
                    return GetLocalString(oNPC, sRest);
                }
            }
        } // slash base tokens
    }
    //return "<UNRECOGNIZEDTOKEN>";
    // Or better - "<" + sOrig " ">"
    return "<" + sOrig + ">";
}


// nStart should point to an opening "<"
// this will return a struct parser with the
// text of the token in sTok or "" on error.
// Regardless of error or not, the nLen field will
// have the number of characters consumed.
// This can be used to advance the callers location counter.
// and to put the data up to this point into the cooked string.
// If both sTok == "" and nLen == 0,
struct parser tbParseToken(string sIn, int nStart) {

    struct parser ss;
    string sCur = GetSubString(sIn, nStart, 1);
    int nLen = GetStringLength(sIn);

    ss.sTok = "";
    ss.nLen = 0;

    // This is a check to see that we are at the start of what may be a token
    if (sCur != "<") {
        return ss;
    }

    // consume the "<"
    ss.nLen ++;
    int nLoc = nStart + 1;

    while (nLoc <= nLen) {
        sCur = GetSubString(sIn, nLoc, 1);
        // We're done - return the string
        if (sCur == ">") {
            return ss;
        }

        // Error - return empty string with current length
        if (sCur == " ") {
            ss.sTok = "";
            ss.nLen --;
            return ss;
        }

                // Error - return empty string with length on smaller
        // so that the "<" can be parsed again.
        if (sCur == "<") {
            ss.sTok = "";
            ss.nLen--;
            return ss;
        }

        // Add the character to the
        ss.sTok += sCur;
        nLoc ++;
        ss.nLen ++;

        // error too long - return empty string with length
        if (ss.nLen > STRING_TOKEN_MAXLEN) {
            ss.sTok = "";
            return ss;
        }

    }
    // ran out of string before end >. Return empty string and current length
    ss.sTok = "";
    return ss;
}

// Return a "cooked" version of the given string. Cooking involved replacing
// supported tokens with their real in game values.
// Does not work for custom tokens.
string tbCookString(string sString, object oTarget) {

    int nLen = GetStringLength(sString);
    struct parser ss;

    int nCur = 0; // Current location in original string
    int nStrIdx = 0; // current location in the result string.
    int nTokIdx;
    int nTokEnd;
    int nTokTmp;
    string sTok;
    string sRest;
    string sTok2;
    int count = 0;
    int nMax = nLen/5;

    string sCooked = "";

   // SendMessageToPC(GetFirstPC(), "tbCookString : " + sString);

    while (nCur < nLen) {
        nTokIdx = FindSubString(sString, "<", nCur);
        if (nTokIdx == -1) {
            sCooked += GetSubString(sString, nCur, nLen - nCur);
            return sCooked;
        }

        ss =  tbParseToken(sString, nTokIdx);
        nTokEnd = nTokIdx + ss.nLen;

        // We know we have at least a whole token -
        // Validate the max length of our tokens,
        // get the token
        if (GetStringLength(ss.sTok) == 0) {
            // skip this and continue
            if (ss.nLen == 0)
                nTokEnd ++;

            sCooked += GetSubString(sString, nCur, nTokEnd - nCur);
            nCur = nTokEnd;
        } else {
            // put the part before the token
            if (nTokIdx > nCur) {
                sCooked += GetSubString(sString, nCur, nTokIdx - nCur);
            }
            sCooked += GetStringToken(ss.sTok, oTarget);
            nCur = nTokEnd + 1;
        }
        // repeat until there is nothing left to do
        // This is a safety valve in case of bugs.
        if (count++ > nMax)
            return sCooked;
    }
    //SendMessageToPC(GetFirstPC(), "tbCookString return: " + sCooked);
    return sCooked;
}

int getCharHexVal(string sHex) {

        if (sHex == "1") return 1;
        else if (sHex == "2") return 2;
        else if (sHex == "3") return 3;
        else if (sHex == "4") return 4;
        else if (sHex == "5") return 5;
        else if (sHex == "6") return 6;
        else if (sHex == "7") return 7;
        else if (sHex == "8") return 8;
        else if (sHex == "9") return 9;
        else if (sHex == "A" || sHex == "a") return 10;
        else if (sHex == "B" || sHex == "b") return 11;
        else if (sHex == "C" || sHex == "c") return 12;
        else if (sHex == "D" || sHex == "d") return 13;
        else if (sHex == "E" || sHex == "e") return 14;
        else if (sHex == "F" || sHex == "f") return 15;

        return 0;

}

int getIsDecimalInt(string sInt) {
        if (sInt == "0" || sInt == "1" || sInt == "2" || sInt == "3" || sInt == "4" || sInt == "5" 
                || sInt == "6" || sInt == "7" || sInt == "8" || sInt == "9") { 
                return TRUE;
        }
        return FALSE;
}


int HexStringToInt(string sHex) {
        sHex = GetStringUpperCase(sHex);
        if (GetStringLeft(sHex, 2) == "0X") {
                sHex = GetStringRight(sHex, GetStringLength(sHex) -2);
        }
        int nLoc = GetStringLength(sHex);
        if (nLoc < 1 || nLoc > 8) {
                //SendMessageToPC(GetFirstPC(), "HexStringToInt got bad length.");
                return 0;
        }

        int nRes = 0;
        string sRest = sHex;
        string tmp;

        while (nLoc > 0) {
                tmp = GetStringLeft(sRest, 1);
                nRes = nRes * 16 + getCharHexVal(tmp);
                nLoc --;
                sRest = GetStringRight(sRest, nLoc);
        }
        //SendMessageToPC(GetFirstPC(), "HexStringToInt returns " + IntToString(nRes));
        return nRes;
}

// Return the substring of sIn containing the right most
// end of the string if that end of the string is made up of 
// numbers.  e.g  sIn = "wrn_hollis_30"  ret = "30"
//                sIn = "commoner_m_001" ret = "001"
//                sIn = "m_bandit000"    ret = "000"
//                sIn = "cr_troll_common" ret = "" 
string getNumFromEndOfString(string sIn) {
        int nStart = GetStringLength(sIn);
        int nLen = nStart;

        while ( getIsDecimalInt(GetSubString(sIn, nStart -1 , 1))) {
                nStart --;
        }
        if (nStart == nLen) {
                return "";
        }
        
        return GetStringRight(sIn, nLen - nStart); 
}
