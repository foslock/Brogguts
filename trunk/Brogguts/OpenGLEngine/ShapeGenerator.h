/*
 *  ShapeGenerator.h
 *  ShapeGenerator
 *
 *  Created by James F Lockwood on 1/25/11.
 *  Copyright 2011 Games in Dorms. All rights reserved.
 *
 */

class ShapeGenerator {
private:
	bool shapeGenerated;
	float* generatorBuffer;
	int xComplexity;
	int yComplexity;
public:
	ShapeGenerator(int xComp, int yComp); // Constructor
	
	// Returns the number of bytes needed to store shape
	int generateNewShape(CGPoint location, int width, int height, int pointiness, bool roundness);
	// width is the number of pixels wide the generating shape will be
	// height " " tall the generating the array will be
	// xComplexity is how many blocks will be used on the x axis for generating
	// yComplexity " " y axis for generating
	// pointiness is how pointy the shape should be. 0 means a very full shape, 50 means a very pointy shape.
	// roundness is a bool that will force the vertex into a corner of the grid box
	
	void createShapeIntoArray(float* destinationArray);
	// will copy the generator buffer into the destinationArray and verify that the width and height are correct.
	// The passed in 2D array should be allocated as such, according to the return value (size of array needed)
	
	~ShapeGenerator(); // Destructor
};
