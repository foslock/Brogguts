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
#import "PlayerProfile.h"
#import "GameController.h"
#import "TextObject.h"
#import "ImageRenderSingleton.h"

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
@synthesize isCurrentlyProcessingUpgrade, currentUpgradeProgress, currentUpgradeObjectID;

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectStructureStructureUpgradesID withLocation:location isTraveling:traveling];
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
            [[[GameController sharedGameController] currentProfile] completeUpgradeWithID:currentUpgradeObjectID];
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
            StructureUpgradesSideBar* sideBar = [[StructureUpgradesSideBar alloc] initWithStructure:self];
            [sideBar setMyController:[[self currentScene] sideBar]];
            [[[self currentScene] sideBar] pushSideBarObject:sideBar];
            [[[self currentScene] sideBar] moveSideBarIn];
            [sideBar release];
        }
    }
    isBeingPressed = NO;
}

- (void)presentStructureUpgradeDialogueWithObjectID:(int)objectID {
    UpgradeDialogueObject* dialogue = [[UpgradeDialogueObject alloc] initWithUpgradeID:objectID];
    [dialogue setUpgradesStructure:self];
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

- (void)renderOverObjectWithScroll:(Vector2f)scroll {
    [super renderOverObjectWithScroll:scroll];
    if (isCurrentlyProcessingUpgrade) {
        enablePrimitiveDraw();
        Circle progressCircle;
        progressCircle.x = objectLocation.x;
        progressCircle.y = objectLocation.y;
        progressCircle.radius = [self boundingCircle].radius + 8.0f;
        int totalSegments = upgradeTotalGoal * 2;
        int filledSegments = currentUpgradeProgress * 2;
        glLineWidth(2.0f);
        drawPartialDashedCircle(progressCircle, filledSegments, totalSegments, Color4fOnes, Color4fBlack, scroll);
        disablePrimitiveDraw();
    }
}

- (void)objectWasDestroyed {
    if (isCurrentlyProcessingUpgrade) {
        PlayerProfile* profile = [[GameController sharedGameController] currentProfile];
        [profile unPurchaseUpgradeWithID:currentUpgradeObjectID];
    }
    isCurrentlyProcessingUpgrade = NO;
    currentUpgradeObjectID = -1;
    currentUpgradeProgress = 0.0f;
    upgradeTotalGoal = 0.0f;
    [super objectWasDestroyed];
}

- (void)purchaseUpgradeForStructure:(int)objectID withStartTime:(float)startTime {
    if (isCurrentlyProcessingUpgrade || destroyNow) {
        return;
    }
    
    int upgradeCost = 0;
    
    switch (objectID) {
        case kObjectStructureBaseStationID:
            upgradeCost = kStructureBaseStationUpgradeCost;
            break;
        case kObjectStructureBlockID:
            upgradeCost = kStructureBlockUpgradeCost;
            break;
        case kObjectStructureRefineryID:
            upgradeCost = kStructureRefineryUpgradeCost;
            break;
        case kObjectStructureCraftUpgradesID:
            upgradeCost = kStructureCraftUpgradesUpgradeCost;
            break;
        case kObjectStructureStructureUpgradesID:
            upgradeCost = kStructureStructureUpgradesUpgradeCost;
            break;
        case kObjectStructureTurretID:
            upgradeCost = kStructureTurretUpgradeCost;
            break;
        case kObjectStructureFixerID:
            upgradeCost = kStructureFixerUpgradeCost;
            break;
        case kObjectStructureRadarID:
            upgradeCost = kStructureRadarUpgradeCost;
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
        
        [self startUpgradeForStructure:objectID withStartTime:startTime];
    }
    
}

- (void)startUpgradeForStructure:(int)objectID withStartTime:(float)startTime {
    if (isCurrentlyProcessingUpgrade || destroyNow) {
        return;
    }
    
    switch (objectID) {
        case kObjectStructureBaseStationID:
            upgradeTotalGoal = kStructureBaseStationUpgradeTime;
            break;
        case kObjectStructureBlockID:
            upgradeTotalGoal = kStructureBlockUpgradeTime;
            break;
        case kObjectStructureRefineryID:
            upgradeTotalGoal = kStructureRefineryUpgradeTime;
            break;
        case kObjectStructureCraftUpgradesID:
            upgradeTotalGoal = kStructureCraftUpgradesUpgradeTime;
            break;
        case kObjectStructureStructureUpgradesID:
            upgradeTotalGoal = kStructureStructureUpgradesUpgradeTime;
            break;
        case kObjectStructureTurretID:
            upgradeTotalGoal = kStructureTurretUpgradeTime;
            break;
        case kObjectStructureFixerID:
            upgradeTotalGoal = kStructureFixerUpgradeTime;
            break;
        case kObjectStructureRadarID:
            upgradeTotalGoal = kStructureRadarUpgradeTime;
            break;
        default:
            upgradeTotalGoal = 0;
            break;
    }
    
    // Check brogguts
    PlayerProfile* profile = [[GameController sharedGameController] currentProfile];    
    [profile purchaseUpgradeWithID:objectID];
    isCurrentlyProcessingUpgrade = YES;
    currentUpgradeObjectID = objectID;
    currentUpgradeProgress = startTime;
}

@end
