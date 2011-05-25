//
//  StructureObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/12/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "StructureObject.h"
#import "Image.h"
#import "BroggutScene.h"
#import "CollisionManager.h"
#import "CraftObject.h"
#import "CraftAndStructures.h"
#import "ExplosionObject.h"
#import "ImageRenderSingleton.h"
#import "NotificationObject.h"

@implementation StructureObject
@synthesize attributeHullCurrent;

- (void)initStructureWithID:(int)typeID {
	switch (typeID) {
		case kObjectStructureBaseStationID:
			attributeBroggutCost = kStructureBaseStationCostBrogguts;
			attributeMetalCost = kStructureBaseStationCostMetal;
			attributeHullCapacity = kStructureBaseStationHull;
			attributeHullCurrent = kStructureBaseStationHull;
			attributeMovingTime = kStructureBaseStationMovingTime;
			break;
		case kObjectStructureBlockID:
			attributeBroggutCost = kStructureBlockCostBrogguts;
			attributeMetalCost = kStructureBlockCostMetal;
			attributeHullCapacity = kStructureBlockHull;
			attributeHullCurrent = kStructureBlockHull;
			attributeMovingTime = kStructureBlockMovingTime;
			break;
		case kObjectStructureRefineryID:
			attributeBroggutCost = kStructureRefineryCostBrogguts;
			attributeMetalCost = kStructureRefineryCostMetal;
			attributeHullCapacity = kStructureRefineryHull;
			attributeHullCurrent = kStructureRefineryHull;
			attributeMovingTime = kStructureRefineryMovingTime;
			break;
		case kObjectStructureCraftUpgradesID:
			attributeBroggutCost = kStructureCraftUpgradesCostBrogguts;
			attributeMetalCost = kStructureCraftUpgradesCostMetal;
			attributeHullCapacity = kStructureCraftUpgradesHull;
			attributeHullCurrent = kStructureCraftUpgradesHull;
			attributeMovingTime = kStructureCraftUpgradesMovingTime;
			break;
		case kObjectStructureStructureUpgradesID:
			attributeBroggutCost = kStructureStructureUpgradesCostBrogguts;
			attributeMetalCost = kStructureStructureUpgradesCostMetal;
			attributeHullCapacity = kStructureStructureUpgradesHull;
			attributeHullCurrent = kStructureStructureUpgradesHull;
			attributeMovingTime = kStructureStructureUpgradesMovingTime;
			break;
		case kObjectStructureTurretID:
			attributeBroggutCost = kStructureTurretCostBrogguts;
			attributeMetalCost = kStructureTurretCostMetal;
			attributeHullCapacity = kStructureTurretHull;
			attributeHullCurrent = kStructureTurretHull;
			attributeMovingTime = kStructureTurretMovingTime;
			break;
		case kObjectStructureRadarID:
			attributeBroggutCost = kStructureRadarCostBrogguts;
			attributeMetalCost = kStructureRadarCostMetal;
			attributeHullCapacity = kStructureRadarHull;
			attributeHullCurrent = kStructureRadarHull;
			attributeMovingTime = kStructureRadarMovingTime;
			break;
		case kObjectStructureFixerID:
			attributeBroggutCost = kStructureFixerCostBrogguts;
			attributeMetalCost = kStructureFixerCostMetal;
			attributeHullCapacity = kStructureFixerHull;
			attributeHullCurrent = kStructureFixerHull;
			attributeMovingTime = kStructureFixerMovingTime;
			break;
		default:
			break;
	}
}

- (id)initWithTypeID:(int)typeID withLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	Image* image;
	switch (typeID) {
		case kObjectStructureBaseStationID:
			image = [[Image alloc] initWithImageNamed:kObjectStructureBaseStationSprite filter:GL_LINEAR];
			break;
		case kObjectStructureBlockID:
			image = [[Image alloc] initWithImageNamed:kObjectStructureBlockSprite filter:GL_LINEAR];
			break;
		case kObjectStructureRefineryID:
			image = [[Image alloc] initWithImageNamed:kObjectStructureRefinerySprite filter:GL_LINEAR];
			break;
		case kObjectStructureCraftUpgradesID:
			image = [[Image alloc] initWithImageNamed:kObjectStructureCraftUpgradesSprite filter:GL_LINEAR];
			break;
		case kObjectStructureStructureUpgradesID:
			image = [[Image alloc] initWithImageNamed:kObjectStructureStructureUpgradesSprite filter:GL_LINEAR];
			break;
		case kObjectStructureTurretID:
			image = [[Image alloc] initWithImageNamed:kObjectStructureTurretSprite filter:GL_LINEAR];
			break;
		case kObjectStructureRadarID:
			image = [[Image alloc] initWithImageNamed:kObjectStructureRadarSprite filter:GL_LINEAR];
			break;
		case kObjectStructureFixerID:
			image = [[Image alloc] initWithImageNamed:kObjectStructureFixerSprite filter:GL_LINEAR];
			break;
		default:
            image = [[Image alloc] initWithImageNamed:kObjectStructureBlockSprite filter:GL_LINEAR]; // Default to block
			break;
	}
	self = [super initWithImage:image withLocation:location withObjectType:typeID];
    [image release];
	if (self) {
		staticObject = YES;
		isTouchable = YES;
		isCheckedForMultipleCollisions = YES;
		isCheckedForRadialEffect = YES;
		pathPointArray = nil;
		pathPointNumber = 0;
		isFollowingPath = NO;
        isDirtyImage = NO;
		hasCurrentPathFinished = YES;
		creationEndLocation = location;
        
        lightBlinkTimer = (arc4random() % LIGHT_BLINK_FREQUENCY) + 1;
		lightBlinkAlpha = 0.0f;
		blinkingLightImage = [[Image alloc] initWithImageNamed:@"defaultTexture.png" filter:GL_LINEAR];
		blinkingLightImage.scale = Scale2fMake(0.35f, 0.35f);
        blinkingLightImage.renderLayer = kLayerTopLayer;
        
        buildingDroneImage = [[Image alloc] initWithImageNamed:@"craftbuilddrone.png" filter:GL_LINEAR];
        [buildingDroneImage setRenderLayer:kLayerTopLayer];
		// Initialize the structure
		[self initStructureWithID:typeID];
        [[[self currentScene] collisionManager] setPathNodeIsOpen:NO atLocation:location];
		if (traveling) {
            [[self currentScene] setIsBuildingStructure:YES];
			[self setIsTraveling:YES];
			NSArray* path = [NSArray arrayWithObject:[NSValue valueWithCGPoint:location]];
			[self followPath:path isLooped:NO];
		}
	}
	return self;
}

- (void)dealloc {
    [blinkingLightImage release];
    [buildingDroneImage release];
    [super dealloc];
}

- (void)setCurrentHull:(int)newHull {
	if (newHull >= 0) {
		attributeHullCurrent = CLAMP(newHull, 0, attributeHullCapacity);
	}
}

- (void)drawHoverSelectionWithScroll:(Vector2f)scroll {
	// Draw "selection circle"
    glLineWidth(2.0f);
    if (objectAlliance == kAllianceFriendly) {
        Color4f filled = Color4fMake(0.0f, 1.0f, 0.0f, 1.0f);
        Color4f unfilled = Color4fMake(0.5f, 0.5f, 0.5f, 0.6f);
        drawPartialDashedCircle(self.boundingCircle, attributeHullCurrent, attributeHullCapacity, filled, unfilled, scroll);
    } else {
        Color4f filled = Color4fMake(1.0f, 0.0f, 0.0f, 1.0f);
        Color4f unfilled = Color4fMake(0.5f, 0.5f, 0.5f, 0.6f);
        drawPartialDashedCircle(self.boundingCircle, attributeHullCurrent, attributeHullCapacity, filled, unfilled, scroll);
    }
    glLineWidth(1.0f);
}

- (BOOL)attackedByEnemy:(TouchableObject *)enemy withDamage:(int)damage {
	[super attackedByEnemy:enemy withDamage:damage];
    if (objectAlliance == kAllianceFriendly) {
        NotificationObject* noti = [[NotificationObject alloc] initWithLocation:self.objectLocation withDuration:3.0f];
        [noti attachToObject:self];
        [[self currentScene] setNotification:noti];
        [noti release];
    }
	attributeHullCurrent -= damage;
	if (attributeHullCurrent <= 0) {
		destroyNow = YES;
		return YES;
	}
	return NO;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
	if (attributeHullCurrent <= 0) {
		destroyNow = YES;
		return;
	}
    
    if (attributeHullCurrent <= (attributeHullCapacity / 2)) {
        if (!isDirtyImage) {
            isDirtyImage = YES;
            NSString* fileName = [[objectImage imageFileName] stringByDeletingPathExtension];
            Color4f color = [objectImage color];
            Scale2f scale = [objectImage scale];
            [objectImage autorelease];
            NSString* newName = [NSString stringWithFormat:@"%@dirty.png",fileName];
            Image* newImage = [[Image alloc] initWithImageNamed:newName filter:GL_LINEAR];
            if (newImage) {
                objectImage = newImage;
                [objectImage setColor:color];
                [objectImage setScale:scale];
                [objectImage setRotation:objectRotation];
            } else {
                [objectImage retain];
            }
        }
    }
	
	// Get the current point we should be following
	if (isFollowingPath && pathPointArray && !hasCurrentPathFinished) {
		NSValue* pointValue = [pathPointArray objectAtIndex:pathPointNumber];
		CGPoint moveTowardsPoint = [pointValue CGPointValue];
		// If the structure has reached the point...
		if (AreCGPointsEqual(objectLocation, moveTowardsPoint, 0.1f)) {
			pathPointNumber++;
		}
		if (pathPointNumber < [pathPointArray count]) {
			NSValue* pointValue = [pathPointArray objectAtIndex:pathPointNumber];
			moveTowardsPoint = [pointValue CGPointValue];
		} else {
			if (isPathLooped) {
				pathPointNumber = 0;
			} else {
				isFollowingPath = NO;
				hasCurrentPathFinished = YES;
				[self setMovingAIState:kMovingAIStateStill];
				if (isTraveling) {
                    [[self currentScene] setIsBuildingStructure:NO];
					[self setIsTraveling:NO];
					[[self.currentScene collisionManager] setPathNodeIsOpen:NO atLocation:objectLocation];
				}
			}
		}
		[self moveTowardsLocation:moveTowardsPoint];
	} else {
		// Don't move, has reached target location
		objectVelocity = Vector2fZero;
	}
    
    // Update the light blinking
    if (lightBlinkTimer <= 0) {
        lightBlinkTimer = LIGHT_BLINK_FREQUENCY;
        lightBlinkAlpha = LIGHT_BLINK_BRIGHTNESS;
    } else {
        lightBlinkTimer--;
        if (lightBlinkAlpha > 0) {
            lightBlinkAlpha -= LIGHT_BLINK_FADE_SPEED;
        } else {
            lightBlinkAlpha = 0.0f;
        }
    }
    
	CGPoint oldPoint = objectLocation;
	[super updateObjectLogicWithDelta:aDelta];
    CGPoint newPoint = objectLocation;
    movingDirection = GetAngleInDegreesFromPoints(oldPoint, newPoint);
}

- (void)renderOverObjectWithScroll:(Vector2f)scroll {
    [super renderOverObjectWithScroll:scroll];
    
    if (objectType != kObjectStructureBaseStationID) {
        disablePrimitiveDraw();
        CGPoint topLeft = CGPointMake(objectLocation.x - ([objectImage imageSize].width / 2) + STRUCTURE_LIGHT_INSET,
                                      objectLocation.y + ([objectImage imageSize].height / 2) - STRUCTURE_LIGHT_INSET);
        CGPoint topRight = CGPointMake(objectLocation.x + ([objectImage imageSize].width / 2) - STRUCTURE_LIGHT_INSET,
                                       objectLocation.y + ([objectImage imageSize].height / 2) - STRUCTURE_LIGHT_INSET);
        CGPoint botLeft = CGPointMake(objectLocation.x - ([objectImage imageSize].width / 2) + STRUCTURE_LIGHT_INSET,
                                      objectLocation.y - ([objectImage imageSize].height / 2) + STRUCTURE_LIGHT_INSET);
        CGPoint botRight = CGPointMake(objectLocation.x + ([objectImage imageSize].width / 2) - STRUCTURE_LIGHT_INSET,
                                       objectLocation.y - ([objectImage imageSize].height / 2) + STRUCTURE_LIGHT_INSET);
        if (self.objectAlliance == kAllianceFriendly) {
            if (!isTraveling)
                blinkingLightImage.color = Color4fMake(0.0f, 1.0f, 0.0f, lightBlinkAlpha);
            else
                blinkingLightImage.color = Color4fMake(1.0f, 1.0f, 0.0f, lightBlinkAlpha);
        } else {
            blinkingLightImage.color = Color4fMake(1.0f, 0.0f, 0.0f, lightBlinkAlpha);
        }
        [blinkingLightImage renderCenteredAtPoint:topLeft withScrollVector:scroll];
        [blinkingLightImage renderCenteredAtPoint:topRight withScrollVector:scroll];
        [blinkingLightImage renderCenteredAtPoint:botLeft withScrollVector:scroll];
        [blinkingLightImage renderCenteredAtPoint:botRight withScrollVector:scroll];
    }
    
	if (isCurrentlyHoveredOver && !isBlinkingSelectionCircle) {
        enablePrimitiveDraw();
        [self drawHoverSelectionWithScroll:scroll];
        disablePrimitiveDraw();
    }
}

- (void)renderUnderObjectWithScroll:(Vector2f)scroll {
    [super renderUnderObjectWithScroll:scroll];
    if (isTraveling) {
        CGRect rect = CGRectMake(objectLocation.x - (objectImage.imageSize.width / 2),
                                 objectLocation.y - (objectImage.imageSize.height / 2),
                                 objectImage.imageSize.width,
                                 objectImage.imageSize.height);
        CGPoint point1 = CGPointMake(rect.origin.x, rect.origin.y);
        CGPoint point2 = CGPointMake(rect.origin.x + objectImage.imageSize.width, rect.origin.y);
        CGPoint point3 = CGPointMake(rect.origin.x, rect.origin.y + objectImage.imageSize.height);
        CGPoint point4 = CGPointMake(rect.origin.x + objectImage.imageSize.width, rect.origin.y + objectImage.imageSize.height);
        
        [buildingDroneImage setRotation:movingDirection];
        [buildingDroneImage renderCenteredAtPoint:point1 withScrollVector:scroll];
        [buildingDroneImage renderCenteredAtPoint:point2 withScrollVector:scroll];
        [buildingDroneImage renderCenteredAtPoint:point3 withScrollVector:scroll];
        [buildingDroneImage renderCenteredAtPoint:point4 withScrollVector:scroll];
        enablePrimitiveDraw();
        glColor4f(1.0f, 1.0f, 1.0f, CLAMP(RANDOM_0_TO_1(), 0.25f, 0.75f));
        drawLine(point1, point2, scroll);
        glColor4f(1.0f, 1.0f, 1.0f, CLAMP(RANDOM_0_TO_1(), 0.25f, 0.75f));
        drawLine(point2, point4, scroll);
        glColor4f(1.0f, 1.0f, 1.0f, CLAMP(RANDOM_0_TO_1(), 0.25f, 0.75f));
        drawLine(point4, point3, scroll);
        glColor4f(1.0f, 1.0f, 1.0f, CLAMP(RANDOM_0_TO_1(), 0.25f, 0.75f));
        drawLine(point3, point1, scroll);
        disablePrimitiveDraw();
        
    }
}

- (void)moveTowardsLocation:(CGPoint)location {
	float movingMagnitude = 1.0f / (float)attributeMovingTime;
	if (location.x > objectLocation.x) {
		if (fabs(location.x - objectLocation.x) > movingMagnitude)
			objectVelocity.x = movingMagnitude;
		else
			objectVelocity.x = location.x - objectLocation.x;
	}
	if (location.x < objectLocation.x) {
		if (fabs(location.x - objectLocation.x) > movingMagnitude)
			objectVelocity.x = - movingMagnitude;
		else
			objectVelocity.x = location.x - objectLocation.x;
	}
	if (location.y > objectLocation.y) {
		if (fabs(location.y - objectLocation.y) > movingMagnitude)
			objectVelocity.y = movingMagnitude;
		else
			objectVelocity.y = location.y - objectLocation.y;
	}
	if (location.y < objectLocation.y) {
		if (fabs(location.y - objectLocation.y) > movingMagnitude)
			objectVelocity.y = - movingMagnitude;
		else
			objectVelocity.y = location.y - objectLocation.y;
	}
}

- (void)followPath:(NSArray*)array isLooped:(BOOL)looped {
	if ([array count] == 0) {
		NSLog(@"Path contained no points!");
		return;
	}
	[pathPointArray autorelease];
	pathPointArray = [[NSMutableArray alloc] initWithArray:array];
	isFollowingPath = YES;
	pathPointNumber = 0;
	isPathLooped = looped;
	hasCurrentPathFinished = NO;
}

- (void)stopFollowingCurrentPath {
	isFollowingPath = NO;
	hasCurrentPathFinished = YES;
	[self setMovingAIState:kMovingAIStateStill];
}

- (void)resumeFollowingCurrentPath {
	if (pathPointArray && [pathPointArray count] != 0) {
		isFollowingPath = YES;
		hasCurrentPathFinished = NO;
		[self setMovingAIState:kMovingAIStateMoving];
	}
}

- (void)objectWasDestroyed {
    if (isTraveling) {
        [[self currentScene] setIsBuildingStructure:NO];
    }
    ExplosionObject* explosion = [[ExplosionObject alloc] initWithLocation:objectLocation withSize:kExplosionSizeLarge];
    [self.currentScene addCollidableObject:explosion];
    [explosion release];
    [super objectWasDestroyed];
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
	NSLog(@"Object (%i) was double tapped!", uniqueObjectID);
}

@end
