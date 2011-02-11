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
@synthesize isCurrentlyTouched, touchableBounds;

- (id)initWithImage:(Image*)image withLocation:(CGPoint)location withObjectType:(int)objecttype {
	self = [super initWithImage:image withLocation:location withObjectType:objecttype];
	if (self) {
		isTouchable = YES;
		isCurrentlyTouched = NO;
		touchableBounds = CGRectMake(objectLocation.x - (objectImage.imageSize.width / 2),
									 objectLocation.y - (objectImage.imageSize.height / 2),
									 objectImage.imageSize.width,
									 objectImage.imageSize.height);
	}
	return self;
}

- (CGRect)touchableBounds {
	return CGRectMake(objectLocation.x - (objectImage.imageSize.width / 2),
					  objectLocation.y - (objectImage.imageSize.height / 2),
					  objectImage.imageSize.width,
					  objectImage.imageSize.height);
}

- (void)touchesBeganAtLocation:(CGPoint)location {
	// OVERRIDE ME
}

- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation {
	// OVERRIDE ME
	
	// Just testing dragging
	objectLocation = toLocation;
}

- (void)touchesEndedAtLocation:(CGPoint)location {
	// OVERRIDE ME
}

- (void)touchesDoubleTappedAtLocation:(CGPoint)location {
	// OVERRIDE ME
	NSLog(@"Object (%i) was double tapped!",uniqueObjectID);
}

@end
