#include "_inc_util"
#include "_inc_xp"

void main()
{
    object oVic = GetLastUsedBy();

    int xp  = XPGetPCNeedsToLevel(oVic)+300;

    GiveXPToCreature(oVic,xp);
}
