//
//  ParticleSingleton.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "ParticleSingleton.h"
#import "ParticleEmitter.h"

static ParticleSingleton* sharedPartSingletonInstance = nil;

@implementation ParticleSingleton

#pragma mark -
#pragma mark Singleton implementation

+ (ParticleSingleton*)sharedParticleSingleton
{
	@synchronized (self) {
		if (sharedPartSingletonInstance == nil) {
			[[self alloc] init];
		}
	}
	
	return sharedPartSingletonInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharedPartSingletonInstance == nil) {
			sharedPartSingletonInstance = [super allocWithZone:zone];
			return sharedPartSingletonInstance;
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

// Normal stuff now:

- (void)dealloc {
	[particleEmitterArray release];
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self) {
		NSMutableArray* tempArray = [[NSMutableArray alloc] init];
		for (int j = 0; j < PARTICLE_TYPE_COUNT; j++) {
			ParticleEmitter* emitter = [[ParticleEmitter alloc] initParticleEmitterWithParticleID:j];
			[tempArray addObject:emitter];
			[emitter release];
		}
		particleEmitterArray = tempArray;
	}
	return self;
}

- (void)updateParticlesWithDelta:(GLfloat)aDelta {
	for (int i = 0; i < [particleEmitterArray count]; i++) {
		ParticleEmitter* emitter = [particleEmitterArray objectAtIndex:i];
		if (emitter.active)
			[emitter updateWithDelta:aDelta];
	}
}

- (void)renderParticlesWithScroll:(Vector2f)scroll {
	for (int i = 0; i < [particleEmitterArray count]; i++) {
		ParticleEmitter* emitter = [particleEmitterArray objectAtIndex:i];
		if (emitter.active)
			[emitter renderParticlesWithScroll:scroll];
	}
}

- (void)createParticles:(int)count withType:(int)particleType atLocation:(CGPoint)location {
	if (particleType >= PARTICLE_TYPE_COUNT) {
		NSLog(@"That particle type is invalid");
		return;
	}
		ParticleEmitter* emitter = [particleEmitterArray objectAtIndex:particleType];
		[emitter addParticles:count atLocation:location];
}

@end
