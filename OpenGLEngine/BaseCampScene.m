//
//  GameScene.m
//  SLQTSOR
//
//  Created by Mike Daley on 29/08/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "BaseCampScene.h"
#import "Image.h"
#import "ImageRenderSingleton.h"
#import "GameController.h"
#import "GameCenterSingleton.h"
#import "SoundSingleton.h"
#import "BitmapFont.h"
#import "ParticleEmitter.h"
#import "GameCenterStructs.h"
#import "StarSingleton.h"
#import "CollisionManager.h"
#import "CollidableObject.h"
#import "BitmapFont.h"
#import "TouchableObject.h"
#import "TextObject.h"
#import "ControllableObject.h"
#import "SideBarObject.h"

@implementation BaseCampScene

- (void)dealloc {
	if (cameraImage) {
		[cameraImage release];
	}
	if (controllingShip) {
		[controllingShip release];
	}
	[textObject release];
	[super dealloc];
}

- (id)initWithScreenBounds:(CGRect)screenBounds withFullMapBounds:(CGRect)mapBounds withName:(NSString*)sName 
{
	self = [super initWithScreenBounds:screenBounds withFullMapBounds:mapBounds withName:sName];
	if (self != nil) {
		
		// Grab an instance of the render manager
		sharedGameController = [GameController sharedGameController];
		sharedImageRenderSingleton = [ImageRenderSingleton sharedImageRenderSingleton];
		sharedSoundSingleton = [SoundSingleton sharedSoundSingleton];
		sharedGameCenterSingleton = [GameCenterSingleton sharedGCSingleton];
		sharedStarSingleton = [StarSingleton sharedStarSingleton];
		[sharedStarSingleton randomizeStars];
		
		Image* shipImage = [[Image alloc] initWithImageNamed:@"ship.png" filter:GL_LINEAR];
		controllingShip = [[ControllableObject alloc]
						   initWithImage:shipImage withLocation:CGPointMake(256, 256) withObjectType:kObjectCraftAntID];
		[renderableObjects addObject:controllingShip];
		[shipImage release];

		frameCounter = 0;
		
		cameraImage = [[Image alloc] initWithImageNamed:@"rock.png" filter:GL_LINEAR];		
	}
	return self;
}

- (void)scrollScreenWithVector:(Vector2f)scrollVector {
	float xAddition = scrollVector.x;
	float yAddition = scrollVector.y;
	
	// Check bounds against the mapRect
	if (visibleScreenBounds.origin.x + visibleScreenBounds.size.width + xAddition > fullMapBounds.size.width) {
		xAddition = fullMapBounds.size.width - (visibleScreenBounds.origin.x + visibleScreenBounds.size.width);
	}
	if (visibleScreenBounds.origin.y + visibleScreenBounds.size.height + yAddition > fullMapBounds.size.height) {
		yAddition = fullMapBounds.size.height - (visibleScreenBounds.origin.y + visibleScreenBounds.size.height);
	}
	if (visibleScreenBounds.origin.x + xAddition < fullMapBounds.origin.x) {
		xAddition = fullMapBounds.origin.x - visibleScreenBounds.origin.x;
	}
	if (visibleScreenBounds.origin.y + yAddition < fullMapBounds.origin.y) {
		yAddition = fullMapBounds.origin.y - visibleScreenBounds.origin.y;
	}
	
	// Set the new visible screen bounds
	visibleScreenBounds = CGRectMake(visibleScreenBounds.origin.x + xAddition,
									 visibleScreenBounds.origin.y + yAddition,
									 visibleScreenBounds.size.width,
									 visibleScreenBounds.size.height);
	
	// Update the camera container rectangle
	cameraContainRect = CGRectInset(visibleScreenBounds, SCROLL_BOUNDS_X_INSET, SCROLL_BOUNDS_Y_INSET);
	
	// Scroll the stars, this needs to be called separately since they scroll at different rates
	[sharedStarSingleton scrollStarsWithVector:Vector2fMake(-xAddition, -yAddition)];
	
	// Update the touch location, since we are scrolling
	currentTouchLocation = CGPointMake(currentTouchLocation.x + xAddition, currentTouchLocation.y + yAddition);
}

- (Vector2f)newScrollVectorFromCamera {
	Vector2f newVector = Vector2fMake(0, 0);
	
	if (CGRectContainsPoint(cameraContainRect, cameraLocation)) {
		return newVector;
	} else {
		CGPoint screenMiddle = [self middleOfVisibleScreen];
		newVector.x = CLAMP(newVector.x + SCROLL_MAX_SPEED * (cameraLocation.x - screenMiddle.x) / visibleScreenBounds.size.width,
							-SCROLL_MAX_SPEED, SCROLL_MAX_SPEED);
		newVector.y = CLAMP(newVector.y + SCROLL_MAX_SPEED * (cameraLocation.y - screenMiddle.y) / visibleScreenBounds.size.height,
							-SCROLL_MAX_SPEED, SCROLL_MAX_SPEED);
	}
	return newVector;
}

- (void)updateSceneWithDelta:(float)aDelta {
	
	// Update the stars' positions and brightness if applicable
	[sharedStarSingleton updateStars];
	
	// Update the camera's location
	if (isTouchScrolling) {
		[controllingShip accelerateTowardsLocation:currentTouchLocation];
		cameraLocation = GetMidpointFromPoints(controllingShip.objectLocation, currentTouchLocation);
	} else {
		[controllingShip decelerate];
	}
	
	// Gets the vector that the screen shoudl scroll, and scrolls it, updating the rects as necessary
	Vector2f cameraScroll = [self newScrollVectorFromCamera];
	[self scrollScreenWithVector:Vector2fMultiply(cameraScroll, 1.0f)];
	
	// Stop the player moving beyond the bounds of the screen
	/*
	if (playerLocation.x < fullMapBounds.origin.x) playerLocation.x = fullMapBounds.origin.x;
	if (playerLocation.x > fullMapBounds.size.width) playerLocation.x = fullMapBounds.size.width;
	if (playerLocation.y < fullMapBounds.origin.y) playerLocation.y = fullMapBounds.origin.y;
	if (playerLocation.y > fullMapBounds.size.height) playerLocation.y = fullMapBounds.size.height;
	*/
	[super updateSceneWithDelta:aDelta];
}

- (void)renderScene {

	// Clear the screen
	glClear(GL_COLOR_BUFFER_BIT);
	
	// Get the scroll vector that most images will need to by translated with
	Vector2f scroll = [self scrollVectorFromScreenBounds];
	
	// Rendering stars
	[sharedStarSingleton renderStars];
	
	// Draw the grid that collisions are based off of
	[collisionManager drawCellGridAtPoint:[self middleOfEntireMap] withScale:Scale2fMake(1.0f, 1.0f) withScroll:scroll withAlpha:0.1f];
	
	// Draw the medium/large brogguts
	[collisionManager renderMediumBroggutsInScreenBounds:visibleScreenBounds withScrollVector:scroll];
	
	// Render all objects (excluding text objects)
	for (int i = 0; i < [renderableObjects count]; i++) {
		CollidableObject* tempObj = [renderableObjects objectAtIndex:i];
		[tempObj renderCenteredAtPoint:tempObj.objectLocation withScrollVector:scroll];
	}
	
	// Render text objects
	for (int i = 0; i < [textObjectArray count]; i++) {
		TextObject* tempObj = [textObjectArray objectAtIndex:i];
		if (tempObj.scrollWithBounds)
			[tempObj renderWithFont:[fontArray objectAtIndex:tempObj.fontID] withScrollVector:scroll];
		else
			[tempObj renderWithFont:[fontArray objectAtIndex:tempObj.fontID]];
	}
	
	// Render camera sprite
	// [camera renderCenteredAtPoint:cameraLocation withScrollVector:scroll];

	// Render images to screen
	[sharedImageRenderSingleton renderImages];
	
	// Draw a line to the closest broggut
	BroggutObject* closestBrog = [collisionManager closestSmallBroggutToLocation:controllingShip.objectLocation];
	if (GetDistanceBetweenPoints(controllingShip.objectLocation, closestBrog.objectLocation) < 125)
		drawLine(controllingShip.objectLocation, closestBrog.objectLocation, scroll);
	
	[super renderScene];
}

#pragma mark -
#pragma mark Touch events

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
	for (UITouch *touch in touches) {
		if ([touches count] >= 2) {
			if (!isShowingOverview)
				[self fadeOverviewMapIn];
			else
				[self fadeOverviewMapOut];
			break;
		}
		
        // Get the point where the player has touched the screen
        CGPoint originalTouchLocation = [touch locationInView:aView];
        CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:visibleScreenBounds];
		if (CGRectContainsPoint([sideBar buttonRect], [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero])) {
			if (![sideBar isSideBarShowing]) {
				[sideBar moveSideBarIn];
			} else {
				[sideBar moveSideBarOut];
			}
			break;
		}
		
		if ([currentObjectsTouching count] == 0 && isTouchScrolling == NO && (!isShowingOverview || isFadingOverviewOut)) {
			isTouchScrolling = YES;
			movingTouchHash = [touch hash];
			currentTouchLocation = touchLocation;
		}
				
		for (int i = 0; i < [touchableObjects count]; i++) {
			TouchableObject* obj = [touchableObjects objectAtIndex:i];
			if (CircleContainsPoint(obj.touchableBounds, touchLocation)) {
				if (!obj.isCurrentlyTouched) {
					if (touch.tapCount == 2) {
						[obj touchesDoubleTappedAtLocation:touchLocation];
					} else {
						[obj touchesBeganAtLocation:touchLocation];
						[currentObjectsTouching setObject:obj forKey:[NSNumber numberWithInt:[touch hash]]];
						isTouchScrolling = NO;
					}					
					break;
				}
			}
		}
	}
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
    // Loop through all the touches
	for (UITouch *touch in touches) {
		CGPoint originalTouchLocation = [touch locationInView:aView];
		CGPoint previousOrigTouchLocation = [touch previousLocationInView:aView];
		CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:visibleScreenBounds];
		CGPoint prevTouchLocation = [sharedGameController adjustTouchOrientationForTouch:previousOrigTouchLocation inScreenBounds:visibleScreenBounds];

		if (movingTouchHash == [touch hash]) {
			currentTouchLocation = touchLocation;
		}
		
		TouchableObject* currentObj = [currentObjectsTouching objectForKey:[NSNumber numberWithInt:[touch hash]]];
		if (currentObj) {
			[currentObj touchesMovedToLocation:touchLocation from:prevTouchLocation];
		}
    }
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
	[self touchesEnded:touches withEvent:event view:aView];
}


- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
	for (UITouch *touch in touches) {
		CGPoint originalTouchLocation = [touch locationInView:aView];
		CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:visibleScreenBounds];
		
		TouchableObject* currentObj = [currentObjectsTouching objectForKey:[NSNumber numberWithInt:[touch hash]]];
		if (currentObj) {
			[currentObj touchesEndedAtLocation:touchLocation];
			[currentObjectsTouching removeObjectForKey:[NSNumber numberWithInt:[touch hash]]];
		}
		
		if ([touch hash] == movingTouchHash) {
			currentTouchLocation = touchLocation;
			isTouchScrolling = NO;
			movingTouchHash = 0;
			return;
		}
	}
}

@end
