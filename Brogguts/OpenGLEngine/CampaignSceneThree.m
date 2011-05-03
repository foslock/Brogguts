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

@implementation CampaignSceneThree

- (id)init {
    self = [super initWithCampaignIndex:2];
    if (self) {
        // Create waves!
    }
    return self;  
}

- (BOOL)checkObjective {
    int count = [[[GameController sharedGameController] currentProfile] broggutCount];
    if (count >= 2500) {
        return YES;
    }
    return NO;
}

- (BOOL)checkFailure {
    if (numberOfCurrentShips <= 0 && numberOfCurrentStructures <= 0) {
        return YES;
    }
    return NO;
}

@end