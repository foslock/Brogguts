//
//  SideBarButton.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SideBarButton : NSObject {
	NSString* buttonText;
	BOOL isPressed;
	float buttonWidth;
	float buttonHeight;
	CGPoint buttonCenter;
}

@property (retain) NSString* buttonText;
@property (nonatomic, assign) BOOL isPressed;
@property (nonatomic, assign) float buttonWidth;
@property (nonatomic, assign) float buttonHeight;
@property (nonatomic, assign) CGPoint buttonCenter;

- (CGRect)buttonRect;
- (id)initWithWidth:(float)width withHeight:(float)height withCenter:(CGPoint)center;

@end
