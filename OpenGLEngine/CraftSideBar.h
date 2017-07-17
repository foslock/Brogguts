//
//  CraftSideBar.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/27/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SideBarObject.h"

#define CRAFT_BUTTON_DRAG_SEGMENTS 10

enum CraftButtonIDs {
	kCraftButtonAntID, // Basic
	kCraftButtonMothID,
	kCraftButtonBeetleID,
	kCraftButtonMonarchID,
	kCraftButtonCamelID, // Advanced
	kCraftButtonRatID,
	kCraftButtonSpiderID,
	kCraftButtonEagleID,
};

extern NSString* const kCraftButtonLockedText;

@interface CraftSideBar : SideBarObject {
	int currentDragButtonID;
	CGPoint currentDragButtonLocation;
}

@end
