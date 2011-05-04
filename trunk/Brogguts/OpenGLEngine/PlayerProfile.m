//
//  PlayerProfile.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/12/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "PlayerProfile.h"
#import "GameController.h"

int kObjectUnlockLevelTable[TOTAL_OBJECT_TYPES_COUNT] = {
    0, 0, 0, 0, 0, 0, 0,
    0, // Ant
    1, // Moth
    2, // Beetle
    3, // Monarch
    4, // Camel
    5, // Rat
    7, // Spider
    0, // (drone)
    8, // Eagle
    0, // Base Station
    0, // Block
    3, // Refinery
    4, // Turret
    3, // Fixer
    2, // Radar
    0, 0,
};

int kUpgradeUnlockLevelTable[TOTAL_OBJECT_TYPES_COUNT] = {
    0, 0, 0, 0, 0, 0, 0,
    2, // Ant
    6, // Moth
    7, // Beetle
    8, // Monarch
    11, // Camel
    10, // Rat
    12, // Spider
    0, // (drone)
    13, // Eagle
    0, // Base Station
    1, // Block
    7, // Refinery
    6, // Turret
    5, // Fixer
    6, // Radar
    0, 0,
};

static NSString* kSavedUnlockedFileName = @"savedUnlocksFile.plist";


@implementation PlayerProfile
@synthesize playerSpaceYear;
@synthesize broggutCount;
@synthesize metalCount;
@synthesize playerExperience;

- (void)dealloc {
    [currentUpgradesTable release];
    [currentUnlocksTable release];
    [super dealloc];
}

- (id)init {
    self = [super init];
	if (self)
	{
		playerSpaceYear = 0;
		broggutCount = PROFILE_BROGGUT_START_COUNT;
		broggutDisplayNumber = 0;
		metalCount = PROFILE_METAL_START_COUNT;
		metalDisplayNumber = 0;
		playerExperience = 0;
        isInSkirmish = NO;
        [self loadDefaultOrPreviousUnlockTable];
        currentUpgradesTable = [[NSMutableArray alloc] initWithCapacity:TOTAL_OBJECT_TYPES_COUNT];
        for (int i = 0; i < TOTAL_OBJECT_TYPES_COUNT; i++) {
            NSNumber* num = [NSNumber numberWithBool:NO];
            [currentUpgradesTable addObject:num];
        }
	}
	return self;
}

- (void)updateProfile {
    if (!isInSkirmish) {
        if (broggutDisplayNumber < broggutCount) {
            broggutDisplayNumber += BROGGUT_DISPLAY_CHANGE_RATE;
            broggutDisplayNumber = CLAMP(broggutDisplayNumber, 0, broggutCount);
        }
        if (broggutDisplayNumber > broggutCount) {
            broggutDisplayNumber -= BROGGUT_DISPLAY_CHANGE_RATE;
            broggutDisplayNumber = CLAMP(broggutDisplayNumber, 0, PROFILE_BROGGUT_MAX_COUNT);
        }
        if (metalDisplayNumber < metalCount) {
            metalDisplayNumber += BROGGUT_DISPLAY_CHANGE_RATE;
            metalDisplayNumber = CLAMP(metalDisplayNumber, 0, metalCount);
        }
        if (metalDisplayNumber > metalCount) {
            metalDisplayNumber -= BROGGUT_DISPLAY_CHANGE_RATE;
            metalDisplayNumber = CLAMP(metalDisplayNumber, 0, PROFILE_METAL_MAX_COUNT);
        }
    } else {
        if (broggutDisplayNumber < skirmishBroggutCount) {
            broggutDisplayNumber += BROGGUT_DISPLAY_CHANGE_RATE;
            broggutDisplayNumber = CLAMP(broggutDisplayNumber, 0, skirmishBroggutCount);
        }
        if (broggutDisplayNumber > skirmishBroggutCount) {
            broggutDisplayNumber -= BROGGUT_DISPLAY_CHANGE_RATE;
            broggutDisplayNumber = CLAMP(broggutDisplayNumber, 0, PROFILE_BROGGUT_MAX_COUNT);
        }
        if (metalDisplayNumber < skirmishMetalCount) {
            metalDisplayNumber += BROGGUT_DISPLAY_CHANGE_RATE;
            metalDisplayNumber = CLAMP(metalDisplayNumber, 0, skirmishMetalCount);
        }
        if (metalDisplayNumber > skirmishMetalCount) {
            metalDisplayNumber -= BROGGUT_DISPLAY_CHANGE_RATE;
            metalDisplayNumber = CLAMP(metalDisplayNumber, 0, PROFILE_METAL_MAX_COUNT);
        }
    }
}

- (void)addBrogguts:(int)brogs {
    if (!isInSkirmish) {
        broggutCount += brogs;
        broggutCount = CLAMP(broggutCount, 0, PROFILE_BROGGUT_MAX_COUNT);
    } else {
        skirmishBroggutCount += brogs;
        skirmishBroggutCount = CLAMP(skirmishBroggutCount, 0, PROFILE_BROGGUT_MAX_COUNT);
    }
}

- (void)addMetal:(int)metal {
    if (!isInSkirmish) {
        metalCount += metal;
        metalCount = CLAMP(metalCount, 0, PROFILE_METAL_MAX_COUNT);
    } else {
        skirmishMetalCount += metal;
        skirmishMetalCount = CLAMP(skirmishMetalCount, 0, PROFILE_METAL_MAX_COUNT);
    }
}

- (BOOL)subtractBrogguts:(int)brogs metal:(int)metal {
    if (!isInSkirmish) {
        if (brogs > broggutCount || metal > metalCount) {
            return NO;
        } else {
            metalCount -= metal;
            broggutCount -= brogs;
            return YES;
        }
    } else {
        if (brogs > skirmishBroggutCount || metal > skirmishMetalCount) {
            return NO;
        } else {
            skirmishMetalCount -= metal;
            skirmishBroggutCount -= brogs;
            return YES;
        }
    }
}

- (int)broggutCount {
	return broggutDisplayNumber;
}

- (int)realBroggutCount {
    if (!isInSkirmish) {
        return broggutCount;
    } else {
        return skirmishBroggutCount;
    }
}

- (int)metalCount {
	return metalDisplayNumber;
}

- (int)realMetalCount {
    if (!isInSkirmish) {
        return metalCount;
    } else {
        return skirmishMetalCount;
    }
}

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super init];
	if (self)
	{
		[self setPlayerSpaceYear:	[coder decodeIntForKey:@"playerSpaceYear"]];
		[self setBroggutCount:		CLAMP([coder decodeIntForKey:@"broggutCount"], 0, PROFILE_BROGGUT_MAX_COUNT)];
		[self setMetalCount:		CLAMP([coder decodeIntForKey:@"metalCount"], 0, PROFILE_METAL_MAX_COUNT)];
		[self setPlayerExperience:	[coder decodeIntForKey:@"playerExperience"]];
		broggutDisplayNumber = broggutCount;
		metalDisplayNumber = metalCount;
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
	[coder encodeInt:playerSpaceYear	forKey:@"playerSpaceYear"];
	[coder encodeInt:broggutCount		forKey:@"broggutCount"];
	[coder encodeInt:metalCount			forKey:@"metalCount"];
	[coder encodeInt:playerExperience	forKey:@"playerExperience"];
}

- (void)updateSpaceYear {
    // Perform a calculation (log based) on the total broggut count to get the space year
}

- (void)startSceneWithType:(int)sceneType {
    if (sceneType != kSceneTypeBaseCamp &&
        sceneType != kSceneTypeTutorial) {
        isInSkirmish = YES;
        skirmishBroggutCount = 0;
        skirmishMetalCount = 0;
        broggutDisplayNumber = skirmishBroggutCount;
        metalDisplayNumber = skirmishMetalCount;
    }
}

- (void)endSceneWithType:(int)sceneType wasSuccessful:(BOOL)success {
    if (sceneType != kSceneTypeBaseCamp &&
        sceneType != kSceneTypeTutorial) {
        if (isInSkirmish) {
            isInSkirmish = NO;
            broggutDisplayNumber = broggutCount;
            metalDisplayNumber = metalCount;
            if (success) {
                [self addBrogguts:(int)((float)skirmishBroggutCount * PERCENT_BROGGUTS_CREDITED_FOR_SKIRMISH)];
            }
        }
    }
}

// Unlocks // 

- (void)loadDefaultOrPreviousUnlockTable {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"hasStoredUnlockTable"]) {
        NSString* filePath = [[GameController sharedGameController] documentsPathWithFilename:kSavedUnlockedFileName];
        currentUnlocksTable = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
        if (!currentUnlocksTable) {
            NSLog(@"Unable to load previous unlock table");
            currentUnlocksTable = [[NSMutableArray alloc] initWithCapacity:TOTAL_OBJECT_TYPES_COUNT];
            for (int i = 0; i < TOTAL_OBJECT_TYPES_COUNT; i++) {
                NSNumber* num = [NSNumber numberWithBool:NO];
                [currentUnlocksTable addObject:num];
            }
        }
    } else {
        currentUnlocksTable = [[NSMutableArray alloc] initWithCapacity:TOTAL_OBJECT_TYPES_COUNT];
        for (int i = 0; i < TOTAL_OBJECT_TYPES_COUNT; i++) {
            NSNumber* num = [NSNumber numberWithBool:NO];
            [currentUnlocksTable addObject:num];
        }
    }
}

- (void)saveCurrentUnlocksTable {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* filePath = [[GameController sharedGameController] documentsPathWithFilename:kSavedUnlockedFileName];
    if ([currentUnlocksTable writeToFile:filePath atomically:YES]) {
        [defaults setBool:YES forKey:@"hasStoredUnlockTable"];
    } else {
        [defaults setBool:NO forKey:@"hasStoredUnlockTable"];
    }
}

- (BOOL)isObjectUnlockedWithID:(int)objectID {
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        NSNumber* num = [currentUnlocksTable objectAtIndex:objectID];
        return [num boolValue];
    }
    return NO;
}


- (int)levelObjectUnlockedWithID:(int)objectID {
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        return kObjectUnlockLevelTable[objectID];
    }
    return 0;
}

- (void)unlockObjectWithID:(int)objectID {
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        [currentUnlocksTable replaceObjectAtIndex:objectID withObject:[NSNumber numberWithBool:YES]];
    }
}

- (void)unlockUpgradeWithID:(int)objectID {
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        [currentUpgradesTable replaceObjectAtIndex:objectID withObject:[NSNumber numberWithBool:YES]];
    }
}

// Upgrades // 

- (BOOL)isUpgradePurchasedWithID:(int)objectID {
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        NSNumber* num = [currentUpgradesTable objectAtIndex:objectID];
        return [num boolValue];
    }
    return NO;
}


- (int)levelUpgradeUnlockedWithID:(int)objectID {
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        return kUpgradeUnlockLevelTable[objectID];
    }
    return 0;
}

@end
