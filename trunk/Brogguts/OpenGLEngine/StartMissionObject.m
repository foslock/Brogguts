//
//  StartMissionObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/28/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "StartMissionObject.h"
#import "TextObject.h"
#import "TiledButtonObject.h"
#import "BroggutScene.h"
#import "ImageRenderSingleton.h"
#import "GameController.h"
#import "CampaignScene.h"
#import "GameplayConstants.h"
#import "BitmapFont.h"
#import "PlayerProfile.h"

@implementation StartMissionObject
@synthesize rect;

- (id)init
{
    self = [super initWithImage:nil withLocation:[currentScene middleOfVisibleScreen] withObjectType:kObjectStartMissionObjectID];
    if (self) {
        isCheckedForCollisions = NO;
        isTouchable = YES;
        CGPoint center = CGPointMake(kPadScreenLandscapeWidth / 2, kPadScreenLandscapeHeight / 2);
        CGRect temprect = CGRectMake(0, 0, kPadScreenLandscapeWidth, kPadScreenLandscapeHeight);
        rect = CGRectInset(temprect,
                           (kPadScreenLandscapeWidth - START_MISSION_BACKGROUND_WIDTH) / 2,
                           (kPadScreenLandscapeHeight - START_MISSION_BACKGROUND_HEIGHT) / 2);
        CGRect buttonRect = CGRectMake(rect.origin.x + START_MISSION_BUTTON_INSET,
                                       rect.origin.y + START_MISSION_BUTTON_INSET,
                                       START_MISSION_BUTTON_WIDTH,
                                       START_MISSION_BUTTON_HEIGHT);
        background = [[TiledButtonObject alloc] initWithRect:rect];
        [background setColor:Color4fMake(0.8f, 0.8f, 0.8f, 1.0f)];
        [background setIsPushable:NO];
        menuButton = [[TiledButtonObject alloc] initWithRect:buttonRect];
        CGRect confirmRect = CGRectOffset(buttonRect, START_MISSION_BACKGROUND_WIDTH - START_MISSION_BUTTON_WIDTH - (START_MISSION_BUTTON_INSET * 2), 0);
        confirmButton = [[TiledButtonObject alloc] initWithRect:confirmRect];
        CGPoint textPoint = CGPointMake(center.x, center.y + 150);
        headerText = [[TextObject alloc] initWithFontID:kFontBlairID Text:@"TEXT" withLocation:textPoint withDuration:-1.0f];
        textPoint = CGPointMake(center.x, center.y + 60);
        missionTextOne = [[TextObject alloc] initWithFontID:kFontBlairID Text:@"" withLocation:textPoint withDuration:-1.0f];
        textPoint = CGPointMake(center.x, center.y + 20);
        missionTextTwo = [[TextObject alloc] initWithFontID:kFontBlairID Text:@"" withLocation:textPoint withDuration:-1.0f];
        textPoint = CGPointMake(center.x, center.y - 20);
        missionTextThree = [[TextObject alloc] initWithFontID:kFontBlairID Text:@"" withLocation:textPoint withDuration:-1.0f];
        textPoint = CGPointMake(center.x, center.y - 60);
        missionTextFour = [[TextObject alloc] initWithFontID:kFontBlairID Text:@"" withLocation:textPoint withDuration:-1.0f];
        buttonArray = [[NSMutableArray alloc] initWithCapacity:3];
        textArray = [[NSMutableArray alloc] initWithCapacity:3];
        [buttonArray addObject:background];
        [buttonArray addObject:menuButton];
        [buttonArray addObject:confirmButton];
        [textArray addObject:headerText];
        [textArray addObject:missionTextOne];
        [textArray addObject:missionTextTwo];
        [textArray addObject:missionTextThree];
        [textArray addObject:missionTextFour];
        
        for (TextObject* text in textArray) {
            [text setScrollWithBounds:NO];
            [text setRenderLayer:kLayerHUDTopLayer];
        }
        [background setRenderLayer:kLayerHUDBottomLayer];
        [confirmButton setRenderLayer:kLayerHUDMiddleLayer];
        [menuButton setRenderLayer:kLayerHUDMiddleLayer];
        
        [background release];
        [confirmButton release];
        [menuButton release];
        [headerText release];
        [missionTextOne release];
        [missionTextTwo release];
        [missionTextThree release];
        [missionTextFour release];
    }
    return self;
}

- (void)setMissionHeader:(NSString*)header {
    [headerText setObjectText:header];
}

- (void)setMissionTextOne:(NSString*)text {
    [missionTextOne setObjectText:text];
}

- (void)setMissionTextTwo:(NSString*)text {
    [missionTextTwo setObjectText:text];
}

- (void)setMissionTextThree:(NSString*)text {
    [missionTextThree setObjectText:text];
}

- (void)setMissionTextFour:(NSString*)text {
    [missionTextFour setObjectText:text];
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
    CGPoint center = CGPointMake(kPadScreenLandscapeWidth / 2, kPadScreenLandscapeHeight / 2);
    [super renderCenteredAtPoint:center withScrollVector:Vector2fZero];
    for (TiledButtonObject* object in buttonArray) {
        [object renderCenteredAtPoint:object.objectLocation withScrollVector:Vector2fZero];
    }
    
    BitmapFont* font = [[[self currentScene] fontArray] objectAtIndex:kFontGothicID];
    for (TextObject* text in textArray) {
        [text renderWithFont:font withScrollVector:Vector2fZero centered:YES];
    }
    
    // Render button text
    BitmapFont* buttonfont = [[[self currentScene] fontArray] objectAtIndex:kFontBlairID];
    [buttonfont renderStringJustifiedInFrame:[menuButton drawRect] justification:BitmapFontJustification_MiddleCentered text:@"Main Menu" onLayer:kLayerHUDTopLayer];
    [buttonfont renderStringJustifiedInFrame:[confirmButton drawRect] justification:BitmapFontJustification_MiddleCentered text:@"Continue" onLayer:kLayerHUDTopLayer];
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    CampaignScene* scene = (CampaignScene*)[self currentScene];
    if ([confirmButton wasJustReleased]) {
        if ([scene isKindOfClass:[CampaignScene class]]) {
            [scene setIsStartingMission:NO];
            [scene setIsMissionPaused:NO];
        }
    } else if ([menuButton wasJustReleased]) {
        if (![scene isStartingMission] || [scene isLoadedScene]) {
            [[GameController sharedGameController] returnToMainMenuWithSave:YES];
        } else {
            [[GameController sharedGameController] returnToMainMenuWithSave:NO];
        }
    }
    
    for (TiledButtonObject* object in buttonArray) {
        [object updateObjectLogicWithDelta:aDelta];
    }
    for (TextObject* text in textArray) {
        [text updateObjectLogicWithDelta:aDelta];
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
    [textArray release];
    [buttonArray release];
    [super dealloc];
}

@end
