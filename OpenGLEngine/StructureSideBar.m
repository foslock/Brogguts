//
//  StructureSideBar.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/27/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "StructureSideBar.h"
#import "SideBarButton.h"
#import "BroggutScene.h"
#import "SideBarController.h"
#import "CraftSideBar.h"
#import "GameController.h"
#import "CollisionManager.h"
#import "PlayerProfile.h"

enum StructureButtonIDs {
	kStructureButtonBlockID,
	kStructureButtonRefineryID,
	kStructureButtonCraftUpgradesID,
	kStructureButtonStructureUpgradesID,
	kStructureButtonTurretID,
	kStructureButtonRadarID,
	kStructureButtonFixerID,
};

NSString* const kStructureButtonText[7] = {
    @"Block",
    @"Refinery",
    @"Craft\nUpgrades",
    @"Structure\nUpgrades",
    @"Turret",
    @"Radar",
    @"Fixer",
};

NSString* const kStructureButtonLockedText = @"LOCKED";

@implementation StructureSideBar

- (id)init {
	self = [super init];
	if (self) {
        PlayerProfile* profile = [[GameController sharedGameController] currentProfile];
		for (int i = 0; i < 7; i++) {
			SideBarButton* button = [[SideBarButton alloc] initWithWidth:(SIDEBAR_WIDTH - 32.0f) withHeight:100 withCenter:CGPointMake(SIDEBAR_WIDTH / 2, 50)];
			[buttonArray addObject:button];
			BOOL isUnlocked = NO;
            switch (i) {
                case kStructureButtonBlockID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectStructureBlockID];
                    break;
                case kStructureButtonRefineryID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectStructureRefineryID];
                    break;
                case kStructureButtonCraftUpgradesID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectStructureCraftUpgradesID];
                    break;
                case kStructureButtonStructureUpgradesID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectStructureStructureUpgradesID];
                    break;
                case kStructureButtonTurretID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectStructureTurretID];
                    break;
                case kStructureButtonRadarID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectStructureRadarID];
                    break;
                case kStructureButtonFixerID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectStructureFixerID];
                    break;
                default:
                    break;
            }
            if (isUnlocked) {
                [button setIsDisabled:NO];
                [button setButtonText:kStructureButtonText[i]];
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
    BroggutScene* scene = [[GameController sharedGameController] currentScene];
    for (int i = 0; i < 7; i++) {
        SideBarButton* button = [buttonArray objectAtIndex:i];
        if ([scene isBuildingStructure]) {
            [button setIsDisabled:YES];
        } else {
            PlayerProfile* profile = [[GameController sharedGameController] currentProfile];
            BOOL isUnlocked = NO;
            switch (i) {
                case kStructureButtonBlockID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectStructureBlockID];
                    break;
                case kStructureButtonRefineryID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectStructureRefineryID];
                    break;
                case kStructureButtonCraftUpgradesID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectStructureCraftUpgradesID];
                    break;
                case kStructureButtonStructureUpgradesID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectStructureStructureUpgradesID];
                    break;
                case kStructureButtonTurretID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectStructureTurretID];
                    break;
                case kStructureButtonRadarID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectStructureRadarID];
                    break;
                case kStructureButtonFixerID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectStructureFixerID];
                    break;
                default:
                    break;
            }
            if (isUnlocked) {
                [button setIsDisabled:NO];
            } else {
                [button setIsDisabled:YES];
            }
        }
    }
    
    if (isTouchDraggingButton && 
        !CGRectContainsPoint([myController sideBarRect], currentDragButtonLocation)) {
        Vector2f scroll = [[[GameController sharedGameController] currentScene] scrollVectorFromScreenBounds];
        CGPoint absoluteLocation = CGPointMake(currentDragButtonLocation.x + scroll.x, currentDragButtonLocation.y + scroll.y);
        [scene setCurrentBuildDragLocation:absoluteLocation];
        switch (currentDragButtonID) {
            case kStructureButtonBlockID:
                [scene setCurrentBuildBroggutCost:kStructureBlockCostBrogguts];
                [scene setCurrentBuildMetalCost:kStructureBlockCostMetal];
                break;
            case kStructureButtonRefineryID:
                [scene setCurrentBuildBroggutCost:kStructureRefineryCostBrogguts];
                [scene setCurrentBuildMetalCost:kStructureRefineryCostMetal];
                break;
            case kStructureButtonCraftUpgradesID:
                [scene setCurrentBuildBroggutCost:kStructureCraftUpgradesCostBrogguts];
                [scene setCurrentBuildMetalCost:kStructureCraftUpgradesCostMetal];
                break;
            case kStructureButtonStructureUpgradesID:
                [scene setCurrentBuildBroggutCost:kStructureStructureUpgradesCostBrogguts];
                [scene setCurrentBuildMetalCost:kStructureStructureUpgradesCostMetal];
                break;
            case kStructureButtonTurretID:
                [scene setCurrentBuildBroggutCost:kStructureTurretCostBrogguts];
                [scene setCurrentBuildMetalCost:kStructureTurretCostMetal];
                break;
            case kStructureButtonRadarID:
                [scene setCurrentBuildBroggutCost:kStructureRadarCostBrogguts];
                [scene setCurrentBuildMetalCost:kStructureRadarCostMetal];
                break;
            case kStructureButtonFixerID:
                [scene setCurrentBuildBroggutCost:kStructureFixerCostBrogguts];
                [scene setCurrentBuildMetalCost:kStructureFixerCostMetal];
                break;
            default:
                break;
        }
        [scene setIsShowingBuildingValues:YES];
    } else {
        [scene setIsShowingBuildingValues:NO];
    }
}

- (void)renderWithOffset:(Vector2f)vector { // vector is the sidebar relative vector, not the current scene's
    [super renderWithOffset:vector];
    if (isTouchDraggingButton) {
        enablePrimitiveDraw();
        Vector2f scroll = [[[GameController sharedGameController] currentScene] scrollVectorFromScreenBounds];
        glColor4f(1.0f, 1.0f, 1.0f, 0.5f);
        drawOffsetDashedLine([[buttonArray objectAtIndex:currentDragButtonID] buttonCenter], currentDragButtonLocation, 0, 16.0f, vector);
        disablePrimitiveDraw();
        CGPoint flooredLocation = CGPointMake(currentDragButtonLocation.x + scroll.x,
                                              currentDragButtonLocation.y + scroll.y);
        if (!CGRectContainsPoint([myController sideBarRect], currentDragButtonLocation)) {
            [[[[GameController sharedGameController]
               currentScene]
              collisionManager]	
             drawValidityRectForLocation:flooredLocation forMining:NO];
        }
    }
}

- (void)buttonPressedWithID:(int)buttonID {
    [super buttonPressedWithID:buttonID];
    currentDragButtonID = buttonID;
}

- (void)touchesBeganAtLocation:(CGPoint)location {
    [super touchesBeganAtLocation:location];
    if (isTouchDraggingButton) {
        currentDragButtonLocation = location;
    }
}

- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation {
    if (isTouchDraggingButton) {
        currentDragButtonLocation = toLocation;
    }
    [super touchesMovedToLocation:toLocation from:fromLocation];
}

- (void)touchesEndedAtLocation:(CGPoint)location {
    if (isTouchDraggingButton && 
        !CGRectContainsPoint([myController sideBarRect], currentDragButtonLocation)) {
        NSLog(@"Dragging button ended at <%.1f, %.1f> with ID (%i)", location.x, location.y, currentDragButtonID);
        Vector2f scroll = [[[GameController sharedGameController] currentScene] scrollVectorFromScreenBounds];
        float xRounded = COLLISION_CELL_WIDTH * floorf((location.x + scroll.x) / COLLISION_CELL_WIDTH) + COLLISION_CELL_WIDTH / 2;
        float yRounded = COLLISION_CELL_HEIGHT * floorf((location.y + scroll.y) / COLLISION_CELL_HEIGHT) + COLLISION_CELL_HEIGHT / 2;
        CGPoint absoluteLocation = CGPointMake(xRounded, yRounded);
        BroggutScene* scene = [[GameController sharedGameController] currentScene];
        switch (currentDragButtonID) {
            case kStructureButtonBlockID:
                [scene attemptToCreateStructureWithID:kObjectStructureBlockID atLocation:absoluteLocation isTraveling:YES withAlliance:kAllianceFriendly];
                break;
            case kStructureButtonRefineryID:
                [scene attemptToCreateStructureWithID:kObjectStructureRefineryID atLocation:absoluteLocation isTraveling:YES withAlliance:kAllianceFriendly];
                break;
            case kStructureButtonCraftUpgradesID:
                [scene attemptToCreateStructureWithID:kObjectStructureCraftUpgradesID atLocation:absoluteLocation isTraveling:YES withAlliance:kAllianceFriendly];
                break;
            case kStructureButtonStructureUpgradesID:
                [scene attemptToCreateStructureWithID:kObjectStructureStructureUpgradesID atLocation:absoluteLocation isTraveling:YES withAlliance:kAllianceFriendly];
                break;
            case kStructureButtonTurretID:
                [scene attemptToCreateStructureWithID:kObjectStructureTurretID atLocation:absoluteLocation isTraveling:YES withAlliance:kAllianceFriendly];
                break;
            case kStructureButtonRadarID:
                [scene attemptToCreateStructureWithID:kObjectStructureRadarID atLocation:absoluteLocation isTraveling:YES withAlliance:kAllianceFriendly];
                break;
            case kStructureButtonFixerID:
                [scene attemptToCreateStructureWithID:kObjectStructureFixerID atLocation:absoluteLocation isTraveling:YES withAlliance:kAllianceFriendly];
                break;
            default:
                break;
        }
    }
    
    [super touchesEndedAtLocation:location];
}

@end
