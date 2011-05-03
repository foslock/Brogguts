//
//  BroggutGenerator.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/13/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//
#import <CoreFoundation/CoreFoundation.h>
#import "BroggutGenerator.h"
#import "GameController.h"

static NSString* kMediumBroggutYoungImageSprite = @"spritetrashyoung";
static NSString* kMediumBroggutOldImageSprite = @"spritetrashold";
static NSString* kMediumBroggutAncientImageSprite = @"spritetrashancient";

@implementation BroggutGenerator

- (int)indexForRow:(int)row forColumn:(int)col {
	return col + (row * cellsWide);
}

- (void)generateVerticiesForRow:(int)row forColumn:(int)column {
	int index = [self indexForRow:row forColumn:column];
	CGPoint location = CGPointMake(column * COLLISION_CELL_WIDTH - (BROGGUT_PADDING / 2),
								   row * COLLISION_CELL_HEIGHT - (BROGGUT_PADDING / 2));
	int size = generator->generateNewShape(location,
										   COLLISION_CELL_WIDTH + BROGGUT_PADDING,
										   COLLISION_CELL_HEIGHT + BROGGUT_PADDING,
										   BROGGUT_POINTINESS,
										   true);
	verticies[index] = (float*)malloc(size);
	
	generator->createShapeIntoArray(verticies[index]);
	vertexedBroggutCount++;
}

- (void)dealloc {
	if (verticies) {
		for (int i = 0; i < cellsWide * cellsHigh; i++) {
			free(verticies[i]);
		}
		free(verticies);
	}
	delete generator;
	[super dealloc];
}

- (id)initWithBroggutArray:(BroggutArray*)broggutArray {
	self = [super init];
	if (self) {
		generator = new ShapeGenerator(VERTICIES_PER_BROGGUT / 2, VERTICIES_PER_BROGGUT / 2);
		vertexedBroggutCount = 0;
		cellsWide = broggutArray->bWidth;
		cellsHigh = broggutArray->bHeight;
		broggutCount = broggutArray->broggutCount;
		verticies = (float**)malloc( cellsWide * cellsHigh * sizeof(*verticies) );
		for (int i = 0; i < cellsWide * cellsHigh; i++) {
			verticies[i] = (float*)malloc((2 * VERTICIES_PER_BROGGUT) + (2 * VERTICIES_PER_BROGGUT) - 4);
		}
		for (int j = 0; j < cellsHigh; j++) {
			for (int i = 0; i < cellsWide; i++) {
				int straightIndex = [self indexForRow:j forColumn:i];
				MediumBroggut* broggut = &broggutArray->array[straightIndex];
				if (broggut->broggutValue != -1) {
					// Make some verticies for this!
					[self generateVerticiesForRow:j forColumn:i];
				}
			}
		}
	}
	return self;
}

- (int)verticesOfMediumBroggutAtIndex:(int)index intoArray:(float**)array{
    (*array) = verticies[index];
	return (VERTICIES_PER_BROGGUT * 2) - 4;
}


- (UIImage*)imageForRandomMediumBroggutWithAge:(int)broggutAge {
    NSString* path;
    switch (broggutAge) {
        case kBroggutMediumAgeYoung:
            path = [[NSBundle mainBundle] pathForResource:kMediumBroggutYoungImageSprite ofType:@"png"];
            break;
        case kBroggutMediumAgeOld:
            path = [[NSBundle mainBundle] pathForResource:kMediumBroggutOldImageSprite ofType:@"png"];
            break;
        case kBroggutMediumAgeAncient:
            path = [[NSBundle mainBundle] pathForResource:kMediumBroggutAncientImageSprite ofType:@"png"];
            break;
        default:
            break;
    }
    UIImage* trashTexture = [[UIImage alloc] initWithContentsOfFile:path];
    
    CGSize size = CGSizeMake(COLLISION_CELL_WIDTH + (BROGGUT_PADDING * 2),
                             COLLISION_CELL_HEIGHT + (BROGGUT_PADDING * 2));
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect drawRect = CGRectMake((RANDOM_0_TO_1() * COLLISION_CELL_WIDTH) - COLLISION_CELL_WIDTH,
                                 (RANDOM_0_TO_1() * COLLISION_CELL_HEIGHT) - COLLISION_CELL_HEIGHT,
                                 COLLISION_CELL_WIDTH * 4,
                                 COLLISION_CELL_HEIGHT * 4);
    
    float* thisArray;
    [self generateVerticiesForRow:0 forColumn:0];
    int vertexCount = [self verticesOfMediumBroggutAtIndex:0 intoArray:&thisArray];
    int vertexIndex = 0;
    
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 1.5f);
    CGContextSetRGBStrokeColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
    for (int i = 0; i < vertexCount; i++) {
        float pointx = thisArray[vertexIndex++] + BROGGUT_PADDING;
        float pointy = thisArray[vertexIndex++] + BROGGUT_PADDING;
        if (i == 0) {
            CGContextMoveToPoint(context, pointx, pointy);
        }
        CGContextAddLineToPoint(context, pointx, pointy);
    }
    CGContextClosePath(context);
    CGContextClip(context);
    
    // Draw the image in the clipping space
    CGContextDrawImage(context, drawRect, [trashTexture CGImage]);
        
    // drawing commands go here
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    /* WRITE TO FILE
    NSData* imageData = UIImagePNGRepresentation(newImage);
    [imageData writeToFile:[[GameController sharedGameController] documentsPathWithFilename:@"broggutImage.png"] atomically:YES];
    */
    
    UIGraphicsEndImageContext();
    [trashTexture release];
    return newImage;
}


@end
