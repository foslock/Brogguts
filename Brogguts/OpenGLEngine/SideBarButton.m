//
//  SideBarButton.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "SideBarButton.h"


@implementation SideBarButton
@synthesize buttonHeight, buttonWidth, buttonCenter;

- (id)initWithWidth:(float)width withHeight:(float)height withCenter:(CGPoint)center {
	self = [super init];
	if (self) {
		buttonWidth = width;
		buttonHeight = height;
		buttonCenter = center;
	}
	return self;
}

- (CGRect)buttonRect {
	return CGRectMake(buttonCenter.x - buttonWidth / 2, buttonCenter.y - buttonHeight / 2, buttonWidth, buttonHeight);
}

@end
