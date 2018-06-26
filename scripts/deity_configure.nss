///////////////////////////////////////////////////////////////////////////////
// deity_configure.nss
//
// Created by: The Krit
// Date: 2/24/07
///////////////////////////////////////////////////////////////////////////////
//
// This file defines various settings used by Dynamic Deity Populated Pantheon.
// They are grouped here for convenience.
//
// Change this file as needed.
//
///////////////////////////////////////////////////////////////////////////////

#include "00_debug"

// Set the following string to describe your world. (Used in some level-up messages.)
const string WORLDNAME = "this world";

// Set the following constant to FALSE if neutral clerics are allowed to choose
// the good, evil, law, and chaos domains.
const int bForceAlignmentDomainMatch = TRUE;

// Set the following constant to TRUE if you want the pre-packaged pantheons to
// use the new law and chaos domains.
// (Not needed or used if you make your own pantheon.)
// Not needed anymore since we are using the new domains. 
//const int bUseNewDomains = TRUE;

// Set this to be the default church name when not otherwise set.
// For example, temple, shrine. Default is church.
const string DEFAULT_CHURCHNAME = "church";

// This is the base amount used in tithe calculations.
const int DEFAULT_TITHE_BASE_COST = 25;

// This is the base amount used in healing calculations.
const int DEFAULT_HEAL_BASE_COST = 25;

const int DEFAULT_PRAYER_EFFECT_HOURS = 12;

///////////////////////////////////////////////////////////////////////////
// CEP
///////////////////////////////////////////////////////////////////////////

// Set the following constant to TRUE if your module uses CEP.
// (Only affects the pre-packaged pantheons.)
const int bUseCEP = FALSE;

