//
//  StructureUpgradesStructureObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/11/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "StructureUpgradesStructureObject.h"
#import "Image.h"
#import "BroggutScene.h"
#import "SideBarController.h"
#import "UpgradeDialogueObject.h"
#import "StructureUpgradesSideBar.h"

NSString* const kStructureUpgradeTexts[8] = {
    @"Base Station Upgrade",
    @"Block Upgrade",
    @"Refinery Upgrade",
    @"Craft Upgrades Upgrade",
    @"Structure Upgrades Upgrade",
    @"Turret Upgrade",
    @"Fixer Upgrade",
    @"Radar Upgrade",
};

@implementation StructureUpgradesStructureObject

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectStructureStructureUpgradesID withLocation:location isTraveling:traveling];
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
        StructureUpgradesSideBar* sideBar = [[StructureUpgradesSideBar alloc] initWithStructure:self];
        [sideBar setMyController:[[self currentScene] sideBar]];
        [[[self currentScene] sideBar] pushSideBarObject:sideBar];
        [[[self currentScene] sideBar] moveSideBarIn];
    }
    isBeingPressed = NO;
}

- (void)presentStructureUpgradeDialogueWithObjectID:(int)objectID {
    UpgradeDialogueObject* dialogue = [[UpgradeDialogueObject alloc] initWithUpgradeID:objectID];
    [[currentScene sceneDialogues] addObject:dialogue];
    [dialogue release];
    
    int imageIndex = 0;
    NSString* upgradeText = nil;
    switch (objectID) {
        case kObjectStructureBaseStationID:
            imageIndex = 0;
            upgradeText = [NSString stringWithString:kStructureUpgradeTexts[0]];
            break;
        case kObjectStructureBlockID:
            imageIndex = 0;
            upgradeText = [NSString stringWithString:kStructureUpgradeTexts[1]];
            break;
        case kObjectStructureRefineryID:
            imageIndex = 0;
            upgradeText = [NSString stringWithString:kStructureUpgradeTexts[2]];
            break;
        case kObjectStructureCraftUpgradesID:
            imageIndex = 0;
            upgradeText = [NSString stringWithString:kStructureUpgradeTexts[3]];
            break;
        case kObjectStructureStructureUpgradesID:
            imageIndex = 0;
            upgradeText = [NSString stringWithString:kStructureUpgradeTexts[4]];
            break;
        case kObjectStructureTurretID:
            imageIndex = 0;
            upgradeText = [NSString stringWithString:kStructureUpgradeTexts[5]];
            break;
        case kObjectStructureFixerID:
            imageIndex = 0;
            upgradeText = [NSString stringWithString:kStructureUpgradeTexts[6]];
            break;
        case kObjectStructureRadarID:
            imageIndex = 0;
            upgradeText = [NSString stringWithString:kStructureUpgradeTexts[7]];
            break;
        default:
            break;
    }
    
    [dialogue setDialogueImageIndex:imageIndex];
    [dialogue setDialogueText:upgradeText];
    [dialogue presentDialogue];
}

@end
