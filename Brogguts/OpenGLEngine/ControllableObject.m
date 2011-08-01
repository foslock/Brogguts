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
@synthesize maxVelocity;

- (void)dealloc {
	
	[super dealloc];
}

- (id)initWithImage:(Image*)image withLocation:(CGPoint)location withObjectType:(int)objecttype {
	self = [super initWithImage:image withLocation:location withObjectType:objecttype];
	if (self) {
		dragLocation = objectLocation;
		isBeingControlled = NO;
		isBeingDragged = NO;
		maxVelocity = 1.0f;
		rotationAcceleration = 2.0f;
	}
	return self;
}

- (void)rotateTowardsAngle:(float)angle {
    
}

- (void)accelerateTowardsLocation:(CGPoint)location withMaxVelocity:(float)otherMaxVelocity {
	if (otherMaxVelocity < 0.0f) {
        otherMaxVelocity = maxVelocity;
    }
	// Are the points equal?
	if (AreCGPointsEqual(objectLocation, location, otherMaxVelocity)) {
		return;
	}
	
	// Are the points close enough to set velocity directly?
	if (GetDistanceBetweenPointsSquared(objectLocation, location) < POW2(boundingCircle.radius)) {
		// If point is closer than the objects radius, move it in the direct 1velocity
		float dx = location.x - objectLocation.x;
		float dy = location.y - objectLocation.y;
		objectVelocity.x = CLAMP(dx, -otherMaxVelocity, otherMaxVelocity);
		objectVelocity.y = CLAMP(dy, -otherMaxVelocity, otherMaxVelocity);
		float direction = RADIANS_TO_DEGREES(atan2f(location.y - objectLocation.y, location.x - objectLocation.x));
		if (direction < 0.0f) direction += 360.0f;
		self.objectRotation = (int)direction; // FIX ROTATION SPEED HERE
		return;
	}
	
	float direction = RADIANS_TO_DEGREES(atan2f(location.y - objectLocation.y, location.x - objectLocation.x));
	if (direction < 0.0f) direction += 360.0f;
	float deltaDirection = objectRotation - direction;
	if (fabs(deltaDirection) < rotationAcceleration) {
		self.objectRotation = (int)direction;
		float radDir = DEGREES_TO_RADIANS(objectRotation);
		float xRatio = cosf(radDir);
		float yRatio = sinf(radDir);
		if (xRatio > 0.0f && xRatio != 0.0f) xRatio += 0.8f; // This ensure that it is above 1.0f
		if (yRatio > 0.0f && yRatio != 0.0f) yRatio += 0.8f; // This ensure that it is above 1.0f
		if (xRatio < 0.0f && xRatio != 0.0f) xRatio -= 0.8f; // This ensure that it is below -1.0f
		if (yRatio < 0.0f && yRatio != 0.0f) yRatio -= 0.8f; // This ensure that it is below -1.0f
		objectVelocity.x = CLAMP((fabs(objectVelocity.x) + 0.1f) * xRatio, -otherMaxVelocity, otherMaxVelocity);
		objectVelocity.y = CLAMP((fabs(objectVelocity.y) + 0.1f) * yRatio, -otherMaxVelocity, otherMaxVelocity);
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
	objectVelocity.x = CLAMP((fabs(objectVelocity.x) + 0.1f) * cosf(radDir), -otherMaxVelocity, otherMaxVelocity);
	objectVelocity.y = CLAMP((fabs(objectVelocity.y) + 0.1f) * sinf(radDir), -otherMaxVelocity, otherMaxVelocity);
}

- (void)decelerate {
	objectVelocity.x /= 1.1f;
	objectVelocity.y /= 1.1f;
	if (objectVelocity.x < 0.01f && objectVelocity.x > 0.0f ) { objectVelocity.x = 0.0f; [self normalizePosition]; }
	if (objectVelocity.x > -0.01f && objectVelocity.x < 0.0f ) { objectVelocity.x = 0.0f; [self normalizePosition]; }
	if (objectVelocity.y < 0.01f && objectVelocity.y > 0.0f ) { objectVelocity.y = 0.0f; [self normalizePosition]; }
	if (objectVelocity.y > -0.01f && objectVelocity.y < 0.0f ) { objectVelocity.y = 0.0f; [self normalizePosition]; }
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
