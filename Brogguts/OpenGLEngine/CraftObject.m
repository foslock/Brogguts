//
//  CraftObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/12/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CraftObject.h"
#import "Image.h"
#import "GameController.h"
#import "BroggutScene.h"

@implementation CraftObject


- (void)dealloc {
	[pathPointArray release];
	[super dealloc];
}

- (id)initWithTypeID:(int)typeID withLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	Image* image;
	switch (typeID) {
		case kObjectCraftAntID:
			image = [[Image alloc] initWithImageNamed:kObjectCraftAntSprite filter:GL_LINEAR];
			break;
		case kObjectCraftMothID:
			image = [[Image alloc] initWithImageNamed:kObjectCraftMothSprite filter:GL_LINEAR];
			break;
		case kObjectCraftBeetleID:
			image = [[Image alloc] initWithImageNamed:kObjectCraftBeetleSprite filter:GL_LINEAR];
			break;
		case kObjectCraftMonarchID:
			image = [[Image alloc] initWithImageNamed:kObjectCraftMonarchSprite filter:GL_LINEAR];
			break;
		case kObjectCraftCamelID:
			image = [[Image alloc] initWithImageNamed:kObjectCraftCamelSprite filter:GL_LINEAR];
			break;
		case kObjectCraftRatID:
			image = [[Image alloc] initWithImageNamed:kObjectCraftRatSprite filter:GL_LINEAR];
			break;
		case kObjectCraftSpiderID:
			image = [[Image alloc] initWithImageNamed:kObjectCraftSpiderSprite filter:GL_LINEAR];
			break;
		case kObjectCraftEagleID:
			image = [[Image alloc] initWithImageNamed:kObjectCraftEagleSprite filter:GL_LINEAR];
			break;
		default:
			break;
	}
	self = [super initWithImage:image withLocation:location withObjectType:typeID];
	if (self) {
		// Initialize the craft
		pathPointArray = nil;
		pathPointNumber = 0;
		isFollowingPath = NO;
		hasCurrentPathFinished = YES;
	}
	return self;
}

- (void)followPath:(NSArray*)array isLooped:(BOOL)looped {
	if ([array count] == 0) {
		NSLog(@"Path contained no points!");
		return;
	}
	[pathPointArray autorelease];
	pathPointArray = [[NSMutableArray alloc] initWithArray:array];
	isFollowingPath = YES;
	pathPointNumber = 0;
	isPathLooped = looped;
	hasCurrentPathFinished = NO;
}

- (void)stopFollowingCurrentPath {
	isFollowingPath = NO;
	hasCurrentPathFinished = YES;
}

- (void)resumeFollowingCurrentPath {
	if (pathPointArray && [pathPointArray count] != 0) {
		isFollowingPath = YES;
		hasCurrentPathFinished = NO;
	}
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
	// Get the current point we should be following
	if (isFollowingPath && pathPointArray && !hasCurrentPathFinished) {
		NSValue* pointValue = [pathPointArray objectAtIndex:pathPointNumber];
		CGPoint moveTowardsPoint = [pointValue CGPointValue];
		// If the craft has reached the point...
		if (AreCGPointsEqual(objectLocation, moveTowardsPoint)) {
			pathPointNumber++;
		}
		if (pathPointNumber < [pathPointArray count]) {
			NSValue* pointValue = [pathPointArray objectAtIndex:pathPointNumber];
			moveTowardsPoint = [pointValue CGPointValue];
		} else {
			if (isPathLooped) {
				pathPointNumber = 0;
			} else {
				hasCurrentPathFinished = YES;
			}
		}
		[self accelerateTowardsLocation:moveTowardsPoint];
	} else {
		[self decelerate];
	}

	
	[super updateObjectLogicWithDelta:aDelta];
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
	if (isBeingDragged) {
		enablePrimitiveDraw();
		if (isBeingControlled) {
			glColor4f(1.0f, 0.0f, 0.0f, 0.8f);
		} else {
			glColor4f(0.0f, 1.0f, 0.0f, 0.8f);
		}		
		drawDashedLine(objectLocation, dragLocation, 4, vector);
		disablePrimitiveDraw();
	}
	
	[super renderCenteredAtPoint:aPoint withScrollVector:vector];
}

- (void)touchesBeganAtLocation:(CGPoint)location {
	// OVERRIDE ME
	isBeingDragged = YES;
	dragLocation = location;
}

- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation {
	// OVERRIDE ME
	dragLocation = toLocation;
}

- (void)touchesEndedAtLocation:(CGPoint)location {
	// OVERRIDE ME
	
	if (isBeingDragged && !isBeingControlled) {
		NSArray* newPath = [NSArray arrayWithObjects:
							[NSValue valueWithCGPoint:dragLocation],
							nil];
		[self followPath:newPath isLooped:NO];
	}
	isBeingDragged = NO;
	dragLocation = objectLocation;					
	
}

- (void)touchesDoubleTappedAtLocation:(CGPoint)location {
	// OVERRIDE ME
	NSLog(@"Object (%i) was double tapped!",uniqueObjectID);
}

@end
