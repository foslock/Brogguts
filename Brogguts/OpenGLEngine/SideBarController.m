//
//  SideBarObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/12/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "SideBarController.h"
#import "SideBarObject.h"
#import "MainMenuSideBar.h"

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
		sideBarObjectLocation = location;
		MainMenuSideBar* topTemp = [[MainMenuSideBar alloc] init];
		[topTemp setMyController:self];
		[sideBarStack addObject:topTemp];
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
		
		if (!isMovingObjectIn && !isMovingObjectOut) {
			sideBarObjectLocation = sideBarLocation;
		}
			
		
		if (!isSideBarMovingIn && !isSideBarMovingOut) {
			// update the current object on the top of the stack
			SideBarObject* topObject = [sideBarStack objectAtIndex:([sideBarStack count] - 1)];
			[topObject updateSideBar];
			if (topObject) {
				if (isMovingObjectIn) {
					isMovingObjectOut = NO;
					sideBarObjectLocation = CGPointMake(sideBarObjectLocation.x + SIDEBAR_MOVE_SPEED, sideBarObjectLocation.y);
					if (sideBarObjectLocation.x >= sideBarLocation.x) {
						sideBarObjectLocation = sideBarLocation;
						isMovingObjectIn = NO;
					}
				}
				if (isMovingObjectOut) {
					isMovingObjectIn = NO;
					sideBarObjectLocation = CGPointMake(sideBarObjectLocation.x - SIDEBAR_MOVE_SPEED, sideBarObjectLocation.y);
					if (sideBarObjectLocation.x <= sideBarLocation.x - sideBarWidth) {
						sideBarObjectLocation = CGPointMake(sideBarLocation.x - sideBarWidth, sideBarLocation.y);
						isMovingObjectOut = NO;
						[sideBarStack removeLastObject];
					}
				}
			}
		}
	}
}

- (CGRect)backButtonRect {
	CGRect rect = CGRectMake(sideBarLocation.x,
							 sideBarLocation.y + sideBarHeight - SIDEBAR_BUTTON_HEIGHT,
							 SIDEBAR_BUTTON_WIDTH,
							 SIDEBAR_BUTTON_HEIGHT);
	return rect;
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
	[topObject renderWithOffset:Vector2fMake(-sideBarObjectLocation.x, -sideBarObjectLocation.y)];
	
	if ([sideBarStack count] > 1) {
		// Draw the back button
		enablePrimitiveDraw();
		glColor4f(1.0f, 0.0f, 0.0f, 0.5f);
		drawFilledRect([self backButtonRect], Vector2fZero);
		disablePrimitiveDraw();
	}
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
	if (!isSideBarMovingIn && !isSideBarMovingOut &&
		!isMovingObjectIn && !isMovingObjectOut) {
		if ([sideBarStack count] > 1) {
			if (CGRectContainsPoint([self backButtonRect], location)) {
				[self popSideBarObject];
				return;
			}
		}
		SideBarObject* topObject = [sideBarStack objectAtIndex:([sideBarStack count] - 1)];
		[topObject touchesScrolledAtLocation:location];
	}
}

- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation {
	if (!isSideBarMovingIn && !isSideBarMovingOut &&
		!isMovingObjectIn && !isMovingObjectOut) {
		SideBarObject* topObject = [sideBarStack objectAtIndex:([sideBarStack count] - 1)];
		[topObject touchesMovedToLocation:toLocation from:fromLocation];
	}
}

- (void)touchesEndedAtLocation:(CGPoint)location {
	if (!isSideBarMovingIn && !isSideBarMovingOut &&
		!isMovingObjectIn && !isMovingObjectOut) {
		SideBarObject* topObject = [sideBarStack objectAtIndex:([sideBarStack count] - 1)];
		[topObject touchesEndedAtLocation:location];
	}
}

- (void)touchesDoubleTappedAtLocation:(CGPoint)location {
	if (!isSideBarMovingIn && !isSideBarMovingOut &&
		!isMovingObjectIn && !isMovingObjectOut) {
		SideBarObject* topObject = [sideBarStack objectAtIndex:([sideBarStack count] - 1)];
		[topObject touchesDoubleTappedAtLocation:location];
	}
}

@end
