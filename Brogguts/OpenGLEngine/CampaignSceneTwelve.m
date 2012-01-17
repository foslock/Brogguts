//
//  CampaignSceneTwelve.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneTwelve.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "SpawnerObject.h"
#import "StartMissionObject.h"
#import "TextObject.h"

#define CAMPAIGN_TWELVE_TIME_LIMIT 10.0f

@implementation CampaignSceneTwelve

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:11 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextTwo:@"- Destroy the enemy base station"];
        [startObject setMissionTextThree:[NSString stringWithFormat:@"- Do it in under %i minutes", (int)CAMPAIGN_TWELVE_TIME_LIMIT]];
        if (!loaded) {
            DialogueObject* dia1 = [[DialogueObject alloc] init];
            [dia1 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE];
            [dia1 setDialogueImageIndex:kDialoguePortraitAnon];
            [dia1 setDialogueText:@"You have been moved to a new colony, as there were rumors a rare deposit of ancient brogguts is located near the local company's base station. Use your impressive talents to destroy the enemy's base with at least some of the brogguts left."];
            [sceneDialogues addObject:dia1];
            [dia1 release];
            
            DialogueObject* dia2 = [[DialogueObject alloc] init];
            [dia2 setDialogueActivateTime:(CAMPAIGN_TWELVE_TIME_LIMIT / 2) * 60.0f];
            [dia2 setDialogueImageIndex:kDialoguePortraitAnon];
            [dia2 setDialogueText:@"We've intercepted a transmission from the company, it seems that they've already mined half of the ancient broggut deposit. Hurry up and destroy them before it's all gone!"];
            [sceneDialogues addObject:dia2];
            [dia2 release];
            
            SpawnerObject* spawner = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:0.1f withCount:0];
            [spawner pauseSpawnerForDuration:(CAMPAIGN_TWELVE_TIME_LIMIT * 60.0f) + 1.0f];
            [spawner setSendingLocation:homeBaseLocation];
            [spawner setSendingLocationVariance:100.0f];
            [spawner setStartingLocationVariance:128.0f];
            [self addSpawner:spawner];
            [spawner release];
        }
    }
    return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
    [super updateSceneWithDelta:aDelta];
    if (isStartingMission || isMissionPaused || isShowingDialogue) {
        return;
    }
    int minutes = [[self spawnerWithID:0] pauseTimeLeft] / 60.0f;
    int seconds = [[self spawnerWithID:0] pauseTimeLeft] - (60.0f * minutes);
    NSString* countdown;
    
    if (seconds >= 10) {
        countdown = [NSString stringWithFormat:@"Timer: %i:%i", minutes, seconds];
    } else {
        countdown = [NSString stringWithFormat:@"Timer: %i:0%i", minutes, seconds];
    }
    
    if (minutes > 0 || seconds > 0) {
        [countdownTimer setObjectText:countdown];
    } else {
        [countdownTimer setObjectText:@""];
    }
    [self updateSpawnersWithDelta:aDelta];
}

- (BOOL)checkObjective {
    if (!isEnemyBaseStationAlive) {
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
    if ([[self spawnerWithID:0] isDoneSpawning]) {
        return YES;
    }
    return NO;
}

@end