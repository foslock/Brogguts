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
#import "BitmapFont.h"
#import "ImageRenderSingleton.h"
#import "TiledButtonObject.h"

@implementation SideBarObject
@synthesize myController, scrollTouchTimer;

- (void)dealloc {
	[buttonArray release];
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self) {
		buttonArray = [[NSMutableArray alloc] init];
		currentYOffset = 0.0f;
		totalSideBarHeight = kPadScreenLandscapeHeight - SIDE_BAR_BOTTOM_VALUE;
		isTouchMovingScroll = NO;
		isTouchDraggingButton = NO;
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
	}
	
	// Update the scroll
	if (!isTouchMovingScroll) {
		if (currentYOffset > SIDE_BAR_BOTTOM_VALUE) {
			currentYOffset /= 1.2;
            if (currentYOffset < SIDE_BAR_BOTTOM_VALUE) {
                currentYOffset = SIDE_BAR_BOTTOM_VALUE;
            }
		}
		float diff = (kPadScreenLandscapeHeight) - totalSideBarHeight;
		if (currentYOffset < diff) {
			currentYOffset = (diff) + (currentYOffset - diff) / 1.2;
		}
	}
}

- (void)renderWithOffset:(Vector2f)vector {
	// Render buttons
	float currentYPosition = 0.0f;
    for (int i = 0; i < [buttonArray count]; i++) {
        // For each button, update it's center
        SideBarButton* button = [buttonArray objectAtIndex:i];
        currentYPosition += SPACE_BETWEEN_SIDEBAR_BUTTONS + (button.buttonHeight / 2);
        button.buttonCenter = CGPointMake(button.buttonCenter.x, kPadScreenLandscapeHeight - (currentYPosition + currentYOffset));
        currentYPosition += button.buttonHeight / 2;
        totalSideBarHeight = currentYPosition + SPACE_BETWEEN_SIDEBAR_BUTTONS;
        [button renderButtonWithScroll:vector];
        
        CGRect scrolledFrame = CGRectOffset([button buttonRect], -vector.x, -vector.y);
        // Draw button text
        [[myController sideBarFont] setFontColor:[button textColor]];
        [[myController sideBarFont] renderStringJustifiedInFrame:scrolledFrame justification:BitmapFontJustification_MiddleCentered text:[button buttonText] onLayer:kLayerHUDMiddleLayer];
    }
}

- (void)buttonPressedWithID:(int)buttonID {
	// OVERRIDE
	SideBarButton* button = [buttonArray objectAtIndex:buttonID];
	[button setIsPressed:YES];
}

- (void)buttonReleasedWithID:(int)buttonID atLocation:(CGPoint)location {
	// OVERRIDE
	SideBarButton* button = [buttonArray objectAtIndex:buttonID];
	[button setIsPressed:NO];
}

- (void)buttonCancelledWithId:(int)buttonID {
	// OVERRIDE
	SideBarButton* button = [buttonArray objectAtIndex:buttonID];
	[button setIsPressed:NO];
}

- (void)touchesBeganAtLocation:(CGPoint)location {
	// NSLog(@"Began");
	scrollTouchTimer = SCROLL_TIME_INTERVAL;
	firstTouchLocation = location;
	// Press button by default if the touch is on one
	for (int i = 0; i < [buttonArray count]; i++) {
		// For each button, check if the location is in the rect
		SideBarButton* button = [buttonArray objectAtIndex:i];
		if (CGRectContainsPoint([button buttonRect], location) && ![button isDisabled]) {
			[self buttonPressedWithID:i];
			isTouchDraggingButton = YES;
		}
	}
}

- (void)touchesTappedAtLocation:(CGPoint)location { // Called when the touch has began and ended within the threshold timing without moving significantly
	// OVERRIDE
	// NSLog(@"Tapped");
	for (int i = 0; i < [buttonArray count]; i++) {
		// For each button, check if the location is in the rect
		SideBarButton* button = [buttonArray objectAtIndex:i];
		if (CGRectContainsPoint([button buttonRect], location) && ![button isDisabled]) {
			[self buttonPressedWithID:i];
			[self buttonReleasedWithID:i atLocation:location];
		}
	}
	isTouchDraggingButton = NO;
	isTouchMovingScroll = NO;
}

- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation {
	// OVERRIDE
	// NSLog(@"Moved");
	if (scrollTouchTimer > 0) {
		if (fabs(fromLocation.y - toLocation.y) > SCROLLING_DISTANCE_THRESHOLD) {
			scrollTouchTimer = -1;
			isTouchMovingScroll = YES;
			if (isTouchDraggingButton) { // Cancel any touches that may be touching a button
				isTouchDraggingButton = NO;
				for (int i = 0; i < [buttonArray count]; i++) {
					// For each button, check if the location is in the rect
					SideBarButton* button = [buttonArray objectAtIndex:i];
					if (CGRectContainsPoint([button buttonRect], fromLocation) && ![button isDisabled]) {
						[self buttonCancelledWithId:i];
					}
				}
			}
		}
	}
	if (isTouchMovingScroll) {
		currentYOffset += fromLocation.y - toLocation.y;
	}
}

- (void)touchesEndedAtLocation:(CGPoint)location {
	// OVERRIDE
	// NSLog(@"Ended");
	if (!isTouchMovingScroll) {
		for (int i = 0; i < [buttonArray count]; i++) {
			// For each button, check if the location is in the rect
			SideBarButton* button = [buttonArray objectAtIndex:i];
			if (CGRectContainsPoint([button buttonRect], location) && ![button isDisabled]) {
				[self buttonReleasedWithID:i atLocation:location];
			}
			[button setIsPressed:NO];
		}
	}
	isTouchDraggingButton = NO;
	isTouchMovingScroll = NO;
}

- (void)touchesDoubleTappedAtLocation:(CGPoint)location {
	// OVERRIDE
}

@end
