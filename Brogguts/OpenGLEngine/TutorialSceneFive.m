//
//  TutorialSceneFive.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TutorialSceneFive.h"
#import "GameController.h"
#import "GameplayConstants.h"
#import "TriggerObject.h"
#import "CraftAndStructures.h"
#import "Image.h"
#import "TextObject.h"

@implementation TutorialSceneFive

- (void)dealloc {
    [antTrigger release];
    [super dealloc];
}

- (id)init {
    self = [super initWithTutorialIndex:4];
    if (self) {
        CGPoint triggerLoc = CGPointMake(fullMapBounds.size.width * (7.0f / 8.0f) ,
                                         fullMapBounds.size.height * (1.0f / 8.0f));
        
        CGPoint antOneLoc = CGPointMake(fullMapBounds.size.width * (1.0f / 8.0f) + COLLISION_CELL_WIDTH,
                                        fullMapBounds.size.height * (7.0f / 8.0f));
        
        CGPoint antTwoLoc = CGPointMake(fullMapBounds.size.width * (1.0f / 8.0f),
                                        fullMapBounds.size.height * (7.0f / 8.0f) + COLLISION_CELL_HEIGHT);
        
        antTrigger = [[TriggerObject alloc] initWithLocation:triggerLoc];
        antTrigger.numberOfObjectsNeeded = 2;
        antTrigger.objectImage.scale = Scale2fMake(2.0f, 2.0f);
        antTrigger.objectIDNeeded = kObjectCraftAntID;
        NotificationObject* notiObj = [[NotificationObject alloc] initWithLocation:antTrigger.objectLocation withDuration:-1.0f];
        [self addCollidableObject:notiObj];
        [notiObj release];
        
        AntCraftObject* newAntOne = [[AntCraftObject alloc] initWithLocation:antOneLoc isTraveling:NO];
        [newAntOne setObjectAlliance:kAllianceFriendly];
        myCraftOne = newAntOne;
        
        AntCraftObject* newAntTwo = [[AntCraftObject alloc] initWithLocation:antTwoLoc isTraveling:NO];
        [newAntTwo setObjectAlliance:kAllianceFriendly];
        myCraftTwo = newAntTwo;
        
        [self addTouchableObject:newAntOne withColliding:CRAFT_COLLISION_YESNO];
        [self addTouchableObject:newAntTwo withColliding:CRAFT_COLLISION_YESNO];
        [self addCollidableObject:antTrigger];
        [newAntOne release];
        [newAntTwo release];
        [self setCameraLocation:GetMidpointFromPoints(antOneLoc, antTwoLoc)];
        [self setMiddleOfVisibleScreenToCamera];
        
        [helpText setObjectText:@"Selecting multiple ships is just like selecting one. Use two fingers, tap, and make a shape containing both ships."];
    }
    return self;
}

- (BOOL)checkObjective {
    return ([antTrigger isComplete]);
}

@end
