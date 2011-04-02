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
#import "ImageRenderSingleton.h"
#import "GameCenterSingleton.h"

static int globalUniqueID = 0;

@implementation CollidableObject

@synthesize currentScene, objectRotation;
@synthesize renderLayer;
@synthesize isHidden, isCheckedForCollisions, isCheckedForMultipleCollisions, destroyNow, isTextObject;
@synthesize objectImage, rotationSpeed, remoteLocation, objectLocation, objectVelocity;
@synthesize uniqueObjectID, boundingCircle, boundingCircleRadius;
@synthesize isRenderedInOverview, hasBeenCheckedForCollisions;
@synthesize objectAlliance, objectType;
@synthesize staticObject, isRemoteObject;

- (void)dealloc {
	if (objectImage)
		[objectImage release];
	[super dealloc];
}

- (id)initWithImage:(Image*)image withLocation:(CGPoint)location withObjectType:(int)objecttype {
	self = [super init];
	if (self) {
        currentScene = nil;
		uniqueObjectID = globalUniqueID++; // Must use this method to ensure no overlapping in UIDs
		objectImage = [image retain];
        objectImage.scale = Scale2fMake(OBJECT_GLOBAL_SCALE_FACTOR, OBJECT_GLOBAL_SCALE_FACTOR);
		self.renderLayer = kLayerBottomLayer;
		objectLocation = location;
		objectType = objecttype;
		objectAlliance = kAllianceNeutral;
		objectVelocity = Vector2fZero;
		rotationSpeed = 0.0f;
        isRenderedInOverview = YES;
		isHidden = NO;							// Defaults to being drawn
		isCheckedForCollisions = NO;			// Defaults to NOT being in the spacial collision grid
		hasBeenCheckedForCollisions = NO;		// Var that is used to make sure duplicate collisions aren't checked
		isCheckedForMultipleCollisions = NO;	// Set to YES if you want multiple objects checking collisions with this one.
        isPaddedForCollisions = YES;            // If there should be a shrunken radius for collisions
		isTextObject = NO;
		staticObject = NO;
        isRemoteObject = NO;
        remoteLocation = CGPointZero;
		
		// Set bounding information
		boundingCircle.x = location.x;
		boundingCircle.y = location.y;
        if (isPaddedForCollisions) {
            boundingCircle.radius = (image.imageSize.width / 2) - BOUNDING_BOX_X_PADDING; // Half the width for now
        } else {
            boundingCircle.radius = (image.imageSize.width / 2);
        }
	}
	return self;
}

- (void)collidedWithOtherObject:(CollidableObject*)other { // Called ONCE for each object, ON each object in the collision
	if (!isCheckedForMultipleCollisions) hasBeenCheckedForCollisions = YES;
	if (!other.isCheckedForMultipleCollisions) other.hasBeenCheckedForCollisions = YES;
	
	// NSLog(@"Object (%i) collided with Object (%i) at location: <%.0f,%.0f>", uniqueObjectID, other.uniqueObjectID, objectLocation.x, objectLocation.y);
}

- (Circle)boundingCircle {
	boundingCircle.x = objectLocation.x;
	boundingCircle.y = objectLocation.y;
    if (isPaddedForCollisions) {
        boundingCircle.radius = ((objectImage.imageSize.width * objectImage.scale.x) / 2) - BOUNDING_BOX_X_PADDING; // Half the width for now
    } else {
        boundingCircle.radius = ((objectImage.imageSize.width * objectImage.scale.x) / 2);
    }
	return boundingCircle;
}

- (BroggutScene*)currentScene {
    if (!currentScene) {
        currentScene = [[GameController sharedGameController] currentScene];
    }
    return currentScene;
}

- (void)setObjectRotation:(float)rot {
	objectRotation = rot;
	if (objectRotation > 360.0f) objectRotation -= 360.0f;
	if (objectRotation < 0.0f) objectRotation += 360.0f;
}

- (void)setRenderLayer:(GLuint)layer {
    renderLayer = layer;
    objectImage.renderLayer = renderLayer;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    if (isRemoteObject) {
        objectVelocity = Vector2fMake( (remoteLocation.x - objectLocation.x) * (GAME_CENTER_OBJECT_UPDATE_FRAME_PAUSE / kFrameRateTarget)  ,
                                       (remoteLocation.y - objectLocation.y) * (GAME_CENTER_OBJECT_UPDATE_FRAME_PAUSE / kFrameRateTarget) );
    }
    
    if (objectVelocity.x != 0 || objectVelocity.y != 0) {
        objectLocation = CGPointMake(objectLocation.x + objectVelocity.x,
                                     objectLocation.y + objectVelocity.y);
    }
    
    if (rotationSpeed != 0) {
        objectRotation += rotationSpeed;
    }
    
    if (objectImage.rotation != objectRotation) {
        objectImage.rotation = objectRotation;
    }
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
	if (objectImage && !isHidden) {
		[objectImage renderCenteredAtPoint:aPoint withScrollVector:vector];
    }
}

- (void)renderUnderObjectWithScroll:(Vector2f)scroll {
    // OVERRIDE
}

- (void)renderOverObjectWithScroll:(Vector2f)scroll {
#ifdef BOUNDING_DEBUG
    enablePrimitiveDraw();
    glColor4f(1.0f, 1.0f, 0.0f, 1.0f);
    drawCircle(self.boundingCircle, CIRCLE_SEGMENTS_COUNT, scroll);
    disablePrimitiveDraw();
#endif
}

- (BOOL)isOnScreen {
    CGRect bounds = [[self currentScene] visibleScreenBounds];
    return CGRectContainsPoint(CGRectInset(bounds, -objectImage.imageSize.width / 2, -objectImage.imageSize.height / 2), objectLocation);
}

- (void)objectWasDestroyed {
	// NSLog(@"Object (%i) was destroyed", uniqueObjectID);
}

@end
