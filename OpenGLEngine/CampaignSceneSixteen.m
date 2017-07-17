//
//  CampaignSceneSixteen.m
//  OpenGLEngine
//
//  Created by James Lockwood on 1/19/12.
//  Copyright (c) 2012 Games in Dorms. All rights reserved.
//

#import "CampaignSceneSixteen.h"
#import "PlayerProfile.h"
#import "GameController.h"
#import "StartMissionObject.h"
#import "FireworkObject.h"

@implementation CampaignSceneSixteen

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:15 wasLoaded:loaded];
    if (self) {
        [startObject setMissionHeader:@""];
        [startObject setMissionTextTwo:@"Congratulations, you have beaten the Campaign."];
        [startObject setMissionTextThree:@"Enjoy the fireworks!"];
        fireworkTimer = 1.0f;
        // Congrats WINNING LEVEL!
    }
    return self;  
}

- (void)updateSceneWithDelta:(float)aDelta {
    [super updateSceneWithDelta:aDelta];
    
    if (fireworkTimer > 0) {
        fireworkTimer -= aDelta;
    } else {
        int subCount = 1 + (int)(RANDOM_0_TO_1() * 8);
        float time = 0.5f + (RANDOM_0_TO_1() * 1.0f);
        float speed = 2.0f + (RANDOM_0_TO_1() * 2.0f);
        FireworkObject* firework = [[FireworkObject alloc] initWithLocation:homeBaseLocation withSubCount:subCount withDuration:time withSpeed:speed];
        [firework setMovingDirection:(RANDOM_0_TO_1() * M_PI_2)];
        [self addCollidableObject:firework];
        [firework release];
        fireworkTimer = 4.0f + RANDOM_0_TO_1() * 2.0f;
    }
}

- (BOOL)checkObjective {
    return NO; // NO
}

- (BOOL)checkFailure {
    return NO;
}

@end
