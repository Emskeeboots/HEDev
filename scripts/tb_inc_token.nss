// tb_inc_tokens

// original code from : zzdlg_tokens_inc
// Copyright 2005-2006 by Greyhawk0

// Reworked by Meaglyn

// Token for Day/Night.
string dlgTokenDayNight(int bLower = TRUE);

// Token for morning, afternoon, evening, night.
string dlgTokenQuarterDay(int bLower = TRUE);

// Token for year.
string dlgTokenYear();

// Token for month.
string dlgTokenMonth();

// Token for day.
string dlgTokenDay();

// Token for hour
// return the numerical hour, if b24 then 0-23 is returned.
// if not b24 then 1-12 is returned. And if bAM_PM is true also, 1-12AP/PM is returned
string dlgTokenHour(int b24 = TRUE, int bAM_PM = FALSE);

// Token for time.  full 24 hour time e.g.  22:15
// if bAM_PM is true then hours and minutes with am/pm e.g. 6:30AM, 8PM
// This ignores real seconds and make an approximation of game time minutes
// based on minutes per hour.  E.g. if the real time is 22:01:00 (an minperhour is the default 2)
// it would be "22:30" or 10:30 PM
string dlgTokenTime(int bAM_PM = FALSE);


// Token for player name.
string dlgTokenPlayerName(object oTarget);

// Token for full name.
string dlgTokenFullName(object oTarget);

// Token for first name.  Based on first space in the name
string dlgTokenFirstName(object oTarget);

// Token for last name. Everything after first space
string dlgTokenLastName(object oTarget);

// Token for Bitch/Bastard curse.
string dlgTokenBitchBastard(object oTarget, int bLower = TRUE);

// Token for Boy/Girl.
string dlgTokenBoyGirl(object oTarget, int bLower = TRUE);

// Token for Sir/Madam
string dlgTokenSirMadam(object oTarget, int bLower = TRUE);

// Token for Man/Woman.
string dlgTokenManWoman(object oTarget, int bLower = TRUE);

// Token for Brother/Sister.
string dlgTokenBrotherSister(object oTarget, int bLower = TRUE);

// Token for He/She.
string dlgTokenHeShe(object oTarget, int bLower = TRUE);

// Token for His/Hers.
string dlgTokenHisHers(object oTarget, int bLower = TRUE);

// Token for Him/Her.
string dlgTokenHimHer(object oTarget, int bLower = TRUE);

// Token for His/Her.
string dlgTokenHisHer(object oTarget, int bLower = TRUE);

// Token for Lad/Lass.
string dlgTokenLadLass(object oTarget, int bLower = TRUE);

// Token for Laddie/Lassie.
string dlgTokenLaddieLassie(object oTarget, int bLower = TRUE);

// Token for Lord/Lady.
string dlgTokenLordLady(object oTarget, int bLower = TRUE);

// Token for Male/Female.
string dlgTokenMaleFemale(object oTarget, int bLower = TRUE);

// Token for Master/Mistress.
string dlgTokenMasterMistress(object oTarget, int bLower = TRUE);

// Token for Mister/Missus.
string dlgTokenMisterMissus(object oTarget, int bLower = TRUE);

// Gives the name of the class, plural if specified. Uses the highest leveled
// class.
string dlgTokenClass(object oTarget, int bPlural = FALSE, int bLower = TRUE);

// token for deity.
string dlgTokenDeity(object oTarget);

//  Grabs whether the object is good, evil, or neutral.
string dlgTokenGoodEvil(object oTarget, int bLower = TRUE);

//  Grabs whether the object is lawful, chaotic, or neutral in that respect.
string dlgTokenLawfulChaotic(object oTarget, int bLower = TRUE);

// Returns the alignment of the object. bLower1 is first word and bLower2 is second word.
string dlgTokenAlignment(object oTarget, int bLower1 = TRUE, int bLower2 = TRUE);

// Token for target's level.
string dlgTokenLevel(object oTarget);

// Token for target's race: in Noun form (e.g Half-Elf or Half-Elves)
string dlgTokenRace(object oTarget, int bPlural = FALSE, int bLower = TRUE);

// Token for target's race: in adjective form (e.g Half-Elven or half-elven)
// no plural form
string dlgTokenRaceAdj(object oTarget, int bLower = TRUE);

// Token for target's race.
string dlgTokenSubRace(object oTarget);

/***********************************************/

string dlgTokenDayNight(int bLower = TRUE) {
    if (GetIsDay()) {
        if (bLower) return "day";
        else return "Day";
    } else {
        if (bLower) return "night";
        else return "Night";
    }
}

// Token for morning, afternoon, evening, night.
// TODO - these should be tunables based on module day start etc
string dlgTokenQuarterDay(int bLower = TRUE) {
    int iHour = GetTimeHour();
    if (iHour < 6) { // 12:00am - 5:59am  night
        if (bLower) return "night";
        else return "Night";
    } else  if (iHour < 12) {   // 6:00am  - 11:59am morning
        if (bLower) return "morning";
        else return "Morning";
    } else if (iHour <= 18) { // 12:00pm - 5:59pm  afternoon
            if (bLower) return "afternoon";
        else return "Afternoon";
    } else {     // 6:00pm  - 11:59pm evening
        if (bLower) return "evening";
        else return "Evening";
    }
}

string dlgTokenYear() {
    return ( IntToString( GetCalendarYear() ) );
}

string dlgTokenMonth() {
    return ( IntToString( GetCalendarMonth() ) );
}

// Token for day.
string dlgTokenDay() {
    return ( IntToString( GetCalendarDay() ) );
}

// Token for player name.
string dlgTokenPlayerName(object oTarget) {
    return ( GetPCPlayerName(oTarget) );
}

// Token for full name.
string dlgTokenFullName(object oTarget) {
    return ( GetName(oTarget) );
}

// Token for first name. Based on first space in the name
string dlgTokenFirstName(object oTarget) {
    string sName =  GetName(oTarget);
    int iPos = FindSubString(sName, " ");

    sName = GetSubString(sName, 0, iPos);

    return ( sName );
}

string dlgTokenLastName(object oTarget) {
    string sName =  GetName(oTarget);
    int iPos = FindSubString(sName, " ");

    sName = GetSubString(sName, iPos + 1, GetStringLength(sName) - iPos);

    return ( sName );
}


// return the numerical hour, if b24 then 0-23 is returned.
// if not b24 then 1-12 is returned. And if bAM_PM is true also, 1-12AP/PM is returned
string dlgTokenHour(int b24 = TRUE, int bAM_PM = FALSE) {
    int iHour = GetTimeHour();

    if (b24) {
        return IntToString(iHour);
    } else {
        string sTime;
        string sAM;
        if (iHour < 12) {
            if (iHour == 0)
            sTime = "12";
            else
            sTime = ( IntToString(iHour) );
            sAM = "AM";
        } else {
            if (iHour == 12)
            sTime = "12";
        else
            sTime = ( IntToString(iHour-12) );
            sAM = "PM";
        }
        if (bAM_PM) sTime += sAM;

        return sTime;
    }
}

// Token for time.  full 24 hour time e.g.  22:15:04
// if bAM_PM is true then hours and minutes with am/pm e.g. 6:30AM, 8Pm
string dlgTokenTime(int bAM_PM = FALSE) {
    int iHour = GetTimeHour();
    int iMinutes = GetTimeMinute();
    int iSeconds = GetTimeSecond();

    int nMinPer = FloatToInt(HoursToSeconds(1))/60;
    int nMin = ((iMinutes * 60) + iSeconds)/nMinPer;

    if (!bAM_PM) {
        return GetStringRight("000"+IntToString(iHour),2) + ":"
        + GetStringRight("000"+IntToString(nMin),2);
        //+ ":" + GetStringRight("000"+IntToString(iSeconds),2);
    } else {
        string sTime;
        string sAM;
        if (iHour < 12) {
            if (iHour == 0) sTime = "12";
            sTime = ( IntToString(iHour) );
            sAM = "AM";
        } else {
            if (iHour == 12) sTime = "12";
            sTime = ( IntToString(iHour-12) );
            sAM = "PM";
        }

    if (nMin != 0)
        sTime +=  ":" + GetStringRight("000"+IntToString(nMin),2);
        sTime += sAM;
        return sTime;
    }
}

// Token for Bitch/Bastard curse.
string dlgTokenBitchBastard(object oTarget, int bLower = TRUE) {
    if (GetGender(oTarget) != GENDER_FEMALE) {
        if (bLower) return "bastard";
        else return "Bastard";
    } else {
        if (bLower) return "bitch";
        else return "Bitch";
    }
}

// Token for Boy/Girl.
string dlgTokenBoyGirl(object oTarget, int bLower = TRUE) {
    if (GetGender(oTarget) != GENDER_FEMALE) {
        if (bLower) return "boy";
        else return "Boy";
    } else {
        if (bLower) return "girl";
        else return "Girl";
    }
}

// Token for Sir/Madam
string dlgTokenSirMadam(object oTarget, int bLower = TRUE) {
    if (GetGender(oTarget) != GENDER_FEMALE) {
        if (bLower) return "sir";
        else return "Sir";
    } else {
        if (bLower) return "madam";
        else return "Madam";
    }
}

//knave/wench
string dlgTokenKnaveWench(object oTarget, int bLower = TRUE) {
    if (GetGender(oTarget) != GENDER_FEMALE) {
        if (bLower) return "knave";
        else return "Knave";
    } else {
        if (bLower) return "wench";
        else return "Wench";
    }
}

//rake/whore
string dlgTokenRakeWhore(object oTarget, int bLower = TRUE) {
    if (GetGender(oTarget) != GENDER_FEMALE) {
        if (bLower) return "rake";
        else return "Rake";
    } else {
        if (bLower) return "whore";
        else return "Whore";
    }
}

//cad/harlot
string dlgTokenCadHarlot(object oTarget, int bLower = TRUE) {
    if (GetGender(oTarget) != GENDER_FEMALE) {
        if (bLower) return "cad";
        else return "Cad";
    } else {
        if (bLower) return "harlot";
        else return "Harlot";
    }
}




// Token for Man/Woman.
string dlgTokenManWoman(object oTarget, int bLower = TRUE) {
    if ( GetGender(oTarget) != GENDER_FEMALE) {
        if (bLower) return "man";
        else return "Man";
    } else {
        if (bLower) return "woman";
        else return "Woman";
    }
}

// Gives the name of the class, plural if specified. Uses the highest leveled
// class.
string dlgTokenClass(object oTarget, int bPlural = FALSE, int bLower = TRUE) {
    int iLevel1 = GetLevelByClass(GetClassByPosition(1, oTarget), oTarget);
    int iLevel2 = GetLevelByClass(GetClassByPosition(2, oTarget), oTarget);
    int iLevel3 = GetLevelByClass(GetClassByPosition(3, oTarget), oTarget);
    int iBiggestClass;

    if (iLevel1 > iLevel2) {
        if (iLevel1 > iLevel3) iBiggestClass = GetClassByPosition(1, oTarget);
        else iBiggestClass = GetClassByPosition(3, oTarget);
    } else {
        if (iLevel2 > iLevel3) iBiggestClass = GetClassByPosition(2, oTarget);
        else iBiggestClass = GetClassByPosition(3, oTarget);
    }

    string sClassref;

    if (bPlural==TRUE) sClassref = Get2DAString( "classes", "Plural", iBiggestClass );
    else if (bLower==TRUE) sClassref = Get2DAString( "classes", "Lower", iBiggestClass );
    else sClassref = Get2DAString( "classes", "Name", iBiggestClass );

    string sClassname = GetStringByStrRef( StringToInt( sClassref ), GetGender( oTarget ) );

    if (bPlural && bLower) return ( GetStringLowerCase( sClassname ) );

    return ( sClassname );
}

// Grabs the deity.
string dlgTokenDeity(object oTarget) {
    return ( GetDeity( oTarget ) );
}

//  Grabs whether the object is good, evil, or neutral in that respect.
string dlgTokenGoodEvil(object oTarget, int bLower = TRUE) {
    int iAlign = GetAlignmentGoodEvil(oTarget);
    if (iAlign == ALIGNMENT_GOOD) {
        if (bLower) return "good";
        else return "Good";
    } else if (iAlign == ALIGNMENT_EVIL) {
        if (bLower) return "evil";
        else return "Evil";
    } else {
        if (bLower) return "neutral";
        else return "Neutral";
    }
}

//  Grabs whether the object is lawful, chaotic, or neutral in that respect.
string dlgTokenLawfulChaotic(object oTarget, int bLower = TRUE) {
    int iAlign = GetAlignmentLawChaos(oTarget);
    if (iAlign == ALIGNMENT_LAWFUL) {
        if (bLower) return "lawful";
        else return "Lawful";
    } else if (iAlign == ALIGNMENT_CHAOTIC) {
        if (bLower) return "chaotic";
        else return "Chaotic";
    } else {
        if (bLower) return "neutral";
        else return "Neutral";
    }
}

// Returns the alignment of the object. bLower1 is first word and bLower2 is second word.
string dlgTokenAlignment(object oTarget, int bLower1 = TRUE, int bLower2 = TRUE) {
    string sFirst = dlgTokenGoodEvil(oTarget, bLower1);
    string sSecond = dlgTokenLawfulChaotic(oTarget, bLower2);

    if (sFirst == "neutral" || sFirst == "Neutral") {
        if (sSecond == "neutral" || sSecond == "Neutral") {
            return ( ( bLower1?"t":"T" ) + "rue " + ( bLower2?"n":"N" ) + "eutral" );
        }
    }

    return sSecond + " " + sFirst;
}

// Token for Brother/Sister.
string dlgTokenBrotherSister(object oTarget, int bLower = TRUE) {
    if (GetGender(oTarget) != GENDER_FEMALE) {
        if (bLower) return "brother";
        else return "Brother";
    } else {
        if (bLower) return "sister";
        else return "Sister";
    }
}

// Token for He/She.
string dlgTokenHeShe(object oTarget, int bLower = TRUE) {
    if (GetGender(oTarget) != GENDER_FEMALE) {
        if (bLower) return "he";
        else return "He";
    } else {
        if (bLower) return "she";
        else return "She";
    }
}

// Token for His/Hers.
string dlgTokenHisHers(object oTarget, int bLower = TRUE) {
    if (GetGender(oTarget) != GENDER_FEMALE) {
        if (bLower) return "his";
        else return "His";
    } else {
        if (bLower) return "hers";
        else return "Hers";
    }
}

// Token for Him/Her.
string dlgTokenHimHer(object oTarget, int bLower = TRUE) {
    if (GetGender(oTarget) != GENDER_FEMALE) {
        if (bLower) return "him";
        else return "Him";
    } else {
        if (bLower) return "her";
        else return "Her";
    }
}

// Token for His/Her.
string dlgTokenHisHer(object oTarget, int bLower = TRUE) {
    if (GetGender(oTarget) != GENDER_FEMALE) {
        if (bLower) return "his";
        else return "His";
    } else {
        if (bLower) return "her";
        else return "Her";
    }
}

// Token for Lad/Lass.
string dlgTokenLadLass(object oTarget, int bLower = TRUE) {
    if ( GetGender(oTarget)!= GENDER_FEMALE) {
        if (bLower) return "lad";
        else return "Lad";
    } else {
        if (bLower) return "lass";
        else return "Lass";
    }
}

// Token for Laddie/Lassie.
string dlgTokenLaddieLassie(object oTarget, int bLower = TRUE) {
    if ( GetGender(oTarget)!= GENDER_FEMALE) {
        if (bLower) return "laddie";
        else return "Laddie";
    } else {
        if (bLower) return "lassie";
        else return "Lassie";
    }
}
// Token for Lord/Lady.
string dlgTokenLordLady(object oTarget, int bLower = TRUE) {
    if (GetGender(oTarget) != GENDER_FEMALE) {
        if (bLower) return "lord";
        else return "Lord";
    } else {
        if (bLower) return "lady";
        else return "Lady";
    }
}

// Token for Male/Female.
string dlgTokenMaleFemale(object oTarget, int bLower = TRUE) {
    if ( GetGender(oTarget) != GENDER_FEMALE) {
        if (bLower) return "male";
        else return "Male";
    } else {
        if (bLower) return "female";
        else return "Female";
    }
}

// Token for Master/Mistress.
string dlgTokenMasterMistress(object oTarget, int bLower = TRUE) {
    if ( GetGender(oTarget) != GENDER_FEMALE) {
        if (bLower) return "master";
        else return "Master";
    } else {
        if (bLower) return "mistress";
        else return "Mistress";
    }
}

// Token for Mister/Missus.
string dlgTokenMisterMissus(object oTarget, int bLower = TRUE) {
    if ( GetGender(oTarget) != GENDER_FEMALE) {
        if (bLower) return "mister";
        else return "Mister";
    } else {
        if (bLower) return "missus";
        else return "Missus";
    }
}

// Token for target's level.
string dlgTokenLevel(object oTarget) {
    int iLevel = GetLevelByPosition(1, oTarget);
    iLevel += GetLevelByPosition(2, oTarget);
    iLevel += GetLevelByPosition(3, oTarget);
    return ( IntToString(iLevel) );
}

// Token for target's race: in Noun form (e.g Half-Elf or Half-Elves)
string dlgTokenRace(object oTarget, int bPlural = FALSE, int bLower = TRUE) {
    int iRace = GetRacialType(oTarget);
    string sRaceref;

    if (bPlural)
        sRaceref = Get2DAString( "racialtypes", "NamePlural", iRace );
    else
        sRaceref = Get2DAString( "racialtypes", "Name", iRace );

    string sRacename = GetStringByStrRef(StringToInt(sRaceref), GetGender(oTarget));

    if (bLower)
        return (GetStringLowerCase(sRacename));

    return sRacename;
}

// Token for target's race: in adjective form (e.g Half-Elven or half-elven)
// no plural form
string dlgTokenRaceAdj(object oTarget, int bLower = TRUE) {
    int iRace = GetRacialType(oTarget);
    string sRaceref;

    if (bLower)
        sRaceref = Get2DAString( "racialtypes", "ConverNameLower", iRace );
    else
        sRaceref = Get2DAString( "racialtypes", "ConverName", iRace );

    string sRacename = GetStringByStrRef(StringToInt(sRaceref), GetGender(oTarget));

    return sRacename;
}

// Token for target's race.
string dlgTokenSubRace(object oTarget) {
    return ( GetSubRace(oTarget) );
}

