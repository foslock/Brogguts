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

@implementation CampaignSceneTwo

- (id)init {
    self = [super initWithCampaignIndex:1];
    if (self) {
        
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
    return NO;
}

@end
