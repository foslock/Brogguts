//
//  ParticleSingleton.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "ParticleSingleton.h"
#import "ParticleEmitter.h"

static const NSString* kParticleTypeFileName[PARTICLE_TYPE_COUNT] = {
	@"broggutParticle.pex",
	@"laserParticle.pex",
	@"shipPartsParticle.pex",
	@"shipThrusterParticle.pex",
	@"buildLocationParticle.pex",
};

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
		NSMutableArray* tempOuterArray = [[NSMutableArray alloc] init];
		for (int j = 0; j < PARTICLE_TYPE_COUNT; j++) {
			NSMutableArray* tempInnerArray = [[NSMutableArray alloc] init];
			for (int i = 0; i < PARTICLE_EMITTER_COUNT; i++) {
				ParticleEmitter* emitter = [[ParticleEmitter alloc] initParticleEmitterWithFile:kParticleTypeFileName[j]];
				[tempInnerArray addObject:emitter];
				[emitter release];
			}
			[tempOuterArray addObject:tempInnerArray];
			[tempInnerArray release];
		}
		
		particleEmitterArray = tempOuterArray;
	}
	return self;
}

- (void)updateParticlesWithDelta:(GLfloat)aDelta {
	for (int i = 0; i < [particleEmitterArray count]; i++) {
		NSArray* partArray = [particleEmitterArray objectAtIndex:i];
		for (int j = 0; j < [partArray count]; j++) {
			ParticleEmitter* emitter = [partArray objectAtIndex:j];
			if (emitter.active)
				[emitter updateWithDelta:aDelta];
		}
	}
}

- (void)renderParticlesWithScroll:(Vector2f)scroll {
	for (int i = 0; i < [particleEmitterArray count]; i++) {
		NSArray* partArray = [particleEmitterArray objectAtIndex:i];
		for (int j = 0; j < [partArray count]; j++) {
			ParticleEmitter* emitter = [partArray objectAtIndex:j];
			if (emitter.active)
				[emitter renderParticlesWithScroll:scroll];
		}
	}
}

- (void)createParticles:(int)count withType:(int)particleType atLocation:(CGPoint)location {
	if (particleType >= PARTICLE_TYPE_COUNT) {
		NSLog(@"That particle type is invalid");
		return;
	}
	NSArray* partArray = [particleEmitterArray objectAtIndex:particleType];
	for (int i = 0; i < [partArray count]; i++) {
		ParticleEmitter* emitter = [partArray objectAtIndex:i];
		if (emitter.active)
			continue;
		else {
			[emitter setSourcePosition:Vector2fMake(location.x, location.y)];
			[emitter setParticleCount:count];
			emitter.active = YES;
			return;
		}
	}
}

@end
