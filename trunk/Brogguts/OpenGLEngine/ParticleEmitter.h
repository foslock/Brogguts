//
//  ParticleEmitter.h
//  SLQTSOR
//
//  Created by Michael Daley on 17/04/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "Global.h"
#import "ParticleSingleton.h"

@class GameController;
@class Image;

// Structure that holds the location and size for each point sprite
typedef struct {
	GLfloat x;
	GLfloat y;
	GLfloat size;
	Color4f color;
} PointSprite;

// Structure used to hold particle specific information
typedef struct {
	Vector2f position;
	Vector2f velocity;
	Color4f color;
	Color4f deltaColor;
	GLfloat particleSize;
	GLfloat particleSizeDelta;
	GLfloat timeToLive;
} Particle;

#define MAXIMUM_UPDATE_RATE 30.0f		// The maximum number of updates that occur per frame
#define MAXIMUM_PARTICLE_COUNT 100		// Maximum number of particles allowed
#define PARTICLE_PRIMITIVE_SCALE 4.0f	// Factor the line particles are scaled by 

// The particleEmitter allows you to define parameters that are used when generating particles.
// These particles are OpenGL particle sprites that based on the parameters provided each have
// their own characteristics such as speed, lifespan, start and end colors etc.  Using these
// particle emitters allows you to create organic looking effects such as smoke, fire and 
// explosions.
//
// The design for this particle emitter was influenced by the point sprite particle system
// used in the Cocos2D game engine
//
@interface ParticleEmitter : NSObject {

	/////////////////// Singleton Managers
	GameController *sharedGameController;
	
	/////////////////// Particle iVars
	Image *texture;
	int particleType;
	BOOL blendAdditive;						// Should the OpenGL Blendmode be additive

	//////////////////// Particle Emitter iVars
	BOOL active;
	GLint particleCount;
	GLint particleIndex;		// Stores the number of particles that are going to be rendered
	
	///////////////////// Render
	GLuint verticesID;			// Holds the buffer name of the VBO that stores the color and vertices info for the particles
	Particle *particles;		// Array of particles that hold the particle emitters particle details
	PointSprite *vertices;		// Array of vertices and color information for each particle to be rendered
	
}

@property(nonatomic, assign) GLint particleCount;
@property(nonatomic, assign) BOOL active;

// Initialises a particle emitter using configuration read from a file
- (id)initParticleEmitterWithParticleID:(int)particleID;

// Adds particles to the emitter
- (void)addParticles:(int)count atLocation:(CGPoint)location;

// Renders the particles for this emitter to the screen
- (void)renderParticlesWithScroll:(Vector2f)scroll;

// Updates all particles in the particle emitter
- (void)updateWithDelta:(GLfloat)aDelta;

@end
