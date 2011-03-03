//
//  BroggutsSideBar.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "BroggutsSideBar.h"
#import "SideBarButton.h"
#import "BroggutScene.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "TextObject.h"

@implementation BroggutsSideBar

enum BroggutButtonIDs {
	kBroggutButtonConvert50,
	kBroggutButtonConvert100,
	kBroggutButtonConvert200,
	kBroggutButtonConvert500,
};

- (id)init {
	self = [super init];
	if (self) {
		for (int i = 0; i < 4; i++) {
			SideBarButton* button = [[SideBarButton alloc] initWithWidth:(SIDEBAR_WIDTH - 32.0f) withHeight:100 withCenter:CGPointMake(SIDEBAR_WIDTH / 2, 50)];
			[buttonArray addObject:button];
			switch (i) {
				case kBroggutButtonConvert50:
					[button setButtonText:@"Convert 50B"];
					break;
				case kBroggutButtonConvert100:
					[button setButtonText:@"Convert 100B"];
					break;
				case kBroggutButtonConvert200:
					[button setButtonText:@"Convert 200B"];
					break;
				case kBroggutButtonConvert500:
					[button setButtonText:@"Convert 500B"];
				default:
					break;
			}
			[button release];
		}
	}
	return self;
}

- (void)buttonReleasedWithID:(int)buttonID atLocation:(CGPoint)location {
	[super buttonReleasedWithID:buttonID atLocation:location];
	GameController* controller = [GameController sharedGameController];
	int metalCount = 0;
	BOOL didConvert = NO;
	switch (buttonID) {
		case kBroggutButtonConvert50:
			metalCount = 5;
			if ([[controller currentPlayerProfile] subtractBrogguts:(metalCount * 10) metal:0]) {
				[[controller currentPlayerProfile] addMetal:metalCount];
				didConvert = YES;
			}
			break;
		case kBroggutButtonConvert100:
			metalCount = 10;
			if ([[controller currentPlayerProfile] subtractBrogguts:(metalCount * 10) metal:0]) {
				[[controller currentPlayerProfile] addMetal:metalCount];
				didConvert = YES;
			}
			break;
		case kBroggutButtonConvert200:
			metalCount = 20;
			if ([[controller currentPlayerProfile] subtractBrogguts:(metalCount * 10) metal:0]) {
				[[controller currentPlayerProfile] addMetal:metalCount];
				didConvert = YES;
			}
			break;
		case kBroggutButtonConvert500:
			metalCount = 50;
			if ([[controller currentPlayerProfile] subtractBrogguts:(metalCount * 10) metal:0]) {
				[[controller currentPlayerProfile] addMetal:metalCount];
				didConvert = YES;
			}
			break;
		default:
			didConvert = NO;
			break;
	}
	if (didConvert) {
		// Create a text object telling we added metal
		CGPoint point = [[[controller currentScene] metalCounter] objectLocation];
		NSString* metalString = [NSString stringWithFormat:@"+%i metal", metalCount];
		TextObject* metalText = [[TextObject alloc] initWithFontID:kFontBlairID Text:metalString withLocation:point withDuration:2.0f];
		[metalText setObjectVelocity:Vector2fMake(0.0f, -0.3f)];
		[metalText setFontColor:Color4fMake(0.4f, 0.5f, 1.0f, 1.0f)];
		[metalText setScrollWithBounds:NO];
		[[controller currentScene] addTextObject:metalText];
		[metalText release];
	}
}

@end
