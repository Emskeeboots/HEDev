//::///////////////////////////////////////////////
//:: _plc_describe
//:://////////////////////////////////////////////
/*
    use or click  placeable to get its description

*/
//:://////////////////////////////////////////////
//:: Created:   henesua (2015 aug 4)
//::

#include "_inc_color"

void main()
{
    object clicker  = GetPlaceableLastClickedBy();

    SendMessageToPC(clicker, " ");
    SendMessageToPC(clicker, COLOR_OBJECT+GetName(OBJECT_SELF));
    SendMessageToPC(clicker, COLOR_DESCRIPTION+GetDescription(OBJECT_SELF));
}
