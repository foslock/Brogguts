//
//  CampaignSceneEight.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneEight.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "SpawnerObject.h"

@implementation CampaignSceneEight

- (void)dealloc {
    [spawner release];
    [super dealloc];
}

- (id)init {
    self = [super initWithCampaignIndex:7];
    if (self) {
        spawner = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:1.0f withCount:2];
        [spawner pauseSpawnerForDuration:10.0f];
        [spawner setSendingLocation:homeBaseLocation];
        [spawner setSendingLocationVariance:100.0f];
    }
    return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
    [super updateSceneWithDelta:aDelta];
    [spawner updateSpawnerWithDelta:aDelta];
}

- (BOOL)checkObjective {
    int count = [[[GameController sharedGameController] currentProfile] broggutCount];
    if (count >= 2500) {
        return YES;
    }
    return NO;
}

- (BOOL)checkFailure {
    if (numberOfCurrentStructures <= 0) {
        return YES;
    }
    return NO;
}

@end