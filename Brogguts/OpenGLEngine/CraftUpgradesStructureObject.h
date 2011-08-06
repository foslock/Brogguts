//
//  CraftUpgradesStructureObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/11/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StructureObject.h"

extern NSString* const kCraftUpgradeTexts[8];

@interface CraftUpgradesStructureObject : StructureObject {
    BOOL isBeingPressed;
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling;

- (void)presentCraftUpgradeDialogueWithObjectID:(int)objectID;

@end
