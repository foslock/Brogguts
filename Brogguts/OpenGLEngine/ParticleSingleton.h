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

enum ParticleLayers {
    kParticleLayerBottom,
    kParticleLayerMiddle,
    kParticleLayerTop,
};

extern const int kLayerForParticleType[PARTICLE_TYPE_COUNT];

@interface ParticleSingleton : NSObject {
	NSMutableArray* particleEmitterArray;
}

+ (ParticleSingleton*)sharedParticleSingleton;

- (void)updateParticlesWithDelta:(GLfloat)aDelta;
- (void)renderParticlesOnLayer:(int)layer WithScroll:(Vector2f)scroll;

- (void)resetAllEmitters;
- (void)createParticles:(int)count withType:(int)particleType atLocation:(CGPoint)location;

@end
