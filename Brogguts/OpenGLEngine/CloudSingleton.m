//
//  CloudSingleton.m
//  OpenGLEngine
//
//  Created by James Lockwood on 1/29/12.
//  Copyright (c) 2012 Games in Dorms. All rights reserved.
//

#import "CloudSingleton.h"
#import "Image.h"
#import "ImageRenderSingleton.h"
#import "GameController.h"

#define SCREEN_TILES_WIDE 8
#define SCREEN_TILES_HIGH 6
#define SCREEN_TILES_TOTAL (SCREEN_TILES_WIDE * SCREEN_TILES_HIGH)


static CloudSingleton* sharedCloudinstance = nil;

@implementation CloudSingleton

// SINGLETON STUFF

+ (CloudSingleton*)sharedCloudSingleton
{
	@synchronized (self) {
		if (sharedCloudinstance == nil) {
			[[self alloc] initCloudSingleton];
		}
	}
	return sharedCloudinstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharedCloudinstance == nil) {
			sharedCloudinstance = [super allocWithZone:zone];
			return sharedCloudinstance;
		}
	}
	
	return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (oneway void)release
{
	// do nothing
}

- (id)autorelease
{
	return self;
}

- (NSUInteger)retainCount
{
	return NSUIntegerMax; // This is sooo not zero
}

//////

- (void)dealloc {
    if (vertexArray) {
        free(vertexArray);
    }
    [cloudTiledImages release];
    [super dealloc];
}

- (id)initCloudSingleton {
    self = [super init];
    if (self) {
        //
        hasCreatedVertexArray = NO;
        vertexArray = NULL;
        widthCells = 0;
        heightCells = 0;
        cloudTiledImages = [[NSMutableArray alloc] initWithCapacity:SCREEN_TILES_TOTAL];
        Image* bigImage = [[Image alloc] initWithImageNamed:@"tilecloud.png" filter:GL_LINEAR];
        float xRatio = bigImage.imageSize.width / kPadScreenLandscapeWidth; // < 1
        float yRatio = bigImage.imageSize.height / kPadScreenLandscapeHeight; // < 1
        for (int i = 0; i < SCREEN_TILES_TOTAL; i++) {
            float x = (i % SCREEN_TILES_WIDE) * COLLISION_CELL_WIDTH * xRatio;
            float y = ((i / SCREEN_TILES_WIDE) + 1) * COLLISION_CELL_HEIGHT * yRatio;
            CGRect rect = CGRectMake(x,
                                     bigImage.imageSize.height - y,
                                     COLLISION_CELL_WIDTH * xRatio,
                                     COLLISION_CELL_HEIGHT * yRatio);
            Image* tile = [bigImage subImageInRect:rect];
            [cloudTiledImages addObject:tile];
        }
        [bigImage release];
    }
    return self;
}

- (CGPoint)pointForArrayIndex:(int)index {
    CGPoint point;
    point.x = index % widthCells;
    point.y = index / widthCells;
    return point;
}

- (Image*)tileForCGPoint:(CGPoint)point {
    CGPoint newPoint = point;
    while (newPoint.x > kPadScreenLandscapeWidth) {
        newPoint.x -= kPadScreenLandscapeWidth;
    }
    while (newPoint.y > kPadScreenLandscapeHeight) {
        newPoint.y -= kPadScreenLandscapeHeight;
    }
    int xIndex = newPoint.x / COLLISION_CELL_WIDTH;
    int yIndex = newPoint.y / COLLISION_CELL_HEIGHT;
    return [self tileForXIndex:xIndex forYIndex:yIndex];
}

- (Image*)tileForXIndex:(int)x forYIndex:(int)y {
    int index = (y * SCREEN_TILES_WIDE) + x;
    if (index < [cloudTiledImages count]) {
        return [cloudTiledImages objectAtIndex:index];
    }
    return nil;
}

- (Color4f*)vertexPointerForCGPoint:(CGPoint)point; {
    int xIndex = point.x / COLLISION_CELL_WIDTH;
    int yIndex = point.y / COLLISION_CELL_HEIGHT;
    return [self vertexPointerForXIndex:xIndex forYIndex:yIndex];
}

- (Color4f)vertexForCGPoint:(CGPoint)point; {
    int xIndex = point.x / COLLISION_CELL_WIDTH;
    int yIndex = point.y / COLLISION_CELL_HEIGHT;
    return [self vertexForXIndex:xIndex forYIndex:yIndex];
}

- (Color4f*)vertexPointerForXIndex:(int)x forYIndex:(int)y {
    int index = (y * widthCells) + x;
    if (index > 0 && index < (heightCells * widthCells)) {
        if (vertexArray) {
            return &vertexArray[index];
        }
    }
    return NULL;
}

- (Color4f)vertexForXIndex:(int)x forYIndex:(int)y {
    int index = (y * widthCells) + x;
    if (index > 0 && index < (heightCells * widthCells)) {
        if (vertexArray) {
            return vertexArray[index];
        }
    }
    return Color4fZeroes;
}

- (void)setWidthCells:(int)cellsWide withHeight:(int)cellsHigh {
    widthCells = cellsWide;
    heightCells = cellsHigh;
    
    if (vertexArray)
        free(vertexArray);
    
    vertexArray = malloc(widthCells * heightCells * sizeof(*vertexArray));
    for (int i = 0; i < widthCells * heightCells; i++) {
        Color4f* vertex = &vertexArray[i];
        vertex->red = RANDOM_0_TO_1();
        vertex->green = RANDOM_0_TO_1();
        vertex->blue = RANDOM_0_TO_1();
        vertex->alpha = CLAMP(RANDOM_0_TO_1(), 0.0f, 0.15f);
        // Do something fancy maybe
    }
    hasCreatedVertexArray = YES;
}

- (void)updateCloudData {
    if (hasCreatedVertexArray) {
        //
    }
}

- (void)renderCloudInRect:(CGRect)rect WithScroll:(Vector2f)scroll {
    if (hasCreatedVertexArray) {
        for (int y = 0; y < heightCells; y++) {
            for (int x = 0; x < widthCells; x++) {
                CGPoint thisPoint = CGPointMake((x * COLLISION_CELL_WIDTH) + COLLISION_CELL_WIDTH/2 + 1,
                                                (y * COLLISION_CELL_HEIGHT) + COLLISION_CELL_HEIGHT/2 + 1);
                if (!CGRectContainsPoint(CGRectInset(rect, -COLLISION_CELL_WIDTH, -COLLISION_CELL_HEIGHT),
                                         thisPoint)) {
                    // Don't worry if not in rect
                    continue;
                }
                
                Image* tile = [self tileForCGPoint:thisPoint];
                if (tile) {
                    [tile setRenderLayer:kLayerBottomLayer];
                    [tile setRenderSolidColor:NO];
                    [tile setScale:Scale2fMake(COLLISION_CELL_WIDTH / tile.imageSize.width,
                                               COLLISION_CELL_HEIGHT / tile.imageSize.height)];
                    
                    // Bottom Left
                    Color4f botLeft = [self vertexForXIndex:x forYIndex:y];
                    tile.imageDetails->texturedColoredQuad->vertex1.vertexColor = botLeft;
                    
                    // Bottom Right
                    Color4f botRight = [self vertexForXIndex:x+1 forYIndex:y];
                    tile.imageDetails->texturedColoredQuad->vertex2.vertexColor = botRight;
                    
                    // Top left
                    Color4f topLeft = [self vertexForXIndex:x forYIndex:y+1];
                    tile.imageDetails->texturedColoredQuad->vertex3.vertexColor = topLeft;
                    
                    // Top right
                    Color4f topRight = [self vertexForXIndex:x+1 forYIndex:y+1];
                    tile.imageDetails->texturedColoredQuad->vertex4.vertexColor = topRight;
                    
                    [tile renderCenteredAtPoint:thisPoint withScrollVector:scroll];
                }
            }
        }
    }
}


@end
