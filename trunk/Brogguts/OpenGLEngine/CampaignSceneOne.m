//
//  CampaignSceneOne.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/22/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneOne.h"
#import "PlayerProfile.h"
#import "GameController.h"
#import "StartMissionObject.h"

#define CAMPAIGN_ONE_BROGGUT_GOAL 2500 // 1000

@implementation CampaignSceneOne

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:0 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextTwo:[NSString stringWithFormat:@"- Collect %i Brogguts", CAMPAIGN_ONE_BROGGUT_GOAL]];
        
        if (!loaded) {
            DialogueObject* dia = [[DialogueObject alloc] init];
            [dia setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE];
            [dia setDialogueImageIndex:kDialoguePortraitBase];
            [dia setDialogueText:@"Welcome to your first mining colony commander. It doesn't look like much, but we all started small at one time or another. Get yourself aquainted with the technology, and go bring back some brogguts."];
            [sceneDialogues addObject:dia];
            [dia release];
        }
    }
    return self;  
}

- (BOOL)checkObjective {
    int count = [[[GameController sharedGameController] currentProfile] broggutCount];
    if (count >= CAMPAIGN_ONE_BROGGUT_GOAL) {
        return YES;
    }
    return NO; // NO
}

- (BOOL)checkFailure {
    if ([self checkDefaultFailure]) {
        return YES;
    }
    return NO;
}

@end
