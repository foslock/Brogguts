//
//  SpawnerObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/3/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SPAWNER_TIMER_SPEED_FACTOR 1.0f

@interface SpawnerObject : NSObject {
    float spawnerDuration;
    float currentTimer;
    BOOL hasTriggeredOnce;
    int idCount[TOTAL_OBJECT_TYPES_COUNT];
    CGPoint spawnerLocation;
    CGPoint sendingLocation;
    float sendingLocationVariance;
    float startingLocationVariance;
    BOOL isDoneSpawning;
}

@property (assign) CGPoint sendingLocation;
@property (assign) float sendingLocationVariance;
@property (assign) float startingLocationVariance;
@property (readonly) BOOL isDoneSpawning;

// Pass -1 in to count for infinite spawning
- (id)initWithLocation:(CGPoint)location objectID:(int)objectID withDuration:(float)duration withCount:(int)count;

- (id)initWithSavedArray:(NSArray*)infoArray;
- (NSArray*)infoArrayFromSpawner;

- (void)addObjectWithID:(int)objectID withCount:(int)count;
- (void)updateSpawnerWithDelta:(float)aDelta;

- (void)pauseSpawnerForDuration:(float)duration;
- (float)pauseTimeLeft;

- (void)stopSpawnerAndClearCounts;

@end
