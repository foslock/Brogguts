//
//  TutorialSceneNine.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/17/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TutorialSceneNine.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "GameplayConstants.h"
#import "TriggerObject.h"
#import "FingerObject.h"
#import "CraftAndStructures.h"
#import "TextObject.h"

@implementation TutorialSceneNine

- (id)init {
    self = [super initWithTutorialIndex:8];
    if (self) {
        isAllowingOverview = YES;
        isShowingBroggutCount = YES;
        
        CGPoint homeLoc = CGPointMake(COLLISION_CELL_WIDTH / 2, COLLISION_CELL_HEIGHT / 2);
        CGPoint antLoc = CGPointMake(8 * COLLISION_CELL_WIDTH / 2, 8 * COLLISION_CELL_HEIGHT / 2);
        
        /*
        NotificationObject* notiObj = [[NotificationObject alloc] initWithLocation:antTrigger.objectLocation withDuration:-1.0f];
        [self addCollidableObject:notiObj];
        [notiObj release];
         */
        
        BaseStationStructureObject* station = [[BaseStationStructureObject alloc] initWithLocation:homeLoc isTraveling:NO];
        [self setHomeBaseLocation:station.objectLocation];
        [self addTouchableObject:station withColliding:STRUCTURE_COLLISION_YESNO];
        [station release];
        
        
        AntCraftObject* newAnt = [[AntCraftObject alloc] initWithLocation:antLoc isTraveling:NO];
        myCraft = newAnt;
        [newAnt setObjectAlliance:kAllianceFriendly];
        [self addTouchableObject:newAnt withColliding:CRAFT_COLLISION_YESNO];
        [newAnt release];
        
        [helpText setObjectText:@""];
    }
    return self;
}

- (BOOL)checkObjective {
    // Really check for mining brogguts
    if ([[sharedGameController currentProfile] broggutCount] > 0) {
        return YES;
    } else {
        return NO;
    }
}

@end
