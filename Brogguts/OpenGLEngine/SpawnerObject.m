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
@synthesize sendingLocation, sendingLocationVariance, startingLocationVariance, isDoneSpawning;

- (id)initWithLocation:(CGPoint)location objectID:(int)objectID withDuration:(float)duration withCount:(int)count {
    self = [super init];
    if (self) {
        spawnerLocation = location;
        spawnerDuration = duration;
        currentTimer = spawnerDuration;
        hasTriggeredOnce = NO;
        isDoneSpawning = NO;
        for (int i = 0; i < TOTAL_OBJECT_TYPES_COUNT; i++) {
            idCount[i] = 0;
        }
        idCount[objectID] = count;
        sendingLocationVariance = 0.0f;
        startingLocationVariance = 0.0f;
    }
    return self;
}

- (id)initWithSavedArray:(NSArray*)infoArray {
    self = [super init];
    if (self) {
        spawnerLocation.x = [[[infoArray objectAtIndex:0] objectAtIndex:0] floatValue];
        spawnerLocation.y = [[[infoArray objectAtIndex:0] objectAtIndex:1] floatValue];
        spawnerDuration = [[infoArray objectAtIndex:1] floatValue];
        currentTimer = [[infoArray objectAtIndex:2] floatValue];
        hasTriggeredOnce = [[infoArray objectAtIndex:3] boolValue];
        isDoneSpawning = [[infoArray objectAtIndex:4] boolValue];
        
        NSArray* idCountArray = [infoArray objectAtIndex:5];
        for (int i = 0; i < TOTAL_OBJECT_TYPES_COUNT; i++) {
            idCount[i] = [[idCountArray objectAtIndex:i] intValue];
        }
        startingLocationVariance = [[infoArray objectAtIndex:6] floatValue];
        sendingLocationVariance = [[infoArray objectAtIndex:7] floatValue];
    }
    return self;
}

- (NSArray*)infoArrayFromSpawner {
    NSMutableArray* spawnerArray = [[NSMutableArray alloc] init];
    
    // Location
    NSArray* locationArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:spawnerLocation.x],
                              [NSNumber numberWithFloat:spawnerLocation.y], nil];
    
    // Duration
    NSNumber* durationNumber = [NSNumber numberWithFloat:spawnerDuration];
    
    // Current Timer
    NSNumber* timerNumber = [NSNumber numberWithFloat:currentTimer];
    
    // Has Triggered
    NSNumber* hasTriggeredNumber = [NSNumber numberWithBool:hasTriggeredOnce];
    
    // isDoneSpawning
    NSNumber* isDoneNumber = [NSNumber numberWithBool:isDoneSpawning];
    
    // IDCount array
    NSMutableArray* idCountArray = [NSMutableArray arrayWithCapacity:TOTAL_OBJECT_TYPES_COUNT];
    for (int i = 0; i < TOTAL_OBJECT_TYPES_COUNT; i++) {
        NSNumber* idCountNumber = [NSNumber numberWithInt:idCount[i]];
        [idCountArray addObject:idCountNumber];
    }
    
    // Starting Variance
    NSNumber* startingVarNumber = [NSNumber numberWithFloat:startingLocationVariance];
    
    // Arrival Variance
    NSNumber* arrivalVarNumber = [NSNumber numberWithFloat:sendingLocationVariance];
    
    [spawnerArray addObject:locationArray];
    [spawnerArray addObject:durationNumber];
    [spawnerArray addObject:timerNumber];
    [spawnerArray addObject:hasTriggeredNumber];
    [spawnerArray addObject:isDoneNumber];
    [spawnerArray addObject:idCountArray];
    [spawnerArray addObject:startingVarNumber];
    [spawnerArray addObject:arrivalVarNumber];
    
    return [spawnerArray autorelease];
}

- (void)createObjectWithID:(int)objectID withEndingLocation:(CGPoint)endLocation {
    BroggutScene* scene = [[GameController sharedGameController] currentScene];
    CGPoint startingPoint = CGPointMake(spawnerLocation.x + (RANDOM_MINUS_1_TO_1() * startingLocationVariance),
                                        spawnerLocation.y + (RANDOM_MINUS_1_TO_1() * startingLocationVariance));
    switch (objectID) {
        case kObjectCraftAntID: {
            AntCraftObject* newCraft = [[AntCraftObject alloc] initWithLocation:startingPoint isTraveling:NO];
            NSArray* path = [[scene collisionManager] pathFrom:startingPoint to:endLocation allowPartial:YES isStraight:YES];
            [newCraft followPath:path isLooped:NO];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [scene createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            [newCraft release];
            break;
        }
        case kObjectCraftMothID: {
            MothCraftObject* newCraft = [[MothCraftObject alloc] initWithLocation:startingPoint isTraveling:NO];
            NSArray* path = [[scene collisionManager] pathFrom:startingPoint to:endLocation allowPartial:YES isStraight:YES];
            [newCraft followPath:path isLooped:NO];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [scene createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            [newCraft release];
            break;
        }
        case kObjectCraftBeetleID: {
            BeetleCraftObject* newCraft = [[BeetleCraftObject alloc] initWithLocation:startingPoint isTraveling:NO];
            NSArray* path = [[scene collisionManager] pathFrom:startingPoint to:endLocation allowPartial:YES isStraight:YES];
            [newCraft followPath:path isLooped:NO];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [scene createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            [newCraft release];
            break;
        }
        case kObjectCraftMonarchID: {
            MonarchCraftObject* newCraft = [[MonarchCraftObject alloc] initWithLocation:startingPoint isTraveling:NO];
            NSArray* path = [[scene collisionManager] pathFrom:startingPoint to:endLocation allowPartial:YES isStraight:YES];
            [newCraft followPath:path isLooped:NO];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [scene createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            [newCraft release];
            break;
        }
        case kObjectCraftCamelID: {
            CamelCraftObject* newCraft = [[CamelCraftObject alloc] initWithLocation:startingPoint isTraveling:NO];
            NSArray* path = [[scene collisionManager] pathFrom:startingPoint to:endLocation allowPartial:YES isStraight:YES];
            [newCraft followPath:path isLooped:NO];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [scene createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            [newCraft release];
            break;
        }
        case kObjectCraftRatID: {
            RatCraftObject* newCraft = [[RatCraftObject alloc] initWithLocation:startingPoint isTraveling:NO];
            NSArray* path = [[scene collisionManager] pathFrom:startingPoint to:endLocation allowPartial:YES isStraight:YES];
            [newCraft followPath:path isLooped:NO];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [scene createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            [newCraft release];
            break;
        }
        case kObjectCraftSpiderID: {
            SpiderCraftObject* newCraft = [[SpiderCraftObject alloc] initWithLocation:startingPoint isTraveling:NO];
            NSArray* path = [[scene collisionManager] pathFrom:startingPoint to:endLocation allowPartial:YES isStraight:YES];
            [newCraft followPath:path isLooped:NO];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [scene createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            [newCraft release];
            break;
        }
        case kObjectCraftEagleID: {
            EagleCraftObject* newCraft = [[EagleCraftObject alloc] initWithLocation:startingPoint isTraveling:NO];
            NSArray* path = [[scene collisionManager] pathFrom:startingPoint to:endLocation allowPartial:YES isStraight:YES];
            [newCraft followPath:path isLooped:NO];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [scene createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            [newCraft release];
            break;
        }
        default:
            NSLog(@"Tried to create craft with invalid ID (%i)", objectID);
            break;
    }
}

- (void)addObjectWithID:(int)objectID withCount:(int)count {
    if (objectID >= 0 && objectID < TOTAL_OBJECT_TYPES_COUNT) {
        idCount[objectID] += count;
    }
}

- (void)updateSpawnerWithDelta:(float)aDelta {
    if (currentTimer > 0.0f) {
        currentTimer -= aDelta * SPAWNER_TIMER_SPEED_FACTOR;
    } else {
        for (int index = 0; index < TOTAL_OBJECT_TYPES_COUNT; index++) {
            if (idCount[index] > 0 || idCount[index] == -1) {
                hasTriggeredOnce = YES;
                currentTimer = spawnerDuration;
                CGPoint newPoint = CGPointMake(sendingLocation.x + (RANDOM_MINUS_1_TO_1() * sendingLocationVariance),
                                               sendingLocation.y + (RANDOM_MINUS_1_TO_1() * sendingLocationVariance));
                
                [self createObjectWithID:index withEndingLocation:newPoint];
                if (idCount[index] > 0) {
                    idCount[index]--;
                }
            }
        }
        BOOL allDone = YES;
        for (int i = 0; i < TOTAL_OBJECT_TYPES_COUNT; i++) {
            if (idCount[i] != 0) {
                allDone = NO;
            }
        }
        isDoneSpawning = allDone;
    }
}

- (void)pauseSpawnerForDuration:(float)duration {
    currentTimer += duration;
}

- (float)pauseTimeLeft {
    return (currentTimer - spawnerDuration);
}

@end