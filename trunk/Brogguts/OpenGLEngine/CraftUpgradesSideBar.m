//
//  CraftUpgradesSideBar.m
//  OpenGLEngine
//
//  Created by James Lockwood on 8/6/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CraftUpgradesSideBar.h"
#import "SideBarButton.h"
#import "BroggutScene.h"
#import "SideBarController.h"
#import "CraftSideBar.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "CraftUpgradesStructureObject.h"

NSString* const kCraftUpgradeButtonText[8] = {
    @"Ant",
    @"Moth",
    @"Beetle",
    @"Monarch",
    @"Camel",
    @"Rat",
    @"Spider",
    @"Eagle",
};

@implementation CraftUpgradesSideBar
@synthesize upgradesStructure;

- (void)dealloc {
    [upgradesStructure release];
    [super dealloc];
}

- (id)initWithStructure:(CraftUpgradesStructureObject*)structure {
	self = [super init];
	if (self) {
        self.upgradesStructure = structure;
        PlayerProfile* profile = [[GameController sharedGameController] currentProfile];
		for (int i = 0; i < 8; i++) {
			SideBarButton* button = [[SideBarButton alloc] initWithWidth:(SIDEBAR_WIDTH - 32.0f) withHeight:100 withCenter:CGPointMake(SIDEBAR_WIDTH / 2, 50)];
			[buttonArray addObject:button];
            BOOL isUnlocked = NO;
            BOOL isPurchased = NO;
            switch (i) {
                case kCraftButtonAntID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftAntID];
                    isPurchased = [profile isUpgradePurchasedWithID:kObjectCraftAntID];
                    break;
                case kCraftButtonMothID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftMothID];
                    isPurchased = [profile isUpgradePurchasedWithID:kObjectCraftMothID];
                    break;
                case kCraftButtonBeetleID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftBeetleID];
                    isPurchased = [profile isUpgradePurchasedWithID:kObjectCraftBeetleID];
                    break;
                case kCraftButtonMonarchID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftMonarchID];
                    isPurchased = [profile isUpgradePurchasedWithID:kObjectCraftMonarchID];
                    break;
                case kCraftButtonCamelID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftCamelID];
                    isPurchased = [profile isUpgradePurchasedWithID:kObjectCraftCamelID];
                    break;
                case kCraftButtonRatID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftRatID];
                    isPurchased = [profile isUpgradePurchasedWithID:kObjectCraftRatID];
                    break;
                case kCraftButtonSpiderID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftSpiderID];
                    isPurchased = [profile isUpgradePurchasedWithID:kObjectCraftSpiderID];
                    break;
                case kCraftButtonEagleID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftEagleID];
                    isPurchased = [profile isUpgradePurchasedWithID:kObjectCraftEagleID];
                    break;
                default:
                    break;
            }
            if (isUnlocked) {
                if (isPurchased) {
                    [button setIsDisabled:YES];
                    [button setButtonText:kCraftUpgradeButtonText[i]];
                } else {
                    [button setIsDisabled:NO];
                    [button setButtonText:kCraftUpgradeButtonText[i]];
                }
            } else {
                [button setIsDisabled:YES];
                [button setButtonText:kCraftButtonLockedText];
            }
			[button release];
		}
	}
	return self;
}

- (void)updateSideBar {
    [super updateSideBar];
    if ([upgradesStructure destroyNow]) {
        [myController popSideBarObject];
    }
    PlayerProfile* profile = [[GameController sharedGameController] currentProfile];
    for (int i = 0; i < [buttonArray count]; i++) {
        SideBarButton* button = [buttonArray objectAtIndex:i];
        BOOL isPurchased = NO;
        switch (i) {
            case kCraftButtonAntID:
                isPurchased = [profile isUpgradePurchasedWithID:kObjectCraftAntID];
                break;
            case kCraftButtonMothID:
                isPurchased = [profile isUpgradePurchasedWithID:kObjectCraftMothID];
                break;
            case kCraftButtonBeetleID:
                isPurchased = [profile isUpgradePurchasedWithID:kObjectCraftBeetleID];
                break;
            case kCraftButtonMonarchID:
                isPurchased = [profile isUpgradePurchasedWithID:kObjectCraftMonarchID];
                break;
            case kCraftButtonCamelID:
                isPurchased = [profile isUpgradePurchasedWithID:kObjectCraftCamelID];
                break;
            case kCraftButtonRatID:
                isPurchased = [profile isUpgradePurchasedWithID:kObjectCraftRatID];
                break;
            case kCraftButtonSpiderID:
                isPurchased = [profile isUpgradePurchasedWithID:kObjectCraftSpiderID];
                break;
            case kCraftButtonEagleID:
                isPurchased = [profile isUpgradePurchasedWithID:kObjectCraftEagleID];
                break;
            default:
                break;
        }
        if (isPurchased) {
            [button setIsDisabled:YES];
        }
    }
}

- (void)buttonReleasedWithID:(int)buttonID atLocation:(CGPoint)location {
	[super buttonReleasedWithID:buttonID atLocation:location];
    if ([upgradesStructure destroyNow]) {
        return;
    }
    switch (buttonID) {
        case kCraftButtonAntID:
            [upgradesStructure presentCraftUpgradeDialogueWithObjectID:kObjectCraftAntID];
            break;
        case kCraftButtonMothID:
            [upgradesStructure presentCraftUpgradeDialogueWithObjectID:kObjectCraftMothID];
            break;
        case kCraftButtonBeetleID:
            [upgradesStructure presentCraftUpgradeDialogueWithObjectID:kObjectCraftBeetleID];
            break;
        case kCraftButtonMonarchID:
            [upgradesStructure presentCraftUpgradeDialogueWithObjectID:kObjectCraftMonarchID];
            break;
        case kCraftButtonCamelID:
            [upgradesStructure presentCraftUpgradeDialogueWithObjectID:kObjectCraftCamelID];
            break;
        case kCraftButtonRatID:
            [upgradesStructure presentCraftUpgradeDialogueWithObjectID:kObjectCraftRatID];
            break;
        case kCraftButtonSpiderID:
            [upgradesStructure presentCraftUpgradeDialogueWithObjectID:kObjectCraftSpiderID];
            break;
        case kCraftButtonEagleID:
            [upgradesStructure presentCraftUpgradeDialogueWithObjectID:kObjectCraftEagleID];
            break;
        default:
            break;
    }
}

@end
