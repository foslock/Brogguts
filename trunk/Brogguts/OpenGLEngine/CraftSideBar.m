//
//  CraftSideBar.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/27/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CraftSideBar.h"
#import "SideBarButton.h"
#import "BroggutScene.h"
#import "SideBarController.h"
#import "CraftSideBar.h"

@implementation CraftSideBar

- (id)init {
	self = [super init];
	if (self) {
		for (int i = 0; i < 8; i++) {
			SideBarButton* button = [[SideBarButton alloc] initWithWidth:(SIDEBAR_WIDTH - 32.0f) withHeight:100 withCenter:CGPointMake(SIDEBAR_WIDTH / 2, 50)];
			[buttonArray addObject:button];
			[button release];
		}
	}
	return self;
}

- (void)updateSideBar {
	
	[super updateSideBar];
}

- (void)renderWithOffset:(Vector2f)vector {
	
	[super renderWithOffset:vector];
}

- (void)touchesTappedAtLocation:(CGPoint)location {
	
	[super touchesTappedAtLocation:location];
}

- (void)touchesEndedAtLocation:(CGPoint)location {
	
	[super touchesEndedAtLocation:location];
}

@end
