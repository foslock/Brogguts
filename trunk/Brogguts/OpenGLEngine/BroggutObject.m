//
//  BroggutObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/13/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "BroggutObject.h"
#import "BroggutScene.h"
#import "Image.h"

@implementation BroggutObject
@synthesize broggutValue, broggutType;

- (id)initWithImage:(Image *)image withLocation:(CGPoint)location {
	self = [super initWithImage:image withLocation:location withObjectType:kObjectBroggutSmallID];
	if (self) {
		broggutValue = 0;
		broggutType = kObjectBroggutSmallID;
        float randomScale = (RANDOM_0_TO_1() * 0.25f) + 0.75f;
        objectImage.scale = Scale2fMake(randomScale, randomScale);
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

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
    if (![self isOnScreen]) {
        return;
    }
    [super renderCenteredAtPoint:aPoint withScrollVector:vector];
}

@end
