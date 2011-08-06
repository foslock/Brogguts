//
//  CraftUpgradesSideBar.h
//  OpenGLEngine
//
//  Created by James Lockwood on 8/6/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "SideBarObject.h"

@class CraftUpgradesStructureObject;

@interface CraftUpgradesSideBar : SideBarObject {
    CraftUpgradesStructureObject* upgradesStructure;
}

@property (nonatomic, retain) CraftUpgradesStructureObject* upgradesStructure;

- (id)initWithStructure:(CraftUpgradesStructureObject*)structure;

@end
