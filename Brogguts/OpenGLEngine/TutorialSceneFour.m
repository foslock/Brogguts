//
//  TutorialSceneFour.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TutorialSceneFour.h"
#import "GameController.h"
#import "GameplayConstants.h"
#import "TriggerObject.h"
#import "CraftAndStructures.h"

@implementation TutorialSceneFour

- (void)dealloc {
    [antTrigger release];
    [super dealloc];
}

- (id)init {
    self = [super initWithTutorialIndex:3];
    if (self) {
        CGPoint triggerLoc = CGPointMake(fullMapBounds.size.width * (3.0f / 4.0f) + (COLLISION_CELL_WIDTH / 2),
                                         fullMapBounds.size.height * (1.0f / 2.0f));
        CGPoint antLoc = CGPointMake((float)kPadScreenLandscapeWidth * (1.0f / 4.0f) - (COLLISION_CELL_WIDTH / 2),
                                     (float)kPadScreenLandscapeHeight * (1.0f / 2.0f));
        antTrigger = [[TriggerObject alloc] initWithLocation:triggerLoc];
        antTrigger.numberOfObjectsNeeded = 1;
        antTrigger.objectIDNeeded = kObjectCraftAntID;
        NotificationObject* notiObj = [[NotificationObject alloc] initWithLocation:antTrigger.objectLocation withDuration:-1.0f];
        [self addCollidableObject:notiObj];
        [notiObj release];
        AntCraftObject* newAnt = [[AntCraftObject alloc] initWithLocation:antLoc isTraveling:NO];
        myCraft = newAnt;
        [newAnt setObjectAlliance:kAllianceFriendly];
        [self addTouchableObject:newAnt withColliding:CRAFT_COLLISION_YESNO];
        [self addCollidableObject:antTrigger];
        [newAnt release];
    }
    return self;
}

- (BOOL)checkObjective {
    return ([antTrigger isComplete]);
}

@end