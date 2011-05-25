//
//  CampaignSceneSix.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneSix.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "SpawnerObject.h"

@implementation CampaignSceneSix

- (void)dealloc {
    [spawner release];
    [super dealloc];
}

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:5 wasLoaded:loaded];
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
    if ([self checkDefaultFailure]) {
        return YES;
    }
    if (numberOfCurrentStructures <= 0) {
        return YES;
    }
    return NO;
}

@end