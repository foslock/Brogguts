//
//  ParticleEmitter.m
//  SLQTSOR
//
//  Created by Michael Daley on 17/04/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//
// The design and code for the ParticleEmitter were heavely influenced by the design and code
// used in Cocos2D for their particle system.

#import "ParticleEmitter.h"
#import "GameController.h"
#import "Image.h"
#import "TBXML.h"
#import "TBXMLParticleAdditions.h"
#import "ParticleSingleton.h"

#pragma mark -
#pragma mark Private interface

@interface ParticleEmitter (Private)

// Adds a particle from the particle pool to the emitter
- (BOOL)addParticleWithPosition:(CGPoint)location;

// Set up the arrays that are going to store our particles
- (void)setupArrays;

@end

#pragma mark -
#pragma mark Public implementation

@implementation ParticleEmitter

@synthesize active;
@synthesize particleCount;

- (void)dealloc {
	
	// Release the memory we are using for our vertex and particle arrays etc
	// If vertices or particles exist then free them
	if (vertices) 
		free(vertices);
	if (particles)
		free(particles);
	
	if(texture)
		[texture release];
	
	// Release the VBOs created
	glDeleteBuffers(1, &verticesID);
	
	[super dealloc];
}

- (id)initParticleEmitterWithParticleID:(int)particleID {
	self = [super init];
	if (self) {
		
		sharedGameController = [GameController sharedGameController];
		active = NO;
		particleType = particleID;
		blendAdditive = NO;
		
		switch (particleID) {
			case kParticleTypeBroggut:
				texture = [[Image alloc] initWithImageNamed:@"particlebroggut.png" filter:GL_LINEAR];
				break;
			case kParticleTypeShipParts:
				texture = [[Image alloc] initWithImageNamed:@"particleshippart.png" filter:GL_LINEAR];
				break;
			case kParticleTypeShipThruster:
				texture = [[Image alloc] initWithImageNamed:@"particleshipthruster.png" filter:GL_LINEAR];
				blendAdditive = YES;
				break;
			default:
				texture = nil;
				break;
		}

		[self setupArrays];
		
	}
	return self;
}

- (void)updateWithDelta:(GLfloat)aDelta {
	
	// Reset the particle index before updating the particles in this emitter
	particleIndex = 0;
	
	// Loop through all the particles updating their location and color
	while(particleIndex < particleCount) {
		
		// Get the particle for the current particle index
		Particle *currentParticle = &particles[particleIndex];
		
		// If the current particle is alive then update it
		if( currentParticle->timeToLive > 0 && 
		   currentParticle->particleSize > 0.0f &&
		   currentParticle->color.alpha > 0.0f) {
			
			// Update particle position
			currentParticle->position.x += currentParticle->velocity.x;
			currentParticle->position.y += currentParticle->velocity.y;
			
			// Update the particles color
			currentParticle->color.red += currentParticle->deltaColor.red;
			currentParticle->color.green += currentParticle->deltaColor.green;
			currentParticle->color.blue += currentParticle->deltaColor.blue;
			currentParticle->color.alpha += currentParticle->deltaColor.alpha;
			
			// Reduce the life span of the particle
			currentParticle->timeToLive -= aDelta;
			
			// Place the position of the current particle into the vertices array
			vertices[particleIndex].x = currentParticle->position.x;
			vertices[particleIndex].y = currentParticle->position.y;
			
			// Place the size of the current particle in the size array
			currentParticle->particleSize += currentParticle->particleSizeDelta;
			vertices[particleIndex].size = MAX(0, currentParticle->particleSize);
			
			// Place the color of the current particle into the color array
			vertices[particleIndex].color = currentParticle->color;
			
			// Update the particle counter
			particleIndex++;
		} else {
			// Make sure all the values are zeroed
			currentParticle->timeToLive = 0;
			currentParticle->particleSize = 0.0f;
			currentParticle->color = Color4fMake(1.0f, 1.0f, 1.0f, 0.0f);
			
			// As the particle is not alive anymore replace it with the last active particle 
			// in the array and reduce the count of particles by one.  This causes all active particles
			// to be packed together at the start of the array so that a particle which has run out of
			// life will only drop into this clause once
			if(particleIndex != particleCount - 1)
				particles[particleIndex] = particles[particleCount - 1];
			particleCount--;
		}
	}
	if (particleCount == 0) {
		active = NO;
	}
}

- (void)renderParticlesWithScroll:(Vector2f)scroll {
	if (particleType == kParticleTypeBroggut ||
		particleType == kParticleTypeShipParts ||
		particleType == kParticleTypeShipThruster) {
		// Disable the texture coord array so that texture information is not copied over when rendering
		// the point sprites.
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		
		// Bind to the verticesID VBO and popuate it with the necessary vertex & color informaiton
		glBindBuffer(GL_ARRAY_BUFFER, verticesID);
		glBufferData(GL_ARRAY_BUFFER, sizeof(PointSprite) * MAXIMUM_PARTICLE_COUNT, vertices, GL_DYNAMIC_DRAW);
		
		// Configure the vertex pointer which will use the currently bound VBO for its data
		glVertexPointer(2, GL_FLOAT, sizeof(PointSprite), 0);
		glColorPointer(4,GL_FLOAT,sizeof(PointSprite),(GLvoid*) (sizeof(GLfloat)*3));
		
		// Bind to the particles texture
		glBindTexture(GL_TEXTURE_2D, texture.textureName);
		
		// Enable the point size array
		glEnableClientState(GL_POINT_SIZE_ARRAY_OES);
		
		// Configure the point size pointer which will use the currently bound VBO.  PointSprite contains
		// both the location of the point as well as its size, so the config below tells the point size
		// pointer where in the currently bound VBO it can find the size for each point
		glPointSizePointerOES(GL_FLOAT,sizeof(PointSprite),(GLvoid*) (sizeof(GLfloat)*2));
		
		// Change the blend function used if blendAdditive has been set
		if(blendAdditive) {
			glBlendFunc(GL_ONE_MINUS_SRC_ALPHA, GL_ONE);
		}
		
		// Enable and configure point sprites which we are going to use for our particles
		glEnable(GL_POINT_SPRITE_OES);
		glTexEnvi( GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE );
		glPushMatrix();
		
		// Translate for scroll vector
		glTranslatef(-scroll.x, -scroll.y, 0.0f);
		
		// Now that all of the VBOs have been used to configure the vertices, pointer size and color
		// use glDrawArrays to draw the points
		glDrawArrays(GL_POINTS, 0, particleCount);
		
		glPopMatrix();
		// Unbind the current VBO
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		
		// Disable the client states which have been used incase the next draw function does 
		// not need or use them
		glDisableClientState(GL_POINT_SIZE_ARRAY_OES);
		glDisable(GL_POINT_SPRITE_OES);
		
		if(blendAdditive) {
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		}
		
		// Re-enable the texture coordinates as we use them elsewhere in the game and it is expected that
		// its on
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	} else if (particleType == kParticleTypeBuildLocation ||
			   particleType == kParticleTypeSpark) {
		// Draw each particle as a line
		enablePrimitiveDraw();
		for (int i = 0; i < particleCount; i++) {
			Particle* particle = &particles[i];
			CGPoint toPoint = CGPointMake(particle->position.x, particle->position.y);
			CGPoint fromPoint = CGPointMake(particle->position.x - (particle->velocity.x * PARTICLE_PRIMITIVE_SCALE),
											particle->position.y - (particle->velocity.y * PARTICLE_PRIMITIVE_SCALE));
			glColor4f(particle->color.red, particle->color.green, particle->color.blue, particle->color.alpha);
			glLineWidth(particle->particleSize);
			drawLine(fromPoint, toPoint, scroll);
		}
		glLineWidth(1.0f);
		disablePrimitiveDraw();
	}
}

- (void)addParticles:(int)count atLocation:(CGPoint)location {
	active = YES;
	for (int i = 0; i < count; i++) {
		[self addParticleWithPosition:location];
	}
}

@end

#pragma mark -
#pragma mark Private implementation

@implementation ParticleEmitter (Private)

- (BOOL)addParticleWithPosition:(CGPoint)location {
	
	// If we have already reached the maximum number of particles then do nothing
	if(particleCount == MAXIMUM_PARTICLE_COUNT)
		return NO;
	
	// Take the next particle out of the particle pool we have created and initialize it
	Particle *particle = &particles[particleCount];
	switch (particleType) {
		case kParticleTypeBroggut:
			particle->position = Vector2fMake(location.x, location.y);
			particle->velocity = Vector2fMake(RANDOM_MINUS_1_TO_1() / 4, RANDOM_MINUS_1_TO_1() / 4);
			particle->color = Color4fMake(1.0f, 1.0f, 1.0f, 1.0f);
			particle->deltaColor = Color4fMake(0.0f, 0.0f, 0.0f, -0.01f);
			particle->timeToLive = 200;
			particle->particleSize = 32.0f;
			particle->particleSizeDelta = 0.0f;
			break;
		case kParticleTypeSpark:
			particle->position = Vector2fMake(location.x, location.y);
			particle->velocity = Vector2fMake(RANDOM_MINUS_1_TO_1(), RANDOM_MINUS_1_TO_1());
			particle->timeToLive = 200;
			particle->color = Color4fMake(1.0f, 1.0f, 1.0f, 1.0f);
			particle->deltaColor = Color4fMake(0.0f, 0.0f, 0.0f, -0.01f);
			particle->particleSize = 1.0f;
			particle->particleSizeDelta = 0.0f;
			break;
		case kParticleTypeShipThruster:
			particle->position = Vector2fMake(location.x, location.y);
			particle->velocity = Vector2fZero;
			particle->timeToLive = 200;
			particle->color = Color4fMake(0.5f, 0.5f, 1.0f, 1.0f);
			particle->deltaColor = Color4fMake(-0.01f, -0.01f, 0.0f, 0.0f);
			particle->particleSize = 16.0f;
			particle->particleSizeDelta = -0.1f;
			break;
		default:
			return NO;
			break;
	}
	
	// Increment the particle count
	particleCount++;
	
	// Return YES to show that a particle has been created
	return YES;
}

- (void)setupArrays {
	// Allocate the memory necessary for the particle emitter arrays
	particles = malloc( sizeof(Particle) * MAXIMUM_PARTICLE_COUNT);
	vertices = malloc( sizeof(PointSprite) * MAXIMUM_PARTICLE_COUNT);
	
	// If one of the arrays cannot be allocated throw an assertion as this is bad
	NSAssert(particles && vertices, @"ERROR - ParticleEmitter: Could not allocate arrays.");
	
	// Generate the vertices VBO
	glGenBuffers(1, &verticesID);
	
	// By default the particle emitter is NOT active when created
	active = NO;
	
	// Set the particle count to zero
	particleCount = 0;
}

@end

