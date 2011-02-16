//
//  SideBarObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/12/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "SideBarController.h"
#import "SideBarObject.h"

@implementation SideBarController

@synthesize isSideBarShowing;

- (id)initWithLocation:(CGPoint)location withWidth:(float)width withHeight:(float)height {
	self = [super init];
	if (self) {
		isSideBarShowing = NO;
		isSideBarMovingIn = NO;
		isSideBarMovingOut = NO;
		sideBarLocation = location;
		originalLocation = location;
		sideBarWidth = width;
		sideBarHeight = height;
		sideBarStack = [[NSMutableArray alloc] init];
		SideBarObject* topTemp = [[SideBarObject alloc] init];
		[self pushSideBarObject:topTemp];
		[topTemp release];
	}
	return self;
}

- (BOOL)isSideBarShowing {
	if (isSideBarShowing && !isSideBarMovingIn && !isSideBarMovingOut) {
		return YES;
	}
	return NO;
}

- (CGRect)sideBarRect {
	return CGRectMake(sideBarLocation.x, sideBarLocation.y, sideBarWidth, sideBarHeight);
}

- (CGRect)buttonRect {
	return CGRectMake(sideBarLocation.x + sideBarWidth,
					  sideBarLocation.y + sideBarHeight - SIDEBAR_BUTTON_HEIGHT,
					  SIDEBAR_BUTTON_WIDTH,
					  SIDEBAR_BUTTON_HEIGHT); // Width and height of the button are hardcoded
}

- (void)moveSideBarIn {
	if (!isSideBarShowing) {
		if (!isSideBarMovingOut) {
			isSideBarShowing = YES;
			isSideBarMovingIn = YES;
			isSideBarMovingOut = NO;
		}
	}
}

- (void)moveSideBarOut {
	if (isSideBarShowing) {
		if (!isSideBarMovingIn) {
			isSideBarShowing = YES;
			isSideBarMovingIn = NO;
			isSideBarMovingOut = YES;
		}
	}
}

- (void)updateSideBar {
	if (isSideBarShowing) {
		if (isSideBarMovingIn) {
			sideBarLocation = CGPointMake(sideBarLocation.x + SIDEBAR_MOVE_SPEED, sideBarLocation.y);
			if (sideBarLocation.x >= originalLocation.x + sideBarWidth) {
				isSideBarMovingIn = NO;
				sideBarLocation = CGPointMake(originalLocation.x + sideBarWidth, sideBarLocation.y);
			}
		}
		if (isSideBarMovingOut) {
			sideBarLocation = CGPointMake(sideBarLocation.x - SIDEBAR_MOVE_SPEED, sideBarLocation.y);
			if (sideBarLocation.x <= originalLocation.x) {
				isSideBarMovingOut = NO;
				isSideBarShowing = NO;
				sideBarLocation = CGPointMake(originalLocation.x, sideBarLocation.y);
			}
		}
		
		if (!isSideBarMovingIn && !isSideBarMovingOut) {
			// update the current object on the top of the stack
			SideBarObject* topObject = [sideBarStack objectAtIndex:([sideBarStack count] - 1)];
			if (topObject) {
				if (isMovingObjectIn) {
					isMovingObjectOut = NO;
					sideBarObjectLocation = CGPointMake(sideBarObjectLocation.x - SIDEBAR_MOVE_SPEED, sideBarObjectLocation.y);
					if (sideBarObjectLocation.x <= sideBarLocation.x) {
						sideBarObjectLocation = sideBarLocation;
						isMovingObjectIn = NO;
					}
				}
				if (isMovingObjectOut) {
					isMovingObjectIn = NO;
					sideBarObjectLocation = CGPointMake(sideBarObjectLocation.x + SIDEBAR_MOVE_SPEED, sideBarObjectLocation.y);
					if (sideBarObjectLocation.x >= sideBarLocation.x + sideBarWidth) {
						sideBarObjectLocation = CGPointMake(sideBarLocation.x + sideBarWidth, sideBarLocation.y);
						isMovingObjectOut = NO;
					}
				}
			}
		}
	}
}

- (void)renderSideBar {
	CGRect renderRect = [self sideBarRect];
	CGRect buttonRect = [self buttonRect];
	
	if (isSideBarShowing) {
		glColor4f(0.0f, 0.0f, 1.0f, 0.8f);
		enablePrimitiveDraw();
		drawRect(renderRect, Vector2fZero);
		disablePrimitiveDraw();
	}
	
	glColor4f(0.0f, 1.0f, 0.0f, 0.8f);
	enablePrimitiveDraw();
	drawRect(buttonRect, Vector2fZero);
	disablePrimitiveDraw();
	
	SideBarObject* topObject = [sideBarStack objectAtIndex:([sideBarStack count] - 1)];
	[topObject renderWithOffset:Vector2fMake(sideBarObjectLocation.x, sideBarObjectLocation.y)];
}

- (void)pushSideBarObject:(SideBarObject*)sideBar {
	[sideBarStack addObject:sideBar];
	isMovingObjectIn = YES;
	isMovingObjectOut = NO;
	sideBarObjectLocation = CGPointMake(sideBarLocation.x + sideBarWidth, sideBarLocation.y);
}

- (void)popSideBarObject {
	isMovingObjectIn = NO;
	isMovingObjectOut = YES;
}

- (void)touchesBeganAtLocation:(CGPoint)location {
	// OVERRIDE
	// NSLog(@"Touches began in sidebar");
}

- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation {
	// OVERRIDE
	// NSLog(@"Touches moved in sidebar");
}

- (void)touchesEndedAtLocation:(CGPoint)location {
	// OVERRIDE
	// NSLog(@"Touches ended in sidebar");
}

- (void)touchesDoubleTappedAtLocation:(CGPoint)location {
	// OVERRIDE
	// NSLog(@"Touches double tapped in sidebar");
}

@end
