//
//  CollidableObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/9/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CollidableObject.h"
#import "Image.h"

static int globalUniqueID = 0;

@implementation CollidableObject

@synthesize isCheckedForCollisions, destroyNow, isTextObject;
@synthesize objectImage, rotationSpeed, objectLocation, objectVelocity;
@synthesize uniqueObjectID, boundingCircle, boundingCircleRadius;

- (void)dealloc {
	if (objectImage)
		[objectImage release];
	[super dealloc];
}

- (id)initWithImage:(Image*)image withLocation:(CGPoint)location withObjectType:(int)objecttype {
	self = [super init];
	if (self) {
		uniqueObjectID = globalUniqueID++; // Must use this method to ensure no overlapping in UIDs
		objectImage = [image retain];
		objectLocation = location;
		objectType = objecttype;
		objectVelocity = Vector2fZero;
		rotationSpeed = 0.0f;
		isCheckedForCollisions = NO;
		isTextObject = NO;
		
		// Set bounding information
		boundingCircle.x = location.x;
		boundingCircle.y = location.y;
		boundingCircle.radius = image.imageSize.width / 2; // Half the width for now
	}
	return self;
}

- (void)collidedWithOtherObject:(CollidableObject*)other {
	// NSLog(@"Object (%i) collided with Object (%i) at location: <%.0f,%.0f>", uniqueObjectID, other.uniqueObjectID, objectLocation.x, objectLocation.y);
	
}

- (Circle)boundingCircle {
	boundingCircle.x = objectLocation.x;
	boundingCircle.y = objectLocation.y;
	return boundingCircle;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
	objectLocation = CGPointMake(objectLocation.x + objectVelocity.x,
								 objectLocation.y + objectVelocity.y);

	objectImage.rotation += rotationSpeed;
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
	if (objectImage) {
		[objectImage renderCenteredAtPoint:aPoint withScrollVector:vector];
#ifdef BOUNDING_DEBUG
		Circle newCircle = boundingCircle;
		newCircle.x -= vector.x;
		newCircle.y -= vector.y;
		drawCircle(newCircle, 20);
#endif
	}
		
}

- (void)objectWasDestroyed {
	NSLog(@"Object (%i) was destroyed", uniqueObjectID);
}

@end
