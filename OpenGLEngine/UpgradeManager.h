//
//  UpgradeManager.h
//  OpenGLEngine
//
//  Created by James Lockwood on 8/10/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameplayConstants.h"

extern NSString* kObjectUnlockDetailText[TOTAL_OBJECT_TYPES_COUNT];

@interface UpgradeManager : NSObject {
    // Upgrades for the current scene/match
    int currentPurchasedUpgrades[TOTAL_OBJECT_TYPES_COUNT]; // Array of int bools that represent whether that object's upgrade has been purchased
    int currentCompletedUpgrades[TOTAL_OBJECT_TYPES_COUNT]; // Array of int bools that represent whether that object's upgrade has been completed
}

+ (NSString*)formalNameForObjectWithID:(int)objectID;

// Upgrades
- (BOOL)isUpgradePurchasedWithID:(int)objectID;
- (BOOL)isUpgradeCompleteWithID:(int)objectID;

- (void)purchaseUpgradeWithID:(int)objectID;    // Start the upgrade for this match
- (void)unPurchaseUpgradeWithID:(int)objectID;  // Cancel the upgrade (building was destroyed)

- (void)completeUpgradeWithID:(int)objectID;    // Sets the upgrade as complete and active for this match

- (void)setCompletedUpgradesArray:(NSArray*)upgradeInfoArray;
- (NSArray*)arrayFromCompletedUpgrades;

- (void)setPurchasedUpgradesArray:(NSArray*)upgradeInfoArray;
- (NSArray*)arrayFromPurchasedUpgrades;


@end
