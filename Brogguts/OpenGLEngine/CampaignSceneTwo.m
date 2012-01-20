//
//  CampaignSceneTwo.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/22/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneTwo.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "StartMissionObject.h"
#import "SpawnerObject.h"
#import "TextObject.h"

#define CAMPAIGN_TWO_BROGGUT_GOAL 2500
#define CAMPAIGN_TWO_TIME_LIMIT 4.0f

@implementation CampaignSceneTwo

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:1 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextTwo:[NSString stringWithFormat:@"- Collect %i Brogguts in %i minutes", CAMPAIGN_TWO_BROGGUT_GOAL, (int)CAMPAIGN_TWO_TIME_LIMIT]];
        
        if (!loaded) {
            DialogueObject* dia1 = [[DialogueObject alloc] init];
            [dia1 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE];
            [dia1 setDialogueImageIndex:kDialoguePortraitBase];
            [dia1 setDialogueText:@"We've put you on a new colony this time around, where we need you to collect a large number of brogguts in a limited amount of time. You are provided with enough blocks so you don't need to worry about the craft limit, so hurry and mine some brogguts!"];
            [sceneDialogues addObject:dia1];
            [dia1 release];
            
            DialogueObject* dia2 = [[DialogueObject alloc] init];
            [dia2 setDialogueActivateTime:CAMPAIGN_TWO_TIME_LIMIT * 60.0f / 2];
            [dia2 setDialogueImageIndex:kDialoguePortraitBase];
            [dia2 setDialogueText:@"You are halfway through your allotted time, hurry up and bring as many of those brogguts as you can back to base!"];
            [sceneDialogues addObject:dia2];
            [dia2 release];
            
            SpawnerObject* spawner = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:0.1f withCount:0];
            [spawner pauseSpawnerForDuration:(CAMPAIGN_TWO_TIME_LIMIT * 60.0f) + 1.0f];
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
    if (isStartingMission || isMissionPaused || isShowingDialogue || isObjectiveComplete || isObjectiveComplete) {
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
    int count = [[[GameController sharedGameController] currentProfile] broggutCount];
    if (count >= CAMPAIGN_TWO_BROGGUT_GOAL) {
        return YES;
    }
    return NO; // NO
}

- (BOOL)checkFailure {
    if ([self checkDefaultFailure]) {
        return YES;
    }
    if ([[self spawnerWithID:0] isDoneSpawning]) {
        return YES;
    }
    return NO;
}

@end
