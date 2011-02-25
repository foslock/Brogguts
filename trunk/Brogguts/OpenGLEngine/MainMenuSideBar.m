//
//  MainMenuSideBar.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "MainMenuSideBar.h"
#import "SideBarButton.h"
#import "BroggutScene.h"
#import "SideBarController.h"

@implementation MainMenuSideBar

- (id)init {
	self = [super init];
	if (self) {
		for (int i = 0; i < 5; i++) {
			SideBarButton* button = [[SideBarButton alloc] initWithWidth:(SIDEBAR_WIDTH - 32.0f) withHeight:128 withCenter:CGPointMake(SIDEBAR_WIDTH / 2, 50)];
			[buttonArray addObject:button];
			[button release];
		}
	}
	return self;
}

- (void)buttonReleasedWithID:(int)buttonID {
	if (buttonID == 0) {
		MainMenuSideBar* newMenu = [[MainMenuSideBar alloc] init];
		[newMenu setMyController:myController];
		[myController pushSideBarObject:newMenu];
		[newMenu release];
	}
}

@end
