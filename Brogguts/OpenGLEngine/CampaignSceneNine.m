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

#define CAMPAIGN_NINE_WAVE_TIME 0.1f

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
            [dia1 setDialogueText:@"In honor of all your recent missions being successfully completed we at the company have decided to let you settle into a base that you can get used to. There is rumor of some pirate activity nearby, but given your history you should be able to handle it."];
            [sceneDialogues addObject:dia1];
            [dia1 release];
            
            DialogueObject* dia2 = [[DialogueObject alloc] init];
            [dia2 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE + 5.0f];
            [dia2 setDialogueImageIndex:kDialoguePortraitBase];
            [dia2 setDialogueText:@"Good news! Our sensors have picked up an extremely old deposit of brogguts nearby your basestation. These are the most rare and valuable brogguts, you should get some mining craft over there as soon as you can."];
            [sceneDialogues addObject:dia2];
            [dia2 release];
            
            DialogueObject* dia3 = [[DialogueObject alloc] init];
            [dia3 setDialogueActivateTime:(CAMPAIGN_NINE_WAVE_TIME * 60.0f) + 2.0f];
            [dia3 setDialogueImageIndex:kDialoguePortraitAnon];
            [dia3 setDialogueText:@"You better come with us..."];
            [sceneDialogues addObject:dia3];
            [dia3 release];
            
            SpawnerObject* spawner = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:0.05f withCount:5];
            [spawner addObjectWithID:kObjectCraftBeetleID withCount:6];
            [spawner addObjectWithID:kObjectCraftMothID withCount:6];
            [spawner addObjectWithID:kObjectCraftSpiderID withCount:5];
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
    // On destruction of the base station, "win"
    if (isFriendlyBaseStationAlive) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)checkFailure {
    // Can't lose this mission, unless there are no enemies and spawner is done
    if ([[self spawnerWithID:0] isDoneSpawning] && numberOfEnemyShips == 0) {
        return YES;
    }
    return NO;
}

@end