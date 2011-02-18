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
@synthesize isTouchable, isCurrentlyTouched, touchableBounds;

- (id)initWithImage:(Image*)image withLocation:(CGPoint)location withObjectType:(int)objecttype {
	self = [super initWithImage:image withLocation:location withObjectType:objecttype];
	if (self) {
		isTouchable = YES;
		isCurrentlyTouched = NO;
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
