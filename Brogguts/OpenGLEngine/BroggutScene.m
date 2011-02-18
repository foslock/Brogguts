//
//  AbstractState.m
//  SLQTSOR
//
//  Created by Michael Daley on 01/06/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "BroggutScene.h"
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
#import "SideBarController.h"
#import "BroggutObject.h"
#import "PlayerProfile.h"
#import "CraftObject.h"
#import "ParticleSingleton.h"

@implementation BroggutScene

@synthesize sceneName;
@synthesize collisionManager;
@synthesize cameraContainRect, cameraLocation;
@synthesize fullMapBounds, visibleScreenBounds;
@synthesize isShowingOverview;
@synthesize controllingShip, commandingShip;
@synthesize homeBaseLocation;

- (void)dealloc {
	if (cameraImage) {
		[cameraImage release];
	}
	[broggutCounter release];
	[controllingShip release];
	[sideBar release];
	[sceneName release];
	[fontArray release];
	[textObjectArray release];
	[currentObjectsTouching release];
	[renderableObjects release];
	[renderableDestroyed release];
	[touchableObjects release];
	[collisionManager release];
	[super dealloc];
}

- (id)initWithScreenBounds:(CGRect)screenBounds withFullMapBounds:(CGRect)mapBounds withName:(NSString*)sName {
	self = [super init];
	if (self) {
		self.sceneName = sName;
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
		
		sideBar = [[SideBarController alloc] initWithLocation:CGPointMake(-SIDEBAR_WIDTH, 0.0f) withWidth:SIDEBAR_WIDTH withHeight:screenBounds.size.height];
		
		// Set up the overview map variables
		isShowingOverview = NO;
		isFadingOverviewIn = NO;
		isFadingOverviewOut = NO;
		overviewAlpha = 0.0f;
		
		// Set up fonts
		fontArray = [[NSMutableArray alloc] initWithCapacity:10];
		BitmapFont* gothic = [[BitmapFont alloc]
							  initWithFontImageNamed:@"gothic.png" controlFile:@"gothic" scale:Scale2fMake(1.0f, 1.0f) filter:GL_LINEAR];
		[fontArray insertObject:gothic atIndex:kFontGothicID];
		BitmapFont* blair = [[BitmapFont alloc]
							 initWithFontImageNamed:@"blair.png" controlFile:@"blair" scale:Scale2fMake(1.0f, 1.0f) filter:GL_LINEAR];
		[fontArray insertObject:blair atIndex:kFontBlairID];
		[gothic release];
		[blair release];
		
		CGPoint middleFontLocation = CGPointMake([self middleOfVisibleScreen].x - [[fontArray objectAtIndex:kFontGothicID] getWidthForString:sceneName] / 2,
												 [self middleOfVisibleScreen].y);
		TextObject* nameObject = [[TextObject alloc]
								  initWithFontID:kFontGothicID Text:sceneName withLocation:middleFontLocation withDuration:5.0f];
		[nameObject setScrollWithBounds:NO];
		[textObjectArray addObject:nameObject];
		[nameObject release];
		
		NSString* brogCount = [NSString stringWithFormat:@"Brogguts: %i",[sharedGameController currentPlayerProfile].broggutCount];
		broggutCounter = [[TextObject alloc]
						  initWithFontID:kFontBlairID Text:brogCount withLocation:CGPointMake(90, visibleScreenBounds.size.height - 32) withDuration:-1.0f];
		[broggutCounter setScrollWithBounds:NO];
		[textObjectArray addObject:broggutCounter];
		
		// Grab an instance of the render manager
		sharedGameController = [GameController sharedGameController];
		sharedImageRenderSingleton = [ImageRenderSingleton sharedImageRenderSingleton];
		sharedSoundSingleton = [SoundSingleton sharedSoundSingleton];
		sharedGameCenterSingleton = [GameCenterSingleton sharedGCSingleton];
		sharedStarSingleton = [StarSingleton sharedStarSingleton];
		sharedParticleSingleton = [ParticleSingleton sharedParticleSingleton];
		[sharedStarSingleton randomizeStars];
		
		frameCounter = 0;
		
		cameraImage = [[Image alloc] initWithImageNamed:@"starTexture.png" filter:GL_LINEAR];
	}
	return self;
}

- (void)addBroggutValue:(int)value atLocation:(CGPoint)location {
	NSString* string = [NSString stringWithFormat:@"+%i Bgs", value];
	float stringWidth = [[fontArray objectAtIndex:kFontBlairID] getWidthForString:string];
	CGPoint newLoc = CGPointMake(CLAMP(location.x - (stringWidth / 2), fullMapBounds.origin.x, fullMapBounds.size.width),
								 CLAMP(location.y + 16, fullMapBounds.origin.y, fullMapBounds.size.height));
	TextObject* obj = [[TextObject alloc] initWithFontID:kFontBlairID Text:string withLocation:newLoc withDuration:2.5f];
	[obj setScrollWithBounds:YES];
	[obj setObjectVelocity:Vector2fMake(0.0f, 0.5f)];
	[textObjectArray addObject:obj];
	[[sharedGameController currentPlayerProfile] addBrogguts:value];
	[obj release];
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

// Used for scrolling the screen with the camera, NOT to be used by other objects
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

// ALL objects should use this to do their scrolled drawing
- (Vector2f)scrollVectorFromScreenBounds {
	return Vector2fMake(visibleScreenBounds.origin.x, visibleScreenBounds.origin.y);
}
- (CGPoint)middleOfVisibleScreen {
	return CGPointMake(visibleScreenBounds.origin.x + (visibleScreenBounds.size.width / 2),
					   visibleScreenBounds.origin.y + (visibleScreenBounds.size.height / 2));
}
- (void)setMiddleOfVisibleScreenToCamera {
	float originX = cameraLocation.x - (visibleScreenBounds.size.width / 2);
	float originY = cameraLocation.y - (visibleScreenBounds.size.height / 2);
	visibleScreenBounds = CGRectMake(CLAMP(originX, 0.0f, fullMapBounds.size.width - visibleScreenBounds.size.width),
									 CLAMP(originY, 0.0f, fullMapBounds.size.height - visibleScreenBounds.size.height), 
									 visibleScreenBounds.size.width,
									 visibleScreenBounds.size.height);
}
- (CGPoint)middleOfEntireMap {
	return CGPointMake(fullMapBounds.origin.x + (fullMapBounds.size.width / 2),
					   fullMapBounds.origin.y + (fullMapBounds.size.height / 2));
}

- (void)updateSceneWithDelta:(GLfloat)aDelta {
	
	// Update the stars' positions and brightness if applicable
	[sharedStarSingleton updateStars];
	
	// Update the particle manager's particles
	[sharedParticleSingleton updateParticlesWithDelta:aDelta];
	
	// Update the camera's location
	if (isTouchScrolling) {
		[controllingShip accelerateTowardsLocation:currentTouchLocation];
		cameraLocation = GetMidpointFromPoints(controllingShip.objectLocation, currentTouchLocation);
	} else {
		cameraLocation = controllingShip.objectLocation;
	}
	
	BroggutObject* closestBrog = [collisionManager closestSmallBroggutToLocation:controllingShip.objectLocation];
	if (closestBrog && !closestBrog.destroyNow) {
		if (GetDistanceBetweenPoints(controllingShip.objectLocation, closestBrog.objectLocation) < 75) {
			[self addBroggutValue:closestBrog.broggutValue atLocation:closestBrog.objectLocation];
			[closestBrog setDestroyNow:YES];
			[sharedParticleSingleton createParticles:50 withType:kParticleTypeBroggut atLocation:closestBrog.objectLocation];
		}
	}
	
	// Update the current broggut count
	NSString* brogCount = [NSString stringWithFormat:@"Brogguts: %i",[sharedGameController currentPlayerProfile].broggutCount];
	[broggutCounter setObjectText:brogCount];
	
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
	
	// Update the frame counter used by the scene
	if (++frameCounter >= FRAME_COUNTER_MAX) {
		frameCounter = 0;
	}
	
	// Update side bar
	[sideBar updateSideBar];
	
	// Update alpha of the overview map
	if (isFadingOverviewIn) {
		overviewAlpha += OVERVIEW_FADE_IN_RATE;
	} else if (isFadingOverviewOut) {
		overviewAlpha -= OVERVIEW_FADE_IN_RATE;
		if (overviewAlpha <= 0.0f) {
			isShowingOverview = NO; // Ending fade out
		}
	} else if (!isShowingOverview) {
		overviewAlpha = 0.0f;
	}
	overviewAlpha = CLAMP(overviewAlpha, 0.0f, 1.0f);
	
	// Loop through all text objects and update them
	for (int i = 0; i < [textObjectArray count]; i++) {
		TextObject* tempObj = [textObjectArray objectAtIndex:i];
		[tempObj updateObjectLogicWithDelta:aDelta];
		if (tempObj.destroyNow) {
			[renderableDestroyed addObject:tempObj];
		}
	}
	
	// Loop through all collidable objects and update them
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

- (void)sortRenderableObjectsByLayer {
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"renderLayer"
												  ascending:YES];
	[renderableObjects sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
}

- (void)renderScene {
	
	// Clear the screen
	glClear(GL_COLOR_BUFFER_BIT);
	
	// Get the scroll vector that most images will need to by translated with
	Vector2f scroll = [self scrollVectorFromScreenBounds];
	
	// Rendering stars
	[sharedStarSingleton renderStars];
	
	// Render all of the particles in the manager
	[sharedParticleSingleton renderParticlesWithScroll:scroll];
	
	enablePrimitiveDraw();
	// Draw the grid that collisions are based off of
	[collisionManager drawCellGridAtPoint:[self middleOfEntireMap] withScale:Scale2fMake(1.0f, 1.0f) withScroll:scroll withAlpha:0.08f];
	disablePrimitiveDraw();
	
	// Draw the medium/large brogguts
	[collisionManager renderMediumBroggutsInScreenBounds:visibleScreenBounds withScrollVector:scroll];
	
	// Resort the objects so they are drawn in the correct layer
	[self sortRenderableObjectsByLayer];
	
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
	if (closestBrog && GetDistanceBetweenPoints(controllingShip.objectLocation, closestBrog.objectLocation) < 100) {
		enablePrimitiveDraw();
		glColor4f(1.0f, 1.0f, 0.0f, 0.6f);
		drawLine(controllingShip.objectLocation, closestBrog.objectLocation, scroll);
		disablePrimitiveDraw();
	}
	
	// Render the map overview if present
	if (isShowingOverview) {
		[self renderOverviewMapWithAlpha:overviewAlpha];
	} else {
		overviewAlpha = 0.0f;
	}
	
	/*
	 if (isTouchScrolling) {
		glColor4f(0.5f, 0.5f, 0.5f, 1.0f);
		enablePrimitiveDraw();
		drawDashedLine(currentTouchLocation, controllingShip.objectLocation, 16, scroll);
		disablePrimitiveDraw();
	 }
	 */
	
	// Render the sidebar button (and sidebar, if activated)
	[sideBar renderSideBar];
}

- (void)fadeOverviewMapIn {
	if (!isShowingOverview) {
		if (!isFadingOverviewIn) {
			isShowingOverview = YES; // Start the fade in
			isFadingOverviewIn = YES;
			isFadingOverviewOut = NO;
		}
	}
}

- (void)fadeOverviewMapOut {
	if (isShowingOverview) {
		if (!isFadingOverviewOut) {
			isShowingOverview = YES; // Start the fade out 
			isFadingOverviewOut = YES;
			isFadingOverviewIn = NO;
		}
	}
}

- (void)renderOverviewMapWithAlpha:(float)alpha {
	// Disable the color array and switch off texturing
	enablePrimitiveDraw();
	GLfloat vertices[10] = {
		0.0f, 0.0f, // V1
		0.0f, kPadScreenLandscapeHeight, // V2
		kPadScreenLandscapeWidth, 0.0f, // V3
		0.0f, kPadScreenLandscapeHeight, // V4
		kPadScreenLandscapeWidth, kPadScreenLandscapeHeight // V5
	};
	
	// Render the back (black) square at this alpha
	glColor4f(0.0f, 0.0f, 0.0f, CLAMP(alpha, 0.0f, OVERVIEW_MAX_ALPHA));
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 5);
	float xRatio = visibleScreenBounds.size.width / fullMapBounds.size.width;
	float yRatio = visibleScreenBounds.size.height / fullMapBounds.size.height;
	
	CGPoint relativeMiddle = CGPointMake(kPadScreenLandscapeWidth / 2, kPadScreenLandscapeHeight / 2);
	[collisionManager drawCellGridAtPoint:relativeMiddle withScale:Scale2fMake(xRatio, yRatio) withScroll:Vector2fZero withAlpha:CLAMP(alpha - 0.5f, 0.0f, 0.1f)];
	
	// Render each object as a point (sprite?) on the overview map
	GLfloat objPoint[2];
	for (int i = 0; i < [renderableObjects count]; i++) {
		CollidableObject* obj = [renderableObjects objectAtIndex:i];
		objPoint[0] = obj.objectLocation.x * xRatio;
		objPoint[1] = obj.objectLocation.y * yRatio;
		if (obj.objectType == kObjectBroggutSmallID)
			glColor4f(1.0f, 1.0f, 0.0f, alpha);
		else
			glColor4f(0.0f, 1.0f, 0.0f, alpha);
		glVertexPointer(2, GL_FLOAT, 0, objPoint);
		glDrawArrays(GL_POINTS, 0, 1);
	}
	
	// Draw the medium broggut grid
	BroggutArray* brogArray = [collisionManager broggutArray];
	int cellsWide, cellsHigh;
	cellsWide = brogArray->bWidth;
	cellsHigh = brogArray->bHeight;
	glColor4f(1.0f, 1.0f, 1.0f, CLAMP(alpha, 0.0f, 0.1f));
	for (int j = 0; j < cellsHigh; j++) {
		for (int i = 0; i < cellsWide; i++) {
			int straightIndex = i + (j * cellsWide);
			MediumBroggut* broggut = &brogArray->array[straightIndex];
			CGRect brogRect = CGRectMake(1 + i * COLLISION_CELL_WIDTH * xRatio,
										 1 + j * COLLISION_CELL_HEIGHT * yRatio,
										 COLLISION_CELL_WIDTH * xRatio, 
										 COLLISION_CELL_HEIGHT * yRatio);
			if (broggut->broggutValue != -1) {
				if (broggut->broggutEdge == kMediumBroggutEdgeNone) {
					glColor4f(1.0f, 1.0f, 1.0f, CLAMP(alpha * 0.1f, 0.0f, 1.0f));
				} else {
					glColor4f(1.0f, 1.0f, 1.0f, CLAMP(alpha * 0.15f, 0.0f, 1.0f));
				}
				drawFilledRect(brogRect, Vector2fZero);
			}
		}
	}
	
	CGRect viewportRect = CGRectMake(visibleScreenBounds.origin.x * xRatio,
									 visibleScreenBounds.origin.y * yRatio,
									 visibleScreenBounds.size.width * xRatio,
									 visibleScreenBounds.size.height * yRatio);
	glColor4f(1.0f, 1.0f, 1.0f, alpha);
	
	drawRect(viewportRect, Vector2fZero);
	
	// Switch the color array back on and enable textures.  This is the default state
	// for our game engine
	disablePrimitiveDraw();
}

- (void)addSmallBrogguts:(int)number inBounds:(CGRect)bounds withLocationArray:(NSArray*)locationArray {
	for (int i = 0; i < number; i++) {
		CGPoint curPoint;
		if ([locationArray count] != 0) {
			int randomIndex = arc4random() % [locationArray count];
			NSArray* numberArray = [locationArray objectAtIndex:randomIndex];
			curPoint = CGPointMake([[numberArray objectAtIndex:0] floatValue],
								   [[numberArray objectAtIndex:1] floatValue]);
		} else {
			curPoint = CGPointMake(RANDOM_0_TO_1() * bounds.size.width,
								   RANDOM_0_TO_1() * bounds.size.height);
		}
		
		Image* rockImage = [[Image alloc] initWithImageNamed:kObjectBroggutSmallSprite filter:GL_LINEAR];
		float randomDarkness = CLAMP(RANDOM_0_TO_1() + 0.2f, 0.0f, 0.8f);
		[rockImage setColor:Color4fMake(randomDarkness, randomDarkness, randomDarkness, 1.0f)];
		BroggutObject* tempObj = [[BroggutObject alloc]
								  initWithImage:rockImage
								  withLocation:CGPointMake(curPoint.x + RANDOM_MINUS_1_TO_1() * (COLLISION_CELL_WIDTH / 2),
														   curPoint.y + RANDOM_MINUS_1_TO_1() * (COLLISION_CELL_HEIGHT / 2))
								  withObjectType:kObjectBroggutSmallID];
		tempObj.objectRotation = 360 * RANDOM_0_TO_1();
		tempObj.rotationSpeed = RANDOM_MINUS_1_TO_1() * kBroggutSmallMaxRotationSpeed;
		tempObj.objectVelocity = Vector2fMake(RANDOM_MINUS_1_TO_1() * ((float)kBroggutSmallMaxVelocity / 100.0f),
											  RANDOM_MINUS_1_TO_1() * ((float)kBroggutSmallMaxVelocity / 100.0f));
		
		int rarityFactor = arc4random() % kBroggutRarityBase;
		if (rarityFactor > (kBroggutRarityBase - kBroggutYoungRarity)) {
			tempObj.broggutValue = kBroggutYoungSmallMinValue + (arc4random() % (kBroggutYoungSmallMaxValue - kBroggutYoungSmallMinValue));
		} else if (rarityFactor > (kBroggutRarityBase - (kBroggutOldRarity + kBroggutYoungRarity))) {
			tempObj.broggutValue = kBroggutOldSmallMinValue + (arc4random() % (kBroggutOldSmallMaxValue - kBroggutOldSmallMinValue));
		} else {
			tempObj.broggutValue = kBroggutAncientSmallMinValue + (arc4random() % (kBroggutAncientSmallMaxValue - kBroggutAncientSmallMinValue));
		}
		
		[collisionManager addCollidableObject:tempObj];
		[renderableObjects insertObject:tempObj atIndex:0]; // Insert the broggut at the beginning so it is rendered first
		[tempObj release];
		[rockImage release];
	}
}

- (void)addTouchableObject:(TouchableObject*)obj withColliding:(BOOL)collides {
	if (collides) {
		[collisionManager addCollidableObject:obj]; // Adds to the collision detection
	}
	[renderableObjects addObject:obj];			// Adds to the rendering queue
	[touchableObjects addObject:obj];			// Adds to the touchable queue
}

- (void)setControllingShip:(CraftObject *)craft {
	[controllingShip setIsBeingControlled:NO];
	[controllingShip autorelease];
	controllingShip = [craft retain];
	[craft setIsBeingControlled:YES];
}

- (void)attemptToControlShipAtLocation:(CGPoint)location {
	for (int i = 0; i < [touchableObjects count]; i++) {
		TouchableObject* object = [touchableObjects objectAtIndex:i];
		if ([object isKindOfClass:[CraftObject class]]) {
			// Object is a craft
			if (object == controllingShip) {
				continue;
			}
			if (CircleContainsPoint(object.boundingCircle, location)) {
				NSLog(@"Set controlling ship to object (%i)", object.uniqueObjectID);
				[self setControllingShip:(CraftObject*)object];
				break;
			}
		}
	}
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
	for (UITouch *touch in touches) {
		// Get the point where the player has touched the screen
        CGPoint originalTouchLocation = [touch locationInView:aView];
        CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:visibleScreenBounds];
		
		// Check if the touch is in the (active) sidebar
		if (CGRectContainsPoint([sideBar sideBarRect], [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero])) {
			if ([sideBar isSideBarShowing]) {
				if (touch.tapCount == 2) {
					[sideBar touchesDoubleTappedAtLocation:[sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero]];
				} else {
					[sideBar touchesBeganAtLocation:[sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero]];
				}
			}
			break;
		}
		
		// Check if there are more than 1 touches (bring up overview)
		if ([touches count] >= 2) {
			if (!isShowingOverview)
				[self fadeOverviewMapIn];
			else
				[self fadeOverviewMapOut];
			break;
		}
		
        // Check if the touch is in the button to bring out the sidebar
		if (CGRectContainsPoint([sideBar buttonRect], [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero])) {
			if (![sideBar isSideBarShowing]) {
				[sideBar moveSideBarIn];
			} else {
				[sideBar moveSideBarOut];
			}
			break;
		}
		
		// If it is somewhere else, scroll using this touch
		if ([currentObjectsTouching count] == 0 && isTouchScrolling == NO && (!isShowingOverview || isFadingOverviewOut)) {
			isTouchScrolling = YES;
			movingTouchHash = [touch hash];
			currentTouchLocation = touchLocation;
			/*
			
			*/
		}
		BOOL noObjectTouched = YES;
		// Check all touchable objects and call their methods
		for (int i = 0; i < [touchableObjects count]; i++) {
			TouchableObject* obj = [touchableObjects objectAtIndex:i];
			if (obj.isTouchable) {
				if (CircleContainsPoint(obj.touchableBounds, touchLocation)) {
					if (!obj.isCurrentlyTouched) {
						if (touch.tapCount == 2) {
							[obj touchesDoubleTappedAtLocation:touchLocation];
						} else {
							[obj touchesBeganAtLocation:touchLocation];
							[currentObjectsTouching setObject:obj forKey:[NSNumber numberWithInt:[touch hash]]];
							if ([touches count] == 1) isTouchScrolling = NO;
						}
						noObjectTouched = NO;
						break;
					}
				}
			}
		}
		
		if (noObjectTouched) { // If touch used for scrolling, stop the current path
			if (!CircleContainsPoint(controllingShip.boundingCircle, touchLocation)) {
				[controllingShip stopFollowingCurrentPath];
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
		
		// Check if the touch is in the (active) sidebar
		if (CGRectContainsPoint([sideBar sideBarRect], [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero])) {
			if ([sideBar isSideBarShowing] && movingTouchHash != [touch hash]) {
				CGPoint toPoint = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero];
				CGPoint fromPoint = [sharedGameController adjustTouchOrientationForTouch:previousOrigTouchLocation inScreenBounds:CGRectZero];
				[sideBar touchesMovedToLocation:toPoint from:fromPoint];
				break;
			}
		}
		
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
		
		// Check if the touch is in the (active) sidebar
		if (CGRectContainsPoint([sideBar sideBarRect], [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero])) {
			if ([sideBar isSideBarShowing] && movingTouchHash != [touch hash]) {
				[sideBar touchesEndedAtLocation:[sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero]];
				break;
			}
		}
		
		if ([touch hash] == movingTouchHash) {
			currentTouchLocation = touchLocation;
			isTouchScrolling = NO;
			movingTouchHash = 0;
		}
	}
}



@end