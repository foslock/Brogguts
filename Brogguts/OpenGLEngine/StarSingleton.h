//
//  BroggutSingleton.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/8/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GameController;
@class Image;

// Structure that holds the location and size for each point sprite
typedef struct {
	GLfloat x;
	GLfloat y;
	GLfloat size;
	Color4f color;
} StarSprite;

// Structure used to hold particle specific information
typedef struct {
	GLint starLayer; // 0, 1, or 2, each scrolling at different rates
	GLfloat distanceValue;
	Vector2f position;
	GLfloat brightness;
	GLfloat particleSize;
} StarParticle;

#define STAR_TEXTURE_COUNT 1
#define INITIAL_NUMBER_OF_STARS 300

@interface StarSingleton : NSObject {
	GameController* sharedGameController;
	
	NSMutableArray* starTextureArray; // Array containing the textures used for small brogguts
	int starMax;
	int starCount;
	
	GLuint verticesID; // Buffer name of VBO associated with small brogguts
	StarSprite* starVertices; // Array containing the location/point sprite information for small brogguts
	StarParticle* starArray; // Array containing all of the current small brogguts 
}

+ (StarSingleton*)sharedStarSingleton;

- (id)initWithSmallBroggutCapacity:(int)capacity;

- (void)randomizeStars;

- (void)addStarAtLocation:(CGPoint)location;

- (void)scrollStarsWithVector:(Vector2f)moveVector;

- (void)updateStars;

- (void)renderStars;

@end
