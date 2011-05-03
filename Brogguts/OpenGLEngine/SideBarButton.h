//
//  SideBarButton.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TiledButtonObject;

@interface SideBarButton : NSObject {
	NSString* buttonText;
	BOOL isPressed;
	int buttonWidth;
	int buttonHeight;
	CGPoint buttonCenter;
    TiledButtonObject* button;
}

@property (retain) NSString* buttonText;
@property (nonatomic, assign) BOOL isPressed;
@property (nonatomic, assign) int buttonWidth;
@property (nonatomic, assign) int buttonHeight;
@property (nonatomic, assign) CGPoint buttonCenter;
@property (assign) TiledButtonObject* button;

- (CGRect)buttonRect;
- (id)initWithWidth:(float)width withHeight:(float)height withCenter:(CGPoint)center;
- (void)renderButtonWithScroll:(Vector2f)scroll;

@end
