//
//  ParticleSingleton.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PARTICLE_EMITTER_COUNT 5
#define PARTICLE_TYPE_COUNT 5

enum ParticleTypes {
	kParticleTypeBroggut,
	kParticleTypeSpark,
	kParticleTypeShipParts,
	kParticleTypeShipThruster,
	kParticleTypeBuildLocation,
};

@interface ParticleSingleton : NSObject {
	NSMutableArray* particleEmitterArray;
}

+ (ParticleSingleton*)sharedParticleSingleton;

- (void)updateParticlesWithDelta:(GLfloat)aDelta;
- (void)renderParticlesWithScroll:(Vector2f)scroll;

- (void)createParticles:(int)count withType:(int)particleType atLocation:(CGPoint)location;

@end
