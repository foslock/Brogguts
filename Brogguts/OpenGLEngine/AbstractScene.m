//
//  AbstractState.m
//  SLQTSOR
//
//  Created by Michael Daley on 01/06/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "AbstractScene.h"
#import "Image.h"
#import "CollisionManager.h"
#import "CollidableObject.h"
#import "BitmapFont.h"
#import "TextObject.h"

@implementation AbstractScene

@synthesize cameraContainRect, cameraLocation;
@synthesize fullMapBounds, visibleScreenBounds;
@synthesize state;
@synthesize alpha;
@synthesize name;

- (void)dealloc {
	[fontArray release];
	[textObjectArray release];
	[currentObjectsTouching release];
	[renderableObjects release];
	[renderableDestroyed release];
	[touchableObjects release];
	[collisionManager release];
	[super dealloc];
}

- (id)initWithScreenBounds:(CGRect)screenBounds withFullMapBounds:(CGRect)mapBounds {
	self = [super init];
	if (self) {
		renderableObjects = [[NSMutableArray alloc] initWithCapacity:INITIAL_OBJECT_CAPACITY];
		renderableDestroyed = [[NSMutableArray alloc] initWithCapacity:INITIAL_OBJECT_CAPACITY];
		touchableObjects = [[NSMutableArray alloc] initWithCapacity:INITIAL_OBJECT_CAPACITY];
		textObjectArray = [[NSMutableArray alloc] initWithCapacity:INITIAL_OBJECT_CAPACITY];
		currentObjectsTouching = [[NSMutableDictionary alloc] initWithCapacity:11];
		collisionManager = [[CollisionManager alloc] initWithContainingRect:mapBounds WithCellWidth:COLLISION_CELL_WIDTH withHeight:COLLISION_CELL_HEIGHT];
		visibleScreenBounds = screenBounds;
		fullMapBounds = mapBounds;
		cameraContainRect = CGRectInset(screenBounds, SCROLL_BOUNDS_X_INSET, SCROLL_BOUNDS_Y_INSET);
		cameraLocation = [self middleOfVisibleScreen];
		
		
		// Set up fonts
		fontArray = [[NSMutableArray alloc] initWithCapacity:10];
		BitmapFont* gothic = [[BitmapFont alloc]
							  initWithFontImageNamed:@"gothic.png" controlFile:@"gothic" scale:Scale2fMake(1, 1) filter:GL_LINEAR];
		[fontArray insertObject:gothic atIndex:kFontGothicID];
	}
	return self;
}

- (void)scrollScreenWithVector:(Vector2f)scrollVector {}

- (Vector2f)newScrollVectorFromCamera {
	return Vector2fZero; // Meant for overriding
}
- (Vector2f)scrollVectorFromScreenBounds {
	return Vector2fMake(visibleScreenBounds.origin.x, visibleScreenBounds.origin.y);
}
- (CGPoint)middleOfVisibleScreen {
	return CGPointMake(visibleScreenBounds.origin.x + (visibleScreenBounds.size.width / 2),
					   visibleScreenBounds.origin.y + (visibleScreenBounds.size.height / 2));
}
- (CGPoint)middleOfEntireMap {
	return CGPointMake(fullMapBounds.origin.x + (fullMapBounds.size.width / 2),
					   fullMapBounds.origin.y + (fullMapBounds.size.height / 2));
}


- (void)updateSceneWithDelta:(GLfloat)aDelta {
	if (++frameCounter >= FRAME_COUNTER_MAX) {
		frameCounter = 0;
	}
	
	for (int i = 0; i < [textObjectArray count]; i++) {
		TextObject* tempObj = [textObjectArray objectAtIndex:i];
		[tempObj updateObjectLogicWithDelta:aDelta];
		if (tempObj.destroyNow) {
			[renderableDestroyed addObject:tempObj];
		}
	}
	
	for (int i = 0; i < [renderableObjects count]; i++) {
		CollidableObject* tempObj = [renderableObjects objectAtIndex:i];
		[tempObj updateObjectLogicWithDelta:aDelta];
		
		// Keep objects in the fullMapBounds
		if (tempObj.objectLocation.x < fullMapBounds.origin.x)
			tempObj.objectLocation = CGPointMake(fullMapBounds.size.width, tempObj.objectLocation.y);
		if (tempObj.objectLocation.x > fullMapBounds.size.width)
			tempObj.objectLocation = CGPointMake(fullMapBounds.origin.x, tempObj.objectLocation.y);
		if (tempObj.objectLocation.y < fullMapBounds.origin.y)
			tempObj.objectLocation = CGPointMake(tempObj.objectLocation.x, fullMapBounds.size.height);
		if (tempObj.objectLocation.y > fullMapBounds.size.height)
			tempObj.objectLocation = CGPointMake(tempObj.objectLocation.x, fullMapBounds.origin.y);
		if (tempObj.destroyNow) {
			[renderableDestroyed addObject:tempObj];
		}
	}
	
	if (frameCounter % (COLLISION_DETECTION_FREQ + 1) == 0) {
		[collisionManager processAllCollisionsWithScreenBounds:visibleScreenBounds];
	} else {
		[collisionManager updateAllObjectsInTableInScreenBounds:visibleScreenBounds];
	}
	
	// Destroy all objects in the destory array, and remove them from other arrays
	for (int i = 0; i < [renderableDestroyed count]; i++) {
		CollidableObject* tempObj = [renderableDestroyed objectAtIndex:i];
		[renderableObjects removeObject:tempObj];
		if (tempObj.isCheckedForCollisions) {
			[collisionManager removeCollidableObject:tempObj];
		}
		if (tempObj.isTextObject) {
			[textObjectArray removeObject:tempObj];
		}
		[tempObj objectWasDestroyed];
		[renderableDestroyed removeObject:tempObj];
	}
}
- (void)addSmallBrogguts:(int)number inBounds:(CGRect)bounds {
	for (int i = 0; i < number; i++) {
		Image* rockImage = [[Image alloc] initWithImageNamed:@"rock.png" filter:GL_LINEAR];
		CollidableObject* tempObj = [[CollidableObject alloc]
									 initWithImage:rockImage
									 withLocation:CGPointMake(RANDOM_0_TO_1() * fullMapBounds.size.width,
															  RANDOM_0_TO_1() * fullMapBounds.size.height)
									 withObjectType:kObjectBroggutSmallID];
		tempObj.objectImage.rotation = 360 * RANDOM_0_TO_1();
		tempObj.rotationSpeed = RANDOM_MINUS_1_TO_1() * kBroggutSmallMaxRotationSpeed;
		tempObj.objectVelocity = Vector2fMake(RANDOM_MINUS_1_TO_1() * ((float)kBroggutSmallMaxVelocity / 100.0f),
											  RANDOM_MINUS_1_TO_1() * ((float)kBroggutSmallMaxVelocity / 100.0f));
		[collisionManager addCollidableObject:tempObj];
		[renderableObjects addObject:tempObj];
		[tempObj release];
		[rockImage release];
	}
	
}
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {}
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {}
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {}
- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {}
- (void)transitionToSceneWithKey:(NSString*)aKey {}
- (void)transitionIn{};
- (void)renderScene {}

@end