//
//  EndMissionObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/28/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "EndMissionObject.h"
#import "TextObject.h"
#import "TiledButtonObject.h"
#import "BroggutScene.h"
#import "ImageRenderSingleton.h"
#import "GameController.h"
#import "CampaignScene.h"
#import "GameplayConstants.h"

@implementation EndMissionObject
@synthesize rect, wasSuccessfulMission;

- (id)init
{
    self = [super initWithImage:nil withLocation:[currentScene middleOfVisibleScreen] withObjectType:kObjectEndMissionObjectID];
    if (self) {
        isTouchable = YES;
        wasSuccessfulMission = NO;
        CGRect temprect = CGRectMake(0, 0, kPadScreenLandscapeWidth, kPadScreenLandscapeHeight);
        rect = CGRectInset(temprect,
                           (kPadScreenLandscapeWidth - END_MISSION_BACKGROUND_WIDTH) / 2,
                           (kPadScreenLandscapeHeight - END_MISSION_BACKGROUND_HEIGHT) / 2);
        CGRect buttonRect = CGRectMake(rect.origin.x + END_MISSION_BUTTON_INSET,
                                       rect.origin.y + END_MISSION_BUTTON_INSET,
                                       END_MISSION_BUTTON_WIDTH,
                                       END_MISSION_BUTTON_HEIGHT);
        background = [[TiledButtonObject alloc] initWithRect:rect];
        [background setRenderLayer:kLayerTopLayer];
        [background setIsPushable:NO];
        menuButton = [[TiledButtonObject alloc] initWithRect:buttonRect];
        CGRect confirmRect = CGRectOffset(buttonRect, END_MISSION_BACKGROUND_WIDTH - END_MISSION_BUTTON_WIDTH - (END_MISSION_BUTTON_INSET*2), 0);
        confirmButton = [[TiledButtonObject alloc] initWithRect:confirmRect];
        headerText = [[TextObject alloc] initWithFontID:kFontBlairID Text:@"" withLocation:rect.origin withDuration:-1.0f];
        broggutsLeftLabel = [[TextObject alloc] initWithFontID:kFontBlairID Text:@"Brogguts Left: " withLocation:CGPointZero withDuration:-1.0f];
        broggutsEarnedLabel = [[TextObject alloc] initWithFontID:kFontBlairID Text:@"Brogguts Earned: " withLocation:CGPointZero withDuration:-1.0f];
        broggutsTotalLabel = [[TextObject alloc] initWithFontID:kFontBlairID Text:@"Total Brogguts: " withLocation:CGPointZero withDuration:-1.0f];
        broggutsLeftNumber = [[TextObject alloc] initWithFontID:kFontBlairID Text:@"0" withLocation:CGPointZero withDuration:-1.0f];
        broggutsEarnedNumber = [[TextObject alloc] initWithFontID:kFontBlairID Text:@"0" withLocation:CGPointZero withDuration:-1.0f];
        broggutsTotalNumber = [[TextObject alloc] initWithFontID:kFontBlairID Text:@"0" withLocation:CGPointZero withDuration:-1.0f];
        objectArray = [[NSMutableArray alloc] initWithCapacity:10];
        [objectArray addObject:background];
        [objectArray addObject:menuButton];
        [objectArray addObject:confirmButton];
        [objectArray addObject:headerText];
        [objectArray addObject:broggutsLeftLabel];
        [objectArray addObject:broggutsEarnedLabel];
        [objectArray addObject:broggutsTotalLabel];
        [objectArray addObject:broggutsLeftNumber];
        [objectArray addObject:broggutsEarnedNumber];
        [objectArray addObject:broggutsTotalNumber];
        for (CollidableObject* object in objectArray) {
            [object setRenderLayer:kLayerHUDTopLayer];
        }
        [background setRenderLayer:kLayerHUDBottomLayer];
        [menuButton setRenderLayer:kLayerHUDMiddleLayer];
        [confirmButton setRenderLayer:kLayerHUDMiddleLayer];
        
    }
    return self;
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
    CGPoint center = CGPointMake(kPadScreenLandscapeWidth / 2, kPadScreenLandscapeHeight / 2);
    [super renderCenteredAtPoint:center withScrollVector:Vector2fZero];
    for (CollidableObject* object in objectArray) {
        [object renderCenteredAtPoint:object.objectLocation withScrollVector:Vector2fZero];
    }
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    if (wasSuccessfulMission) {
        [headerText setObjectText:@"Mission Successful!"];
    } else {
        [headerText setObjectText:@"Mission Failed!"];
    }
    
    if ([confirmButton wasJustReleased]) {
        BroggutScene* scene = [self currentScene];
        if ([scene isKindOfClass:[CampaignScene class]]) {
            if (wasSuccessfulMission)
                [(CampaignScene*)scene advanceToNextLevel];
            else
                [(CampaignScene*)scene restartCurrentLevel];
        }
    } else if ([menuButton wasJustReleased]) {
        [[GameController sharedGameController] returnToMainMenuWithSave:NO];
    }
    for (CollidableObject* object in objectArray) {
        [object updateObjectLogicWithDelta:aDelta];
    }
}

- (void)touchesBeganAtLocation:(CGPoint)location {
    [super touchesBeganAtLocation:location];
    [menuButton touchesBeganAtLocation:location];
    [confirmButton touchesBeganAtLocation:location];
}

- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation {
    [super touchesMovedToLocation:toLocation from:fromLocation];
    [menuButton touchesMovedToLocation:toLocation from:fromLocation];
    [confirmButton touchesMovedToLocation:toLocation from:fromLocation];
}

- (void)touchesEndedAtLocation:(CGPoint)location {
    [super touchesEndedAtLocation:location];
    [menuButton touchesEndedAtLocation:location];
    [confirmButton touchesEndedAtLocation:location];
}


- (void)dealloc
{
    [objectArray release];
    [background release];
    [menuButton release];
    [confirmButton release];
    [headerText release];
    [broggutsLeftLabel release];
    [broggutsEarnedLabel release];
    [broggutsTotalLabel release];
    [broggutsLeftNumber release];
    [broggutsEarnedNumber release];
    [broggutsTotalNumber release];
    [super dealloc];
}

@end
