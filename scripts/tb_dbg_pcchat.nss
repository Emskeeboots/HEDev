// tb_dbg_pcchat
// Handle debug pc chats
// called with executescriptandreturnint from the main pcchat handler.
// This returns 1 (aka EXECUTE_SCRIPT_END) if it handled the chat string.

#include "tb_inc_dbglib"
#include "x2_inc_switches"

void main() {
      object oPC = GetPCChatSpeaker();
      string sChat =  GetPCChatMessage();

      if (sChat == "")
        return;

      //db("Got chat = " + sChat);

      // See if the debug code wants it
      if (debugChatCommand(sChat, oPC)) {
          SetPCChatMessage("");       // Change the text of the chat.
          SetPCChatVolume(TALKVOLUME_TELL); // make only the speaking PC see it
          SetExecutedScriptReturnValue(TRUE); // EXECUTE_SCRIPT_END
      }

}
