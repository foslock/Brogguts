//
//  CloudSingleton.h
//  OpenGLEngine
//
//  Created by James Lockwood on 1/29/12.
//  Copyright (c) 2012 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Structures.h"

@class Image;

@interface CloudSingleton : NSObject {
    int widthCells;
    int heightCells;
    BOOL hasCreatedVertexArray;
    Color4f* vertexArray; // 2D array on 1D
    NSMutableArray* cloudTiledImages; // 2D array on 1D
}

+ (CloudSingleton*)sharedCloudSingleton;

- (id)initCloudSingleton;

- (CGPoint)pointForArrayIndex:(int)index;

- (Image*)tileForCGPoint:(CGPoint)point; // Wraps tiles in a larger tile pattern
- (Image*)tileForXIndex:(int)x forYIndex:(int)y; // Used only for the first screen's worth of tiles
- (Color4f*)vertexPointerForCGPoint:(CGPoint)point;
- (Color4f)vertexForCGPoint:(CGPoint)point;
- (Color4f*)vertexPointerForXIndex:(int)x forYIndex:(int)y;
- (Color4f)vertexForXIndex:(int)x forYIndex:(int)y;

- (void)setWidthCells:(int)cellsWide withHeight:(int)cellsHigh;
- (void)updateCloudData;
- (void)renderCloudInRect:(CGRect)rect WithScroll:(Vector2f)scroll;

@end
