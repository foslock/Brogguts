//
//  CampaignSceneNine.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneNine.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "SpawnerObject.h"
#import "StartMissionObject.h"
#import "TextObject.h"

#define CAMPAIGN_NINE_WAVE_TIME 10.0f

@implementation CampaignSceneNine


- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:8 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextTwo:@"- A massive wave has been detected"];
        [startObject setMissionTextThree:@"- Survive for as long as you can"];
        if (!loaded) {
            DialogueObject* dia1 = [[DialogueObject alloc] init];
            [dia1 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE];
            [dia1 setDialogueImageIndex:kDialoguePortraitBase];
            [dia1 setDialogueText:@""];
            [sceneDialogues addObject:dia1];
            [dia1 release];
            
            DialogueObject* dia2 = [[DialogueObject alloc] init];
            [dia2 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE + 0.1f];
            [dia2 setDialogueImageIndex:kDialoguePortraitBase];
            [dia2 setDialogueText:@"T"];
            [sceneDialogues addObject:dia2];
            [dia2 release];
            
            SpawnerObject* spawner = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:0.05f withCount:10];
            [spawner addObjectWithID:kObjectCraftBeetleID withCount:10];
            [spawner addObjectWithID:kObjectCraftMothID withCount:10];
            [spawner addObjectWithID:kObjectCraftSpiderID withCount:4];
            [spawner pauseSpawnerForDuration:(CAMPAIGN_NINE_WAVE_TIME * 60.0f) + 1.0f];
            [spawner setSendingLocation:homeBaseLocation];
            [spawner setSendingLocationVariance:100.0f];
            [spawner setStartingLocationVariance:512.0f];
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
        countdown = [NSString stringWithFormat:@"Wave: %i:%i", minutes, seconds];
    } else {
        countdown = [NSString stringWithFormat:@"Wave: %i:0%i", minutes, seconds];
    }
    
    if (minutes != 0 || seconds != 0) {
        [countdownTimer setObjectText:countdown];
    } else {
        [countdownTimer setObjectText:@""];
    }

    [self updateSpawnersWithDelta:aDelta];
}

- (BOOL)checkObjective {
    // On destruction of the base station, "win"
    return NO;
}

- (BOOL)checkFailure {
    // Can't lose this mission, unless there are no enemies and spawner is done
    if ([[self spawnerWithID:0] isDoneSpawning] && numberOfEnemyShips == 0) {
        return YES;
    }
    return NO;
}

@end