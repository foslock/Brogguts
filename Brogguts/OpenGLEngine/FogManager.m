//
//  FogManager.m
//  OpenGLEngine
//
//  Created by James Lockwood on 1/15/12.
//  Copyright (c) 2012 Games in Dorms. All rights reserved.
//

#import "FogManager.h"
#import "GameplayConstants.h"
#import "Global.h"
#import "Primitives.h"
#import "Structures.h"
#import "GameController.h"

static float reusedGridColorData[24];

@implementation FogManager
@synthesize isDrawingFogOnScene, isDrawingFogOnOverview;

- (void)dealloc {
    if (upperFogData) {
        free(upperFogData);
    }
    if (lowerFogData) {
        free(lowerFogData);
    }
    [super dealloc];
}

- (int)indexForXindex:(int)x forYindex:(int)y {
    return (y * cellsWide) + x;
}

- (CGPoint)pointForIndex:(int)index {
    CGPoint point;
    point.x = index % cellsWide;
    point.y = index / cellsWide;
    return point;
}

- (id)initWithWidthCells:(int)widthCells withHeightCells:(int)heightCells withResolution:(int)res {
    self = [super init];
    if (self) {
        cellsWide = widthCells;
        cellsHigh = heightCells;
        gridResolution = res;
        upperFogData = malloc( cellsHigh * cellsWide * sizeof(*upperFogData) );
        lowerFogData = malloc( cellsHigh * cellsWide * sizeof(*lowerFogData) );
        isDrawingFogOnScene = YES;
        isDrawingFogOnOverview = YES;
        [self resetAllFog];
    }
    return self;
}

- (void)clearAllFog {
    for (int i = 0; i < cellsWide * cellsHigh; i++) {
        upperFogData[i] = 0.0f;
        lowerFogData[i] = 0.0f;
    }
}

- (void)resetAllFog {
    for (int i = 0; i < cellsWide * cellsHigh; i++) {
        upperFogData[i] = FOG_UPPER_MAX_ALPHA;
        lowerFogData[i] = FOG_LOWER_MAX_ALPHA;
    }
}

- (void)resetLowerFog {
    for (int i = 0; i < cellsWide * cellsHigh; i++) {
        lowerFogData[i] = FOG_LOWER_MAX_ALPHA;
    }
}

- (float)upperFogValueAtPoint:(CGPoint)point {
    if (!isDrawingFogOnScene && !isDrawingFogOnOverview) {
        return 0.0f;
    }
    int xIndex = (point.x / COLLISION_CELL_WIDTH);
    int yIndex = (point.y / COLLISION_CELL_HEIGHT);
    int gridIndex = [self indexForXindex:xIndex forYindex:yIndex];
    return upperFogData[gridIndex];
}

- (float)lowerFogValueAtPoint:(CGPoint)point {
    if (!isDrawingFogOnScene && !isDrawingFogOnOverview) {
        return 0.0f;
    }
    int xIndex = (point.x / COLLISION_CELL_WIDTH);
    int yIndex = (point.y / COLLISION_CELL_HEIGHT);
    int gridIndex = [self indexForXindex:xIndex forYindex:yIndex];
    return lowerFogData[gridIndex];
}

- (void)removeFogAtPoint:(CGPoint)point withRadius:(int)radius withIntensity:(float)intensity {
    int xIndex = (point.x / COLLISION_CELL_WIDTH);
    int yIndex = (point.y / COLLISION_CELL_HEIGHT);
    
    int gridIndex = [self indexForXindex:xIndex forYindex:yIndex];
    upperFogData[gridIndex] = 0.0f;
    lowerFogData[gridIndex] = 0.0f;
    int blockCountRadius = radius / COLLISION_CELL_WIDTH;
    
    int startYIndex = (point.y - radius) / COLLISION_CELL_HEIGHT;
    int startXIndex = (point.x - radius) / COLLISION_CELL_WIDTH;
    
    for (int y = 0; y < blockCountRadius*2; y++) { // For each row in the circle
        int curYIndex = startYIndex + y;
        if (curYIndex < 0 || curYIndex >= cellsHigh) {
            continue;
        }
        for (int x = 0; x < blockCountRadius*2; x++) {
            int curXIndex = startXIndex + x;
            if (curXIndex < 0 || curXIndex >= cellsWide) {
                continue;
            }
            float dist = GetDistanceBetweenPointsSquared(point,
                                                         CGPointMake((curXIndex * COLLISION_CELL_WIDTH) + (COLLISION_CELL_WIDTH/2),
                                                                     (curYIndex * COLLISION_CELL_HEIGHT) + (COLLISION_CELL_HEIGHT/2)));
            int index = [self indexForXindex:curXIndex forYindex:curYIndex];
            if (upperFogData[index] == 0.0f) { // If it's gone, don't change it
                lowerFogData[index] = 0.0f;
                continue;
            }
            float distRatio = dist / POW2(radius);
            if (distRatio < intensity) {
                // If the the distance is under the intensity, then complete clear the fog
                upperFogData[index] = 0.0f;
                lowerFogData[index] = 0.0f;
            } else {
                // If the distance is greater, than fade out the squares
                if (distRatio < upperFogData[index]) {
                    upperFogData[index] = distRatio;
                    lowerFogData[index] = CLAMP(distRatio, 0.0f, FOG_LOWER_MAX_ALPHA);
                }
            }
        }
    }
}

- (float*)colorArrayForFogBlockWithXIndex:(int)x withYIndex:(int)y isInScene:(BOOL)inScene withMaxAlpha:(float)maxAlpha {
    float* colors = reusedGridColorData;
    int currentIndex = [self indexForXindex:x forYindex:y];
    int colorIndex = 0;
    for (int vert = 0; vert < 6; vert++) {
        if (inScene) {
            colors[colorIndex++] = FOG_SHADE_OF_GRAY_SCENE;
            colors[colorIndex++] = FOG_SHADE_OF_GRAY_SCENE;
            colors[colorIndex++] = FOG_SHADE_OF_GRAY_SCENE; 
        } else {
            colors[colorIndex++] = FOG_SHADE_OF_GRAY_OVERVIEW;
            colors[colorIndex++] = FOG_SHADE_OF_GRAY_OVERVIEW;
            colors[colorIndex++] = FOG_SHADE_OF_GRAY_OVERVIEW; 
        }
        
        float newAlpha = MAX(upperFogData[currentIndex], lowerFogData[currentIndex]);
        // The alpha value is the important one
        if (vert == 0) { // Bottom Left
            if ( (x-1 >= 0) && (y-1 >= 0) ) {
                int botLeft = [self indexForXindex:x-1 forYindex:y-1];
                int bot = [self indexForXindex:x forYindex:y-1];
                int left = [self indexForXindex:x-1 forYindex:y];
                float alpha1 = MAX(upperFogData[botLeft], lowerFogData[botLeft]);
                float alpha2 = MAX(upperFogData[bot], lowerFogData[bot]);
                float alpha3 = MAX(upperFogData[left], lowerFogData[left]);
                newAlpha = (alpha1 + alpha2 + alpha3 + newAlpha) / 4.0f;
            }
        }
        if (vert == 1 || vert == 4) { // Top Left
            if ( (x-1 >= 0) && (y+1 < cellsHigh) ) {
                int topLeft = [self indexForXindex:x-1 forYindex:y+1];
                int top = [self indexForXindex:x forYindex:y+1];
                int left = [self indexForXindex:x-1 forYindex:y];
                float alpha1 = MAX(upperFogData[topLeft], lowerFogData[topLeft]);
                float alpha2 = MAX(upperFogData[top], lowerFogData[top]);
                float alpha3 = MAX(upperFogData[left], lowerFogData[left]);
                newAlpha = (alpha1 + alpha2 + alpha3 + newAlpha) / 4.0f;
            }
        }
        if (vert == 2 || vert == 3) { // Bottom right
            if ( (x+1 < cellsWide) && (y-1 >= 0) ) {
                int botRight = [self indexForXindex:x+1 forYindex:y-1];
                int bot = [self indexForXindex:x forYindex:y-1];
                int right = [self indexForXindex:x+1 forYindex:y];
                float alpha1 = MAX(upperFogData[botRight], lowerFogData[botRight]);
                float alpha2 = MAX(upperFogData[bot], lowerFogData[bot]);
                float alpha3 = MAX(upperFogData[right], lowerFogData[right]);
                newAlpha = (alpha1 + alpha2 + alpha3 + newAlpha) / 4.0f;
            }
        }
        if (vert == 5) { // Top right
            if ( (x+1 < cellsWide) && (y+1 < cellsHigh) ) {
                int topRight = [self indexForXindex:x+1 forYindex:y+1];
                int top = [self indexForXindex:x forYindex:y+1];
                int right = [self indexForXindex:x+1 forYindex:y];
                float alpha1 = MAX(upperFogData[topRight], lowerFogData[topRight]);
                float alpha2 = MAX(upperFogData[top], lowerFogData[top]);
                float alpha3 = MAX(upperFogData[right], lowerFogData[right]);
                newAlpha = (alpha1 + alpha2 + alpha3 + newAlpha) / 4.0f;                
            }
        }
        colors[colorIndex++] = CLAMP(newAlpha - (FOG_UPPER_MAX_ALPHA - maxAlpha), 0.0f, maxAlpha);
    }
    return colors;
}

- (void)renderFogInSceneRect:(CGRect)rect withScroll:(Vector2f)scroll {
    if (isDrawingFogOnScene) {
        enablePrimitiveDraw();
        for (int i = 0; i < cellsWide * cellsHigh; i++) {
            CGPoint indexes = [self pointForIndex:i];
            int xIndex = (int)indexes.x;
            int yIndex = (int)indexes.y;
            CGRect thisRect = CGRectMake(xIndex * COLLISION_CELL_WIDTH,
                                         yIndex * COLLISION_CELL_HEIGHT,
                                         COLLISION_CELL_WIDTH, COLLISION_CELL_HEIGHT);
            if (CGRectIntersectsRect(rect, thisRect) || CGRectContainsRect(rect, thisRect)) {
                // First draw the lower fog
                float* colors = [self colorArrayForFogBlockWithXIndex:xIndex withYIndex:yIndex isInScene:YES withMaxAlpha:FOG_UPPER_MAX_ALPHA];
                drawFilledRectWithColors(thisRect, scroll, colors);
            }
        }
        disablePrimitiveDraw();
    }
}

- (BOOL)isGridUnitSurroundedWithCompleteFogWithIndex:(int)index {
    CGPoint point = [self pointForIndex:index];
    int x = (int)point.x;
    int y = (int)point.y;
    
    for (int i = -1; i < 2; i++) {
        for (int j = -1; j < 2; j++) {
            int newX = x + i;
            int newY = y + j;
            if (newX < 0 || newX >= cellsWide ||
                newY < 0 || newY >= cellsHigh) {
                continue;
            }
            int index = [self indexForXindex:newX forYindex:newY];
            float alpha = MAX(upperFogData[index], lowerFogData[index]);
            if (alpha < FOG_UPPER_MAX_ALPHA) {
                return NO;
            }
        }
    }
    return YES;
}

- (void)renderFogInOverviewAtPoint:(CGPoint)point withScale:(Scale2f)scale withAlpha:(float)alpha {
    if (isDrawingFogOnOverview) {
        CGPoint bottomLeft = CGPointMake(point.x - (cellsWide/2 * COLLISION_CELL_WIDTH * scale.x),
                                         point.y - (cellsHigh/2 * COLLISION_CELL_HEIGHT * scale.y));
        
        // Go through and draw the fog, connecting rects that are all the same alpha
        for (int row = 0; row < cellsHigh; row++) {
            BOOL addingToRect = YES;
            CGRect currentRect = CGRectMake(bottomLeft.x, bottomLeft.y, 0, 0);
            for (int col = 0; col < cellsWide; col++) {
                int index = [self indexForXindex:col forYindex:row];
                float thisAlpha = MAX(upperFogData[index], lowerFogData[index]);
                CGRect thisRect = CGRectMake(bottomLeft.x + (col * COLLISION_CELL_WIDTH * scale.x),
                                             bottomLeft.y + (row * COLLISION_CELL_HEIGHT * scale.y),
                                             COLLISION_CELL_WIDTH * scale.x, COLLISION_CELL_HEIGHT * scale.y);
                
                
                if ((thisAlpha == FOG_UPPER_MAX_ALPHA || thisAlpha == FOG_LOWER_MAX_ALPHA) &&
                    addingToRect && [self isGridUnitSurroundedWithCompleteFogWithIndex:index]) {
                    currentRect = CGRectMake(currentRect.origin.x,
                                             bottomLeft.y + (row * COLLISION_CELL_HEIGHT * scale.y),
                                             currentRect.size.width + (COLLISION_CELL_WIDTH * scale.x),
                                             (COLLISION_CELL_HEIGHT * scale.y));
                } else {
                    // Draw the current rect
                    if (currentRect.size.width > 0.0f) {
                        glColor4f(FOG_SHADE_OF_GRAY_OVERVIEW, FOG_SHADE_OF_GRAY_OVERVIEW, FOG_SHADE_OF_GRAY_OVERVIEW, alpha);
                        drawFilledRect(currentRect, Vector2fZero);
                    }
                    currentRect = CGRectZero;
                    addingToRect = NO;
                    
                    if (thisAlpha != 0.0f) {
                        // Draw this rect
                        float* colors = [self colorArrayForFogBlockWithXIndex:col withYIndex:row isInScene:NO withMaxAlpha:alpha];
                        drawFilledRectWithColors(thisRect, Vector2fZero, colors);
                    }
                }
            }
            // Draw the long rect!
            
            if (currentRect.size.width > 0.0f) {
                glColor4f(FOG_SHADE_OF_GRAY_OVERVIEW, FOG_SHADE_OF_GRAY_OVERVIEW, FOG_SHADE_OF_GRAY_OVERVIEW, alpha);
                drawFilledRect(currentRect, Vector2fZero);
                currentRect = CGRectZero;
            }
        }
    }
}

- (void)resetFogWithFogArray:(NSArray*)array {
    for (int i = 0; i < cellsWide * cellsHigh; i++) {
        NSNumber* num = [array objectAtIndex:i];
        upperFogData[i] = [num floatValue];
        // Don't save the lower fog, since it regerates
    }
}

- (NSArray*)arrayFromFogManager {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < cellsWide * cellsHigh; i++) {
        NSNumber* num = [NSNumber numberWithFloat:upperFogData[i]];
        [array addObject:num];
    }
    
    return [array autorelease];
}

@end
