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

enum CraftButtonIDs {
	kCraftButtonAntID, // Basic
	kCraftButtonMothID,
	kCraftButtonBeetleID,
	kCraftButtonMonarchID,
	kCraftButtonCamelID, // Advanced
	kCraftButtonRatID,
	kCraftButtonSpiderID,
	kCraftButtonEagleID,
};

@implementation CraftSideBar

- (id)init {
	self = [super init];
	if (self) {
		for (int i = 0; i < 8; i++) {
			SideBarButton* button = [[SideBarButton alloc] initWithWidth:(SIDEBAR_WIDTH - 32.0f) withHeight:100 withCenter:CGPointMake(SIDEBAR_WIDTH / 2, 50)];
			[buttonArray addObject:button];
			switch (i) {
				case kCraftButtonAntID:
					[button setButtonText:@"The Ant"];
					break;
				case kCraftButtonMothID:
					[button setButtonText:@"The Moth"];
					break;
				case kCraftButtonBeetleID:
					[button setButtonText:@"The Beetle"];
					break;
				case kCraftButtonMonarchID:
					[button setButtonText:@"The Monarch"];
					break;
				case kCraftButtonCamelID:
					[button setButtonText:@"The Camel"];
					break;
				case kCraftButtonRatID:
					[button setButtonText:@"The Rat"];
					break;
				case kCraftButtonSpiderID:
					[button setButtonText:@"The Spider"];
					break;
				case kCraftButtonEagleID:
					[button setButtonText:@"The Eagle"];
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

- (void)renderWithOffset:(Vector2f)vector {
	[super renderWithOffset:vector];
	if (isTouchDraggingButton) {
		enablePrimitiveDraw();
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
