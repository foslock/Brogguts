//
//  UpgradeManager.m
//  OpenGLEngine
//
//  Created by James Lockwood on 8/10/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "UpgradeManager.h"

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
