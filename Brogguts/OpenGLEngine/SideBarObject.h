//
//  SideBarObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/15/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SideBarController;

#define SPACE_BETWEEN_SIDEBAR_BUTTONS 32.0f
#define SCROLL_TIME_INTERVAL 8				// Frames between when a touch should be considered a tap/scroll
#define SCROLLING_DISTANCE_THRESHOLD 6.0f	// The minimum distance needed to trigger the ONLY scroll touch

@interface SideBarObject : NSObject {
	SideBarController* myController;
	NSMutableArray* buttonArray;
	float currentYOffset;
	float totalSideBarHeight;
	
	BOOL isTouchMovingScroll;
	BOOL isTouchDraggingButton;
	BOOL isTouchTapped;
	int scrollTouchTimer;
	CGPoint firstTouchLocation;
}

@property (assign) SideBarController* myController;

- (void)renderWithOffset:(Vector2f)vector;
- (void)updateSideBar;
- (void)buttonPressedWithID:(int)buttonID;
- (void)buttonReleasedWithID:(int)buttonID atLocation:(CGPoint)location;

// Called first, to see if the touch is a scrolling touch only
- (void)touchesScrolledAtLocation:(CGPoint)location;

// Called after a brief moment if the touch hasn't moved yet
- (void)touchesTappedAtLocation:(CGPoint)location;

- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation;
- (void)touchesEndedAtLocation:(CGPoint)location;
- (void)touchesDoubleTappedAtLocation:(CGPoint)location;

@end
