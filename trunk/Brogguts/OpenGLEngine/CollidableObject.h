//
//  CollidableObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/9/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BOUNDING_BOX_X_PADDING 10
#define BOUNDING_BOX_Y_PADDING 10

@class Image;

@interface CollidableObject : NSObject {
	Image* objectImage;
	float rotationSpeed;
	BOOL isCheckedForCollisions;
	BOOL isTextObject;
	BOOL destroyNow;
	
	CGPoint objectLocation;
	Vector2f objectVelocity;
	int uniqueObjectID;			// The unique ID for a specific object, no two should ever have the same one 
	int objectType;				// This is the type of the object, seen in GameplayConstants.h
	
	// Bounding Circle info
	Circle boundingCircle;
}

@property (readonly) Image* objectImage;
@property (nonatomic, assign) float rotationSpeed;
@property (nonatomic, assign) BOOL isCheckedForCollisions;
@property (nonatomic, assign) BOOL destroyNow;
@property (nonatomic, assign) BOOL isTextObject;
@property (nonatomic, assign) CGPoint objectLocation;
@property (nonatomic, assign) Vector2f objectVelocity;
@property (nonatomic, assign) int uniqueObjectID;
@property (nonatomic, assign) Circle boundingCircle;
@property (nonatomic, assign) float boundingCircleRadius;

- (id)initWithImage:(Image*)image withLocation:(CGPoint)location withObjectType:(int)objecttype;

- (void)collidedWithOtherObject:(CollidableObject*)other;

- (void)updateObjectLogicWithDelta:(float)aDelta;

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector;

- (void)objectWasDestroyed;


@end
