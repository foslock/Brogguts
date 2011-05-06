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

@implementation CampaignSceneOne

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:0 wasLoaded:loaded];
    if (self) {
        
    }
    return self;  
}

- (BOOL)checkObjective {
    int count = [[[GameController sharedGameController] currentProfile] broggutCount];
    if (count >= 100) {
        return YES;
    }
    return NO;
}

- (BOOL)checkFailure {
    // No way to lose this level
    return NO;
}



@end
