//
//  SpawnerObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/3/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SpawnerObject : NSObject {
    float spawnerDuration;
    float currentTimer;
    BOOL doesRepeat;
    int totalUnitCount;
    BOOL hasTriggeredOnce;
    int spawnerObjectID;
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

- (void)updateSpawnerWithDelta:(float)aDelta;

- (void)pauseSpawnerForDuration:(float)duration;
- (float)pauseTimeLeft;

@end
