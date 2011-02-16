//
//  BroggutGenerator.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/13/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "BroggutGenerator.h"
#import "GameController.h"

@implementation BroggutGenerator

- (int)indexForRow:(int)row forColumn:(int)col {
	return col + (row * cellsWide);
}

- (void)generateVerticiesForRow:(int)row forColumn:(int)column {
	int index = [self indexForRow:row forColumn:column];
	CGPoint location = CGPointMake(column * COLLISION_CELL_WIDTH - (BROGGUT_PADDING / 2),
								   row * COLLISION_CELL_HEIGHT - (BROGGUT_PADDING / 2));
	int size = generator->generateNewShape(location, COLLISION_CELL_WIDTH + BROGGUT_PADDING, COLLISION_CELL_HEIGHT + BROGGUT_PADDING, 10, true);
	verticies[index] = (float*)malloc(size);
	
	generator->createShapeIntoArray(verticies[index]);
	vertexedBroggutCount++;
}

- (void)dealloc {
	if (verticies) {
		for (int i = 0; i < broggutCount; i++) {
			free(verticies[i]);
		}
		free(verticies);
	}
	delete generator;
	[super dealloc];
}

- (id)initWithWithBroggutArray:(BroggutArray*)broggutArray {
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
	return VERTICIES_PER_BROGGUT * 2 - 4;
}

@end
