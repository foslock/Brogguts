//
//  CampaignSceneTen.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneTen.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "SpawnerObject.h"
#import "StartMissionObject.h"
#import "TextObject.h"

@implementation CampaignSceneTen

- (void)dealloc {
    [super dealloc];
}

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:9 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextTwo:@"- Command the pirate fleet"];
        [startObject setMissionTextThree:@"- Destroy all enemy craft"];
        if (!loaded) {
            DialogueObject* dia1 = [[DialogueObject alloc] init];
            [dia1 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE];
            [dia1 setDialogueImageIndex:kDialoguePortraitAnon];
            [dia1 setDialogueText:@"Welcome. As much as I hate having to work with an ex-company man, word of your reputable talent has spread through many of the pirating factions. I guess we should consider ourselves lucky that we were the first to successfully capture you."];
            [sceneDialogues addObject:dia1];
            [dia1 release];
            
            DialogueObject* dia2 = [[DialogueObject alloc] init];
            [dia2 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE + 0.1f];
            [dia2 setDialogueImageIndex:kDialoguePortraitAnon];
            [dia2 setDialogueText:@"One thing is to be clear. You work for me now. If I tell you to do something, you do it. Now we need to get you back safely to our closest colony. Unfortunately there is a squadron of your former friends directly in between us and our destination. Take control of our fleet and show me you're worth all the trouble."];
            [sceneDialogues addObject:dia2];
            [dia2 release];
        }
    }
    return self;
}

- (void)sceneDidAppear {
    [super sceneDidAppear];
    [self setCameraLocation:CGPointMake(0.0f, fullMapBounds.size.height / 2.0f)];
    [self setMiddleOfVisibleScreenToCamera];
}

- (BOOL)checkObjective {
    if (numberOfEnemyShips <= 0 && !doesExplosionExist) {
        return YES;
    }
    return NO;
}

- (BOOL)checkFailure {
    if (numberOfCurrentShips <= 0 && !doesExplosionExist) {
        return YES;
    }
    return NO;
}

@end