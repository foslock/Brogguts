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
#import "SoundSingleton.h"

@implementation BroggutsSideBar

enum BroggutButtonIDs {
	kBroggutButtonConvert50,
	kBroggutButtonConvert100,
	kBroggutButtonConvert200,
	kBroggutButtonConvert500,
};

enum BroggutConvertAmounts {
	kBroggutAmountConvert50 = 5,
	kBroggutAmountConvert100 = 10,
	kBroggutAmountConvert200 = 20,
	kBroggutAmountConvert500 = 50,
};

- (id)init {
	self = [super init];
	if (self) {
		for (int i = 0; i < 4; i++) {
			SideBarButton* button = [[SideBarButton alloc] initWithWidth:(SIDEBAR_WIDTH - 32.0f) withHeight:100 withCenter:CGPointMake(SIDEBAR_WIDTH / 2, 50)];
			[buttonArray addObject:button];
            [button setTextScale:Scale2fMake(0.8f, 0.8f)];
            NSString* buttonText;
			switch (i) {
				case kBroggutButtonConvert50:
                    buttonText = [NSString stringWithFormat:@"%iBg to %iM", kBroggutAmountConvert50 * BROGGUTS_NEEDED_FOR_ONE_METAL, kBroggutAmountConvert50];
					[button setButtonText:buttonText];
					break;
				case kBroggutButtonConvert100:
                    buttonText = [NSString stringWithFormat:@"%iBg to %iM", kBroggutAmountConvert100 * BROGGUTS_NEEDED_FOR_ONE_METAL, kBroggutAmountConvert100];
					[button setButtonText:buttonText];
					break;
				case kBroggutButtonConvert200:
                    buttonText = [NSString stringWithFormat:@"%iBg to %iM", kBroggutAmountConvert200 * BROGGUTS_NEEDED_FOR_ONE_METAL, kBroggutAmountConvert200];
					[button setButtonText:buttonText];
					break;
				case kBroggutButtonConvert500:
                    buttonText = [NSString stringWithFormat:@"%iBg to %iM", kBroggutAmountConvert500 * BROGGUTS_NEEDED_FOR_ONE_METAL, kBroggutAmountConvert500];
					[button setButtonText:buttonText];
				default:
					break;
			}
			[button release];
		}
	}
	return self;
}

- (void)updateSideBar {
    [super updateSideBar];
    int broggutCount = [[[GameController sharedGameController] currentProfile] broggutCount];
    
    if (broggutCount < kBroggutAmountConvert50 * BROGGUTS_NEEDED_FOR_ONE_METAL) {
        SideBarButton* button = [buttonArray objectAtIndex:kBroggutButtonConvert50];
        [button setIsDisabled:YES];
    } else {
        SideBarButton* button = [buttonArray objectAtIndex:kBroggutButtonConvert50];
        [button setIsDisabled:NO];
    }
    
    if (broggutCount < kBroggutAmountConvert100 * BROGGUTS_NEEDED_FOR_ONE_METAL) {
        SideBarButton* button = [buttonArray objectAtIndex:kBroggutButtonConvert100];
        [button setIsDisabled:YES];
    } else {
        SideBarButton* button = [buttonArray objectAtIndex:kBroggutButtonConvert100];
        [button setIsDisabled:NO];
    }
    
    if (broggutCount < kBroggutAmountConvert200 * BROGGUTS_NEEDED_FOR_ONE_METAL) {
        SideBarButton* button = [buttonArray objectAtIndex:kBroggutButtonConvert200];
        [button setIsDisabled:YES];
    } else {
        SideBarButton* button = [buttonArray objectAtIndex:kBroggutButtonConvert200];
        [button setIsDisabled:NO];
    }
    
    if (broggutCount < kBroggutAmountConvert500 * BROGGUTS_NEEDED_FOR_ONE_METAL) {
        SideBarButton* button = [buttonArray objectAtIndex:kBroggutButtonConvert500];
        [button setIsDisabled:YES];
    } else {
        SideBarButton* button = [buttonArray objectAtIndex:kBroggutButtonConvert500];
        [button setIsDisabled:NO];
    }
}

- (void)buttonReleasedWithID:(int)buttonID atLocation:(CGPoint)location {
    SideBarButton* button = [buttonArray objectAtIndex:buttonID];
    if ([button isPressed]) {
        [[SoundSingleton sharedSoundSingleton] playSoundWithKey:kSoundFileNames[kSoundFileButtonConfirm]];
        BroggutScene* scene = [[GameController sharedGameController] currentScene];
        switch (buttonID) {
            case kBroggutButtonConvert50:
                [scene refineMetalOutOfBrogguts:kBroggutAmountConvert50];
                break;
            case kBroggutButtonConvert100:
                [scene refineMetalOutOfBrogguts:kBroggutAmountConvert100];
                break;
            case kBroggutButtonConvert200:
                [scene refineMetalOutOfBrogguts:kBroggutAmountConvert200];
                break;
            case kBroggutButtonConvert500:
                [scene refineMetalOutOfBrogguts:kBroggutAmountConvert500];
                break;
            default:
                break;
        }
    }
    [super buttonReleasedWithID:buttonID atLocation:location];
}

@end
