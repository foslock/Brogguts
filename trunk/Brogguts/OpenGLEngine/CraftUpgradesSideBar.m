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
#import "UpgradeManager.h"

NSString* const kCraftUpgradeButtonText[8] = {
    @"Ant\nUpgrade",
    @"Moth\nUpgrade",
    @"Beetle\nUpgrade",
    @"Monarch\nUpgrade",
    @"Camel\nUpgrade",
    @"Rat\nUpgrade",
    @"Spider\nUpgrade",
    @"Eagle\nUpgrade",
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
        BroggutScene* scene = [[GameController sharedGameController] currentScene];
        UpgradeManager* upgradeManager = [scene upgradeManager];
        PlayerProfile* profile = [[GameController sharedGameController] currentProfile];
		for (int i = 0; i < 8; i++) {
			SideBarButton* button = [[SideBarButton alloc] initWithWidth:(SIDEBAR_WIDTH - 32.0f) withHeight:100 withCenter:CGPointMake(SIDEBAR_WIDTH / 2, 50)];
			[buttonArray addObject:button];
            BOOL isUnlocked = NO;
            BOOL isPurchased = NO;
            switch (i) {
                case kCraftButtonAntID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftAntID];
                    isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectCraftAntID];
                    break;
                case kCraftButtonMothID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftMothID];
                    isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectCraftMothID];
                    break;
                case kCraftButtonBeetleID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftBeetleID];
                    isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectCraftBeetleID];
                    break;
                case kCraftButtonMonarchID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftMonarchID];
                    isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectCraftMonarchID];
                    break;
                case kCraftButtonCamelID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftCamelID];
                    isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectCraftCamelID];
                    break;
                case kCraftButtonRatID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftRatID];
                    isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectCraftRatID];
                    break;
                case kCraftButtonSpiderID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftSpiderID];
                    isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectCraftSpiderID];
                    break;
                case kCraftButtonEagleID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftEagleID];
                    isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectCraftEagleID];
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
    BroggutScene* scene = [[GameController sharedGameController] currentScene];
    UpgradeManager* upgradeManager = [scene upgradeManager];
    for (int i = 0; i < [buttonArray count]; i++) {
        SideBarButton* button = [buttonArray objectAtIndex:i];
        BOOL isPurchased = NO;
        switch (i) {
            case kCraftButtonAntID:
                isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectCraftAntID];
                break;
            case kCraftButtonMothID:
                isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectCraftMothID];
                break;
            case kCraftButtonBeetleID:
                isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectCraftBeetleID];
                break;
            case kCraftButtonMonarchID:
                isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectCraftMonarchID];
                break;
            case kCraftButtonCamelID:
                isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectCraftCamelID];
                break;
            case kCraftButtonRatID:
                isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectCraftRatID];
                break;
            case kCraftButtonSpiderID:
                isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectCraftSpiderID];
                break;
            case kCraftButtonEagleID:
                isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectCraftEagleID];
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
    GameController* controller = [GameController sharedGameController];
    if (![controller currentScene].isShowingDialogue) {
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
}

@end
