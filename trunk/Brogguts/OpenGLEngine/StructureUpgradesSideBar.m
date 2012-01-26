//
//  StructureUpgradesSideBar.m
//  OpenGLEngine
//
//  Created by James Lockwood on 8/6/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "StructureUpgradesSideBar.h"
#import "SideBarButton.h"
#import "BroggutScene.h"
#import "SideBarController.h"
#import "StructureSideBar.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "StructureUpgradesStructureObject.h"
#import "UpgradeManager.h"

enum StructureUpgradeButtonIDs {
    kStructureUpgradeButtonBaseStationID,
	kStructureUpgradeButtonBlockID,
	kStructureUpgradeButtonRefineryID,
	kStructureUpgradeButtonCraftUpgradesID,
	kStructureUpgradeButtonStructureUpgradesID,
	kStructureUpgradeButtonTurretID,
	kStructureUpgradeButtonRadarID,
	kStructureUpgradeButtonFixerID,
};

NSString* const kStructureUpgradeButtonText[8] = {
    @"Base Station\nUpgrade",
    @"Block\nUpgrade",
    @"Refinery\nUpgrade",
    @"Craft Ups\nUpgrade",
    @"Structure Ups\nUpgrade",
    @"Turret\nUpgrade",
    @"Fixer\nUpgrade",
    @"Radar\nUpgrade",
};

@implementation StructureUpgradesSideBar
@synthesize upgradesStructure;

- (void)dealloc {
    [upgradesStructure release];
    [super dealloc];
}

- (id)initWithStructure:(StructureUpgradesStructureObject*)structure {
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
                case kStructureUpgradeButtonBaseStationID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectStructureBaseStationID];
                    isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectStructureBaseStationID];
                    break;
                case kStructureUpgradeButtonBlockID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectStructureBlockID];
                    isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectStructureBlockID];
                    break;
                case kStructureUpgradeButtonRefineryID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectStructureRefineryID];
                    isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectStructureRefineryID];
                    break;
                case kStructureUpgradeButtonCraftUpgradesID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectStructureCraftUpgradesID];
                    isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectStructureCraftUpgradesID];
                    break;
                case kStructureUpgradeButtonStructureUpgradesID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectStructureStructureUpgradesID];
                    isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectStructureStructureUpgradesID];
                    break;
                case kStructureUpgradeButtonTurretID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectStructureTurretID];
                    isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectStructureTurretID];
                    break;
                case kStructureUpgradeButtonRadarID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectStructureFixerID];
                    isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectStructureFixerID];
                    break;
                case kStructureUpgradeButtonFixerID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectStructureRadarID];
                    isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectStructureRadarID];
                    break;
                default:
                    break;
            }
            if (isUnlocked) {
                if (isPurchased) {
                    [button setIsDisabled:YES];
                    [button setButtonText:kStructureUpgradeButtonText[i]];
                } else {
                    [button setIsDisabled:NO];
                    [button setButtonText:kStructureUpgradeButtonText[i]];
                }
            } else {
                [button setIsDisabled:YES];
                [button setButtonText:kStructureButtonLockedText];
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
            case kStructureUpgradeButtonBaseStationID:
                isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectStructureBaseStationID];
                break;
            case kStructureUpgradeButtonBlockID:
                isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectStructureBlockID];
                break;
            case kStructureUpgradeButtonRefineryID:
                isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectStructureRefineryID];
                break;
            case kStructureUpgradeButtonCraftUpgradesID:
                isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectStructureCraftUpgradesID];
                break;
            case kStructureUpgradeButtonStructureUpgradesID:
                isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectStructureStructureUpgradesID];
                break;
            case kStructureUpgradeButtonTurretID:
                isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectStructureTurretID];
                break;
            case kStructureUpgradeButtonRadarID:
                isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectStructureFixerID];
                break;
            case kStructureUpgradeButtonFixerID:
                isPurchased = [upgradeManager isUpgradePurchasedWithID:kObjectStructureRadarID];
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
        case kStructureUpgradeButtonBaseStationID:
            [upgradesStructure presentStructureUpgradeDialogueWithObjectID:kObjectStructureBaseStationID];
            break;
        case kStructureUpgradeButtonBlockID:
            [upgradesStructure presentStructureUpgradeDialogueWithObjectID:kObjectStructureBlockID];
            break;
        case kStructureUpgradeButtonRefineryID:
            [upgradesStructure presentStructureUpgradeDialogueWithObjectID:kObjectStructureRefineryID];
            break;
        case kStructureUpgradeButtonCraftUpgradesID:
            [upgradesStructure presentStructureUpgradeDialogueWithObjectID:kObjectStructureCraftUpgradesID];
            break;
        case kStructureUpgradeButtonStructureUpgradesID:
            [upgradesStructure presentStructureUpgradeDialogueWithObjectID:kObjectStructureStructureUpgradesID];
            break;
        case kStructureUpgradeButtonTurretID:
            [upgradesStructure presentStructureUpgradeDialogueWithObjectID:kObjectStructureTurretID];
            break;
        case kStructureUpgradeButtonRadarID:
            [upgradesStructure presentStructureUpgradeDialogueWithObjectID:kObjectStructureFixerID];
            break;
        case kStructureUpgradeButtonFixerID:
            [upgradesStructure presentStructureUpgradeDialogueWithObjectID:kObjectStructureRadarID];
            break;
        default:
            break;
    }
}

@end
