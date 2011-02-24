//
//  BroggutObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/13/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "BroggutObject.h"


@implementation BroggutObject
@synthesize broggutValue, broggutType;

- (id)initWithImage:(Image *)image withLocation:(CGPoint)location withObjectType:(int)objecttype {
	self = [super initWithImage:image withLocation:location withObjectType:objecttype];
	if (self) {
		broggutValue = 0;
		broggutType = kObjectBroggutSmallID;
	}
	return self;
}

- (void)collidedWithOtherObject:(CollidableObject *)other {
	if (objectType == kObjectBroggutSmallID && other.objectType == kObjectBroggutSmallID) {
		Vector2f tempVector = objectVelocity;
		if (!other.staticObject) {
			if (!hasBeenCheckedForCollisions)
				objectVelocity = Vector2fMultiply(other.objectVelocity, COLLISION_ELASTICITY);
			if (!other.hasBeenCheckedForCollisions)
				other.objectVelocity = Vector2fMultiply(tempVector, COLLISION_ELASTICITY);
		} else {
			objectVelocity = Vector2fMultiply(tempVector, -1.0f);
		}
	}
	[super collidedWithOtherObject:other];
}

@end
