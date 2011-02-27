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
		isTouchDraggingButton = NO;
		isTouchTapped = NO;
		scrollTouchTimer = -1;
	}
	return self;
}

- (void)updateSideBar {
	// Update the scroll touch timer
	if (scrollTouchTimer > 0) {
		scrollTouchTimer--;
	} else if (scrollTouchTimer == 0) {
		scrollTouchTimer = -1;
		if (!isTouchMovingScroll) {
			[self touchesTappedAtLocation:firstTouchLocation];
		}
	}
	
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
}

- (void)renderWithOffset:(Vector2f)vector {
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

- (void)buttonReleasedWithID:(int)buttonID atLocation:(CGPoint)location {
	// OVERRIDE
}

- (void)touchesScrolledAtLocation:(CGPoint)location {
	scrollTouchTimer = SCROLL_TIME_INTERVAL;
	firstTouchLocation = location;
}

- (void)touchesTappedAtLocation:(CGPoint)location {
	// OVERRIDE
	if (!isTouchMovingScroll) {
		isTouchTapped = YES;
		for (int i = 0; i < [buttonArray count]; i++) {
			// For each button, check if the location is in the rect
			SideBarButton* button = [buttonArray objectAtIndex:i];
			if (CGRectContainsPoint([button buttonRect], location)) {
				[self buttonPressedWithID:i];
				isTouchDraggingButton = YES;
			}
		}
	}
}

- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation {
	// OVERRIDE
	if (!isTouchTapped)
		currentYOffset += fromLocation.y - toLocation.y;
	
	if (scrollTouchTimer > 0) {
		if (GetDistanceBetweenPoints(fromLocation, toLocation) > SCROLLING_DISTANCE_THRESHOLD) {
			scrollTouchTimer = -1;
			isTouchMovingScroll = YES;
		}
	}
}

- (void)touchesEndedAtLocation:(CGPoint)location {
	// OVERRIDE
	if (!isTouchMovingScroll && isTouchTapped) {
		for (int i = 0; i < [buttonArray count]; i++) {
			// For each button, check if the location is in the rect
			SideBarButton* button = [buttonArray objectAtIndex:i];
			if (CGRectContainsPoint([button buttonRect], location)) {
				[self buttonReleasedWithID:i atLocation:location];
			}
		}
		
	}
	isTouchDraggingButton = NO;
	isTouchMovingScroll = NO;
	isTouchTapped = NO;
}

- (void)touchesDoubleTappedAtLocation:(CGPoint)location {
	// OVERRIDE
}

@end
