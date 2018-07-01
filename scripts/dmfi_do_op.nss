// dmfi_do_op

// Execute as the entereing PC. 
// Set dmfi_tmp_op to 
// 0 (unset)  do mod enter code
// 1     set initial languages

#include "dmfi_init_inc"
#include "_inc_languages"

void main() {

	object oPC = OBJECT_SELF;
	int nOp = GetLocalInt(oPC, "dmfi_tmp_op");
	DeleteLocalInt(oPC, "dmfi_tmp_op");

	if (nOp == 0) {
		float fDelay = GetLocalFloat(GetModule(), "DELAY_DISPLAY_START");
		
		dmfiInitialize(oPC);
		
		if(GetIsDM(oPC)) {
			DelayCommand(fDelay+0.04,SendMessageToPC(oPC," "));
			DelayCommand(fDelay+0.05,SendMessageToPC(oPC,LIGHTBLUE+"DM commands are available to you. Chat "+PALEBLUE+"/help"+LIGHTBLUE+" for more information."));
			DelayCommand(fDelay+0.06,SendMessageToPC(oPC,LIGHTBLUE+"Chat "+PALEBLUE+"/item manual"+LIGHTBLUE+" to spawn to your inventory a manual with more details about chat commands and emotes."));
		}  else {
			DelayCommand(fDelay+0.04,SendMessageToPC(oPC," "));
			DelayCommand(fDelay+0.05,SendMessageToPC(oPC,LIGHTBLUE+"Chat commands are available to you. Chat "+PALEBLUE+"/help"+LIGHTBLUE+" for more information."));
			DelayCommand(fDelay+0.06,SendMessageToPC(oPC,LIGHTBLUE+"Chat "+PALEBLUE+"/item manual"+LIGHTBLUE+" to spawn to your inventory a manual with more details about chat commands and emotes."));
			DelayCommand(fDelay+0.07,SendMessageToPC(oPC,LIGHTBLUE+"The class abilities menu contains roleplaying tools. Right click your character, and navigate to the class menu to find them."));
		}
       
		return;
	}
	
	if (nOp == 1) {
		InitializeDefaultStartingLanguages();
		return;
	}

}
