//
//  BroggutSingleton.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/8/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "StarSingleton.h"
#import "GameController.h"
#import "Image.h"
#import "GameplayConstants.h"
#import "Global.h"

static StarSingleton* sharedStarinstance = nil;

@implementation StarSingleton

// SINGLETON STUFF

+ (StarSingleton*)sharedStarSingleton
{
#ifdef STARS
	@synchronized (self) {
		if (sharedStarinstance == nil) {
			[[self alloc] initWithSmallBroggutCapacity:INITIAL_NUMBER_OF_STARS];
		}
	}
	return sharedStarinstance;
#else
	return nil;
#endif
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharedStarinstance == nil) {
			sharedStarinstance = [super allocWithZone:zone];
			return sharedStarinstance;
		}
	}
	
	return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (void)release
{
	// do nothing
}

- (id)autorelease
{
	return self;
}

- (NSUInteger)retainCount
{
	return NSUIntegerMax; // This is sooo not zero
}

// REAL METHODS

- (void)dealloc {
	
	// Release the memory we are using for our vertex and particle arrays etc
	// If vertices or particles exist then free them
	if (starArray) 
		free(starArray);
	if (starVertices)
		free(starVertices);
	
	[starTextureArray release];
	
	// Release the VBOs created
	glDeleteBuffers(1, &verticesID);
	
	[super dealloc];
}

- (id)initWithSmallBroggutCapacity:(int)capacity {
	self = [super init];
	if (self) {
		starCount = 0;
		starMax = capacity;
		
		sharedGameController = [GameController sharedGameController];
		starTextureArray = [[NSMutableArray alloc] initWithCapacity:INITIAL_NUMBER_OF_STARS];
		
		// Testing star textures
		Image* starImage = [[Image alloc] initWithImageNamed:@"starTexture.png" filter:GL_LINEAR];
		[starTextureArray addObject:starImage];
		[starImage release];
		
		starArray = malloc( starMax * sizeof(*starArray) );
		starVertices = malloc( starMax * sizeof(*starVertices) );
		
		// Generate the smallBroggutsVertices VBO
		glGenBuffers(1, &verticesID);
	}
	return self;
}

- (void)randomizeStars {
	for (int i = 0; i < INITIAL_NUMBER_OF_STARS; i++) {
		int x, y;
		x = kPadScreenLandscapeWidth * RANDOM_0_TO_1();
		y = kPadScreenLandscapeHeight * RANDOM_0_TO_1();
		[self addStarAtLocation:CGPointMake(x, y)];
	}
}

- (void)addStarAtLocation:(CGPoint)location {	
	if (starCount == starMax) {
		// DO NOTHING
		// Too many brogguts on the dance floor
	} else {
		// Turn the broggut at the last index of the array into an active broggut
		int currentStarIndex = starCount;
		
		StarParticle* currentStar = &starArray[currentStarIndex];
		
		currentStar->position = Vector2fMake(location.x, location.y);
		currentStar->distanceValue = RANDOM_0_TO_1();
		currentStar->brightness = kStarBrightnessMin + (RANDOM_0_TO_1() * (kStarBrightnessMax - kStarBrightnessMin));
		currentStar->particleSize = kStarSizeMin + (RANDOM_0_TO_1() * (kStarSizeMax - kStarSizeMin));
		
		if (currentStar->particleSize < kStarBottomLayerSizeMax) {
			// Add star to bottom layer
			currentStar->starLayer = kStarBottomLayerID;
		} else if (currentStar->particleSize < kStarMiddleLayerSizeMax) {
			// Add star to middle layer
			if (starCount % 2 == 0)
				currentStar->starLayer = kStarMiddleLayerID;
			else
				currentStar->starLayer = kStarTopLayerID;
		} else if (currentStar->particleSize < kStarTopLayerSizeMax) {
			// Add star to top layer
			if (starCount % 2 == 0)
				currentStar->starLayer = kStarMiddleLayerID;
			else
				currentStar->starLayer = kStarTopLayerID;
		} else {
			currentStar->starLayer = kStarTopLayerID; // Default to the top layer
		}
		
		StarSprite* currentSprite = &starVertices[currentStarIndex];
		currentSprite->x = location.x;
		currentSprite->y = location.y;
		currentSprite->size = currentStar->particleSize;
		float red = CLAMP(RANDOM_0_TO_1() + 0.65f, 0, 1.0f);
		float green = CLAMP(RANDOM_0_TO_1() + 0.65f, 0, 1.0f);
		float blue = CLAMP(RANDOM_0_TO_1() + 0.65f, 0, 1.0f);
		currentSprite->color = Color4fMake(red, green, blue, ((float)currentStar->brightness) / 100.0f);
		
		starCount++;
	}
}

- (void)scrollStarsWithVector:(Vector2f)moveVector {
	for (int i = 0; i < starCount; i++) {
		StarParticle* currentStar = &starArray[i];
		Vector2f scaledVector = Vector2fZero;
		float distance = currentStar->distanceValue;
		switch (currentStar->starLayer) {
			case kStarTopLayerID:
				scaledVector = Vector2fMultiply(moveVector, 0.01f * distance);
				break;
			case kStarMiddleLayerID:
				scaledVector = Vector2fMultiply(moveVector, 0.20f * distance);
				break;
			case kStarBottomLayerID:
				scaledVector = Vector2fMultiply(moveVector, 0.75f * distance);
				break;
			default:
				break;
		}
		
		currentStar->position = Vector2fAdd(currentStar->position, scaledVector);
		
		if (currentStar->position.x < 0.0f)
			currentStar->position.x += kPadScreenLandscapeWidth;
		if (currentStar->position.x > kPadScreenLandscapeWidth)
			currentStar->position.x -= kPadScreenLandscapeWidth;
		if (currentStar->position.y < 0.0f)
			currentStar->position.y += kPadScreenLandscapeHeight;
		if (currentStar->position.y > kPadScreenLandscapeHeight)
			currentStar->position.y -= kPadScreenLandscapeHeight;
	}
}

- (void)updateStars {
	// Needs to be called to enable the changes made on stars (scrolling, brightness, etc.)
	for (int i = 0; i < starCount; i++) {
		StarParticle* currentStar = &starArray[i];
		StarSprite* currentSprite = &starVertices[i];
		currentSprite->x = currentStar->position.x;
		currentSprite->y = currentStar->position.y;
		currentSprite->size = currentStar->particleSize;
		// currentSprite->color = Color4fMake(1.0f, 1.0f, 1.0f, ((float)currentStar->brightness) / 100.0f);
	}
}

- (void)renderStars {
	// Disable the texture coord array so that texture information is not copied over when rendering
	// the point sprites.
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	// Bind to the verticesID VBO and popuate it with the necessary vertex & color informaiton
	glBindBuffer(GL_ARRAY_BUFFER, verticesID);
	glBufferData(GL_ARRAY_BUFFER, sizeof(StarSprite) * starMax, starVertices, GL_DYNAMIC_DRAW);
	
	// Configure the vertex pointer which will use the currently bound VBO for its data
	glVertexPointer(2, GL_FLOAT, sizeof(StarSprite), 0);
	glColorPointer(4, GL_FLOAT, sizeof(StarSprite),(GLvoid*) (sizeof(GLfloat)*3));
	
	// Bind to the particles texture
	// THIS WILL BE SLOW, ONLY RE-BIND TEXTURE WHEN ABSOLUTELY NECESSARY!
	int textureIndex = (arc4random() % [starTextureArray count]);
	Image* pickedTex = [starTextureArray objectAtIndex:textureIndex];
	glBindTexture(GL_TEXTURE_2D, pickedTex.textureName);
	
	// Enable the point size array
	glEnableClientState(GL_POINT_SIZE_ARRAY_OES);
	
	// Configure the point size pointer which will use the currently bound VBO.  PointSprite contains
	// both the location of the point as well as its size, so the config below tells the point size
	// pointer where in the currently bound VBO it can find the size for each point
	glPointSizePointerOES(GL_FLOAT,sizeof(StarSprite),(GLvoid*) (sizeof(GL_FLOAT)*2));
	
	// Enable and configure point sprites which we are going to use for our particles
	glEnable(GL_POINT_SPRITE_OES);
	glTexEnvi( GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE );
	
	// Now that all of the VBOs have been used to configure the vertices, pointer size and color
	// use glDrawArrays to draw the points
	glDrawArrays(GL_POINTS, 0, starCount);
	
	// Unbind the current VBO
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
	// Disable the client states which have been used incase the next draw function does 
	// not need or use them
	glDisableClientState(GL_POINT_SIZE_ARRAY_OES);
	glDisable(GL_POINT_SPRITE_OES);
	
	// Re-enable the texture coordinates as we use them elsewhere in the game and it is expected that
	// its on
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

@end
