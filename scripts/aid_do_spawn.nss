//aid_do_spawn.nss
// handle spawning of detection AOE for spawned AID secrest. Run as the spawned object.
// Assumes this is valid
// object oParentSpawn = GetLocalObject(OBJECT_SELF, "ParentSpawn");
// so should be called from NESS spawn script.

#include "aid_inc_fcns"

void main() {
	object oParentSpawn = GetLocalObject(OBJECT_SELF, "ParentSpawn");
	CopyAllAIDVariables(oParentSpawn, OBJECT_SELF);
	CopyAllSecretVariables(oParentSpawn, OBJECT_SELF);
	
        // apply a detection AOE around the secret object so that DETECT MODE works for detection
	int nAOE = GetLocalInt(oParentSpawn, "AOE_ID");
	if(!nAOE)  nAOE    = 72;
	
	effect eAOE = EffectAreaOfEffect(nAOE, "v2_sec_detect", "", "v2_sec_exit");
	ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, eAOE, GetLocation(OBJECT_SELF));
	object oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT, OBJECT_SELF);
	SetLocalObject(oAOE,"SECRET_AOE_TARGET",OBJECT_SELF);
	SetLocalInt(oAOE,"X1_L_IMMUNE_TO_DISPEL",10);
       
}
