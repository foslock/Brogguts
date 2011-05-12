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
#import "CraftSideBar.h"
#import "StructureSideBar.h"
#import "BroggutsSideBar.h"
#import "GameController.h"
#import "BroggupediaViewController.h"

@implementation MainMenuSideBar

- (id)init {
	self = [super init];
	if (self) {
		for (int i = 0; i < 5; i++) {
			SideBarButton* button = [[SideBarButton alloc] initWithWidth:(SIDEBAR_WIDTH - 32.0f) withHeight:100 withCenter:CGPointMake(SIDEBAR_WIDTH / 2, 50)];
			[buttonArray addObject:button];
			switch (i) {
				case 0:
					[button setButtonText:@"Refinery"];
                    [button setIsDisabled:YES];
					break;
				case 1:
					[button setButtonText:@"Craft"];
                    [button setIsDisabled:YES];
					break;
				case 2:
					[button setButtonText:@"Structures"];
                    [button setIsDisabled:YES];
					break;
                case 3:
					[button setButtonText:@"Broggupedia"];
					break;
                case 4:
					[button setButtonText:@"MAIN MENU"];
					break;
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
    BroggutScene* scene = [[GameController sharedGameController] currentScene];
    if (scene.numberOfRefineries > 0) {
        SideBarButton* refinery = [buttonArray objectAtIndex:0];
        if ([refinery isDisabled])
            [refinery setIsDisabled:NO];
    }
    if (scene.isAllowingCraft) {
        SideBarButton* craft = [buttonArray objectAtIndex:1];
        if ([craft isDisabled])
            [craft setIsDisabled:NO];
    }
    if (scene.isAllowingStructures) {
        SideBarButton* structures = [buttonArray objectAtIndex:2];
        if ([structures isDisabled])
            [structures setIsDisabled:NO];
    }
}

- (void)buttonReleasedWithID:(int)buttonID atLocation:(CGPoint)location {
    SideBarButton* button = [buttonArray objectAtIndex:buttonID];
    if ([button isPressed]) {
        if (buttonID == 0) {
            BroggutsSideBar* newMenu = [[BroggutsSideBar alloc] init];
            [newMenu setMyController:myController];
            [myController pushSideBarObject:newMenu];
            [newMenu release];
        }
        if (buttonID == 1) {
            CraftSideBar* newMenu = [[CraftSideBar alloc] init];
            [newMenu setMyController:myController];
            [myController pushSideBarObject:newMenu];
            [newMenu release];
        }
        if (buttonID == 2) {
            StructureSideBar* newMenu = [[StructureSideBar alloc] init];
            [newMenu setMyController:myController];
            [myController pushSideBarObject:newMenu];
            [newMenu release];
        }
        if (buttonID == 3) {
            [[GameController sharedGameController] presentBroggupedia];
        }
        if (buttonID == 4) {
            [myController moveSideBarOut];
            [[GameController sharedGameController] returnToMainMenuWithSave:YES];
        }
    }
    [super buttonReleasedWithID:buttonID atLocation:location];
}

@end
