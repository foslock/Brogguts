//
//  TutorialSceneTen.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TutorialSceneTen.h"
#import "GameController.h"
#import "GameplayConstants.h"
#import "TriggerObject.h"
#import "FingerObject.h"
#import "CraftAndStructures.h"
#import "Image.h"
#import "TextObject.h"

@implementation TutorialSceneTen

- (void)dealloc {
    [mothTrigger release];
    [super dealloc];
}

- (id)init {
    self = [super initWithTutorialIndex:9];
    if (self) {
        isAllowingOverview = YES;
        CGPoint triggerLoc = [self middleOfEntireMap];
        mothTrigger = [[TriggerObject alloc] initWithLocation:triggerLoc];
        [self setCameraLocation:triggerLoc];
        [self setMiddleOfVisibleScreenToCamera];
        mothTrigger.numberOfObjectsNeeded = 16;
        mothTrigger.objectIDNeeded = kObjectCraftMothID;
        mothTrigger.objectImage.scale = Scale2fMake(3.0f, 3.0f);
        [self addCollidableObject:mothTrigger];
        NotificationObject* notiObj = [[NotificationObject alloc] initWithLocation:mothTrigger.objectLocation withDuration:-1.0f];
        [notiObj attachToObject:mothTrigger];
        [self addCollidableObject:notiObj];
        [notiObj release];
        
        for (int row = -1; row < 1; row++) {
            for (int col = -1; col < 1; col++) {
                CGPoint cornerOne = CGPointMake(fullMapBounds.size.width * (1.0f / 8.0f),
                                                fullMapBounds.size.height * (1.0f / 8.0f));
                
                CGPoint cornerTwo = CGPointMake(fullMapBounds.size.width * (7.0f / 8.0f),
                                                fullMapBounds.size.height * (1.0f / 8.0f));
                
                CGPoint cornerThree = CGPointMake(fullMapBounds.size.width * (7.0f / 8.0f),
                                                fullMapBounds.size.height * (7.0f / 8.0f));
                
                CGPoint cornerFour = CGPointMake(fullMapBounds.size.width * (1.0f / 8.0f),
                                                fullMapBounds.size.height * (7.0f / 8.0f));
                
                CGPoint mothOne = CGPointMake(cornerOne.x + (COLLISION_CELL_WIDTH * row),
                                              cornerOne.y + (COLLISION_CELL_HEIGHT * col));
                CGPoint mothTwo = CGPointMake(cornerTwo.x - (COLLISION_CELL_WIDTH * row),
                                              cornerTwo.y + (COLLISION_CELL_HEIGHT * col));
                CGPoint mothThree = CGPointMake(cornerThree.x + (COLLISION_CELL_WIDTH * row),
                                                cornerThree.y - (COLLISION_CELL_HEIGHT * col));
                CGPoint mothFour = CGPointMake(cornerFour.x - (COLLISION_CELL_WIDTH * row),
                                               cornerFour.y - (COLLISION_CELL_HEIGHT * col));
                
                MothCraftObject* mothCraftOne = [[MothCraftObject alloc] initWithLocation:mothOne isTraveling:NO];
                [mothCraftOne setObjectAlliance:kAllianceFriendly];
                [self addTouchableObject:mothCraftOne withColliding:CRAFT_COLLISION_YESNO];
                [mothCraftOne release];
                
                MothCraftObject* mothCraftTwo = [[MothCraftObject alloc] initWithLocation:mothTwo isTraveling:NO];
                [mothCraftTwo setObjectAlliance:kAllianceFriendly];
                [self addTouchableObject:mothCraftTwo withColliding:CRAFT_COLLISION_YESNO];
                [mothCraftTwo release];

                MothCraftObject* mothCraftThree = [[MothCraftObject alloc] initWithLocation:mothThree isTraveling:NO];
                [mothCraftThree setObjectAlliance:kAllianceFriendly];
                [self addTouchableObject:mothCraftThree withColliding:CRAFT_COLLISION_YESNO];
                [mothCraftThree release];

                MothCraftObject* mothCraftFour = [[MothCraftObject alloc] initWithLocation:mothFour isTraveling:NO];
                [mothCraftFour setObjectAlliance:kAllianceFriendly];
                [self addTouchableObject:mothCraftFour withColliding:CRAFT_COLLISION_YESNO];
                [mothCraftFour release];
            }
        }
        
        FingerObject* tempFingerOne = [[FingerObject alloc] initWithStartLocation:CGPointMake(750, 700) withEndLocation:CGPointMake(750, 600) repeats:YES];
        fingerOne = tempFingerOne;
        [self addCollidableObject:tempFingerOne];
        [tempFingerOne setDoesScrollWithScreen:NO];
        [tempFingerOne release];
        
        FingerObject* tempFingerTwo = [[FingerObject alloc] initWithStartLocation:CGPointMake(825, 700) withEndLocation:CGPointMake(825, 600) repeats:YES];
        fingerTwo = tempFingerTwo;
        [self addCollidableObject:tempFingerTwo];
        [tempFingerTwo setDoesScrollWithScreen:NO];
        [tempFingerTwo release];
        
        FingerObject* tempFingerThree = [[FingerObject alloc] initWithStartLocation:CGPointMake(900, 700) withEndLocation:CGPointMake(900, 600) repeats:YES];
        fingerThree = tempFingerThree;
        [self addCollidableObject:tempFingerThree];
        [tempFingerThree setDoesScrollWithScreen:NO];
        [tempFingerThree release];
        
        [helpText setObjectText:@"The map overview shows all the units currently in the game. Drag the white box around and release it on your units to select them."];
    }
    return self;
}

- (BOOL)checkObjective {
    return [mothTrigger isComplete];
}

- (void)updateSceneWithDelta:(float)aDelta {
    [super updateSceneWithDelta:aDelta];
    
    if (!isShowingOverview && [controlledShips count] == 0) {
        fingerOne.isHidden = NO;
        fingerTwo.isHidden = NO;
        fingerThree.isHidden = NO;
    } else {
        fingerOne.isHidden = YES;
        fingerTwo.isHidden = YES;
        fingerThree.isHidden = YES;
    }
}

@end