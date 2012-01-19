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

@implementation CampaignSceneSixteen

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:15 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextTwo:@"Congrats, you have beaten the Campaign!"];
        // Congrats WINNING LEVEL!
    }
    return self;  
}

- (BOOL)checkObjective {
    return NO; // NO
}

- (BOOL)checkFailure {
    return NO;
}

@end
