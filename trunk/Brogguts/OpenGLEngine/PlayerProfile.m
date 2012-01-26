//
//  PlayerProfile.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/12/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "PlayerProfile.h"
#import "GameController.h"
#import "CampaignScene.h"
#import "GameCenterSingleton.h"

int kObjectUnlockLevelTable[TOTAL_OBJECT_TYPES_COUNT] = {
    0, 0, 0, 0, 0, 0, 0,
    kCraftAntUnlockYears, // Ant
    kCraftMothUnlockYears, // Moth
    kCraftBeetleUnlockYears, // Beetle
    kCraftMonarchUnlockYears, // Monarch
    kCraftCamelUnlockYears, // Camel
    kCraftRatUnlockYears, // Rat
    kCraftSpiderUnlockYears, // Spider
    kCraftSpiderDroneUnlockYears, // (drone)
    kCraftEagleUnlockYears, // Eagle
    kStructureBaseStationUnlockYears, // Base Station
    kStructureBlockUnlockYears, // Block
    kStructureRefineryUnlockYears, // Refinery
    kStructureCraftUpgradesUnlockYears, // Craft upgrades
    kStructureStructureUpgradesUnlockYears, // Structure upgrades
    kStructureTurretUnlockYears, // Turret
    kStructureFixerUnlockYears, // Fixer
    kStructureRadarUnlockYears, // Radar
    0, 0,
};

int kUpgradeUnlockLevelTable[TOTAL_OBJECT_TYPES_COUNT] = {
    0, 0, 0, 0, 0, 0, 0,
    kCraftAntUpgradeUnlockYears, // Ant
    kCraftMothUpgradeUnlockYears, // Moth
    kCraftBeetleUpgradeUnlockYears, // Beetle
    kCraftMonarchUpgradeUnlockYears, // Monarch
    kCraftCamelUpgradeUnlockYears, // Camel
    kCraftRatUpgradeUnlockYears, // Rat
    kCraftSpiderUpgradeUnlockYears, // Spider
    kCraftSpiderDroneUpgradeUnlockYears, // (drone)
    kCraftEagleUpgradeUnlockYears, // Eagle
    kStructureBaseStationUpgradeUnlockYears, // Base Station
    kStructureBlockUpgradeUnlockYears, // Block
    kStructureRefineryUpgradeUnlockYears, // Refinery
    kStructureCraftUpgradesUpgradeUnlockYears, // Craft upgrades
    kStructureStructureUpgradesUpgradeUnlockYears, // Structure upgrades
    kStructureTurretUpgradeUnlockYears, // Turret
    kStructureFixerUpgradeUnlockYears, // Fixer
    kStructureRadarUpgradeUnlockYears, // Radar
    0, 0,
};

static NSString* kSavedUnlockedFileName = @"savedUnlocksFile.plist";


@implementation PlayerProfile
@synthesize totalBroggutCount;
@synthesize playerSpaceYear;
@synthesize broggutCount;
@synthesize metalCount;
@synthesize playerExperience;

- (void)dealloc {
    [currentUpgradesCompletedTable release];
    [currentUpgradeUnlocksTable release];
    [currentUpgradesPurchasedTable release];
    [currentObjectUnlocksTable release];
    [super dealloc];
}

- (id)init {
    self = [super init];
	if (self)
	{
        totalBroggutCount = PROFILE_BROGGUT_START_COUNT;
		playerSpaceYear = 0;
		broggutCount = PROFILE_BROGGUT_START_COUNT;
		broggutDisplayNumber = 0;
		metalCount = PROFILE_METAL_START_COUNT;
		metalDisplayNumber = 0;
		playerExperience = 0;
        isInSkirmish = NO;
        [self loadDefaultOrPreviousUnlockTable];
        currentUpgradesPurchasedTable = [[NSMutableArray alloc] initWithCapacity:TOTAL_OBJECT_TYPES_COUNT];
        currentUpgradeUnlocksTable = [[NSMutableArray alloc] initWithCapacity:TOTAL_OBJECT_TYPES_COUNT];
        currentUpgradesCompletedTable = [[NSMutableArray alloc] initWithCapacity:TOTAL_OBJECT_TYPES_COUNT];
        for (int i = 0; i < TOTAL_OBJECT_TYPES_COUNT; i++) {
            NSNumber* num1 = [NSNumber numberWithBool:NO];
            NSNumber* num2 = [NSNumber numberWithBool:NO];
            NSNumber* num3 = [NSNumber numberWithBool:NO];
            [currentUpgradesPurchasedTable addObject:num1];
            [currentUpgradeUnlocksTable addObject:num2];
            [currentUpgradesCompletedTable addObject:num3];
        }
	}
	return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super init];
	if (self)
	{
        [self setTotalBroggutCount: [coder decodeIntForKey:@"totalBroggutCount"]];
		[self setPlayerSpaceYear:	[coder decodeIntForKey:@"playerSpaceYear"]];
		[self setBroggutCount:		CLAMP([coder decodeIntForKey:@"broggutCount"], 0, PROFILE_BROGGUT_MAX_COUNT)];
		[self setMetalCount:		CLAMP([coder decodeIntForKey:@"metalCount"], 0, PROFILE_METAL_MAX_COUNT)];
		[self setPlayerExperience:	[coder decodeIntForKey:@"playerExperience"]];
        [self loadDefaultOrPreviousUnlockTable];
		broggutDisplayNumber = broggutCount;
		metalDisplayNumber = metalCount;
        currentUpgradesPurchasedTable = [[NSMutableArray alloc] initWithCapacity:TOTAL_OBJECT_TYPES_COUNT];
        currentUpgradeUnlocksTable = [[NSMutableArray alloc] initWithCapacity:TOTAL_OBJECT_TYPES_COUNT];
        currentUpgradesCompletedTable = [[NSMutableArray alloc] initWithCapacity:TOTAL_OBJECT_TYPES_COUNT];
        for (int i = 0; i < TOTAL_OBJECT_TYPES_COUNT; i++) {
            NSNumber* num1 = [NSNumber numberWithBool:NO];
            NSNumber* num2 = [NSNumber numberWithBool:NO];
            NSNumber* num3 = [NSNumber numberWithBool:NO];
            [currentUpgradesPurchasedTable addObject:num1];
            [currentUpgradeUnlocksTable addObject:num2];
            [currentUpgradesCompletedTable addObject:num3];
        }
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
	[coder encodeInt:totalBroggutCount	forKey:@"totalBroggutCount"];
	[coder encodeInt:playerSpaceYear	forKey:@"playerSpaceYear"];
	[coder encodeInt:broggutCount		forKey:@"broggutCount"];
	[coder encodeInt:metalCount			forKey:@"metalCount"];
	[coder encodeInt:playerExperience	forKey:@"playerExperience"];
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

- (void)setPlayerExperience:(int)playerEx {
    playerExperience = playerEx;
    [[GameCenterSingleton sharedGCSingleton] updateCompleteAllMissionsAchievement:playerEx];
}

- (void)addBrogguts:(int)brogs {
    if (brogs > 0) {
        totalBroggutCount += brogs;
    }
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

- (void)setBrogguts:(int)brogs {
    if (!isInSkirmish) {
        broggutCount = brogs;
        broggutCount = CLAMP(broggutCount, 0, PROFILE_BROGGUT_MAX_COUNT);
        broggutDisplayNumber = broggutCount;
    } else {
        skirmishBroggutCount = brogs;
        skirmishBroggutCount = CLAMP(skirmishBroggutCount, 0, PROFILE_BROGGUT_MAX_COUNT);
        broggutDisplayNumber = skirmishBroggutCount;
    }
}

- (void)setMetal:(int)metal {
    if (!isInSkirmish) {
        metalCount = metal;
        metalCount = CLAMP(metalCount, 0, PROFILE_METAL_MAX_COUNT);
        metalDisplayNumber = metalCount;
    } else {
        skirmishMetalCount = metal;
        skirmishMetalCount = CLAMP(skirmishMetalCount, 0, PROFILE_METAL_MAX_COUNT);
        metalDisplayNumber = skirmishMetalCount;
    }
}

- (int)subtractBrogguts:(int)brogs metal:(int)metal {
    if (!isInSkirmish) {
        if (brogs > broggutCount && metal > metalCount) {
            return kProfileFailBroggutsAndMetal;
        } else if (brogs > broggutCount) {
            return kProfileFailBrogguts;
        } else if (metal > metalCount) {
            return kProfileFailMetal;
        } else {
            metalCount -= metal;
            broggutCount -= brogs;
            return kProfileNoFail;
        }
    } else {
        if (brogs > skirmishBroggutCount && metal > skirmishMetalCount) {
            return kProfileFailBroggutsAndMetal;
        } else if (brogs > skirmishBroggutCount) {
            return kProfileFailBrogguts;
        } else if (metal > skirmishMetalCount) {
            return kProfileFailMetal;
        } else {
            skirmishMetalCount -= metal;
            skirmishBroggutCount -= brogs;
            return kProfileNoFail;
        }
    }
}

- (int)broggutCount {
	return broggutDisplayNumber;
}

- (int)baseCampBroggutCount {
    return broggutCount;
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

- (int)playerSpaceYear {
    float sceneRatio = ((float)playerExperience / (float)CAMPAIGN_SCENES_COUNT);
    float broggutRatio = ((float)broggutCount / (float)PROFILE_BROGGUT_MAX_COUNT);
    float spaceYear = (float)PROFILE_SPACE_YEAR_MAX * 0.5f * (sceneRatio + broggutRatio);
    playerSpaceYear = (int)spaceYear;
    return playerSpaceYear;
}

- (BOOL)isIDCraftID:(int)thisid {
    if (thisid >= kObjectCraftAntID && thisid <= kObjectCraftEagleID) {
        if (thisid != kObjectCraftSpiderDroneID) { // EXCLUDE THE DRONE
            return YES;
        }
    }
    return NO;
}

- (BOOL)isIDStrucutureID:(int)thisid {
    if (thisid >= kObjectStructureBaseStationID && thisid <= kObjectStructureRadarID) {
        return YES;
    }
    return NO;
}

- (void)updateSpaceYearUnlocks {
    // Unlock the stuff that comes with the current space year
    int craftCount = 0;
    int structureCount = 0;
    
    // Objects
    for (int i = 0; i < TOTAL_OBJECT_TYPES_COUNT; i++) {
        int levelNeeded = [self levelObjectUnlockedWithID:i];
        if (levelNeeded <= playerExperience) {
            [self unlockObjectWithID:i];
            if ([self isIDCraftID:i]) { craftCount++; }
            if ([self isIDStrucutureID:i]) { structureCount++; }
        }
    }
    // Upgrades
    for (int i = 0; i < TOTAL_OBJECT_TYPES_COUNT; i++) {
        int levelNeeded = [self levelUpgradeUnlockedWithID:i];
        if (levelNeeded <= playerExperience) {
            [self unlockUpgradeWithID:i];
        }
    }
    
    [[GameCenterSingleton sharedGCSingleton] updateCraftUnlockAchievement:craftCount];
    [[GameCenterSingleton sharedGCSingleton] updateStructuresUnlockAchievement:structureCount];
}

- (void)startSceneWithType:(int)sceneType {
    if (sceneType != kSceneTypeBaseCamp) {
        isInSkirmish = YES;
        skirmishBroggutCount = PROFILE_BROGGUT_START_COUNT;
        skirmishMetalCount = PROFILE_METAL_START_COUNT;
        broggutDisplayNumber = skirmishBroggutCount;
        metalDisplayNumber = skirmishMetalCount;
    } else {
        if (isInSkirmish) {
            isInSkirmish = NO;
            broggutDisplayNumber = broggutCount;
            metalDisplayNumber = metalCount;
        }
    }
}

- (void)endSceneWithType:(int)sceneType wasSuccessful:(BOOL)success {
    if (sceneType != kSceneTypeBaseCamp) {
        if (isInSkirmish) {
            isInSkirmish = NO;
            broggutDisplayNumber = broggutCount;
            metalDisplayNumber = metalCount;
            if (sceneType != kSceneTypeTutorial) {
                if (success) {
                    [self addBrogguts:(int)((float)skirmishBroggutCount * PERCENT_BROGGUTS_CREDITED_FOR_SKIRMISH)];
                }
            }
        }
    }
}

// Unlocks // 

- (void)loadDefaultOrPreviousUnlockTable {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"hasStoredUnlockTable"]) {
        NSString* filePath = [[GameController sharedGameController] documentsPathWithFilename:kSavedUnlockedFileName];
        currentObjectUnlocksTable = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
        if (!currentObjectUnlocksTable) {
            NSLog(@"Unable to load previous unlock table");
            currentObjectUnlocksTable = [[NSMutableArray alloc] initWithCapacity:TOTAL_OBJECT_TYPES_COUNT];
            for (int i = 0; i < TOTAL_OBJECT_TYPES_COUNT; i++) {
                NSNumber* num = [NSNumber numberWithBool:NO];
                [currentObjectUnlocksTable addObject:num];
            }
        }
    } else {
        currentObjectUnlocksTable = [[NSMutableArray alloc] initWithCapacity:TOTAL_OBJECT_TYPES_COUNT];
        for (int i = 0; i < TOTAL_OBJECT_TYPES_COUNT; i++) {
            NSNumber* num = [NSNumber numberWithBool:NO];
            [currentObjectUnlocksTable addObject:num];
        }
    }
}

- (void)saveCurrentUnlocksTable {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* filePath = [[GameController sharedGameController] documentsPathWithFilename:kSavedUnlockedFileName];
    if ([currentObjectUnlocksTable writeToFile:filePath atomically:YES]) {
        [defaults setBool:YES forKey:@"hasStoredUnlockTable"];
    } else {
        [defaults setBool:NO forKey:@"hasStoredUnlockTable"];
    }
}

- (void)unlockAllObjects {
    [currentObjectUnlocksTable removeAllObjects];
    for (int i = 0; i < TOTAL_OBJECT_TYPES_COUNT; i++) {
        NSNumber* num = [NSNumber numberWithBool:YES];
        [currentObjectUnlocksTable addObject:num];
    }
}

- (BOOL)isObjectUnlockedWithID:(int)objectID {
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        NSNumber* num = [currentObjectUnlocksTable objectAtIndex:objectID];
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
        [currentObjectUnlocksTable replaceObjectAtIndex:objectID withObject:[NSNumber numberWithBool:YES]];
    }
}

// Upgrades //

- (BOOL)isUpgradeUnlockedWithID:(int)objectID {
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        NSNumber* num = [currentUpgradeUnlocksTable objectAtIndex:objectID];
        return [num boolValue];
    }
    return NO;
}

- (BOOL)isUpgradePurchasedWithID:(int)objectID {
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        NSNumber* num = [currentUpgradesPurchasedTable objectAtIndex:objectID];
        return [num boolValue];
    }
    return NO;
}

- (BOOL)isUpgradeCompleteWithID:(int)objectID {
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        NSNumber* num = [currentUpgradesCompletedTable objectAtIndex:objectID];
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

- (void)purchaseUpgradeWithID:(int)objectID {
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        [currentUpgradesPurchasedTable replaceObjectAtIndex:objectID withObject:[NSNumber numberWithBool:YES]];
    }
}

- (void)unPurchaseUpgradeWithID:(int)objectID {
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        [currentUpgradesPurchasedTable replaceObjectAtIndex:objectID withObject:[NSNumber numberWithBool:NO]];
    }
}

- (void)unlockUpgradeWithID:(int)objectID {
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        [currentUpgradeUnlocksTable replaceObjectAtIndex:objectID withObject:[NSNumber numberWithBool:YES]];
    }
}

- (void)completeUpgradeWithID:(int)objectID {
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        [currentUpgradesCompletedTable replaceObjectAtIndex:objectID withObject:[NSNumber numberWithBool:YES]];
    }
}

- (void)setCompletedUpgradesArray:(NSArray*)upgradeInfoArray {
    if ([upgradeInfoArray count] == [currentUpgradesCompletedTable count]) {
        // They are both valid arrays
        [currentUpgradesCompletedTable removeAllObjects];
        for (int i = 0; i < [upgradeInfoArray count]; i++) {
            [currentUpgradesCompletedTable addObject:[upgradeInfoArray objectAtIndex:i]];
        }
    }
}

- (NSArray*)arrayFromCompletedUpgrades {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (int i = 0; i < [currentUpgradesCompletedTable count]; i++) {
        [array insertObject:[currentUpgradesCompletedTable objectAtIndex:i] atIndex:i];
    }
    return [array autorelease];
}



@end
