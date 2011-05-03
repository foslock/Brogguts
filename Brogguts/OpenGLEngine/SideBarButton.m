//
//  SideBarButton.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "SideBarButton.h"
#import "TiledButtonObject.h"

@implementation SideBarButton
@synthesize buttonText, buttonHeight, buttonWidth, buttonCenter, isPressed, button;

- (void)dealloc {
    [button release];
    [super dealloc];
}

- (id)initWithWidth:(float)width withHeight:(float)height withCenter:(CGPoint)center {
	self = [super init];
	if (self) {
		buttonWidth = (int)width;
		buttonHeight = (int)height;
		buttonCenter = center;
        button = [[TiledButtonObject alloc] initWithRect:[self buttonRect]];
	}
	return self;
}

- (void)setIsPressed:(BOOL)pressed {
    isPressed = pressed;
    [button setIsPushed:pressed];
}

- (CGRect)buttonRect {
	return CGRectMake((int)(buttonCenter.x - buttonWidth / 2),
					  (int)(buttonCenter.y - buttonHeight / 2),
					  buttonWidth + (buttonWidth % 2),
					  buttonHeight + (buttonHeight % 2));
}

- (void)renderButtonWithScroll:(Vector2f)scroll {
    [button setDrawRect:[self buttonRect]];
    [button renderCenteredAtPoint:buttonCenter withScrollVector:scroll];
}

@end
