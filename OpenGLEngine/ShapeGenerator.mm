/*
 *  ShapeGenerator.cpp
 *  ShapeGenerator
 *
 *  Created by James F Lockwood on 1/25/11.
 *  Copyright 2011 Games in Dorms. All rights reserved.
 *
 */

#include "ShapeGenerator.h"

ShapeGenerator::ShapeGenerator(int xComp, int yComp) {
	xComplexity = xComp;
	yComplexity = yComp;
	shapeGenerated = false;
	generatorBuffer = NULL;
}

int ShapeGenerator::generateNewShape(CGPoint location, int width, int height, // Must both be at least 4
									  int pointiness, bool roundness) // pointiness out of 50 (from 0)
{
	int verticies = (2 * xComplexity) + (2 * yComplexity) - 4; // Number of total vertecies
	
	if (shapeGenerated == true) {
		free(generatorBuffer);
		generatorBuffer = (float*)malloc(2 * verticies*sizeof(*generatorBuffer));
	} else {
		generatorBuffer = (float*)malloc(2 * verticies*sizeof(*generatorBuffer));
		shapeGenerated = true;
	}

	
	float xRangeLow = 0;
	float widthFraction = ((float)width / 2) * ((float)pointiness / 100.0f);
	float xRangeHigh = (float)width / (float)xComplexity + widthFraction;
	
	float yRangeLow = 0;
	float heightFraction = ((float)height / 2) * ((float)pointiness / 100.0f);
	float yRangeHigh = (float)height / (float)yComplexity + heightFraction;
	
	float spaceInBetweenHorizCorners = width - (widthFraction * 2 + 2*(width / xComplexity));
	float spaceInBetweenVertCorners = height - (heightFraction * 2 + 2*(height / yComplexity));
	
	int currentDirection = 0; // 0 - right, 1 - down, 2 - left, 3 - up
	int currentDirectionCounter = 0; // vertex count in the current direction
	
	int vertexCounter = 0;
	for (int i = 0; i < verticies; i++) {
		// If the direction counter is 0, then change direction (CW)
		if (currentDirectionCounter != 0) {
			if (currentDirection == 0) {
				xRangeLow = xRangeHigh;
				xRangeHigh += spaceInBetweenHorizCorners / (xComplexity - 2);
			} else if (currentDirection == 1) {
				yRangeLow = yRangeHigh;
				yRangeHigh += spaceInBetweenVertCorners / (yComplexity - 2);
			} else if (currentDirection == 2) {
				xRangeHigh = xRangeLow;
				xRangeLow -= spaceInBetweenHorizCorners / (xComplexity - 2);
			} else if (currentDirection == 3) {
				yRangeHigh = yRangeLow;
				yRangeLow -= spaceInBetweenVertCorners / (yComplexity - 2);
			}
			if (currentDirection == 0 || currentDirection == 2) {
				if (currentDirectionCounter < xComplexity - 1) {
					currentDirectionCounter += 1;
				} else {
					currentDirectionCounter = 0;
				}
			} else if (currentDirection == 1 || currentDirection == 3) {
				if (currentDirectionCounter < yComplexity - 1) {
					currentDirectionCounter += 1;
				} else {
					currentDirectionCounter = 0;
				}
			}
		}
		if (currentDirectionCounter == 0) {
			// If the direction is changing
			if (currentDirection == 0) {
				if (i != 0) {
					xRangeLow = width - ((float)width / (float)xComplexity + widthFraction);
					xRangeHigh = width;
					yRangeLow = 0;
					yRangeHigh = (float)height / (float)yComplexity + heightFraction;
					currentDirection = 1;
					// NSLog(@"Changing Direction to Down");
				}
			} else if (currentDirection == 1) {
				yRangeLow = height - ((float)height / (float)yComplexity + heightFraction);
				yRangeHigh = height;
				currentDirection = 2;
				// NSLog(@"Changing Direction to Left");
			} else if (currentDirection == 2) {
				xRangeLow = 0;
				xRangeHigh = (float)width / (float)xComplexity + widthFraction;
				currentDirection = 3;
				// NSLog(@"Changing Direction to Up");
			} else if (currentDirection == 3) {
				// Actually the beginning of the loop
				xRangeLow = 0;
				xRangeHigh = (float)width / (float)xComplexity + widthFraction;
				yRangeLow = 0;
				yRangeHigh = (float)height / (float)yComplexity + heightFraction;
				currentDirection = 0;
				// NSLog(@"Changing Direction to Right");
			}
			currentDirectionCounter += 1;
		}
		
		// Ranges should be set by now, random generating happening!
		float xRandom = (arc4random() % (int)(xRangeHigh - xRangeLow + 1)) + xRangeLow;
		float yRandom = (arc4random() % (int)(yRangeHigh - yRangeLow + 1)) + yRangeLow;
		
		if (!roundness) {
			int biRandomX = arc4random() % 2;
			int biRandomY = arc4random() % 2;
			if (biRandomX == 0) {
				xRandom = xRangeLow + 1;
			} else {
				xRandom = xRangeHigh - 1;
			}
			if (biRandomY == 0) {
				yRandom = yRangeLow + 1;
			} else {
				yRandom = yRangeHigh - 1;
			}
		}
		
		// NSLog(@"Lows: (%f, %f)  Highs: (%f, %f)", xRangeLow, yRangeLow, xRangeHigh, yRangeHigh);
		// NSLog(@"Vertex (%i): <%f, %f>", i, xRandom, yRandom);
		
		generatorBuffer[vertexCounter] = xRandom + location.x;
		vertexCounter++;
		generatorBuffer[vertexCounter] = yRandom + location.y;
		vertexCounter++;
	}
	return verticies * 2 * sizeof(*generatorBuffer);
}

void ShapeGenerator::createShapeIntoArray(float* destinationArray) {
	if (generatorBuffer == NULL) {
		return;
	}
	// Assuming array is already allocated
	int verticies = (2 * xComplexity) + (2 * yComplexity) - 4;
	for (int i = 0; i < verticies * 2; i++) {
		destinationArray[i] = (float)generatorBuffer[i];
	}
	free(generatorBuffer);
	shapeGenerated = false;
}

ShapeGenerator::~ShapeGenerator() {
	if (shapeGenerated == true) {
		free(generatorBuffer);
	}
}