//
//  ControllableObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/11/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "ControllableObject.h"


@implementation ControllableObject
@synthesize isBeingControlled;

- (void)dealloc {
	
	[super dealloc];
}

- (id)initWithImage:(Image*)image withLocation:(CGPoint)location withObjectType:(int)objecttype {
	self = [super initWithImage:image withLocation:location withObjectType:objecttype];
	if (self) {
		dragLocation = objectLocation;
		isBeingControlled = NO;
		isBeingDragged = NO;
		maxVelocity = 2.0f;
		rotationAcceleration = 2.0f;
	}
	return self;
}

- (void)accelerateTowardsLocation:(CGPoint)location {
	float direction = RADIANS_TO_DEGREES(atan2f(location.y - objectLocation.y, location.x - objectLocation.x));
	if (direction < 0.0f) direction += 360.0f;
	float deltaDirection = objectRotation - direction;
	if (fabs(deltaDirection) < rotationAcceleration) {
		self.objectRotation = direction;
		float radDir = DEGREES_TO_RADIANS(objectRotation);
		float xRatio = cosf(radDir);
		float yRatio = sinf(radDir);
		if (xRatio > 0.0f) xRatio += 0.8f; // This ensure that it is above 1.0f
		if (yRatio > 0.0f) yRatio += 0.8f; // This ensure that it is above 1.0f
		if (xRatio < 0.0f) xRatio -= 0.8f; // This ensure that it is below -1.0f
		if (yRatio < 0.0f) yRatio -= 0.8f; // This ensure that it is below -1.0f
		objectVelocity.x = CLAMP((fabs(objectVelocity.x) + 0.1f) * xRatio, -maxVelocity, maxVelocity);
		objectVelocity.y = CLAMP((fabs(objectVelocity.y) + 0.1f) * yRatio, -maxVelocity, maxVelocity);
		return;
	}
	if (fabs(deltaDirection) >= 90.0f) {
		// The location is behind the object
		if (fabs(deltaDirection) >= 90.0f && fabs(deltaDirection) < 180.0f) {
			if (deltaDirection > 0.0f) {
				self.objectRotation -= rotationAcceleration;
			} else {
				self.objectRotation += rotationAcceleration;
			}
		} else {
			if (deltaDirection > 0.0f) {
				self.objectRotation += rotationAcceleration;
			} else {
				self.objectRotation -= rotationAcceleration;
			}
		}
	} else {
		// The location is in front of the object
		if (deltaDirection > 0.0f) {
			self.objectRotation -= rotationAcceleration;
		} else {
			self.objectRotation += rotationAcceleration;
		}
	}
	float radDir = DEGREES_TO_RADIANS(objectRotation);
	objectVelocity.x = CLAMP((fabs(objectVelocity.x) + 0.1f) * cosf(radDir), -maxVelocity, maxVelocity);
	objectVelocity.y = CLAMP((fabs(objectVelocity.y) + 0.1f) * sinf(radDir), -maxVelocity, maxVelocity);
}

- (void)decelerate {
	objectVelocity.x /= 1.1f;
	objectVelocity.y /= 1.1f;
	if (objectVelocity.x < 0.01f && objectVelocity.x > 0.0f ) { objectVelocity.x = 0.0f; }
	if (objectVelocity.x > -0.01f && objectVelocity.x < 0.0f ) { objectVelocity.x = 0.0f; }
	if (objectVelocity.y < 0.01f && objectVelocity.y > 0.0f ) { objectVelocity.y = 0.0f; }
	if (objectVelocity.y > -0.01f && objectVelocity.y < 0.0f ) { objectVelocity.y = 0.0f; }
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