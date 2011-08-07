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
#import "PlayerProfile.h"
#import "GameController.h"
#import "TextObject.h"
#import "ImageRenderSingleton.h"

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
@synthesize isCurrentlyProcessingUpgrade;

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectStructureCraftUpgradesID withLocation:location isTraveling:traveling];
	if (self) {
		isCheckedForRadialEffect = YES;
        isBeingPressed = NO;
        isCurrentlyProcessingUpgrade = NO;
        
        pressedObjectID = -1;
        currentUpgradeObjectID = -1;
        currentUpgradeProgress = 0.0f;
        upgradeTotalGoal = 0.0f;
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
    
    if (isCurrentlyProcessingUpgrade && !destroyNow) {
        if (currentUpgradeProgress < upgradeTotalGoal) {
            currentUpgradeProgress += aDelta;
        } else { // Upgrade is done!
            // Set the upgrade to active in the profile
            isCurrentlyProcessingUpgrade = NO;
            currentUpgradeObjectID = -1;
            currentUpgradeProgress = 0.0f;
            upgradeTotalGoal = 0.0f;
        }
    }
}

- (void)touchesBeganAtLocation:(CGPoint)location {
    [super touchesBeganAtLocation:location];
    isBeingPressed = YES;
}

- (void)touchesEndedAtLocation:(CGPoint)location {
    [super touchesEndedAtLocation:location];
    if (!isCurrentlyProcessingUpgrade && !destroyNow) {
        if (isBeingPressed && CircleContainsPoint([self touchableBounds], location)) {
            CraftUpgradesSideBar* sideBar = [[CraftUpgradesSideBar alloc] initWithStructure:self];
            [sideBar setMyController:[[self currentScene] sideBar]];
            [[[self currentScene] sideBar] pushSideBarObject:sideBar];
            [[[self currentScene] sideBar] moveSideBarIn];
            [sideBar release];
        }
    }
    isBeingPressed = NO;
}

- (void)presentCraftUpgradeDialogueWithObjectID:(int)objectID {
    UpgradeDialogueObject* dialogue = [[UpgradeDialogueObject alloc] initWithUpgradeID:objectID];
    [dialogue setUpgradesStructure:self];
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

- (void)renderOverObjectWithScroll:(Vector2f)scroll {
    [super renderOverObjectWithScroll:scroll];
    if (isCurrentlyProcessingUpgrade) {
        enablePrimitiveDraw();
        Circle progressCircle;
        progressCircle.x = objectLocation.x;
        progressCircle.y = objectLocation.y;
        progressCircle.radius = [self boundingCircle].radius + 10.0f;
        int totalSegments = upgradeTotalGoal;
        int filledSegments = currentUpgradeProgress;
        glLineWidth(2.0f);
        drawPartialDashedCircle(progressCircle, filledSegments, totalSegments, Color4fOnes, Color4fBlack, scroll);
        disablePrimitiveDraw();
    }
}

- (void)objectWasDestroyed {
    isCurrentlyProcessingUpgrade = NO;
    currentUpgradeObjectID = -1;
    currentUpgradeProgress = 0.0f;
    upgradeTotalGoal = 0.0f;
    [super objectWasDestroyed];
}

- (void)startUpgradeForCraft:(int)objectID withStartTime:(float)startTime {
    if (isCurrentlyProcessingUpgrade || destroyNow) {
        return;
    }
    
    int upgradeCost = 0;
    
    switch (objectID) {
        case kObjectCraftAntID:
            upgradeTotalGoal = kCraftAntUpgradeTime;
            upgradeCost = kCraftAntUpgradeCost;
            break;
        case kObjectCraftMothID:
            upgradeTotalGoal = kCraftMothUpgradeTime;
            upgradeCost = kCraftMothUpgradeCost;
            break;
        case kObjectCraftBeetleID:
            upgradeTotalGoal = kCraftBeetleUpgradeTime;
            upgradeCost = kCraftBeetleUpgradeCost;
            break;
        case kObjectCraftMonarchID:
            upgradeTotalGoal = kCraftMonarchUpgradeTime;
            upgradeCost = kCraftMonarchUpgradeCost;
            break;
        case kObjectCraftCamelID:
            upgradeTotalGoal = kCraftCamelUpgradeTime;
            upgradeCost = kCraftCamelUpgradeCost;
            break;
        case kObjectCraftRatID:
            upgradeTotalGoal = kCraftRatUpgradeTime;
            upgradeCost = kCraftRatUpgradeCost;
            break;
        case kObjectCraftSpiderID:
            upgradeTotalGoal = kCraftSpiderUpgradeTime;
            upgradeCost = kCraftSpiderUpgradeCost;
            break;
        case kObjectCraftEagleID:
            upgradeTotalGoal = kCraftEagleUpgradeTime;
            upgradeCost = kCraftEagleUpgradeCost;
            break;
        default:
            upgradeCost = INT_MAX;
            break;
    }
    
    // Check brogguts
    PlayerProfile* profile = [[GameController sharedGameController] currentProfile];
    if ([profile subtractBrogguts:upgradeCost metal:0] == kProfileNoFail) {
        
        // Create broggut lost text at top of screen
        CGPoint broggutCounterLocation = self.currentScene.broggutCounter.objectLocation;
        NSString* string = [NSString stringWithFormat:@"%i Bgs", -(upgradeCost)];
        TextObject* obj = [[TextObject alloc] initWithFontID:kFontBlairID
                                                        Text:string
                                                withLocation:CGPointMake(broggutCounterLocation.x, broggutCounterLocation.y - 20)
                                                withDuration:1.8f];
        [obj setScrollWithBounds:NO];
        [obj setObjectVelocity:Vector2fMake(0.0f, -0.25f)];
        [obj setFontColor:Color4fMake(1.0f, 0.0f, 0.0f, 1.0f)];
        [obj setRenderLayer:kLayerTopLayer];
        [[self currentScene] addTextObject:obj];
        [obj release];
        
        isCurrentlyProcessingUpgrade = YES;
        currentUpgradeObjectID = objectID;
        currentUpgradeProgress = 0.0f;
    }
}

@end
