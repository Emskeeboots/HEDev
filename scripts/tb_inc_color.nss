// tb_inc_color
// text coloring includes
// Meaglyn 2/05/2013
//

// Pull in other color file so that we can easily remove duplicates
#include "_inc_color"

//---------------------------------------------------------
// Text color routines
//
// returns a properly color-coded sText string based on specified RGB values
string ColorRGB(string sText, int nRed=255, int nGreen=255, int nBlue=255);

// returns a properly color-coded sText string based on specified constant string (TEXT_COLOR_*)
string ColorString(string sText, string sColor);

// Produce just the "<colorcode>" token for manually building color strings.
// Don't forget to put the "</c>" after the text to be colored.
string MkColorString(string sTextColor) ;

string RGBColorText( string sColor, string sText) {
	return ColorString(sText, sColor);
}

// Returns the name of oPC, surrounded by color tokens, so the color of
// the name is the lighter blue often used in NWN game engine messages.
string GetNamePCColor(object oPC);

// Returns the name of oNPC, surrounded by color tokens, so the color of
// the name is the shade of purple often used in NWN game engine messages.
string GetNameNPCColor(object oNPC);

// call this once from onModuleLoad script
// Then they can be used in conversations:
// <CUSTOM2501>here is some red text<CUSTOM2500>
void SetModuleColorTokens();

/* Notes on specific values from gaoneng's Hitchhikers guide to color tokens
     0 1 2 3 4 5 6 7 8 9
0000                        * no alt-codes for 0000 ~ 0033
0010                          use space " " to represent 0
0020
0030         " # $ % & '    * 0034 " not useable in scripts, but useable elsewhere
0040 ( ) * + , - . / 0 1
0050 2 3 4 5 6 7 8 9 : ;
0060 < = > ? @ A B C D E    * 0060 < and 0062 > best avoided
0070 F G H I J K L M N O      while valid, they are also used for flagging tokens
0080 P Q R S T U V W X Y
0090 Z [ \ ] ^ _ ` a b c    * 0092 \ not useable in scripts, but useable elsewhere
0100 d e f g h i j k l m
0110 n o p q r s t u v w
0120 x y z { | } ~   Ä Å    * 0127 not useable
0130 Ç É Ñ Ö Ü á à â ä ã    * 0128 ~ 0159 useable in scripts and talk tables only
0140 å ç é è ê ë í ì î ï      they get removed/replaced by the toolset when used elsewhere
0150 ñ ó ò ô ö õ ú ù û ü
0160   ° ¢ £ § • ¶ ß ® ©    * 0160 not useable
0170 ™ ´ ¨ ≠  Æ Ø ∞ ± ≤ ≥    * 0173 not useable
0180 ¥ µ ∂ ∑ ∏ π ¶ ª º Ω
0190 æ ø ¿ ¡ ¬ √ ƒ ≈ ∆ «
0200 » …   À Ã Õ Œ œ – —
0210 “ ” ‘ ’ ÷ ◊ ÿ Ÿ ⁄ €
0220 ‹ › ﬁ ﬂ ‡ · ‚ „ ‰ Â
0230 Ê Á Ë È Í Î Ï Ì Ó Ô
0240  Ò Ú Û Ù ı ˆ ˜ ¯ ˘
0250 ˙ ˚ ¸ ˝ ˛ \377            * 0255 \377 not useable in scripts, but useable elsewhere

\377 is really not usable in scripts even in comments. These are just the four characters \ 3 7 7 no the escape.


In summary: do not use:   034,   060,  062,  092, 127-159,        160, 173 and 255.
which in octal are    :  \042,  \074, \076, \134, \177,\200-237, \240, \255,  \376

Be careful with these. Emacs really struggles with these characters...

*/
///////////
// Colorizing routines
////////////////////
const string COLORTOKEN = "                  ##################$%&'()*+,-./0123456789:;;==?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[[]^_`abcdefghijklmnopqrstuvwxyz{|}~~ÄÅÇÉÑÖÜáàâäãåçéèêëíìîïñóòôöõúùûü°°¢£§•¶ß®©™´¨¨ÆØ∞±≤≥¥µ∂∑∏π∫ªºΩæø¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷◊ÿŸ⁄€‹›ﬁﬂ‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ˜¯˘˙˚¸˝˛˛";


// NOTE - zzdlg uses \200 where this uses \245 so these will be brighter

// bright colors
const string TEXT_COLOR_RED           = "˛  "; // red  \375
const string TEXT_COLOR_GREEN         = " ˛ "; // green
const string TEXT_COLOR_BLUE          = "  ˝"; // blue
const string TEXT_COLOR_CYAN          = " ˝˝"; // cyan
const string TEXT_COLOR_MAGENTA       = "˝ ˝"; // magenta
const string TEXT_COLOR_YELLOW        = "˝˝ "; // yellow

// moderate colors
const string TEXT_COLOR_DARK_RED      = "•  "; // dark red
const string TEXT_COLOR_DARK_GREEN    = " • "; // dark green
const string TEXT_COLOR_DARK_BLUE     = "  •"; // dark blue
const string TEXT_COLOR_DARK_CYAN     = " ••"; // dark cyan
const string TEXT_COLOR_DARK_MAGENTA  = "• •"; // dark magenta
const string TEXT_COLOR_DARK_YELLOW   = "•• "; // dark yellow

// shades of grey
const string TEXT_COLOR_BLACK         = "   "; // black
const string TEXT_COLOR_WHITE         = "˝˝˝" ; //white
const string TEXT_COLOR_GREY          = "•••"; // grey
const string TEXT_COLOR_DARK_GREY     = "}}}"; // dark grey  \175\175\175
const string TEXT_COLOR_SILVER        = "©©©"; // medium grey

// misc
const string TEXT_COLOR_ORANGE        = "˝• "; // orange
const string TEXT_COLOR_DARK_ORANGE   = "˝} "; // dark orange "\375\175 "
const string TEXT_COLOR_BROWN         = "⁄•#"; // brown
const string TEXT_COLOR_DARK_BROWN    = "¬} "; // dark brown  "\302\175 "

// These are useful for direct single line usages 
// like SendMessageToPC(oPC, COL_RED+"You are in trouble now");
/* but they are not currently used anywhere
const string COL_WHITE      = "<c>"; // talk
const string COL_GREY       = "<cäää>"; //"<cÄÄÄ>"; // whisper
//const string COL_LIGHTGREY  = "<c•••>";
//const string COL_SANDY      = "<c˛ÔP>"; // shout

const string COL_RED        = "<c˛  >"; //--used--
//const string COL_DARKRED    = "<c°*0>";
const string COL_PINK       = "<c“dd>";
//const string COL_LIGHTPINK  = "<cÊdd>";

//const string COL_ORANGE     = "<c˛} >";
//const string COL_YELLOWSERV = "<c˛f >"; // experimental

//const string COL_LEMON      = "<c˛˛ >";
//const string COL_YELLOW     = "<c˛◊ >";

const string COL_NEONGREEN  = "<c#˛#>"; // tell
const string COL_GREEN      = "<c0°0>"; // name preceding description
const string COL_LIME       = "<c°“d>"; // description
//const string COL_LIGHTGREEN = "<c°—d>";

//const string COL_DARKBLUE   = "<c  ˛>";
const string COL_BLUE       = "<c z˛>"; // skill blue
//const string BLUE       = "<cAi·>";
//const string BLUE       = "<cd°—>";
//const string COL_PERIWINKLE = "<czz˛>";
//const string COL_CYAN       = "<c ˛˛>"; // saving throw

const string COL_DMBLUE     = "<c#ﬂ˛>"; // DM chat
const string COL_PALEBLUE   = "<cá˛˛>"; // name in skill check/saving throw

//const string COL_VIOLET     = "<c°d—>";
//const string COL_PURPLE     = "<c¢Gd>";
*/

// This is in _inc_color
//const string COLOR_END  = "</c>";


// returns a properly color-coded sText string based on specified RGB values
string ColorRGB(string sText, int nRed=254, int nGreen=254, int nBlue=254)
{
    return "<c" + GetSubString(COLORTOKEN, nRed, 1) + GetSubString(COLORTOKEN, nGreen, 1)
           + GetSubString(COLORTOKEN, nBlue, 1) + ">" + sText + "</c>";
}

// returns a properly color-coded sText string based on specified constant string (TEXT_COLOR_*)
string ColorString(string sText, string sColor)
{
    if (sColor != "")
        return "<c" + sColor + ">" + sText + "</c>";
    return sText;
}

// Produce just the "<colorcode>" token for manually building color strings.
// Don't forget to put the "</c>" after the text to be colored.
string MkColorString(string sTextColor) {
    return "<c" + sTextColor + ">";
}

// call this once from onModuleLoad script
// Then they can be used in conversations:
// <CUSTOM101>here is some red text<CUSTOM100>
void SetModuleColorTokens() {


    SetCustomToken(2500, "</c>"); // CLOSE tag
    SetCustomToken(2501, MkColorString(TEXT_COLOR_RED)); // red
    SetCustomToken(2502, MkColorString(TEXT_COLOR_GREEN)); // green
    SetCustomToken(2503, MkColorString(TEXT_COLOR_BLUE)); // blue
    SetCustomToken(2504, MkColorString(TEXT_COLOR_CYAN)); // cyan
    SetCustomToken(2505, MkColorString(TEXT_COLOR_MAGENTA)); // magenta
    SetCustomToken(2506, MkColorString(TEXT_COLOR_YELLOW)); // yellow
    SetCustomToken(2507, MkColorString(TEXT_COLOR_BLACK)); // black
    SetCustomToken(2508, MkColorString(TEXT_COLOR_DARK_RED)); // dark red
    SetCustomToken(2509, MkColorString(TEXT_COLOR_DARK_GREEN)); // dark green
    SetCustomToken(2510, MkColorString(TEXT_COLOR_DARK_BLUE)); // dark blue
    SetCustomToken(2511, MkColorString(TEXT_COLOR_DARK_CYAN)); // dark cyan
    SetCustomToken(2512, MkColorString(TEXT_COLOR_DARK_MAGENTA)); // dark magenta
    SetCustomToken(2513, MkColorString(TEXT_COLOR_DARK_YELLOW)); // dark yellow
    SetCustomToken(2514, MkColorString(TEXT_COLOR_GREY)); // grey
    SetCustomToken(2515, MkColorString(TEXT_COLOR_DARK_GREY)); // dark grey
    SetCustomToken(2516, MkColorString(TEXT_COLOR_ORANGE)); // orange
    SetCustomToken(2517, MkColorString(TEXT_COLOR_DARK_ORANGE)); // dark orange
    SetCustomToken(2518, MkColorString(TEXT_COLOR_BROWN)); // brown
    SetCustomToken(2519, MkColorString(TEXT_COLOR_DARK_BROWN)); // dark brown

}

///////////////////////////////////////////////////////////////////////////////
// GetNamePCColor()
//
// Returns the name of oPC, surrounded by color tokens, so the color of
// the name is the lighter blue often used in NWN game engine messages.
//
//
string GetNamePCColor(object oPC)
{
    return "<c" + GetSubString(COLORTOKEN, 153, 1) +
            GetSubString(COLORTOKEN, 255, 1) +
            GetSubString(COLORTOKEN, 255, 1) + ">" +
            GetName(oPC) + "</c>";
}

///////////////////////////////////////////////////////////////////////////////
// GetNameNPCColor()
//
// Returns the name of oNPC, surrounded by color tokens, so the color of
// the name is the shade of purple often used in NWN game engine messages.
//
string GetNameNPCColor(object oNPC)
{
    return "<c" + GetSubString(COLORTOKEN, 204, 1) +
            GetSubString(COLORTOKEN, 153, 1) +
            GetSubString(COLORTOKEN, 204, 1) + ">" +
            GetName(oNPC) + "</c>";
}

//void main() {}
