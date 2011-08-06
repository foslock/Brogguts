//
//  CraftUpgradesStructureObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/11/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CraftUpgradesStructureObject.h"
#import "Image.h"
#import "BroggutScene.h"
#import "SideBarController.h"
#import "UpgradeDialogueObject.h"
#import "CraftUpgradesSideBar.h"

NSString* const kCraftUpgradeTexts[8] = {
    @"Ant Upgrade",
    @"Moth Upgrade",
    @"Beetle Upgrade",
    @"Monarch Upgrade",
    @"Camel Upgrade",
    @"Rat Upgrade",
    @"Spider Upgrade",
    @"Eagle Upgrade",
};

@implementation CraftUpgradesStructureObject

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectStructureCraftUpgradesID withLocation:location isTraveling:traveling];
	if (self) {
		isCheckedForRadialEffect = YES;
        isBeingPressed = NO;
	}
	return self;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    if (isBeingPressed) {
        [objectImage setColor:Color4fMake(0.8f, 0.8f, 0.8f, 1.0f)];
    } else {
        [objectImage setColor:Color4fMake(1.0f, 1.0f, 1.0f, 1.0f)];
    }
}

- (void)touchesBeganAtLocation:(CGPoint)location {
    [super touchesBeganAtLocation:location];
    isBeingPressed = YES;
}

- (void)touchesEndedAtLocation:(CGPoint)location {
    [super touchesEndedAtLocation:location];
    if (isBeingPressed && CircleContainsPoint([self touchableBounds], location)) {
        CraftUpgradesSideBar* sideBar = [[CraftUpgradesSideBar alloc] initWithStructure:self];
        [sideBar setMyController:[[self currentScene] sideBar]];
        [[[self currentScene] sideBar] pushSideBarObject:sideBar];
        [[[self currentScene] sideBar] moveSideBarIn];
    }
    isBeingPressed = NO;
}

- (void)presentCraftUpgradeDialogueWithObjectID:(int)objectID {
    UpgradeDialogueObject* dialogue = [[UpgradeDialogueObject alloc] initWithUpgradeID:objectID];
    [[currentScene sceneDialogues] addObject:dialogue];
    [dialogue release];
    
    int imageIndex = 0;
    NSString* upgradeText = nil;
    switch (objectID) {
        case kObjectCraftAntID:
            imageIndex = 0;
            upgradeText = [NSString stringWithString:kCraftUpgradeTexts[0]];
            break;
        case kObjectCraftMothID:
            imageIndex = 0;
            upgradeText = [NSString stringWithString:kCraftUpgradeTexts[1]];
            break;
        case kObjectCraftBeetleID:
            imageIndex = 0;
            upgradeText = [NSString stringWithString:kCraftUpgradeTexts[2]];
            break;
        case kObjectCraftMonarchID:
            imageIndex = 0;
            upgradeText = [NSString stringWithString:kCraftUpgradeTexts[3]];
            break;
        case kObjectCraftCamelID:
            imageIndex = 0;
            upgradeText = [NSString stringWithString:kCraftUpgradeTexts[4]];
            break;
        case kObjectCraftRatID:
            imageIndex = 0;
            upgradeText = [NSString stringWithString:kCraftUpgradeTexts[5]];
            break;
        case kObjectCraftSpiderID:
            imageIndex = 0;
            upgradeText = [NSString stringWithString:kCraftUpgradeTexts[6]];
            break;
        case kObjectCraftEagleID:
            imageIndex = 0;
            upgradeText = [NSString stringWithString:kCraftUpgradeTexts[7]];
            break;
        default:
            break;
    }

    [dialogue setDialogueImageIndex:imageIndex];
    [dialogue setDialogueText:upgradeText];
    [dialogue presentDialogue];
}

@end
