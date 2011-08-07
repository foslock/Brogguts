//
//  StructureUpgradesStructureObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/11/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StructureObject.h"

extern NSString* const kStructureUpgradeTexts[8];

@interface StructureUpgradesStructureObject : StructureObject {
    BOOL isBeingPressed;
    int pressedObjectID;
    
    BOOL isCurrentlyProcessingUpgrade;
    int currentUpgradeObjectID;
    float currentUpgradeProgress; // In seconds
    float upgradeTotalGoal; // In seconds
}

@property (readonly) BOOL isCurrentlyProcessingUpgrade;

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling;

- (void)presentStructureUpgradeDialogueWithObjectID:(int)objectID;

- (void)startUpgradeForStructure:(int)objectID withStartTime:(float)startTime;


@end
