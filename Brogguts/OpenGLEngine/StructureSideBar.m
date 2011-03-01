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

enum StructureButtonIDs {
	kStructureButtonBlockID, // Basic
	kStructureButtonRefineryID,
	kStructureButtonCraftUpgradesID,
	kStructureButtonStructureUpgradesID,
	kStructureButtonTurretID, // Advanced
	kStructureButtonRadarID,
	kStructureButtonFixerID,
};

@implementation StructureSideBar

- (id)init {
	self = [super init];
	if (self) {
		for (int i = 0; i < 8; i++) {
			SideBarButton* button = [[SideBarButton alloc] initWithWidth:(SIDEBAR_WIDTH - 32.0f) withHeight:100 withCenter:CGPointMake(SIDEBAR_WIDTH / 2, 50)];
			[buttonArray addObject:button];
			switch (i) {
				case kStructureButtonBlockID:
					[button setButtonText:@"Block"];
					break;
				case kStructureButtonRefineryID:
					[button setButtonText:@"Refinery"];
					break;
				case kStructureButtonCraftUpgradesID:
					[button setButtonText:@"Craft Upgrades"];
					break;
				case kStructureButtonStructureUpgradesID:
					[button setButtonText:@"Structure Upgrades"];
					break;
				case kStructureButtonTurretID:
					[button setButtonText:@"Turret"];
					break;
				case kStructureButtonRadarID:
					[button setButtonText:@"Radar"];
					break;
				case kStructureButtonFixerID:
					[button setButtonText:@"Fixer"];
					break;
				default:
					break;
			}
			[button release];
		}
	}
	return self;
}

- (void)updateSideBar {
	
	[super updateSideBar];
}

- (void)renderWithOffset:(Vector2f)vector { // vector is the sidebar relative vector, not the current scene's
	[super renderWithOffset:vector];
	if (isTouchDraggingButton) {
		enablePrimitiveDraw();
		Vector2f scroll = [[[GameController sharedGameController] currentScene] scrollVectorFromScreenBounds];
		
		drawDashedLine([[buttonArray objectAtIndex:currentDragButtonID] buttonCenter], currentDragButtonLocation, STRUCTURE_BUTTON_DRAG_SEGMENTS, Vector2fZero);
		disablePrimitiveDraw();
		CGPoint flooredLocation = CGPointMake(currentDragButtonLocation.x + scroll.x,
											  currentDragButtonLocation.y + scroll.y);
		[[[[GameController sharedGameController]
		   currentScene]
		  collisionManager]	
		 drawValidityRectForLocation:flooredLocation forMining:NO];
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
				[scene attemptToCreateStructureWithID:kObjectStructureBlockID atLocation:absoluteLocation isTraveling:YES];
				break;
			case kStructureButtonRefineryID:
				[scene attemptToCreateStructureWithID:kObjectStructureRefineryID atLocation:absoluteLocation isTraveling:YES];
				break;
			case kStructureButtonCraftUpgradesID:
				[scene attemptToCreateStructureWithID:kObjectStructureCraftUpgradesID atLocation:absoluteLocation isTraveling:YES];
				break;
			case kStructureButtonStructureUpgradesID:
				[scene attemptToCreateStructureWithID:kObjectStructureStructureUpgradesID atLocation:absoluteLocation isTraveling:YES];
				break;
			case kStructureButtonTurretID:
				[scene attemptToCreateStructureWithID:kObjectStructureTurretID atLocation:absoluteLocation isTraveling:YES];
				break;
			case kStructureButtonRadarID:
				[scene attemptToCreateStructureWithID:kObjectStructureRadarID atLocation:absoluteLocation isTraveling:YES];
				break;
			case kStructureButtonFixerID:
				[scene attemptToCreateStructureWithID:kObjectStructureFixerID atLocation:absoluteLocation isTraveling:YES];
				break;
			default:
				break;
		}
	}
	
	[super touchesEndedAtLocation:location];
}

@end
