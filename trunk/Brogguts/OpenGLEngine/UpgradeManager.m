//
//  UpgradeManager.m
//  OpenGLEngine
//
//  Created by James Lockwood on 8/10/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "UpgradeManager.h"

NSString* kObjectUnlockDetailText[TOTAL_OBJECT_TYPES_COUNT] = {
    @"", @"", @"", @"", @"", @"", @"", // Nothing
    @"If purchased, all Ants in your fleet will be upgraded with the newest mining technology allowing them to collect brogguts 50 percent faster.", // Ant (faster mining)
    @"If purchased, all Moth craft will have in addition to their incredible speed, the chance to evade enemy attacks.", // Moth (Evades attack sometimes)
    @"If purchased, all Beetle craft will have their lasers replaced with a powerful missile launcher that has a longer range than the basic laser.", // Beetle (fires missles instead of laser)
    @"If purchased, all Monarch craft will have equipment installed to support the protection of more ships from more damage.", // Monarch (provides better protection, different color, to more ships)
    @"If purchased, all Camel craft will have their insides gutted to hold a lot more brogguts when its mining.", // Camel (Increased cargo space)
    @"If purchased, all Rat craft will have their view distance increased greatly to increase their scouting potential.", // Rat (Increased view distance)
    @"If purchased, all Spider craft will replace their drones faster and require less brogguts to do so.", // Spider (Lower's cost and decrease production time of drones)
    @"", // (drone)
    @"If purchased, all Eagle craft will slowly repair themselves over time without the use of a Fixer structure. Take them away from a battle and let them repair for a second wind.", // Eagle (Repairs itself)
    @"If purchased, your Base Station will have its armor increased to withstand more damage from enemy ships.", // Base Station (Increased armor)
    @"If purchased, all Blocks will have their armor increased to withstand more damage from enemy ships.", // Block (Stronger)
    @"If purchased, all Refineries will refine brogguts into metal at a faster rate than normal.", // Refinery (Better broggut/metal ratio)
    @"If purchased, all Craft Upgrade structures will research upgrades at a faster rate.", // Craft upgrades (Faster upgrades)
    @"If purchased, all Structure Upgrade structures will research upgrades at a faster rate.", // Structure upgrades (Faster upgrades)
    @"If purchased, all Turrets will attack at a much faster rate than normal.", // Turret (Double attack speed)
    @"If purchased, all Fixers will repair two nearby friendly craft at once instead of just one.", // Fixer (Fixes two craft instead of one)
    @"If purchased, all Radar structures will have their range and view distance increased greatly.", // Radar (Expanded range/view distance)
    @"", @"", // Nothing
};

enum kIntToBool {
    kIntToBoolFalse,
    kIntToBoolTrue,
};

@implementation UpgradeManager

- (id)init
{
    self = [super init];
    if (self) {
        for (int i = 0; i < TOTAL_OBJECT_TYPES_COUNT; i++) {
            currentPurchasedUpgrades[i] = kIntToBoolFalse;
            currentCompletedUpgrades[i] = kIntToBoolFalse;
        }
    }
    return self;
}

// Upgrades
- (BOOL)isUpgradePurchasedWithID:(int)objectID {
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        int intBool = currentPurchasedUpgrades[objectID];
        if (intBool == kIntToBoolFalse) {
            return NO;
        } else if (intBool == kIntToBoolTrue) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isUpgradeCompleteWithID:(int)objectID {
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        int intBool = currentCompletedUpgrades[objectID];
        if (intBool == kIntToBoolFalse) {
            return NO;
        } else if (intBool == kIntToBoolTrue) {
            return YES;
        }
    }
    return NO;
}

- (void)purchaseUpgradeWithID:(int)objectID {    // Start the upgrade for this match
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        currentPurchasedUpgrades[objectID] = kIntToBoolTrue;
    }
}

- (void)unPurchaseUpgradeWithID:(int)objectID {  // Cancel the upgrade (building was destroyed)
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        currentPurchasedUpgrades[objectID] = kIntToBoolFalse;
    }
}

- (void)completeUpgradeWithID:(int)objectID {    // Sets the upgrade as complete and active for this match
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        currentCompletedUpgrades[objectID] = kIntToBoolTrue;
    }
}

- (void)setCompletedUpgradesArray:(NSArray*)upgradeInfoArray {
    for (int i = 0; i < [upgradeInfoArray count]; i++) {
        NSNumber* boolNum = [upgradeInfoArray objectAtIndex:i];
        if ([boolNum boolValue]) {
            currentCompletedUpgrades[i] = kIntToBoolTrue;
        } else {
            currentCompletedUpgrades[i] = kIntToBoolFalse;
        }
    }
}

- (NSArray*)arrayFromCompletedUpgrades {
    NSMutableArray* newArray = [[NSMutableArray alloc] initWithCapacity:TOTAL_OBJECT_TYPES_COUNT];
    for (int i = 0; i < TOTAL_OBJECT_TYPES_COUNT; i++) {
        int intBool = currentCompletedUpgrades[i];
        if (intBool == kIntToBoolFalse) {
            [newArray addObject:[NSNumber numberWithBool:NO]];
        } else if (intBool == kIntToBoolTrue) {
            [newArray addObject:[NSNumber numberWithBool:YES]];
        }
    }
    return [newArray autorelease];
}

- (void)setPurchasedUpgradesArray:(NSArray*)upgradeInfoArray {
    for (int i = 0; i < [upgradeInfoArray count]; i++) {
        NSNumber* boolNum = [upgradeInfoArray objectAtIndex:i];
        if ([boolNum boolValue]) {
            currentPurchasedUpgrades[i] = kIntToBoolTrue;
        } else {
            currentPurchasedUpgrades[i] = kIntToBoolFalse;
        }
    }
}

- (NSArray*)arrayFromPurchasedUpgrades {
    NSMutableArray* newArray = [[NSMutableArray alloc] initWithCapacity:TOTAL_OBJECT_TYPES_COUNT];
    for (int i = 0; i < TOTAL_OBJECT_TYPES_COUNT; i++) {
        int intBool = currentPurchasedUpgrades[i];
        if (intBool == kIntToBoolFalse) {
            [newArray addObject:[NSNumber numberWithBool:NO]];
        } else if (intBool == kIntToBoolTrue) {
            [newArray addObject:[NSNumber numberWithBool:YES]];
        }
    }
    return [newArray autorelease];
}

@end
