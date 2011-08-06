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
            switch (i) {
                case kCraftButtonAntID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftAntID];
                    break;
                case kCraftButtonMothID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftMothID];
                    break;
                case kCraftButtonBeetleID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftBeetleID];
                    break;
                case kCraftButtonMonarchID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftMonarchID];
                    break;
                case kCraftButtonCamelID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftCamelID];
                    break;
                case kCraftButtonRatID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftRatID];
                    break;
                case kCraftButtonSpiderID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftSpiderID];
                    break;
                case kCraftButtonEagleID:
                    isUnlocked = [profile isUpgradeUnlockedWithID:kObjectCraftEagleID];
                    break;
                default:
                    break;
            }
            if (isUnlocked) {
                [button setIsDisabled:NO];
                [button setButtonText:kCraftUpgradeButtonText[i]];
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
