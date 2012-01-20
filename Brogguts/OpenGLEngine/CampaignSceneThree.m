//
//  CampaignSceneThree.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneThree.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "SpawnerObject.h"
#import "TextObject.h"
#import "StartMissionObject.h"

#define CAMPAIGN_THREE_WAVE_TIME 4.0f

@implementation CampaignSceneThree

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:2 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextTwo:[NSString stringWithFormat:@"- Survive the wave approaching in %i minutes",(int)CAMPAIGN_THREE_WAVE_TIME]];
        [startObject setMissionTextThree:@"- Destroy all 6 enemy Ants in the wave"];
        if (!loaded) {
            DialogueObject* dia1 = [[DialogueObject alloc] init];
            [dia1 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE];
            [dia1 setDialogueImageIndex:kDialoguePortraitBase];
            [dia1 setDialogueText:@"Congratulations, you've been moved to a brand new colony again! Now, if gathering brogguts was getting a little boring, I have something more important for you to worry about. Our long range sensors are picking up a few pirate craft slowing approaching your base station. Defend it from them."];
            [sceneDialogues addObject:dia1];
            [dia1 release];
            
            DialogueObject* dia2 = [[DialogueObject alloc] init];
            [dia2 setDialogueActivateTime:CAMPAIGN_THREE_WAVE_TIME * 60.0f];
            [dia2 setDialogueImageIndex:kDialoguePortraitBase];
            [dia2 setDialogueText:@"Watch out, it appears the pirates have entered your local space. Defend the base station with everything you've got!"];
            [sceneDialogues addObject:dia2];
            [dia2 release];
            
            SpawnerObject* spawner = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:0.1f withCount:6];
            [spawner pauseSpawnerForDuration:(CAMPAIGN_THREE_WAVE_TIME * 60.0f) + 1.0f];
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
    if (isStartingMission || isMissionPaused || isShowingDialogue || isObjectiveComplete) {
        return;
    }
    int minutes = [[self spawnerWithID:0] pauseTimeLeft] / 60.0f;
    int seconds = [[self spawnerWithID:0] pauseTimeLeft] - (60.0f * minutes);
    NSString* countdown;
    
    if (seconds >= 10) {
        countdown = [NSString stringWithFormat:@"Wave: %i:%i", minutes, seconds];
    } else {
        countdown = [NSString stringWithFormat:@"Wave: %i:0%i", minutes, seconds];
    }
    
    if (minutes > 0 || seconds > 0) {
        [countdownTimer setObjectText:countdown];
    } else {
        [countdownTimer setObjectText:@""];
    }
    [self updateSpawnersWithDelta:aDelta];
}

- (BOOL)checkObjective {
    int enemyShipCount = [self numberOfEnemyShips];
    if ([[self spawnerWithID:0] isDoneSpawning] && enemyShipCount == 0) {
        return YES;
    }
    return NO; // NO
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