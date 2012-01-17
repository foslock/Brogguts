//
//  MissileObject.m
//  OpenGLEngine
//
//  Created by James Lockwood on 1/15/12.
//  Copyright (c) 2012 Games in Dorms. All rights reserved.
//

#import "MissileObject.h"
#import "TouchableObject.h"
#import "Image.h"
#import "ParticleSingleton.h"
#import "ImageRenderSingleton.h"
#import "ExplosionObject.h"
#import "BroggutScene.h"

@implementation MissileObject

- (id)initWithOwner:(TouchableObject*)owner withTarget:(TouchableObject*)target {
    Image* image = [[Image alloc] initWithImageNamed:kObjectMissileSprite filter:GL_LINEAR];
    self = [super initWithImage:image withLocation:owner.objectLocation withObjectType:kObjectMissileObjectID];
    if (self) {
        [self setRenderLayer:kLayerBottomLayer];
        ownerObject = owner;
        targetObject = target;
        detonationLocation = target.objectLocation;
        missileDamage = kCraftBeetleMissileDamage;
    }
    [image release];
    return self;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    
    if (targetObject && !targetObject.destroyNow) {
        detonationLocation = targetObject.objectLocation;
    }
    
    // If target or creator are destroyed make sure this gets taken care of
    if (targetObject.destroyNow) {
        targetObject = nil;
    }
    
    if (ownerObject.destroyNow) {
        ownerObject = nil;
    }
    
    if (GetDistanceBetweenPointsSquared(objectLocation, detonationLocation) < POW2(MISSILE_DETONATION_DISTANCE)) {
        // Detonate!
        destroyNow = YES;
    } else {
        // Fly!
        
        // x direction
        if (detonationLocation.x > objectLocation.x) {
            objectVelocity.x += MISSILE_ACCELERATION_RATE * (detonationLocation.x - objectLocation.x);
            objectVelocity.x = CLAMP(objectVelocity.x, 0, MISSILE_MAX_SPEED);
        } else {
            objectVelocity.x += MISSILE_ACCELERATION_RATE * (detonationLocation.x - objectLocation.x);
            objectVelocity.x = CLAMP(objectVelocity.x, -MISSILE_MAX_SPEED, 0);
        }
        
        // y direction
        if (detonationLocation.y > objectLocation.y) {
            objectVelocity.y += MISSILE_ACCELERATION_RATE * (detonationLocation.y - objectLocation.y);
            objectVelocity.y = CLAMP(objectVelocity.y, 0, MISSILE_MAX_SPEED);
        } else {
            objectVelocity.y += MISSILE_ACCELERATION_RATE * (detonationLocation.y - objectLocation.y);
            objectVelocity.y = CLAMP(objectVelocity.y, -MISSILE_MAX_SPEED, 0);
        }
    }
    
    // Create smoke!
    [[ParticleSingleton sharedParticleSingleton] createParticles:1 withType:kParticleTypeSmoke atLocation:objectLocation];
    
    [self setObjectRotation:atan2f(objectVelocity.y, objectVelocity.x)];
}

- (void)objectWasDestroyed {
    [super objectWasDestroyed];
    if (targetObject && !targetObject.destroyNow) {
        if ([targetObject attackedByEnemy:ownerObject withDamage:missileDamage]) {
            [ownerObject setClosestEnemyObject:nil];
        }
    }
    ExplosionObject* explosion = [[ExplosionObject alloc] initWithLocation:objectLocation withSize:kExplosionSizeSmall];
    [[self currentScene] addCollidableObject:explosion];
    [explosion release];
}

@end
