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

#define CLOUD_TILE_WIDTH 128.0f
#define CLOUD_TILE_HEIGHT 128.0f
#define SCREEN_TILES_WIDE (kPadScreenLandscapeWidth / CLOUD_TILE_WIDTH)
#define SCREEN_TILES_HIGH (kPadScreenLandscapeHeight / CLOUD_TILE_HEIGHT)
#define SCREEN_TILES_TOTAL (SCREEN_TILES_WIDE * SCREEN_TILES_HIGH)
#define CLOUD_TOP_LAYER_SCROLL_FACTOR 0.25f

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
    if (vertexTopArray) {
        free(vertexTopArray);
    }
    if (vertexBottomArray) {
        free(vertexBottomArray);
    }
    [cloudTiledImages release];
    [super dealloc];
}

- (id)initCloudSingleton {
    self = [super init];
    if (self) {
        hasCreatedVertexArray = NO;
        vertexTopArray = NULL;
        widthCells = 0;
        heightCells = 0;
        cloudTiledImages = [[NSMutableArray alloc] initWithCapacity:SCREEN_TILES_TOTAL];
        Image* bigImage = [[Image alloc] initWithImageNamed:@"tilecloud.png" filter:GL_LINEAR];
        vertexBottomArray = malloc(SCREEN_TILES_TOTAL * sizeof(*vertexBottomArray));
        float xRatio = (bigImage.imageSize.width) / (kPadScreenLandscapeWidth); // < 1
        float yRatio = (bigImage.imageSize.height) / (kPadScreenLandscapeHeight); // < 1
        for (int i = 0; i < SCREEN_TILES_TOTAL; i++) {
            float x = (i % (int)SCREEN_TILES_WIDE) * CLOUD_TILE_WIDTH * xRatio;
            float y = ((i / (int)SCREEN_TILES_WIDE) + 1) * CLOUD_TILE_HEIGHT * yRatio;
            CGRect rect = CGRectMake(x, (bigImage.imageSize.height - y),
                                     CLOUD_TILE_WIDTH * xRatio,
                                     CLOUD_TILE_HEIGHT * yRatio);
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
    while (newPoint.x >= kPadScreenLandscapeWidth) {
        newPoint.x -= kPadScreenLandscapeWidth;
    }
    while (newPoint.y >= kPadScreenLandscapeHeight) {
        newPoint.y -= kPadScreenLandscapeHeight;
    }
    int xIndex = newPoint.x / CLOUD_TILE_WIDTH;
    int yIndex = newPoint.y / CLOUD_TILE_HEIGHT;
    return [self tileForXIndex:xIndex forYIndex:yIndex];
}

- (Image*)tileForXIndex:(int)x forYIndex:(int)y {
    int index = (y * SCREEN_TILES_WIDE) + x;
    if (index < [cloudTiledImages count]) {
        return [cloudTiledImages objectAtIndex:index];
    }
    return nil;
}

- (Color4f*)topVertexPointerForCGPoint:(CGPoint)point; {
    int xIndex = point.x / CLOUD_TILE_WIDTH;
    int yIndex = point.y / CLOUD_TILE_HEIGHT;
    return [self topVertexPointerForXIndex:xIndex forYIndex:yIndex];
}

- (Color4f)topVertexForCGPoint:(CGPoint)point; {
    int xIndex = point.x / CLOUD_TILE_WIDTH;
    int yIndex = point.y / CLOUD_TILE_HEIGHT;
    return [self topVertexForXIndex:xIndex forYIndex:yIndex];
}

- (Color4f*)topVertexPointerForXIndex:(int)x forYIndex:(int)y {
    int index = (y * widthCells) + x;
    if (index > 0 && index < (heightCells * widthCells)) {
        if (vertexTopArray) {
            return &vertexTopArray[index];
        }
    }
    return NULL;
}

- (Color4f)topVertexForXIndex:(int)x forYIndex:(int)y {
    int index = (y * widthCells) + x;
    if (index > 0 && index < (heightCells * widthCells)) {
        if (vertexTopArray) {
            return vertexTopArray[index];
        }
    }
    return Color4fZeroes;
}

- (Color4f*)botVertexPointerForCGPoint:(CGPoint)point; {
    int xIndex = point.x / CLOUD_TILE_WIDTH;
    int yIndex = point.y / CLOUD_TILE_HEIGHT;
    return [self botVertexPointerForXIndex:xIndex forYIndex:yIndex];
}

- (Color4f)botVertexForCGPoint:(CGPoint)point; {
    int xIndex = point.x / CLOUD_TILE_WIDTH;
    int yIndex = point.y / CLOUD_TILE_HEIGHT;
    return [self botVertexForXIndex:xIndex forYIndex:yIndex];
}

- (Color4f*)botVertexPointerForXIndex:(int)x forYIndex:(int)y {
    int index = (y * SCREEN_TILES_WIDE) + x;
    if (index > 0 && index < SCREEN_TILES_TOTAL) {
        if (vertexBottomArray) {
            return &vertexBottomArray[index];
        }
    }
    return NULL;
}

- (Color4f)botVertexForXIndex:(int)x forYIndex:(int)y {
    int index = (y * SCREEN_TILES_WIDE) + x;
    if (index > 0 && index < SCREEN_TILES_TOTAL) {
        if (vertexBottomArray) {
            return vertexBottomArray[index];
        }
    }
    return Color4fZeroes;
}

- (void)setWidthCells:(int)cellsWide withHeight:(int)cellsHigh {
    widthCells = cellsWide;
    heightCells = cellsHigh;
    
    if (vertexTopArray)
        free(vertexTopArray);
    
    vertexTopArray = malloc(widthCells * heightCells * sizeof(*vertexTopArray));
    for (int i = 0; i < widthCells * heightCells; i++) { // Closer clouds
        Color4f* vertex = &vertexTopArray[i];
        vertex->red = CLAMP(RANDOM_0_TO_1(), 0.05f, 0.4f);
        vertex->green = CLAMP(RANDOM_0_TO_1(), 0.05f, 0.4f);
        vertex->blue = CLAMP(RANDOM_0_TO_1(), 0.05f, 0.4f);
        vertex->alpha = CLAMP(RANDOM_0_TO_1(), 0.0f, 0.15f);
        
        // Solution to the stupid black line bug
        int y = i / widthCells;
        if (y % (int)SCREEN_TILES_HIGH == 0) {
            vertex->alpha = 0.0f;
        }
    }
    
    for (int i = 0; i < SCREEN_TILES_TOTAL; i++) { // Farther clouds
        Color4f* vertex = &vertexBottomArray[i];
        vertex->red = CLAMP(RANDOM_0_TO_1(), 0.05f, 0.2f);
        vertex->green = CLAMP(RANDOM_0_TO_1(), 0.05f, 0.2f);
        vertex->blue = CLAMP(RANDOM_0_TO_1(), 0.05f, 0.2f);
        vertex->alpha = CLAMP(RANDOM_0_TO_1(), 0.0f, 0.1f);
        
        // Solution to the stupid black line bug
        int y = i / SCREEN_TILES_WIDE;
        if (y % (int)SCREEN_TILES_HIGH == 0) {
            vertex->alpha = 0.0f;
        }
    }
    hasCreatedVertexArray = YES;
}

- (void)updateCloudData {
    if (hasCreatedVertexArray) {
        //
    }
}

- (void)renderCloudInRect:(CGRect)rect WithScroll:(Vector2f)thisScroll {
    if (hasCreatedVertexArray) {
        // Regulate scroll vector
        Vector2f scroll = Vector2fMake((int)thisScroll.x, (int)thisScroll.y);
        
        // Bottom array        
        for (int y = 0; y < SCREEN_TILES_HIGH; y++) {
            for (int x = 0; x < SCREEN_TILES_WIDE; x++) {
                CGPoint thisPoint = CGPointMake((x * CLOUD_TILE_WIDTH) + CLOUD_TILE_WIDTH/2,
                                                (y * CLOUD_TILE_HEIGHT) + CLOUD_TILE_HEIGHT/2);
                Image* tile = [self tileForCGPoint:thisPoint];
                if (tile) {
                    [tile setRenderLayer:kLayerBottomLayer];
                    [tile setAlwaysRender:YES];
                    [tile setRenderSolidColor:NO];
                    [tile setScale:Scale2fMake(CLOUD_TILE_WIDTH / tile.imageSize.width,
                                               CLOUD_TILE_HEIGHT / tile.imageSize.height)];
                    
                    // Bottom Left
                    Color4f botLeft = [self botVertexForXIndex:x forYIndex:y];
                    tile.imageDetails->texturedColoredQuad->vertex1.vertexColor = botLeft;
                    
                    // Bottom Right
                    Color4f botRight = [self botVertexForXIndex:x+1 forYIndex:y];
                    tile.imageDetails->texturedColoredQuad->vertex2.vertexColor = botRight;
                    
                    // Top left
                    Color4f topLeft = [self botVertexForXIndex:x forYIndex:y+1];
                    tile.imageDetails->texturedColoredQuad->vertex3.vertexColor = topLeft;
                    
                    // Top right
                    Color4f topRight = [self botVertexForXIndex:x+1 forYIndex:y+1];
                    tile.imageDetails->texturedColoredQuad->vertex4.vertexColor = topRight;
                    
                    [tile renderCenteredAtPoint:thisPoint withScrollVector:Vector2fZero];
                }
            }
        }
        
        // Top array
        for (int y = 0; y < heightCells; y++) {
            for (int x = 0; x < widthCells; x++) {
                CGPoint thisPoint = CGPointMake((x * CLOUD_TILE_WIDTH) + CLOUD_TILE_WIDTH/2,
                                                (y * CLOUD_TILE_HEIGHT) + CLOUD_TILE_HEIGHT/2);
                if (!CGRectContainsPoint(CGRectInset(CGRectOffset(rect,
                                                                  -scroll.x * (1.0-CLOUD_TOP_LAYER_SCROLL_FACTOR),
                                                                  -scroll.y * (1.0-CLOUD_TOP_LAYER_SCROLL_FACTOR)),
                                                     -CLOUD_TILE_WIDTH,
                                                     -CLOUD_TILE_HEIGHT),
                                         thisPoint)) {
                    // Don't worry if not in rect
                    continue;
                }
                
                Image* tile = [self tileForCGPoint:thisPoint];
                if (tile) {
                    [tile setRenderLayer:kLayerBottomLayer];
                    [tile setRenderSolidColor:NO];
                    [tile setAlwaysRender:YES];
                    [tile setScale:Scale2fMake(CLOUD_TILE_WIDTH / tile.imageSize.width,
                                               CLOUD_TILE_HEIGHT / tile.imageSize.height)];
                    
                    // Bottom Left
                    Color4f botLeft = [self topVertexForXIndex:x forYIndex:y];
                    tile.imageDetails->texturedColoredQuad->vertex1.vertexColor = botLeft;
                    
                    // Bottom Right
                    Color4f botRight = [self topVertexForXIndex:x+1 forYIndex:y];
                    tile.imageDetails->texturedColoredQuad->vertex2.vertexColor = botRight;
                    
                    // Top left
                    Color4f topLeft = [self topVertexForXIndex:x forYIndex:y+1];
                    tile.imageDetails->texturedColoredQuad->vertex3.vertexColor = topLeft;
                    
                    // Top right
                    Color4f topRight = [self topVertexForXIndex:x+1 forYIndex:y+1];
                    tile.imageDetails->texturedColoredQuad->vertex4.vertexColor = topRight;
                    
                    [tile renderCenteredAtPoint:thisPoint
                               withScrollVector:Vector2fMake(scroll.x * CLOUD_TOP_LAYER_SCROLL_FACTOR,
                                                             scroll.y * CLOUD_TOP_LAYER_SCROLL_FACTOR)];
                }
            }
        }
        
    }
}


@end
