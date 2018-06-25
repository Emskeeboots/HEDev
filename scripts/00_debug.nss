////////////////////////////////////////////////////////////////////
// FILE NAME : 00_debug
// CREATED BY: Glenn J. Berden aka Jassper
// DATE      : v05.11.27
////////////////////////////////////////////////////////////////////
// Rewritten By : meaglyn for Hill's edge
// Date        : 12/11/17
////////////////////////////////////////////////////////////////////

#include "tb_inc_color"
#include "x0_i0_stringlib"

// Debug levels for different systems to control which are enabled independently.
// Subsys should define for self a DEBUGLEVEL define such as
// int mydblvl = ( DEBUGLEVEL_1 | DEBUG_COLOR_1 );
// and use dblvl(mydblvl , "foo", ...);


const int DEBUGLEVEL_NONE     =     0;  // all zeros.

const int DEBUGLEVEL_1      =  0x01;  // bit 0
const int DEBUGLEVEL_2      =  0x02;  // bit 1
const int DEBUGLEVEL_3      =  0x04;  // bit 2
const int DEBUGLEVEL_4      =  0x08;  // bit 3
const int DEBUGLEVEL_5      =  0x10;  // bit 4    (16)
const int DEBUGLEVEL_6      =  0x20;  // bit 5    (32)
const int DEBUGLEVEL_7      =  0x40;  // bit 6    (64)
const int DEBUGLEVEL_8      =  0x80;  // bit 7    (128)
const int DEBUGLEVEL_9      =  0x100; // bit 8    (256)
const int DEBUGLEVEL_10     =  0x200; // bit 9    (512)
const int DEBUGLEVEL_11     =  0x400; // bit 10   (1024)
const int DEBUGLEVEL_12     =  0x800; // bit 11   (2048)
const int DEBUGLEVEL_13     =  0x1000; // bit 12   (4096)
const int DEBUGLEVEL_14     =  0x2000; // bit 13   (8192)
const int DEBUGLEVEL_15     =  0x4000; // bit 14   (16384)
const int DEBUGLEVEL_16   =  0x8000; // bit 15   (32768)


const int DEBUGLEVEL_ALL      = 0x00ffffff;

const int DEBUG_COLOR_1       = 0x01000000;  // bit 24  = 16777216;
const int DEBUG_COLOR_2       = 0x02000000;  // bit 25  = 33554432;
const int DEBUG_COLOR_3       = 0x04000000;  // bit 26  = 67108864;
const int DEBUG_COLOR_4       = 0x08000000;  // bit 27  = 134217728;
const int DEBUG_COLOR_5       = 0x10000000;  // bit 28  = 268435456;
const int DEBUG_COLOR_6       = 0x20000000;  // bit 29  = 536870912;
const int DEBUG_COLOR_7       = 0x40000000;  // bit 30  = 1073741824;
const int DEBUG_COLOR_8       = 0x80000000;  // bit 31  = 2147483648;


const int DEBUGCOLOR_MASK     = 0xff000000;

const string DEBUG_COLOR_DEF     =  TEXT_COLOR_GREY;

// most of these are defined in the appropriate include file - some don't have
// specific includes.
const int DEBUGLEVEL_REST     =  DEBUGLEVEL_1;  // bit 0
const int DEBUGLEVEL_HB       =  DEBUGLEVEL_2;  // bit 1  // PC and module (area HBs)
const int DEBUGLEVEL_CORPSE   =  DEBUGLEVEL_3;  // bit 2
const int DEBUGLEVEL_AWW      =  DEBUGLEVEL_4;  // bit 3  0x08
const int DEBUGLEVEL_PW       =  DEBUGLEVEL_5;  // bit 4  0x10 (16) // used for player login/logoff, CDkeys etc
const int DEBUGLEVEL_PERSIST  =  DEBUGLEVEL_6;  // bit 5  0x20 (32)/
//const int DEBUGLEVEL_UNK    =  0x40;  // bit 6    (64)
//const int DEBUGLEVEL_PRR      =  0x80;  // bit 7    (128)
//const int DEBUGLEVEL_SPELL    =  0x100; // bit 8    (256)
//const int DEBUGLEVEL_DLG      =  0x200; // bit 9    (512)
//const int DEBUGLEVEL_SPELL    =  0x400; // bit 10   (1024)
//const int DEBUGLEVEL_COINS    =  0x800; // bit 11   (2048)
const int DEBUGLEVEL_AI       =  DEBUGLEVEL_13; // bit 12 0x1000  (4096)  // includes ambient etc NPC hbs
// const int DEBUG_LEVEL_QUEST  =  0x2000; // bit 13   (8192)
//const int DEBUG_LEVEL_RUMOR = DEBUGLEVEL_15     =  0x4000; // bit 14   (16384)
//const int DEBUG_LEVEL_SPAWN =  DEBUGLEVEL_16     =  0x8000; // bit 15   (32768)

/******* PROTOTYPES ******/

//////////////////////////////////////////////////////////////////////
// db will display up to 2 lines of text and 2 integers to the first
// PC if oAlternate is left undefinded. Set iPrintToLog to TRUE if you
// wish for these values to be logged.
// Example, db("Variable DO_ONCE =",iVariable);
// Specifing an object in oAlternate will send the information to that object
// This does nothing if the int variable DEBUG is not set to non-zero on the module.
//////////////////////////////////////////////////////////////////////
void db(string sText1,int iOne = -1,string sText2 = "",int iTwo = -1,int iPrintToLog = TRUE, object oAlternate = OBJECT_INVALID);
void dbstr(string sText1, object oAlternate = OBJECT_INVALID);

//////////////////////////////////////////////////////////////////////
// dblvl will display up to 2 lines of text and 2 integers to the first
// PC if oAlternate is left undefinded. Set iPrintToLog to TRUE if you
// wish for these values to be logged.
// Example, db("Variable DO_ONCE =",iVariable);
// Specifing an object in oAlternate will send the information to that object
// This does nothing if the debuglevel specified by nLev is not set on the module.
//////////////////////////////////////////////////////////////////////
void dblvl(int nLev, string sText1,int iOne = -1,string sText2 = "",int iTwo = -1,int iPrintToLog = TRUE, object oAlternate = OBJECT_INVALID);
void dblvlstr(int nLev, string sText1, object oAlternate = OBJECT_INVALID);

////////////////////////////////////
// err will display text as db, using TEXT_COLOR_RED
// This will always fire (ignored DEBUG and DEBUG_LEVEL), and always write to the log
//(ignores iPrintToLog) using WriteTimeStampedLogEntry.
//////////////////////////////////////////////////////////////////////
void err(string sText1,int iOne = -1,string sText2 = "",int iTwo = -1,int iPrintToLog = TRUE,object oAlternate = OBJECT_INVALID);
void errstr(string sText1, object oAlternate = OBJECT_INVALID);

////////////////////////////////////
// info will display text as db, using TEXT_COLOR_GREY
// This will always fire (ignored DEBUG and DEBUG_LEVEL), and always write to the log
//(ignores iPrintToLog) using WriteTimeStampedLogEntry.
//////////////////////////////////////////////////////////////////////
void info(string sText1,int iOne = -1,string sText2 = "",int iTwo = -1,int iPrintToLog = TRUE,object oAlternate = OBJECT_INVALID);
void infostr(string sText1, object oAlternate = OBJECT_INVALID);

//////////////////////////////////////////////////////////////////////
// Will display the Object Name, TAG, and ResRef of the object + the
// Area in which the object is. Also will display the value of up to 2
// specified variables previously set on the object regardless of the
// Variable type. In the case of an object or location variable
// Information about that variable will also be displayed.
// Leave oAlternate unspecified to send the message to the first PC
//////////////////////////////////////////////////////////////////////
void dbg_dumpObject(object oObject,string sVariableName1 = "",string sVariableName2 = "",int iPrintToLog = FALSE,object oAlternate = OBJECT_INVALID);

//////////////////////////////////////////////////////////////////////
// Will Reload the module
// If the module file is the same as the module name, leave
// sName unspecified. Otherwise, enter the module file name.
// Set iPrintToLog to TRUE for a time stamp log entry of the reload.
// Leave oAlternate unspecified to send the message to the First PC.
//////////////////////////////////////////////////////////////////////
void dbg_reload(string sName = "",int iPrintToLog = FALSE,object oAlternate = OBJECT_INVALID);

// Return a formatted string for the given keyvalue pairs
string dbgInts(string s1, int n1, string s2="", int n2=-1, string s3="", int n3=-1, string s4="", int n4=-1);

//////////////////////////////////////////////////////////////////////
// Used internaly but could work alone
// Will gather information about a variable set on oObject
//////////////////////////////////////////////////////////////////////
string GatherInfo(string sVariableName,object oObject);

const int DEBUG_USEFIRSTPC = FALSE;

/******* DEFINITIONS *******/

int dbIsLevelSet(int nLev) {
    int nBits = GetLocalInt(GetModule(), "DEBUG_LEVEL") & DEBUGLEVEL_ALL;
    int nBit = nLev & DEBUGLEVEL_ALL;

    return (nBits & nBit);
}

string dbGetColorText(int nLev) {
        string sColor = DEBUG_COLOR_DEF;

        int nCol = (nLev & DEBUGCOLOR_MASK); // >> 24;
        switch (nCol) {
                case DEBUG_COLOR_1: sColor = TEXT_COLOR_GREY; break;
                case DEBUG_COLOR_2: sColor = TEXT_COLOR_GREEN; break;
                case DEBUG_COLOR_3: sColor = TEXT_COLOR_BLUE; break;
                case DEBUG_COLOR_4: sColor = TEXT_COLOR_CYAN; break;
                case DEBUG_COLOR_5: sColor = TEXT_COLOR_MAGENTA; break;
                case DEBUG_COLOR_6: sColor = TEXT_COLOR_YELLOW; break;
                case DEBUG_COLOR_7: sColor = TEXT_COLOR_ORANGE; break;
                case DEBUG_COLOR_8: sColor = TEXT_COLOR_BROWN; break;            
        }
        return sColor;
}

void dbSetDebugPC(object oPC) {
    if (GetIsPC(oPC))
        SetLocalObject(GetModule(), "DEBUG_TARGET_PC", oPC);
    else
        DeleteLocalObject(GetModule(), "DEBUG_TARGET_PC");
}

object dbGetDebugPC(object oAlternate = OBJECT_INVALID) {
    if(GetIsPC(oAlternate))
        return oAlternate;

    object oRet = GetLocalObject(GetModule(), "DEBUG_TARGET_PC");
    if (DEBUG_USEFIRSTPC && !GetIsPC(oRet)) {
        oRet = GetFirstPC();
    }
    return oRet;
}

void dbprint(string sColor, string sText1, int iOne = -1, string sText2 = "", int iTwo = -1, int iPrintToLog = TRUE, object oAlternate = OBJECT_INVALID){
    string sOne,sTwo,sSend;
    object oPC =  dbGetDebugPC(oAlternate);

    if(iOne != -1) {
        sOne = IntToString(iOne);
    }
    if(iTwo != -1) {
        sTwo = IntToString(iTwo);
    }
    sSend = sText1 +" "+sOne+" "+sText2+" "+sTwo;

    SendMessageToPC(oPC, ColorString(sSend, sColor));
    if(iPrintToLog)
        WriteTimestampedLogEntry(sSend);
    //PrintString(sSend);
}

void dblvl(int nLev, string sText1,int iOne = -1,string sText2 = "",int iTwo = -1,int iPrintToLog = TRUE, object oAlternate = OBJECT_INVALID) {

    if (!dbIsLevelSet(nLev))
        return;

    dbprint(dbGetColorText(nLev), "DEBUG: " + sText1, iOne, sText2, iTwo, iPrintToLog, oAlternate);
}
void dblvlstr(int nLev, string sText1, object oAlternate = OBJECT_INVALID) {
        dblvl(nLev, sText1, -1, "", -1, TRUE, oAlternate);
}

void db(string sText1,int iOne = -1,string sText2 = "",int iTwo = -1,int iPrintToLog = TRUE,object oAlternate = OBJECT_INVALID) {
    object oPC;

    if (!GetLocalInt(GetModule(), "DEBUG"))
        return;

    dbprint(DEBUG_COLOR_DEF, "DEBUG: " + sText1, iOne, sText2, iTwo, iPrintToLog, oAlternate);
}
void dbstr(string sText1, object oAlternate = OBJECT_INVALID) {
        db(sText1, -1, "", -1, TRUE, oAlternate);
}

void err(string sText1,int iOne = -1,string sText2 = "",int iTwo = -1,int iPrintToLog = TRUE,object oAlternate = OBJECT_INVALID) {
    object oPC;
    string sOne,sTwo,sSend;

    dbprint(TEXT_COLOR_RED, "ERROR: " + sText1, iOne, sText2, iTwo, TRUE, oAlternate);
}
void errstr(string sText1, object oAlternate = OBJECT_INVALID) {
        err(sText1, -1, "", -1, TRUE, oAlternate);
}

void info(string sText1,int iOne = -1,string sText2 = "",int iTwo = -1,int iPrintToLog = TRUE,object oAlternate = OBJECT_INVALID) {
    object oPC;
    string sOne,sTwo,sSend;

    dbprint(TEXT_COLOR_GREY, sText1, iOne, sText2, iTwo, TRUE, oAlternate);
}
void infostr(string sText1, object oAlternate = OBJECT_INVALID) {
        info(sText1, -1, "", -1, TRUE, oAlternate);
}


void dbg_dumpObject(object oObject,string sVariableName1 = "",string sVariableName2 = "",int iPrintToLog = FALSE,object oAlternate = OBJECT_INVALID) {
    object oPC = dbGetDebugPC(oAlternate);

    string sSend,sVar1,sVar2;
    if(!GetIsObjectValid(oObject))
        {
        sSend = "** OBJECT DETAILS **\nObject Not Valid";
        db(sSend,-1,"",-1,iPrintToLog,oPC);
        return;
        }

    string sName = GetName(oObject);
    string sTag = GetTag(oObject);
    string sResRef = GetResRef(oObject);
    string sObjectAreaName = GetName(GetArea(oObject));
    string sObjectAreaTag = GetTag(GetArea(oObject));

    if(sVariableName1 != "")
        sVar1 = GatherInfo(sVariableName1,oObject);

    if(sVariableName2 != "")
        sVar2 = GatherInfo(sVariableName2,oObject);

    sSend = "** OBJECT DETAILS **\nObject Name = "+sName+
            "\nObject Tag = "+sTag+
            "\nObject ResRef = "+sResRef+
            "\nObject Area Name = "+sObjectAreaName+
            "\nObject Area Tag = "+sObjectAreaTag+
            "\nVariables:\n"+sVar1+"\n"+sVar2;

    db(sSend,-1,"",-1,iPrintToLog,oPC);
    if(iPrintToLog)
        PrintString(sSend);
}
// End ObjectDump

void dbg_reload(string sName = "",int iPrintToLog = FALSE,object oAlternate = OBJECT_INVALID) {
    if(sName == "") {
        sName = GetName(GetModule());
    }

    object oPC = dbGetDebugPC(oAlternate);

    dbprint(TEXT_COLOR_RED, "Reloading in *2*...", -1, "", -1, iPrintToLog, oPC);
    DelayCommand(1.0,dbprint(TEXT_COLOR_RED, "*1*...", -1, "", -1, iPrintToLog, oPC));
    if(iPrintToLog)
        DelayCommand(1.8,WriteTimestampedLogEntry("****** RELOAD MODULE ******"));
    DelayCommand(2.0,StartNewModule(sName));

}
// End Reload

// Return a formatted string for the given keyvalue pairs
string dbgInts(string s1, int n1, string s2="", int n2=-1, string s3="", int n3=-1, string s4="", int n4=-1) {
        // Start with a space so callers do not always have to do that.
        string sRet = " " + s1 +":" + IntToString(n1);
        if (s2 != "")
                sRet += " " + s2 +":" + IntToString(n2);
        if (s3 != "")
                sRet += " " + s3 +":" + IntToString(n3);
        if (s4 != "")
                sRet += " " + s4 +":" + IntToString(n4);
        return sRet;
}


string GatherInfo(string sVariableName,object oObject) {
    string f,i,s,sVar,sVector,sArea,sFace,sObName,sObTag,sObResRef;
    location l;
    object o;

    f = FloatToString(GetLocalFloat(oObject,sVariableName));
    i = IntToString(GetLocalInt(oObject,sVariableName));
    s = GetLocalString(oObject,sVariableName);
    l = GetLocalLocation(oObject,sVariableName);
    o = GetLocalObject(oObject,sVariableName);

    sVar = "Variable "+sVariableName+" Values:\n  Float = "+f+"\n  Integer = "+i+"\n  String = "+s;

    if(GetIsObjectValid(GetAreaFromLocation(l))) {
        sArea = GetTag(GetAreaFromLocation(l));
        vector v = GetPositionFromLocation(l);
        sVector = FloatToString(v.x)+","+FloatToString(v.y)+","+FloatToString(v.z);
        sFace = FloatToString(GetFacingFromLocation(l));
        sVar = sVar+"\n  This Variable is a Location\n  Location Details:\n    Area TAG = "+sArea+"\n    Vector = "+sVector+"\n    Facing = "+sFace;
    }
    if(GetIsObjectValid(o)) {
        sObName = GetName(o);
        sObTag = GetTag(o);
        sObResRef = GetResRef(o);
        sVar = sVar+"\n  This Variable is a Object\n  Object Details:\n    Object Name = "+sObName+"\n    Object TAG = "+sObTag+"\n    Object ResRef = "+sObResRef;
    }

    return sVar;
}
//End GatherInfo
int GAA(object oArmor, int nApp) {
        return  GetItemAppearance(oArmor, ITEM_APPR_TYPE_ARMOR_MODEL,nApp);
}
int GIC(object oItem, int nCol) {
        return GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR ,nCol);
}

void debugDumpArmor(object oArmor, object oPC, int nLog = 1) {
        if (GetIsObjectValid(oArmor)) {
                db("Clothing tag = "+GetTag(oArmor)+" Name = " + GetName(oArmor), -1, "",-1, nLog,oPC);

                int iTmp1 = GIC(oArmor,ITEM_APPR_ARMOR_COLOR_CLOTH1 );
                int iTmp2 = GIC(oArmor,ITEM_APPR_ARMOR_COLOR_LEATHER2 );
                db("cloth 1 = " + IntToString(iTmp1) + " cloth 2 = ", GIC(oArmor,ITEM_APPR_ARMOR_COLOR_CLOTH2 ),
                     "leather 1 = ",  GIC(oArmor,ITEM_APPR_ARMOR_COLOR_LEATHER1 ),nLog,oPC);

                db(" leather 2 = " + IntToString(iTmp2) + " metal 1 = ", GIC(oArmor,ITEM_APPR_ARMOR_COLOR_METAL1) ,
                   " metal 2 = ", GIC(oArmor, ITEM_APPR_ARMOR_COLOR_METAL2 ) ,nLog,oPC);

                iTmp1 = GAA(oArmor, ITEM_APPR_ARMOR_MODEL_NECK);
                iTmp2 = GAA(oArmor, ITEM_APPR_ARMOR_MODEL_TORSO);
                db("Neck = " + IntToString(iTmp1) +  " Belt = ", GAA(oArmor, ITEM_APPR_ARMOR_MODEL_BELT ),
                   "Torso = " + IntToString(iTmp2) + " Pelvis = ", GAA(oArmor,ITEM_APPR_ARMOR_MODEL_PELVIS ) ,nLog,oPC);

                iTmp1 =  GAA(oArmor,ITEM_APPR_ARMOR_MODEL_LTHIGH );
                db("L Thigh = " + IntToString(iTmp1) + " L Shin = ", GAA(oArmor,ITEM_APPR_ARMOR_MODEL_LSHIN ) ,
                   "L Foot = ", GAA(oArmor,ITEM_APPR_ARMOR_MODEL_LFOOT ) ,nLog,oPC);

                iTmp1 =  GAA(oArmor,ITEM_APPR_ARMOR_MODEL_RTHIGH );
                db("R Thigh = " + IntToString(iTmp1) + " R Shin = ", GAA(oArmor,ITEM_APPR_ARMOR_MODEL_RSHIN ) ,
                   "R Foot = ", GAA(oArmor,ITEM_APPR_ARMOR_MODEL_RFOOT ) ,nLog,oPC);

                iTmp1 =  GAA(oArmor,ITEM_APPR_ARMOR_MODEL_LSHOULDER );
                db("L Shoulder = " + IntToString(iTmp1) + " L Bicep = ", GAA(oArmor,ITEM_APPR_ARMOR_MODEL_LBICEP ) ,
                   "L Forearm = ", GAA(oArmor,ITEM_APPR_ARMOR_MODEL_LFOREARM ) ,nLog,oPC);

                iTmp1 =  GAA(oArmor,ITEM_APPR_ARMOR_MODEL_RSHOULDER );
                db("R Shoulder = " + IntToString(iTmp1) + " R Bicep = ", GAA(oArmor,ITEM_APPR_ARMOR_MODEL_RBICEP ) ,
                   "R Forearm = ", GAA(oArmor,ITEM_APPR_ARMOR_MODEL_RFOREARM ) ,nLog,oPC);

                db("Robe = ", GAA(oArmor, ITEM_APPR_ARMOR_MODEL_ROBE ) ,"", -1,  nLog,oPC);
        }
}
//void main() {}
