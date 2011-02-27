//
//  StructureSideBar.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/27/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SideBarObject.h"

#define STRUCTURE_BUTTON_DRAG_SEGMENTS 10

@interface StructureSideBar : SideBarObject {
	int currentDragButtonID;
	CGPoint currentDragButtonLocation;
}

@end
