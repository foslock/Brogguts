//
//  SpawnerObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/3/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "SpawnerObject.h"
#import "GameController.h"
#import "BroggutScene.h"
#import "CraftAndStructures.h"
#import "CollisionManager.h"

@implementation SpawnerObject
@synthesize sendingLocation, sendingLocationVariance;

- (id)initWithLocation:(CGPoint)location objectID:(int)objectID withDuration:(float)duration withCount:(int)count {
    self = [super init];
    if (self) {
        spawnerLocation = location;
        spawnerDuration = duration;
        currentTimer = duration;
        totalUnitCount = count;
        hasTriggeredOnce = NO;
        spawnerObjectID = objectID;
        sendingLocationVariance = 0.0f;
    }
    return self;
}

- (void)createObjectWithID:(int)objectID withEndingLocation:(CGPoint)endLocation {
    BroggutScene* scene = [[GameController sharedGameController] currentScene];
    switch (objectID) {
        case kObjectCraftAntID: {
            AntCraftObject* newCraft = [[AntCraftObject alloc] initWithLocation:spawnerLocation isTraveling:NO];
            NSArray* path = [[scene collisionManager] pathFrom:spawnerLocation to:endLocation allowPartial:YES isStraight:YES];
            [newCraft followPath:path isLooped:NO];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [scene createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            break;
        }
        case kObjectCraftMothID: {
            MothCraftObject* newCraft = [[MothCraftObject alloc] initWithLocation:spawnerLocation isTraveling:NO];
            NSArray* path = [[scene collisionManager] pathFrom:spawnerLocation to:endLocation allowPartial:YES isStraight:YES];
            [newCraft followPath:path isLooped:NO];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [scene createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            break;
        }
        case kObjectCraftBeetleID: {
            BeetleCraftObject* newCraft = [[BeetleCraftObject alloc] initWithLocation:spawnerLocation isTraveling:NO];
            NSArray* path = [[scene collisionManager] pathFrom:spawnerLocation to:endLocation allowPartial:YES isStraight:YES];
            [newCraft followPath:path isLooped:NO];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [scene createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            break;
        }
        case kObjectCraftMonarchID: {
            MonarchCraftObject* newCraft = [[MonarchCraftObject alloc] initWithLocation:spawnerLocation isTraveling:NO];
            NSArray* path = [[scene collisionManager] pathFrom:spawnerLocation to:endLocation allowPartial:YES isStraight:YES];
            [newCraft followPath:path isLooped:NO];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [scene createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            break;
        }
        case kObjectCraftCamelID: {
            CamelCraftObject* newCraft = [[CamelCraftObject alloc] initWithLocation:spawnerLocation isTraveling:NO];
            NSArray* path = [[scene collisionManager] pathFrom:spawnerLocation to:endLocation allowPartial:YES isStraight:YES];
            [newCraft followPath:path isLooped:NO];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [scene createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            break;
        }
        case kObjectCraftRatID: {
            RatCraftObject* newCraft = [[RatCraftObject alloc] initWithLocation:spawnerLocation isTraveling:NO];
            NSArray* path = [[scene collisionManager] pathFrom:spawnerLocation to:endLocation allowPartial:YES isStraight:YES];
            [newCraft followPath:path isLooped:NO];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [scene createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            break;
            break;
        }
        case kObjectCraftSpiderID: {
            SpiderCraftObject* newCraft = [[SpiderCraftObject alloc] initWithLocation:spawnerLocation isTraveling:NO];
            NSArray* path = [[scene collisionManager] pathFrom:spawnerLocation to:endLocation allowPartial:YES isStraight:YES];
            [newCraft followPath:path isLooped:NO];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [scene createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            break;
        }
        case kObjectCraftEagleID: {
            EagleCraftObject* newCraft = [[EagleCraftObject alloc] initWithLocation:spawnerLocation isTraveling:NO];
            NSArray* path = [[scene collisionManager] pathFrom:spawnerLocation to:endLocation allowPartial:YES isStraight:YES];
            [newCraft followPath:path isLooped:NO];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [scene createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            break;
        }
        default:
            NSLog(@"Tried to create craft with invalid ID (%i)", objectID);
            break;
    }
}

- (void)updateSpawnerWithDelta:(float)aDelta {
    if (currentTimer > 0.0f) {
        currentTimer -= aDelta;
    }
    if (currentTimer <= 0.0f && (totalUnitCount > 0 || totalUnitCount == -1)) {
        hasTriggeredOnce = YES;
        currentTimer = spawnerDuration;
        CGPoint newPoint = CGPointMake(sendingLocation.x + (RANDOM_MINUS_1_TO_1() * sendingLocationVariance),
                                       sendingLocation.y + (RANDOM_MINUS_1_TO_1() * sendingLocationVariance));
        [self createObjectWithID:spawnerObjectID withEndingLocation:newPoint];
        if (totalUnitCount > 0)
            totalUnitCount--;
    }
}

- (void)pauseSpawnerForDuration:(float)duration {
    currentTimer += duration;
}

- (float)pauseTimeLeft {
    return (currentTimer - spawnerDuration);
}

@end