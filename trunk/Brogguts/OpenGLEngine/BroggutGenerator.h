//
//  BroggutGenerator.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/13/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollisionManager.h"
#import "ShapeGenerator.h"

#define VERTICIES_PER_BROGGUT 32 // Must be multiple of 4
#define BROGGUT_PADDING 20.0f
#define BROGGUT_POINTINESS 10 // Between 0 and 100

@interface BroggutGenerator : NSObject {
	ShapeGenerator* generator;
	float** verticies;
	int cellsWide;
	int cellsHigh;
	int broggutCount;
	int vertexedBroggutCount;
}

- (id)initWithBroggutArray:(BroggutArray*)broggutArray;

- (int)verticesOfMediumBroggutAtIndex:(int)index intoArray:(float**)array;

@end
