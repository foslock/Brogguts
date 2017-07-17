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
    Color4f* vertexTopArray; // 2D array on 1D, this is the scrolling data
    Color4f* vertexBottomArray; // 2D array on 1D, this is the nonscrolling cloud data
    NSMutableArray* cloudTiledImages; // 2D array on 1D
}

+ (CloudSingleton*)sharedCloudSingleton;

- (id)initCloudSingleton;

- (CGPoint)pointForArrayIndex:(int)index;

- (Image*)tileForCGPoint:(CGPoint)point; // Wraps tiles in a larger tile pattern
- (Image*)tileForXIndex:(int)x forYIndex:(int)y; // Used only for the first screen's worth of tiles
- (Color4f*)topVertexPointerForCGPoint:(CGPoint)point;
- (Color4f)topVertexForCGPoint:(CGPoint)point;
- (Color4f*)topVertexPointerForXIndex:(int)x forYIndex:(int)y;
- (Color4f)topVertexForXIndex:(int)x forYIndex:(int)y;

- (Color4f*)botVertexPointerForCGPoint:(CGPoint)point;
- (Color4f)botVertexForCGPoint:(CGPoint)point;
- (Color4f*)botVertexPointerForXIndex:(int)x forYIndex:(int)y;
- (Color4f)botVertexForXIndex:(int)x forYIndex:(int)y;

- (void)setWidthCells:(int)cellsWide withHeight:(int)cellsHigh;
- (void)updateCloudData;
- (void)renderCloudInRect:(CGRect)rect WithScroll:(Vector2f)scroll;

@end
