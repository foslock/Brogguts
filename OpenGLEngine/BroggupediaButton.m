//
//  BroggupediaButton.m
//  OpenGLEngine
//
//  Created by James Lockwood on 1/12/12.
//  Copyright (c) 2012 Games in Dorms. All rights reserved.
//

#import "BroggupediaButton.h"
#import "GameController.h"
#import "PlayerProfile.h"

@implementation BroggupediaButton
@synthesize iconView, altView, labelView;

- (id)init {
    self = [super init];
    if (self) {
        //
    }
    return self;
}

- (void)updateViews {
    if (![[[GameController sharedGameController] currentProfile] isObjectUnlockedWithID:[self tag]]) {
        [iconView setImage:[UIImage imageNamed:@"locked.png"]];
        [altView setHidden:YES];
        [labelView setText:@"LOCKED"];
    }
}

@end
