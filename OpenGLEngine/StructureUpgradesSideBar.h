//
//  StructureUpgradesSideBar.h
//  OpenGLEngine
//
//  Created by James Lockwood on 8/6/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "SideBarObject.h"

@class StructureUpgradesStructureObject;

@interface StructureUpgradesSideBar : SideBarObject {
    StructureUpgradesStructureObject* upgradesStructure;
}

@property (nonatomic, retain) StructureUpgradesStructureObject* upgradesStructure;

- (id)initWithStructure:(StructureUpgradesStructureObject*)structure;

@end
