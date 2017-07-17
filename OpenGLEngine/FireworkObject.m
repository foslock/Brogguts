//
//  FireworkObject.m
//  OpenGLEngine
//
//  Created by James Lockwood on 1/29/12.
//  Copyright (c) 2012 Games in Dorms. All rights reserved.
//

#import "FireworkObject.h"
#import "ParticleSingleton.h"
#import "ExplosionObject.h"
#import "BroggutScene.h"

#define FIREWORK_DECCELERATION 0.005f

@implementation FireworkObject
@synthesize movingDirection;

- (id)initWithLocation:(CGPoint)point withSubCount:(int)count withDuration:(float)duration withSpeed:(float)speed {
    self = [super initWithImage:nil withLocation:point withObjectType:kObjectFireworkObjectID];
    if (self) {
        isRenderedInOverview = NO;
        isCheckedForCollisions = NO;
        isCheckedForMultipleCollisions = NO;
        objectLocation = point;
        subCount = count;
        movingSpeed = speed;
        fireworkDuration = duration;
        fireworkTimer = duration;
        movingDirection = RANDOM_0_TO_1() * 2 * M_PI; // In radians
        
        objectVelocity = Vector2fMake(movingSpeed * cosf(movingDirection),
                                      movingSpeed * sinf(movingDirection));
    }
    return self;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    
    if (fireworkTimer > 0) {
        fireworkTimer -= aDelta;
    } else {
        [self explodeFirework];
    }
    
    if (movingSpeed > 0) {
        movingSpeed -= FIREWORK_DECCELERATION;
    } else {
        movingSpeed = 0;
    }
    
    objectVelocity = Vector2fMake(movingSpeed * cosf(movingDirection),
                                  movingSpeed * sinf(movingDirection));
    
    
    
    if (arc4random() % 4 == 0) {
        [[ParticleSingleton sharedParticleSingleton] createParticles:1 withType:kParticleTypeSmoke atLocation:objectLocation];
        [[ParticleSingleton sharedParticleSingleton] createParticles:1 withType:kParticleTypeSpark atLocation:objectLocation];
    }
}

- (void)explodeFirework {
    [self setDestroyNow:YES];
    int size = kExplosionSizeSmall;
    if (subCount >= 4) { size = kExplosionSizeMedium; }
    if (subCount >= 8) { size = kExplosionSizeLarge; }
    ExplosionObject* explosion = [[ExplosionObject alloc] initWithLocation:objectLocation withSize:size];
    [[self currentScene] addCollidableObject:explosion];
    [explosion release];
    for (int i = 0; i < subCount; i++) {
        FireworkObject* firework = [[FireworkObject alloc] initWithLocation:objectLocation
                                                               withSubCount:subCount / 4
                                                               withDuration:CLAMP(fireworkDuration - 1.0f, 0.2f, fireworkDuration)
                                                                  withSpeed:0.5f + RANDOM_0_TO_1()];
        [[self currentScene] addCollidableObject:firework];
        [firework release];
    }
}

@end
