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

@interface SideBarObject : NSObject {
	SideBarController* myController;
	NSMutableArray* buttonArray;
	float currentYOffset;
	float totalSideBarHeight;
	
	BOOL isTouchMovingScroll;
}

@property (assign) SideBarController* myController;

- (void)renderWithOffset:(Vector2f)vector;
- (void)buttonPressedWithID:(int)buttonID;
- (void)buttonReleasedWithID:(int)buttonID;

- (void)touchesBeganAtLocation:(CGPoint)location;
- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation;
- (void)touchesEndedAtLocation:(CGPoint)location;
- (void)touchesDoubleTappedAtLocation:(CGPoint)location;

@end
