//
//  CollidableObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/9/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CollidableObject.h"
#import "BroggutScene.h"
#import "GameController.h"
#import "Image.h"

static int globalUniqueID = 0;

@implementation CollidableObject

@synthesize objectRotation;
@synthesize renderLayer;
@synthesize isCheckedForCollisions, isCheckedForMultipleCollisions, destroyNow, isTextObject;
@synthesize objectImage, rotationSpeed, objectLocation, objectVelocity;
@synthesize uniqueObjectID, boundingCircle, boundingCircleRadius;
@synthesize hasBeenCheckedForCollisions;
@synthesize objectAlliance, objectType;
@synthesize staticObject;

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
		renderLayer = 1;
		objectLocation = location;
		objectType = objecttype;
		objectAlliance = kAllianceNeutral;
		objectVelocity = Vector2fZero;
		rotationSpeed = 0.0f;
		isCheckedForCollisions = NO;			// Defaults to NOT being in the spacial collision grid
		hasBeenCheckedForCollisions = NO;		// Var that is used to make sure duplicate collisions aren't checked
		isCheckedForMultipleCollisions = NO;	// Set to YES if you want multiple objects checking collisions with this one.
		isTextObject = NO;
		staticObject = NO;
		
		// Set bounding information
		boundingCircle.x = location.x;
		boundingCircle.y = location.y;
		boundingCircle.radius = (image.imageSize.width / 2) - BOUNDING_BOX_X_PADDING; // Half the width for now
	}
	return self;
}

- (BroggutScene*)currentScene {
	return [[GameController sharedGameController] currentScene];
}

- (void)collidedWithOtherObject:(CollidableObject*)other { // Called ONCE for each object, ON each object in the collision
	if (!isCheckedForMultipleCollisions) hasBeenCheckedForCollisions = YES;
	if (!other.isCheckedForMultipleCollisions) other.hasBeenCheckedForCollisions = YES;
	
	// NSLog(@"Object (%i) collided with Object (%i) at location: <%.0f,%.0f>", uniqueObjectID, other.uniqueObjectID, objectLocation.x, objectLocation.y);
	
}

- (Circle)boundingCircle {
	boundingCircle.x = objectLocation.x;
	boundingCircle.y = objectLocation.y;
	return boundingCircle;
}

- (void)setObjectRotation:(float)rot {
	objectRotation = rot;
	if (objectRotation > 360.0f) objectRotation -= 360.0f;
	if (objectRotation < 0.0f) objectRotation += 360.0f;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
	objectLocation = CGPointMake(objectLocation.x + objectVelocity.x,
								 objectLocation.y + objectVelocity.y);

	objectRotation += rotationSpeed;
	objectImage.rotation = objectRotation;
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
	if (objectImage) {
		[objectImage renderCenteredAtPoint:aPoint withScrollVector:vector];
#ifdef BOUNDING_DEBUG
		enablePrimitiveDraw();
		glColor4f(1.0f, 1.0f, 0.0f, 1.0f);
		drawCircle(self.boundingCircle, CIRCLE_SEGMENTS_COUNT, vector);
		disablePrimitiveDraw();
#endif
	}
		
}

- (void)objectWasDestroyed {
	NSLog(@"Object (%i) was destroyed", uniqueObjectID);
}

@end
