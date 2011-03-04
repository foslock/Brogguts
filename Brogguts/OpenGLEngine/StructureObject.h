//
//  StructureObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/12/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchableObject.h"

@interface StructureObject : TouchableObject {
	// Path variables
	NSMutableArray* pathPointArray;		// Array containing the points that this craft should follow
	int pathPointNumber;				// Which index of the path array we should be accelerating towards
	BOOL isFollowingPath;				// True if the craft should follow its current path (if any)
	BOOL isPathLooped;					// Should the unit repeat the path when finished
	BOOL hasCurrentPathFinished;		// True if the previous given path is done
	
	// Variable attributes that all structure must implement
	int attributeBroggutCost;
	int attributeMetalCost;
	int attributeHullCapacity;
	int attributeHullCurrent;
	int attributeMovingTime;	
}

@property (readonly) int attributeHullCurrent;

- (id)initWithTypeID:(int)typeID withLocation:(CGPoint)location isTraveling:(BOOL)traveling;

- (void)setCurrentHull:(int)newHull;

- (void)moveTowardsLocation:(CGPoint)location;
- (void)followPath:(NSArray*)array isLooped:(BOOL)looped;
- (void)stopFollowingCurrentPath;
- (void)resumeFollowingCurrentPath;

@end
