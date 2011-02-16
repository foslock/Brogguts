//
//  ParticleSingleton.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>

enum ParticleTypes {
	kParticleTypeBroggut,
	kParticleTypeLaser,
	kParticleTypeShipParts,
	kParticleTypeShipThruster,
	kParticleTypeBuildLocation,
};

#define PARTICLE_EMITTER_COUNT 5
#define PARTICLE_TYPE_COUNT 5

@interface ParticleSingleton : NSObject {
	NSMutableArray* particleEmitterArray;
}

+ (ParticleSingleton*)sharedParticleSingleton;

- (void)updateParticlesWithDelta:(GLfloat)aDelta;
- (void)renderParticlesWithScroll:(Vector2f)scroll;

- (void)createParticles:(int)count withType:(int)particleType atLocation:(CGPoint)location;

@end
