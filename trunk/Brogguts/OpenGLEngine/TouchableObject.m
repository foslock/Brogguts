//
//  TouchableObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/10/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TouchableObject.h"
#import "Image.h"

@implementation TouchableObject
@synthesize isCheckedForRadialEffect, isTouchable, isCurrentlyTouched, touchableBounds;

- (id)initWithImage:(Image*)image withLocation:(CGPoint)location withObjectType:(int)objecttype {
	self = [super initWithImage:image withLocation:location withObjectType:objecttype];
	if (self) {
		isTouchable = YES;
		isCurrentlyTouched = NO;
		isCurrentlyHoveredOver = NO;
		isCheckedForRadialEffect = NO;
		effectRadius = objectImage.imageSize.width / 2;
	}
	return self;
}

- (Circle)touchableBounds { // Bigger than bounding circle, so that it's not hard to tap on it
	Circle tempBoundingCircle;
	tempBoundingCircle.x = objectLocation.x;
	tempBoundingCircle.y = objectLocation.y;
	tempBoundingCircle.radius = objectImage.imageSize.width / 2;
	return tempBoundingCircle;
}

- (Circle)effectRadiusCircle {
	Circle tempBoundingCircle;
	tempBoundingCircle.x = objectLocation.x;
	tempBoundingCircle.y = objectLocation.y;
	tempBoundingCircle.radius = effectRadius;
	return tempBoundingCircle;
}

- (void)objectEnteredEffectRadius:(TouchableObject*)other {
	// "other" has entered the effect radius of this structure
	// NSLog(@"Object (%i) entered object (%i) effect radius", other.uniqueObjectID, uniqueObjectID);
}

- (void)touchesHoveredOver {
	// OVERRIDE ME, BUT CALL SUPER FIRST
	if (!isCurrentlyHoveredOver) {
		isCurrentlyHoveredOver = YES;
	} else {
		return;
	}

	// NSLog(@"Hovered over object (%i)", uniqueObjectID);
}

- (void)touchesHoveredLeft {
	// OVERRIDE ME, BUT CALL SUPER FIRST
	if (isCurrentlyHoveredOver) {
		isCurrentlyHoveredOver = NO;
	} else {
		return;
	}
	
	// NSLog(@"Hovered left object (%i)", uniqueObjectID);
}

- (void)touchesBeganAtLocation:(CGPoint)location {
	// OVERRIDE ME
}

- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation {
	// OVERRIDE ME
}

- (void)touchesEndedAtLocation:(CGPoint)location {
	// OVERRIDE ME
}

- (void)touchesDoubleTappedAtLocation:(CGPoint)location {
	// OVERRIDE ME
	NSLog(@"Object (%i) was double tapped!",uniqueObjectID);
}

@end
