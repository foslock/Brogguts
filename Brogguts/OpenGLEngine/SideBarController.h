//
//  SideBarObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/12/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SIDEBAR_BUTTON_WIDTH 80
#define SIDEBAR_BUTTON_HEIGHT 80
#define SIDEBAR_MOVE_SPEED 8.0f

@class SideBarObject;

@interface SideBarController : NSObject {
	// Vars dealing with bar appearing and disappearing
	BOOL isSideBarShowing;
	BOOL isSideBarMovingIn;
	BOOL isSideBarMovingOut;
	CGPoint sideBarLocation; // Bottom left point of the sidebar rectangle
	CGPoint originalLocation;
	float sideBarWidth;
	float sideBarHeight;
	
	// Stack for sidebar objects
	NSMutableArray* sideBarStack;
	BOOL isMovingObjectIn;
	BOOL isMovingObjectOut;
	CGPoint sideBarObjectLocation;
	
}

@property (nonatomic, assign) BOOL isSideBarShowing;

- (id)initWithLocation:(CGPoint)location withWidth:(float)width withHeight:(float)height;

- (CGRect)sideBarRect;
- (CGRect)buttonRect;
- (void)moveSideBarIn;
- (void)moveSideBarOut;
- (void)updateSideBar;
- (void)renderSideBar;
- (void)pushSideBarObject:(SideBarObject*)sideBar;
- (void)popSideBarObject;

- (void)touchesBeganAtLocation:(CGPoint)location;
- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation;
- (void)touchesEndedAtLocation:(CGPoint)location;
- (void)touchesDoubleTappedAtLocation:(CGPoint)location;

@end
