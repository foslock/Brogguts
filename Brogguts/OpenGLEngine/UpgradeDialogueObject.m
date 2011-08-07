//
//  UpgradeDialogueObject.m
//  OpenGLEngine
//
//  Created by James Lockwood on 8/6/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "UpgradeDialogueObject.h"
#import "TiledButtonObject.h"
#import "EndMissionObject.h"
#import "BitmapFont.h"
#import "ImageRenderSingleton.h"
#import "StructureObject.h"
#import "CraftAndStructures.h"

@implementation UpgradeDialogueObject
@synthesize upgradesStructure;

- (void)dealloc {
    [upgradesStructure release];
    [confirmButton release];
    [cancelButton release];
    [super dealloc];
}

- (id)initWithUpgradeID:(int)upgradeID {
    self = [super init];
    if (self) {
        objectUpgradeID = upgradeID;
    }
    return self;
}

- (void)initializeMe {
    [super initializeMe];
    isShowingHoldToDismiss = NO;
    CGRect buttonRect = CGRectMake(0, 0, END_MISSION_BUTTON_WIDTH, END_MISSION_BUTTON_HEIGHT);
    cancelButton = [[TiledButtonObject alloc]
                    initWithRect:CGRectOffset(buttonRect,
                                              totalRect.origin.x,
                                              kPadScreenLandscapeHeight * (1.0f/5.0f))];
    confirmButton = [[TiledButtonObject alloc]
                     initWithRect:CGRectOffset(buttonRect,
                                               totalRect.origin.x + totalRect.size.width - (END_MISSION_BUTTON_WIDTH),
                                               kPadScreenLandscapeHeight * (1.0f/5.0f))];
    [cancelButton setColor:Color4fMake(1.0f, 0.8f, 0.8f, 1.0f)];
    [confirmButton setColor:Color4fMake(0.8f, 1.0f, 0.8f, 1.0f)];
}

- (void)renderDialogueObjectWithFont:(BitmapFont *)font {
    [super renderDialogueObjectWithFont:font];
    if (!isZoomingBoxIn && !isZoomingBoxOut) {
        [confirmButton renderCenteredAtPoint:confirmButton.objectLocation withScrollVector:Vector2fZero];
        [cancelButton renderCenteredAtPoint:cancelButton.objectLocation withScrollVector:Vector2fZero];
        [font renderStringJustifiedInFrame:[cancelButton drawRect]
                             justification:BitmapFontJustification_MiddleCentered text:@"Cancel" onLayer:kLayerHUDTopLayer];
        [font renderStringJustifiedInFrame:[confirmButton drawRect]
                             justification:BitmapFontJustification_MiddleCentered text:@"Purchase" onLayer:kLayerHUDTopLayer];
    }
}

- (void)updateDialogueObjectWithDelta:(float)aDelta {
    [super updateDialogueObjectWithDelta:aDelta];
    
    if ([cancelButton wasJustReleased]) {
        isWantingToBeDismissed = YES;
        // Just dismiss dialogue
    } else if ([confirmButton wasJustReleased]) {
        // MAKE SURE THE STRUCTURE IS STILL VALID!
        if (![upgradesStructure destroyNow]) {
            
            // Start the upgrade
            if (upgradesStructure.objectType == kObjectStructureCraftUpgradesID) {
                CraftUpgradesStructureObject* structure = (CraftUpgradesStructureObject*)upgradesStructure;
                if (![structure isCurrentlyProcessingUpgrade]) {
                    [structure startUpgradeForCraft:objectUpgradeID withStartTime:0.0f];
                }
            }
            if (upgradesStructure.objectType == kObjectStructureStructureUpgradesID) {
                StructureUpgradesStructureObject* structure = (StructureUpgradesStructureObject*)upgradesStructure;
                if (![structure isCurrentlyProcessingUpgrade]) {
                    [structure startUpgradeForStructure:objectUpgradeID withStartTime:0.0f];
                }
            }
        }
        isWantingToBeDismissed = YES;
    }
    
    [confirmButton updateObjectLogicWithDelta:aDelta];
    [cancelButton updateObjectLogicWithDelta:aDelta];
}

- (void)touchesBeganAtLocation:(CGPoint)location {
    [super touchesBeganAtLocation:location];
    [confirmButton touchesBeganAtLocation:location];
    [cancelButton touchesBeganAtLocation:location];
}

- (void)touchesEndedAtLocation:(CGPoint)location {
    [super touchesEndedAtLocation:location];
    [confirmButton touchesEndedAtLocation:location];
    [cancelButton touchesEndedAtLocation:location];
}

- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation {
    [super touchesMovedToLocation:toLocation from:fromLocation];
    [confirmButton touchesMovedToLocation:toLocation from:fromLocation];
    [cancelButton touchesMovedToLocation:toLocation from:fromLocation];
}

@end
