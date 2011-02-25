//
//  SideBarObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/15/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "SideBarObject.h"
#import "SideBarButton.h"
#import "BroggutScene.h"
#import "GameController.h"
#import "BroggutScene.h"
#import "SideBarController.h"

@implementation SideBarObject
@synthesize myController;

- (void)dealloc {
	[buttonArray release];
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self) {
		buttonArray = [[NSMutableArray alloc] init];
		currentYOffset = 0.0f;
		totalSideBarHeight = 0.0f;
		isTouchMovingScroll = NO;
	}
	return self;
}

- (void)renderWithOffset:(Vector2f)vector {
	// Update the scroll
	if (!isTouchMovingScroll) {
		if (currentYOffset > 0.0f) {
			currentYOffset /= 1.2;
		}
		float diff = kPadScreenLandscapeHeight - totalSideBarHeight;
		if (currentYOffset < diff) {
			currentYOffset = (diff) + (currentYOffset - diff) / 1.2;
		}
	}
	
	// Render buttons
	enablePrimitiveDraw();
	float currentYPosition = 0.0f;
	for (int i = 0; i < [buttonArray count]; i++) {
		// For each button, update it's center
		SideBarButton* button = [buttonArray objectAtIndex:i];
		currentYPosition += SPACE_BETWEEN_SIDEBAR_BUTTONS + (button.buttonHeight / 2);
		button.buttonCenter = CGPointMake(SIDEBAR_WIDTH / 2, kPadScreenLandscapeHeight - (currentYPosition + currentYOffset));
		currentYPosition += button.buttonHeight / 2;
		totalSideBarHeight = currentYPosition + SPACE_BETWEEN_SIDEBAR_BUTTONS;
		glColor4f(1.0f, 1.0f, 1.0f, 0.8f);
		drawFilledRect([button buttonRect], vector);
	}
	disablePrimitiveDraw();
}

- (void)buttonPressedWithID:(int)buttonID {
	// OVERRIDE
}

- (void)buttonReleasedWithID:(int)buttonID {
	// OVERRIDE
}

- (void)touchesBeganAtLocation:(CGPoint)location {
	// OVERRIDE
	for (int i = 0; i < [buttonArray count]; i++) {
		// For each button, check if the location is in the rect
		SideBarButton* button = [buttonArray objectAtIndex:i];
		if (CGRectContainsPoint([button buttonRect], location)) {
			[self buttonPressedWithID:i];
		}
	}
}

- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation {
	// OVERRIDE
	currentYOffset += fromLocation.y - toLocation.y;
	isTouchMovingScroll = YES;
}

- (void)touchesEndedAtLocation:(CGPoint)location {
	// OVERRIDE
	if (!isTouchMovingScroll) {
		for (int i = 0; i < [buttonArray count]; i++) {
			// For each button, check if the location is in the rect
			SideBarButton* button = [buttonArray objectAtIndex:i];
			if (CGRectContainsPoint([button buttonRect], location)) {
				[self buttonReleasedWithID:i];
			}
		}
	}
	isTouchMovingScroll = NO;
}

- (void)touchesDoubleTappedAtLocation:(CGPoint)location {
	// OVERRIDE
}

@end
