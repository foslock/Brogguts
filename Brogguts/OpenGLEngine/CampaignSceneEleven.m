//
//  CampaignSceneEleven.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneEleven.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "SpawnerObject.h"
#import "StartMissionObject.h"
#import "TextObject.h"

@implementation CampaignSceneEleven

- (void)dealloc {
    [super dealloc];
}

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:10 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextTwo:@"- Build up the pirate colony"];
        [startObject setMissionTextThree:@"- Destroy the company base station"];
        if (!loaded) {
            DialogueObject* dia1 = [[DialogueObject alloc] init];
            [dia1 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE];
            [dia1 setDialogueImageIndex:kDialoguePortraitAnon];
            [dia1 setDialogueText:@"You've been stationed at one of our newest base stations. It is located close to a poorly guarded company owned station, begging to be invaded. Lead this pirate station to victory and you will earn more than just some respect among this faction's ranks."];
            [sceneDialogues addObject:dia1];
            [dia1 release];
        }
    }
    return self;
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
    return NO;
}

@end