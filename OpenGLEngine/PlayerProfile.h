//
//  PlayerProfile.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/12/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PROFILE_BROGGUT_MAX_COUNT 1000000
#define PROFILE_METAL_MAX_COUNT 1000000
#define PROFILE_SPACE_YEAR_MAX 100

// The percent of the brogguts earned in a skirmish are added to the total count
#define PERCENT_BROGGUTS_CREDITED_FOR_SKIRMISH 0.5f

#define PROFILE_BROGGUT_START_COUNT 0
#define PROFILE_METAL_START_COUNT 0
#define BROGGUT_DISPLAY_CHANGE_RATE 6
#define BROGGUTS_NEEDED_FOR_ONE_METAL 10

// Upgrades and unlocks
extern int kObjectUnlockLevelTable[TOTAL_OBJECT_TYPES_COUNT];
extern int kUpgradeUnlockLevelTable[TOTAL_OBJECT_TYPES_COUNT];

enum kProfileFailTypes {
    kProfileNoFail,
    kProfileFailBrogguts,
    kProfileFailMetal,
    kProfileFailBroggutsAndMetal,
};

@interface PlayerProfile : NSObject <NSCoding> {
    int totalBroggutCount; // Keeps track of ALL brogguts ever collected
    
	int playerSpaceYear;
	int broggutCount;
	int broggutDisplayNumber;
	int metalCount;
	int metalDisplayNumber;
	int playerExperience;
    
    // Vars used for independant matches
    BOOL isInSkirmish;
    int skirmishBroggutCount;
    int skirmishMetalCount;

    // This array is indexed with the ID of the structure or craft that is being unlocked, and the NSNumber (bool value) stored indicates whether or not it is unlocked yet.
    NSMutableArray* currentObjectUnlocksTable;
    
    // This array is indexed with the ID of the object with the upgrade, and the bool is whether THE UPGRADE is unlocked or not
    NSMutableArray* currentUpgradeUnlocksTable;
    
    // This array is indexed with the ID of the structure or craft that gets the upgrade, and the NSNumber (bool balue) stored indicates if it has been bought in the current match (it could be in progress).
    NSMutableArray* currentUpgradesPurchasedTable;

    // This array is indexed with the ID of the object that gets the upgrade, and the NSNumber (bool) indicated if the upgrade is complete and active in the the current match (used to check if should apply update)
    NSMutableArray* currentUpgradesCompletedTable;
}

@property (nonatomic, assign) int totalBroggutCount;
@property (nonatomic, assign) int playerSpaceYear;
@property (nonatomic, assign) int broggutCount;
@property (nonatomic, assign) int metalCount;
@property (nonatomic, assign) int playerExperience;

// Updates the display number of brogguts (what "broggutCount" returns)
- (void)updateProfile; 

- (void)addBrogguts:(int)brogs;
- (void)addMetal:(int)metal;
- (void)setBrogguts:(int)brogs;
- (void)setMetal:(int)metal;

// Returns the correct FAIL TYPE (see above) if there isn't enough of a particular resource
- (int)subtractBrogguts:(int)brogs metal:(int)metal;

// This returns the broggut count for the current scene (instantly updated)
- (int)realBroggutCount;

// This returns the metal count for the current scene (instantly updated)
- (int)realMetalCount;

// This returns the broggut amount left in the current Base Camp
- (int)baseCampBroggutCount;

- (void)updateSpaceYearUnlocks;
- (void)startSceneWithType:(int)sceneType;
- (void)endSceneWithType:(int)sceneType wasSuccessful:(BOOL)success;

// Unlocks
- (void)loadDefaultOrPreviousUnlockTable;
- (void)saveCurrentUnlocksTable;
- (BOOL)isObjectUnlockedWithID:(int)objectID;
- (int)levelObjectUnlockedWithID:(int)objectID;
- (void)unlockObjectWithID:(int)objectID;

// Used for testing!
- (void)unlockAllObjects;

// Upgrades
- (BOOL)isUpgradeUnlockedWithID:(int)objectID;
- (int)levelUpgradeUnlockedWithID:(int)objectID;
- (void)unlockUpgradeWithID:(int)objectID;      // Unlock for purchase

@end
