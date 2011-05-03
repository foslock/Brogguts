//
//  PlayerProfile.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/12/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PROFILE_BROGGUT_MAX_COUNT 9999999
#define PROFILE_METAL_MAX_COUNT 9999999

// The percent of the brogguts earned in a skirmish are added to the total count
#define PERCENT_BROGGUTS_CREDITED_FOR_SKIRMISH 0.1f

#define PROFILE_BROGGUT_START_COUNT 200
#define PROFILE_METAL_START_COUNT 0
#define BROGGUT_DISPLAY_CHANGE_RATE 2

extern int kObjectUnlockLevelTable[TOTAL_OBJECT_TYPES_COUNT];
extern int kUpgradeUnlockLevelTable[TOTAL_OBJECT_TYPES_COUNT];

@interface PlayerProfile : NSObject <NSCoding> {
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
    
    // Upgrades and unlocks

    // This array is indexed with the ID of the structure or craft that is being unlocked, and the NSNumber (bool value) stored indicates whether or not it is unlocked yet.
    NSMutableArray* currentUnlocksTable;
    // This array is indexed with the ID of the structure or craft that gets the upgrade, and the NSNumber (bool balue) stored indicates if it has been bought in the current match.
    NSMutableArray* currentUpgradesTable;
}

@property (nonatomic, assign) int playerSpaceYear;
@property (nonatomic, assign) int broggutCount;
@property (nonatomic, assign) int metalCount;
@property (nonatomic, assign) int playerExperience;

// Updates the display number of brogguts (what "broggutCount" returns)
- (void)updateProfile; 

- (void)addBrogguts:(int)brogs;
- (void)addMetal:(int)metal;

// Returns NO if the current broggut count is too low to subtract the passed in brogguts and DOES NOT subtract them
- (BOOL)subtractBrogguts:(int)brogs metal:(int)metal;

- (int)realBroggutCount;
- (int)realMetalCount;

- (void)updateSpaceYear;
- (void)startSceneWithType:(int)sceneType;
- (void)endSceneWithType:(int)sceneType wasSuccessful:(BOOL)success;

// Unlocks
- (void)loadDefaultOrPreviousUnlockTable;
- (void)saveCurrentUnlocksTable;
- (BOOL)isObjectUnlockedWithID:(int)objectID;
- (int)levelObjectUnlockedWithID:(int)objectID;
- (void)unlockObjectWithID:(int)objectID;

// Upgrades
- (BOOL)isUpgradePurchasedWithID:(int)objectID;
- (int)levelUpgradeUnlockedWithID:(int)objectID;


@end
