//
//  SideBarObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/15/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SideBarController;
@class SideBarButton;

#define SPACE_BETWEEN_SIDEBAR_BUTTONS 16.0f
#define SCROLL_TIME_INTERVAL 8				// Frames between when a touch should be considered a tap/scroll
#define SCROLLING_DISTANCE_THRESHOLD 8.0f	// The minimum distance needed to trigger the ONLY scroll touch
#define SIDE_BAR_BOTTOM_VALUE 64.0f

@interface SideBarObject : NSObject {
	SideBarController* myController;
	NSMutableArray* buttonArray;
    int currentPressedButtonID;
	float currentYOffset;
    float scrollVertVelocity;
	float totalSideBarHeight;
	
	BOOL isTouchMovingScroll;
	BOOL isTouchDraggingButton;
	int scrollTouchTimer;
	CGPoint firstTouchLocation;
}

@property (assign) SideBarController* myController;
@property (readonly) int scrollTouchTimer;

- (void)renderWithOffset:(Vector2f)vector;
- (void)updateSideBar;
- (void)buttonPressedWithID:(int)buttonID;
- (void)buttonReleasedWithID:(int)buttonID atLocation:(CGPoint)location;
- (void)buttonCancelledWithId:(int)buttonID;

// Called immediately when the touch lands
- (void)touchesBeganAtLocation:(CGPoint)location;

// Called if the tap is touched and RELEASED within the threshold
- (void)touchesTappedAtLocation:(CGPoint)location;

- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation;
- (void)touchesEndedAtLocation:(CGPoint)location;
- (void)touchesDoubleTappedAtLocation:(CGPoint)location;

@end
