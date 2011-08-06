//
//  CraftSideBar.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/27/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CraftSideBar.h"
#import "SideBarButton.h"
#import "BroggutScene.h"
#import "SideBarController.h"
#import "CraftSideBar.h"
#import "GameController.h"
#import "PlayerProfile.h"

NSString* const kCraftButtonText[8] = {
    @"Ant",
    @"Moth",
    @"Beetle",
    @"Monarch",
    @"Camel",
    @"Rat",
    @"Spider",
    @"Eagle",
};

NSString* const kCraftButtonLockedText = @"LOCKED";

@implementation CraftSideBar

- (id)init {
	self = [super init];
	if (self) {
        PlayerProfile* profile = [[GameController sharedGameController] currentProfile];
		for (int i = 0; i < 8; i++) {
			SideBarButton* button = [[SideBarButton alloc] initWithWidth:(SIDEBAR_WIDTH - 32.0f) withHeight:100 withCenter:CGPointMake(SIDEBAR_WIDTH / 2, 50)];
			[buttonArray addObject:button];
            BOOL isUnlocked = NO;
            switch (i) {
                case kCraftButtonAntID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectCraftAntID];
                    break;
                case kCraftButtonMothID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectCraftMothID];
                    break;
                case kCraftButtonBeetleID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectCraftBeetleID];
                    break;
                case kCraftButtonMonarchID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectCraftMonarchID];
                    break;
                case kCraftButtonCamelID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectCraftCamelID];
                    break;
                case kCraftButtonRatID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectCraftRatID];
                    break;
                case kCraftButtonSpiderID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectCraftSpiderID];
                    break;
                case kCraftButtonEagleID:
                    isUnlocked = [profile isObjectUnlockedWithID:kObjectCraftEagleID];
                    break;
                default:
                    break;
            }
            if (isUnlocked) {
                [button setIsDisabled:NO];
                [button setButtonText:kCraftButtonText[i]];
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
    BroggutScene* scene = [[GameController sharedGameController] currentScene];
    if (isTouchDraggingButton && 
		!CGRectContainsPoint([myController sideBarRect], currentDragButtonLocation)) {
		Vector2f scroll = [[[GameController sharedGameController] currentScene] scrollVectorFromScreenBounds];
		CGPoint absoluteLocation = CGPointMake(currentDragButtonLocation.x + scroll.x, currentDragButtonLocation.y + scroll.y);
        [scene setCurrentBuildDragLocation:absoluteLocation];
		switch (currentDragButtonID) {
			case kCraftButtonAntID:
				[scene setCurrentBuildBroggutCost:kCraftAntCostBrogguts];
                [scene setCurrentBuildMetalCost:kCraftAntCostMetal];
				break;
			case kCraftButtonMothID:
				[scene setCurrentBuildBroggutCost:kCraftMothCostBrogguts];
                [scene setCurrentBuildMetalCost:kCraftMothCostMetal];
				break;
			case kCraftButtonBeetleID:
                [scene setCurrentBuildBroggutCost:kCraftBeetleCostBrogguts];
                [scene setCurrentBuildMetalCost:kCraftBeetleCostMetal];
				break;
			case kCraftButtonMonarchID:
                [scene setCurrentBuildBroggutCost:kCraftMonarchCostBrogguts];
                [scene setCurrentBuildMetalCost:kCraftMonarchCostMetal];
				break;
			case kCraftButtonCamelID:
                [scene setCurrentBuildBroggutCost:kCraftCamelCostBrogguts];
                [scene setCurrentBuildMetalCost:kCraftCamelCostMetal];
				break;
			case kCraftButtonRatID:
                [scene setCurrentBuildBroggutCost:kCraftRatCostBrogguts];
                [scene setCurrentBuildMetalCost:kCraftRatCostMetal];
				break;
			case kCraftButtonSpiderID:
                [scene setCurrentBuildBroggutCost:kCraftSpiderCostBrogguts];
                [scene setCurrentBuildMetalCost:kCraftSpiderCostMetal];
				break;
			case kCraftButtonEagleID:
                [scene setCurrentBuildBroggutCost:kCraftEagleCostBrogguts];
                [scene setCurrentBuildMetalCost:kCraftEagleCostMetal];
				break;
			default:
				break;
		}
        [scene setIsShowingBuildingValues:YES];
	} else {
        [scene setIsShowingBuildingValues:NO];
    }
}

- (void)renderWithOffset:(Vector2f)vector {
	[super renderWithOffset:vector];
	if (isTouchDraggingButton) {
		enablePrimitiveDraw();
        glColor4f(1.0f, 1.0f, 1.0f, 0.5f);
		drawDashedLine([[buttonArray objectAtIndex:currentDragButtonID] buttonCenter], currentDragButtonLocation, CRAFT_BUTTON_DRAG_SEGMENTS, vector);
		disablePrimitiveDraw();
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
		CGPoint absoluteLocation = CGPointMake(location.x + scroll.x, location.y + scroll.y);
		BroggutScene* scene = [[GameController sharedGameController] currentScene];
		switch (currentDragButtonID) {
			case kCraftButtonAntID:
				[scene attemptToCreateCraftWithID:kObjectCraftAntID atLocation:absoluteLocation isTraveling:YES withAlliance:kAllianceFriendly];
				break;
			case kCraftButtonMothID:
				[scene attemptToCreateCraftWithID:kObjectCraftMothID atLocation:absoluteLocation isTraveling:YES withAlliance:kAllianceFriendly];
				break;
			case kCraftButtonBeetleID:
				[scene attemptToCreateCraftWithID:kObjectCraftBeetleID atLocation:absoluteLocation isTraveling:YES withAlliance:kAllianceFriendly];
				break;
			case kCraftButtonMonarchID:
				[scene attemptToCreateCraftWithID:kObjectCraftMonarchID atLocation:absoluteLocation isTraveling:YES withAlliance:kAllianceFriendly];
				break;
			case kCraftButtonCamelID:
				[scene attemptToCreateCraftWithID:kObjectCraftCamelID atLocation:absoluteLocation isTraveling:YES withAlliance:kAllianceFriendly];
				break;
			case kCraftButtonRatID:
				[scene attemptToCreateCraftWithID:kObjectCraftRatID atLocation:absoluteLocation isTraveling:YES withAlliance:kAllianceFriendly];
				break;
			case kCraftButtonSpiderID:
				[scene attemptToCreateCraftWithID:kObjectCraftSpiderID atLocation:absoluteLocation isTraveling:YES withAlliance:kAllianceFriendly];
				break;
			case kCraftButtonEagleID:
				[scene attemptToCreateCraftWithID:kObjectCraftEagleID atLocation:absoluteLocation isTraveling:YES withAlliance:kAllianceFriendly];
				break;
			default:
				break;
		}
	}
	[super touchesEndedAtLocation:location];
}

@end
