//
//  FogManager.h
//  OpenGLEngine
//
//  Created by James Lockwood on 1/15/12.
//  Copyright (c) 2012 Games in Dorms. All rights reserved.
//

// Each scene will have an instance of this
// The grid will be respresented by a 2D (abstracted from 1D) grid with variable resolution (elements per grid square)
// Each value (float) in the grid will represent the alpha of the fog at the corresponding point in the grid
// Each step, every object that has moved will update the grid with new values

#import <Foundation/Foundation.h>

#define FOG_UPDATE_FREQUENCY 4
#define FOG_SHADE_OF_GRAY 0.0f

@interface FogManager : NSObject {
    int gridResolution; // How many units wide a grid cell will be
    float* gridData; // 2D representation on a 1D array
    int cellsWide;
    int cellsHigh;
    BOOL isDrawingFogOnScene;
    BOOL isDrawingFogOnOverview;
}

@property (nonatomic, assign) BOOL isDrawingFogOnScene;
@property (nonatomic, assign) BOOL isDrawingFogOnOverview;

- (id)initWithWidthCells:(int)widthCells withHeightCells:(int)heightCells withResolution:(int)res;

- (void)clearAllFog;
- (void)resetAllFog;

- (float)fogValueAtPoint:(CGPoint)point;
- (void)removeFogAtPoint:(CGPoint)point withRadius:(int)radius withIntensity:(float)intensity;

- (void)renderFogInSceneRect:(CGRect)rect withScroll:(Vector2f)scroll;
- (void)renderFogInOverviewAtPoint:(CGPoint)point withScale:(Scale2f)scale withAlpha:(float)alpha;

- (void)resetFogWithFogArray:(NSArray*)array;
- (NSArray*)arrayFromFogManager;

@end
