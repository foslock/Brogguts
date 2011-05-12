//
//  StructureUpgradesStructureObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/11/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StructureObject.h"

@interface StructureUpgradesStructureObject : StructureObject {
    BOOL isBeingPressed;
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling;

@end
