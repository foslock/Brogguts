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
#define OBJECT_GLOBAL_SCALE_FACTOR 0.85f
#define COLLISION_ELASTICITY 1.0f

@class Image;
@class BroggutScene;

@interface CollidableObject : NSObject {
	Image* objectImage;
    BroggutScene* currentScene;
    GLuint renderLayer;
	float objectRotation;
	float rotationSpeed;
	BOOL isHidden;
    BOOL isRenderedInOverview;
    BOOL isPaddedForCollisions;
	BOOL isCheckedForCollisions;
	BOOL isCheckedForMultipleCollisions;
	BOOL hasBeenCheckedForCollisions;
	BOOL isTextObject;
	BOOL destroyNow;
	BOOL staticObject;
    BOOL isRemoteObject;
	
    CGPoint remoteLocation;     // Used only for remote objects, this is the position received, and will be used in the object movement smoothing
    
	CGPoint objectLocation;
	Vector2f objectVelocity;
	int uniqueObjectID;			// The unique ID for a specific object, no two should ever have the same one
	int objectType;				// This is the type of the object, seen in GameplayConstants.h (each object has a unique type ID)
	int objectAlliance;			// This is used to determine whether or not the object is friendly or enemy
	
	// Bounding Circle info
	Circle boundingCircle;
}

@property (readonly) Image* objectImage;
@property (nonatomic, assign) BroggutScene* currentScene;
@property (nonatomic, assign) GLuint renderLayer;
@property (nonatomic, assign) float rotationSpeed;
@property (nonatomic, assign) float objectRotation;
@property (nonatomic, assign) BOOL isHidden;
@property (nonatomic, assign) BOOL isRenderedInOverview;
@property (nonatomic, assign) BOOL isCheckedForCollisions;
@property (nonatomic, assign) BOOL isCheckedForMultipleCollisions;
@property (nonatomic, assign) BOOL hasBeenCheckedForCollisions;
@property (nonatomic, assign) BOOL destroyNow;
@property (nonatomic, assign) BOOL isTextObject;
@property (nonatomic, assign) BOOL staticObject;
@property (nonatomic, assign) BOOL isRemoteObject;
@property (nonatomic, assign) CGPoint remoteLocation;
@property (nonatomic, assign) CGPoint objectLocation;
@property (nonatomic, assign) Vector2f objectVelocity;
@property (nonatomic, assign) int uniqueObjectID;
@property (nonatomic, assign) int objectType;	
@property (nonatomic, assign) int objectAlliance;
@property (nonatomic, assign) Circle boundingCircle;
@property (nonatomic, assign) float boundingCircleRadius;

- (id)initWithImage:(Image*)image withLocation:(CGPoint)location withObjectType:(int)objecttype;

- (void)updateObjectLogicWithDelta:(float)aDelta;

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector;
- (void)renderUnderObjectWithScroll:(Vector2f)scroll;
- (void)renderOverObjectWithScroll:(Vector2f)scroll;

- (void)objectWasDestroyed;

- (void)normalizePosition;
- (BOOL)isOnScreen;


@end
