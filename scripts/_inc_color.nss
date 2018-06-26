//::///////////////////////////////////////////////
//:: _inc_color
//:://////////////////////////////////////////////
/*
    color constants
*/
//:://////////////////////////////////////////////
//:: Created:   Henesua (2010 dec 29)
//:: Modified:
//:://////////////////////////////////////////////

const string WHITE      = "<cððð>"; // talk
const string GREY       = "<cŠŠŠ>"; //"<c€€€>"; // whisper
const string LIGHTGREY  = "<c¥¥¥>";
const string SANDY      = "<cþïP>"; // shout

const string RED        = "<cþ  >";
const string DARKRED    = "<c¡*0>";
const string PINK       = "<cÒdd>";
const string LIGHTPINK  = "<cædd>";

const string ORANGE     = "<cþ} >";
const string YELLOWSERV = "<cþf >"; // experimental

const string LEMON      = "<cþþ >";
const string YELLOW     = "<cþ× >";

const string NEONGREEN  = "<c#þ#>"; // tell
const string GREEN      = "<c0¡0>"; // name preceding description
const string LIME       = "<c¡Òd>"; // description
const string LIGHTGREEN = "<c¡Ñd>";

const string DARKBLUE   = "<c  þ>";
const string BLUE       = "<c zþ>"; // skill blue
//const string BLUE       = "<cAiá>";
//const string BLUE       = "<cd¡Ñ>";
const string PERIWINKLE = "<czzþ>";
const string CYAN       = "<c þþ>"; // saving throw

const string LIGHTBLUE  = "<c#ßþ>"; // DM chat
const string DMBLUE     = "<c#ßþ>"; // DM chat
const string PALEBLUE   = "<c‡þþ>"; // name in skill check/saving throw

const string VIOLET     = "<c¡dÑ>";
const string PURPLE     = "<c¢Gd>";

const string COLOR_END  = "</c>";

/*  These are the colors used in the AID responses. They may be adjusted to
    taste though be aware that the toolset script editor does not play nice with
    certain characters, as such a number of colors will generate compile errors.
 */

const string COLOR_ACTION       = LIGHTBLUE; //"<c#ßþ>"; // "<c¯>";
const string COLOR_OBJECT       = GREEN; // "<c0¡0>"; //"<c¯æ>";
const string COLOR_DESCRIPTION  = LIME; // "<c¡Òd>";
const string COLOR_MESSAGE      = LIGHTGREY; // "<c¥¥¥>"; // "<cŠŠŠ>";
const string COLOR_WHITE        = WHITE; //"<cððð>";
const string COLOR_DUMPHEADER   = "<c©>";
const string COLOR_VARNAME      = "<c†>";

// STRING Manipulations taken from AID -------


// DoColorize - wrapper for all ColorStringManip() calls [file: _inc_util]
string DoColorize(string sText, int bDescription=FALSE);
// ColorStringManip - replaces all instances of sChar from sText with sColor [file: _inc_util]
string ColorStringManip(string sText, string sChar, string sColor);

//::///////////////////////////////////////////////
//:: Name: Color Fcns
//:: Copyright (c) 2006 Jesse Wright
//:://////////////////////////////////////////////
/*
DoColorize - wrapper for all ColorStringManip() calls
ColorStringManip - replaces all instances of sChar from sText with sColor

  12/22/2006 - Fixed a bug to ColorStringManip that caused an infinite loop if
    the character it was looking to replace was the first character in the
    target string. It was a stupid bug (> 0 needed to be >= 0)  - TV (JW)
*/
//:://////////////////////////////////////////////
//:: Created By: Jesse Wright
//:: Created On: 6/4/2006
//:: Last Modified: 12/22/2006
//:://////////////////////////////////////////////

string DoColorize(string sText, int bDescription=FALSE)
{
    if(bDescription)
        sText = COLOR_DESCRIPTION + sText;
    else
        sText = COLOR_WHITE + sText;

    sText = ColorStringManip(sText, "(", COLOR_OBJECT);
    if(bDescription)
        sText = ColorStringManip(sText, ")", COLOR_DESCRIPTION);
    else
        sText = ColorStringManip(sText, ")", COLOR_WHITE);

    sText = ColorStringManip(sText, "[", COLOR_ACTION);
    if(bDescription)
        sText = ColorStringManip(sText, "]", COLOR_DESCRIPTION);
    else
        sText = ColorStringManip(sText, "]", COLOR_WHITE);

    return sText;
}

string ColorStringManip(string sText, string sChar, string sColor)
{
    int iPosition = 0;               //position of syntax char
    int iLength;

    string sTemp1;
    string sTemp2;

    while (iPosition != -1)
    {
        iPosition = FindSubString(sText, sChar);

        if (iPosition >= 0)
        {
            iLength = GetStringLength(sText);
            sTemp1 = GetSubString(sText, 0, iPosition);
            sTemp2 = GetSubString(sText, (iPosition + 1), (iLength - iPosition));
            sText = sTemp1 + sTemp2;
            sText = InsertString(sText, sColor, iPosition);
        }
    }

    return sText;
}


//void main(){}
