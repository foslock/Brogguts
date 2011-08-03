/*
 *  Primitives.h
 *  SLQTSOR
 *
 *  Created by Mike Daley on 06/09/2009.
 *  Copyright 2009 Michael Daley. All rights reserved.
 *
 */

#import <objc/objc.h>
#import "Global.h"

#define CIRCLE_SEGMENTS_COUNT 20

//
// THESE MUST BE CALLED BEFORE PRIMITIVE DRAWING CAN OCCUR
//


static inline void enablePrimitiveDraw() {
	// Disable the color array and switch off texturing
	glDisableClientState(GL_COLOR_ARRAY);
	glDisable(GL_TEXTURE_2D);
}

static inline void disablePrimitiveDraw() {
	// Switch the color array back on and enable textures.  This is the default state
	// for our game engine
	glEnableClientState(GL_COLOR_ARRAY);
	glEnable(GL_TEXTURE_2D);
}

//
// Drawing functions
//


static inline void drawRect(CGRect aRect, Vector2f scroll) {
    
    // Setup the array used to store the vertices for our rectangle
	static float _rectPointsArray[8];

	// Using the CGRect that has been passed in, calculate the vertices we
	// need to render the rectangle
	_rectPointsArray[0] = aRect.origin.x - scroll.x;
	_rectPointsArray[1] = aRect.origin.y - scroll.y;
	_rectPointsArray[2] = aRect.origin.x + aRect.size.width - scroll.x;
	_rectPointsArray[3] = aRect.origin.y - scroll.y;
	_rectPointsArray[4] = aRect.origin.x + aRect.size.width - scroll.x;
	_rectPointsArray[5] = aRect.origin.y + aRect.size.height - scroll.y;
	_rectPointsArray[6] = aRect.origin.x - scroll.x;
	_rectPointsArray[7] = aRect.origin.y + aRect.size.height - scroll.y;
	
	// Set up the vertex pointer to the array of vertices we have created and
	// then use GL_LINE_LOOP to render them
	glVertexPointer(2, GL_FLOAT, 0, _rectPointsArray);
	glDrawArrays(GL_LINE_LOOP, 0, 4);
}

static inline void drawFilledRect(CGRect aRect, Vector2f scroll) {
	
	// Setup the array used to store the vertices for our rectangle
	static float _rectPointsArray[12];
	
	// Using the CGRect that has been passed in, calculate the vertices we
	// need to render the rectangle
	_rectPointsArray[0] = aRect.origin.x - scroll.x;
	_rectPointsArray[1] = aRect.origin.y - scroll.y;
	
	_rectPointsArray[2] = aRect.origin.x - scroll.x;
	_rectPointsArray[3] = aRect.origin.y + aRect.size.height - scroll.y;
	
	_rectPointsArray[4] = aRect.origin.x + aRect.size.width - scroll.x;
	_rectPointsArray[5] = aRect.origin.y - scroll.y;
	
	_rectPointsArray[6] = aRect.origin.x + aRect.size.width - scroll.x;
	_rectPointsArray[7] = aRect.origin.y - scroll.y;
	
	_rectPointsArray[8] = aRect.origin.x - scroll.x;
	_rectPointsArray[9] = aRect.origin.y + aRect.size.height - scroll.y;
	
	_rectPointsArray[10] = aRect.origin.x + aRect.size.width - scroll.x;
	_rectPointsArray[11] = aRect.origin.y + aRect.size.height - scroll.y;
	
	// Set up the vertex pointer to the array of vertices we have created and
	// then use GL_LINE_LOOP to render them
	glVertexPointer(2, GL_FLOAT, 0, _rectPointsArray);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 6);
}

static inline void drawLine(CGPoint loc1, CGPoint loc2, Vector2f scroll) {
	
	// Setup the array used to store the vertices
    static float _rectPointsArray[4];
	
	_rectPointsArray[0] = loc1.x - scroll.x;
	_rectPointsArray[1] = loc1.y - scroll.y;
	_rectPointsArray[2] = loc2.x - scroll.x;
	_rectPointsArray[3] = loc2.y - scroll.y;
	
	// Set up the vertex pointer to the array of vertices we have created and
	// then use GL_LINE_LOOP to render them
	glVertexPointer(2, GL_FLOAT, 0, _rectPointsArray);
	glDrawArrays(GL_LINES, 0, 2);
}

static inline void drawLines(float* vertices, int count, Vector2f scroll) {
    
	glPushMatrix();
	
	// Set up the vertex pointer to the array of vertices we have created and
	// then use GL_LINE_LOOP to render them
	glTranslatef(-scroll.x, -scroll.y, 0.0f);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_LINE_LOOP, 0, count);
    
	glPopMatrix();
}

static inline void drawPath(NSArray* path, Vector2f scroll) {
	int vertexCount = [path count];
	
	// Setup the array used to store the vertices
	GLfloat* vertices = (GLfloat*)malloc( 2 * vertexCount * sizeof(*vertices) );
	
	for (int i = 0; i < vertexCount * 2; i += 2) {
		NSValue* value = [path objectAtIndex:i / 2];
		CGPoint point = [value CGPointValue];
		vertices[i] = point.x - scroll.x;
		vertices[i+1] = point.y - scroll.y;
	}
	
	// Set up the vertex pointer to the array of vertices we have created and
	// then use GL_LINE_LOOP to render them
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_LINE_STRIP, 0, vertexCount);
	
	free(vertices);
}

static void drawDashedLine(CGPoint loc1, CGPoint loc2, int segments, Vector2f scroll) {
	float space = 0.2f;
    
	// Setup the array used to store the vertices
    static float* _dashedLineArray = NULL;
    static int vertCount = 0;
    
    if ( (2*segments) > vertCount ) {
        if (_dashedLineArray) {
            free(_dashedLineArray);
        }
        _dashedLineArray = (float*)malloc( segments * 4 * sizeof(*_dashedLineArray) );
    }
	vertCount = 2*segments;
    
	float baseX = loc1.x;
	float baseY = loc1.y;
	float xSegmentLength = (loc2.x - loc1.x) / (float)segments;
	float ySegmentLength = (loc2.y - loc1.y) / (float)segments;
	
	for (int i = 0; i < segments; i++) {
		// Put in a single segment (two points)
		int index = i * 4;
		_dashedLineArray[index]   = baseX + (i * xSegmentLength) + (xSegmentLength * space) - scroll.x;
		_dashedLineArray[index+1] = baseY + (i * ySegmentLength) + (ySegmentLength * space) - scroll.y;
		_dashedLineArray[index+2] = baseX + ( (i+1) * xSegmentLength) - (xSegmentLength * space) - scroll.x;
		_dashedLineArray[index+3] = baseY + ( (i+1) * ySegmentLength) - (ySegmentLength * space) - scroll.y;
	}
	
	_dashedLineArray[0] = CLAMP(_dashedLineArray[0], loc1.x - scroll.x, loc1.x - scroll.x);
	_dashedLineArray[1] = CLAMP(_dashedLineArray[1], loc1.y - scroll.y, loc1.y - scroll.y);
	_dashedLineArray[(vertCount * 2) - 2] = CLAMP(_dashedLineArray[(vertCount * 2) - 2], loc2.x - scroll.x, loc2.x - scroll.x);
	_dashedLineArray[(vertCount * 2) - 1] = CLAMP(_dashedLineArray[(vertCount * 2) - 1], loc2.y - scroll.y, loc2.y - scroll.y);
	
	// Set up the vertex pointer to the array of vertices we have created and
	// then use GL_LINE_LOOP to render them
	glVertexPointer(2, GL_FLOAT, 0, _dashedLineArray);
	glDrawArrays(GL_LINES, 0, vertCount);
}

static void drawCircle(Circle aCircle, uint aSegments, Vector2f scroll) {
	
	// Set up the array that will store our vertices.  Each segment will need
	// two vertices {x, y} so we multiply the segments passedin by 2
    static float* _circleArray = NULL;
    static int vertCount = 0;
    
    if ( (aSegments) > vertCount ) {
        if (_circleArray) {
            free(_circleArray);
        }
        _circleArray = (float*)malloc( aSegments * 2 * sizeof(*_circleArray) );
        vertCount = (aSegments);
    }
    
	// Set up the counter that will track the number of vertices we will have
	int vertexCount = 0;
	
	// Loop through each segment creating the vertices for that segment and add
	// the vertices to the vertices array
	for(int segment = 0; segment < aSegments; segment++) 
	{ 
		// Calculate the angle based on the number of segments
		float theta = 2.0f * M_PI * (float)segment / (float)aSegments;
		
		// Calculate the x and y position of the current segment
		float x = aCircle.radius * cosf(theta) - scroll.x;
		float y = aCircle.radius * sinf(theta) - scroll.y;
		
		// Add the new vertices to the vertices array taking into account the circles
		// current x and y position
		_circleArray[vertexCount++] = x + aCircle.x;
		_circleArray[vertexCount++] = y + aCircle.y;
	}
	
	// Set up the vertex pointer to the array of vertices we have created and
	// then use GL_LINE_LOOP to render them
	glVertexPointer(2, GL_FLOAT, 0, _circleArray);
	glDrawArrays(GL_LINE_LOOP, 0, aSegments);
}

static void drawDashedCircle(Circle aCircle, uint aSegments, Vector2f scroll) {
	
	// Set up the array that will store our vertices.  Each segment will need
	// two vertices {x, y} so we multiply the segments passedin by 2
	static float* _circleArray = NULL;
    static int vertCount = 0;
    
    if ( (aSegments) > vertCount ) {
        if (_circleArray) {
            free(_circleArray);
        }
        _circleArray = (float*)malloc( aSegments * 2 * sizeof(*_circleArray) );
        vertCount = (aSegments);
    }
	
	// Set up the counter that will track the number of vertices we will have
	int vertexCount = 0;
	
	// Loop through each segment creating the vertices for that segment and add
	// the vertices to the vertices array
	for(int segment = 0; segment < aSegments; segment++) 
	{ 
		// Calculate the angle based on the number of segments
		float theta = 2.0f * M_PI * (float)segment / (float)aSegments;
		
		// Calculate the x and y position of the current segment
		float x = aCircle.radius * cosf(theta) - scroll.x;
		float y = aCircle.radius * sinf(theta) - scroll.y;
		
		// Add the new vertices to the vertices array taking into account the circles
		// current x and y position
		_circleArray[vertexCount++] = x + aCircle.x;
		_circleArray[vertexCount++] = y + aCircle.y;
	}
	
	// Set up the vertex pointer to the array of vertices we have created and
	// then use GL_LINE_LOOP to render them
	glVertexPointer(2, GL_FLOAT, 0, _circleArray);
	glDrawArrays(GL_LINES, 0, aSegments);
}

static void drawPartialDashedCircle(Circle aCircle,
										   uint filledSegments, uint totalSegments,
										   Color4f filledColor, Color4f unFilledColor,
										   Vector2f scroll) {
	
	// Set up the array that will store our vertices.  Each segment will need
	// two vertices {x, y} so we multiply the segments passedin by 2
    static float* _circleArray = NULL;
    static float* _colorArray = NULL;
    static int vertCount = 0;
    
    if ( (totalSegments) > vertCount ) {
        if (_circleArray) {
            free(_circleArray);
        }
        if (_colorArray) {
            free(_colorArray);
        }
        _circleArray = (float*)malloc( totalSegments * 2 * sizeof(*_circleArray) );
        _colorArray = (float*)malloc( totalSegments * 4 * sizeof(*_colorArray) );
        vertCount = (totalSegments);
    }
	
	// Set up the counter that will track the number of vertices we will have
	int vertexCount = 0;
	int colorCount = 0;
    
	// Loop through each segment creating the vertices for that segment and add
	// the vertices to the vertices array
	for(int segment = 0; segment < totalSegments; segment++) 
	{ 
		// Insert the first color if it is a filled segment
		if (segment <= filledSegments) {
			_colorArray[colorCount++] = filledColor.red;
			_colorArray[colorCount++] = filledColor.green;
			_colorArray[colorCount++] = filledColor.blue;
			_colorArray[colorCount++] = filledColor.alpha;
		} else {
			_colorArray[colorCount++] = unFilledColor.red;
			_colorArray[colorCount++] = unFilledColor.green;
			_colorArray[colorCount++] = unFilledColor.blue;
			_colorArray[colorCount++] = unFilledColor.alpha;
		}
		
		// Calculate the angle based on the number of segments
		float theta = 2.0f * M_PI * (float)segment / (float)totalSegments;
		
		// Calculate the x and y position of the current segment
		float x = aCircle.radius * cosf(theta + M_PI_2) - scroll.x;
		float y = aCircle.radius * sinf(theta + M_PI_2) - scroll.y;
		
		// Add the new vertices to the vertices array taking into account the circles
		// current x and y position
		_circleArray[vertexCount++] = x + aCircle.x;
		_circleArray[vertexCount++] = y + aCircle.y;
	}
	
	// Set up the vertex pointer to the array of vertices we have created and
	// then use GL_LINE_LOOP to render them
	glEnableClientState(GL_COLOR_ARRAY);
	glColorPointer(4, GL_FLOAT, 0, _colorArray);
	glVertexPointer(2, GL_FLOAT, 0, _circleArray);
	glDrawArrays(GL_LINES, 0, totalSegments);
	glDisableClientState(GL_COLOR_ARRAY);
}

static void drawDashedCircleWithColoredSegment(Circle aCircle,
										   uint coloredSegmentIndex, uint totalSegments,
										   Color4f filledColor, Color4f unFilledColor,
										   Vector2f scroll) {
	
	// Set up the array that will store our vertices.  Each segment will need
	// two vertices {x, y} so we multiply the segments passedin by 2
	static float* _circleArray = NULL;
    static float* _colorArray = NULL;
    static int vertCount = 0;
    
    if ( (totalSegments) > vertCount ) {
        if (_circleArray) {
            free(_circleArray);
        }
        if (_colorArray) {
            free(_colorArray);
        }
        _circleArray = (float*)malloc( totalSegments * 2 * sizeof(*_circleArray) );
        _colorArray = (float*)malloc( totalSegments * 4 * sizeof(*_colorArray) );
        vertCount = (totalSegments);
    }
	
	// Set up the counter that will track the number of vertices we will have
	int vertexCount = 0;
	int colorCount = 0;
	// Loop through each segment creating the vertices for that segment and add
	// the vertices to the vertices array
	for(int segment = 0; segment < totalSegments; segment++) 
	{ 
		// Insert the first color if it is a filled segment
		if (segment == coloredSegmentIndex ||
            segment == coloredSegmentIndex + 1) {
			_colorArray[colorCount++] = filledColor.red;
			_colorArray[colorCount++] = filledColor.green;
			_colorArray[colorCount++] = filledColor.blue;
			_colorArray[colorCount++] = filledColor.alpha;
		} else {
			_colorArray[colorCount++] = unFilledColor.red;
			_colorArray[colorCount++] = unFilledColor.green;
			_colorArray[colorCount++] = unFilledColor.blue;
			_colorArray[colorCount++] = unFilledColor.alpha;
		}
		
		// Calculate the angle based on the number of segments
		float theta = 2.0f * M_PI * (float)segment / (float)totalSegments;
		
		// Calculate the x and y position of the current segment
		float x = aCircle.radius * cosf(theta + M_PI_2) - scroll.x;
		float y = aCircle.radius * sinf(theta + M_PI_2) - scroll.y;
		
		// Add the new vertices to the vertices array taking into account the circles
		// current x and y position
		_circleArray[vertexCount++] = x + aCircle.x;
		_circleArray[vertexCount++] = y + aCircle.y;
	}
	
	// Set up the vertex pointer to the array of vertices we have created and
	// then use GL_LINE_LOOP to render them
	glEnableClientState(GL_COLOR_ARRAY);
	glColorPointer(4, GL_FLOAT, 0, _colorArray);
	glVertexPointer(2, GL_FLOAT, 0, _circleArray);
	glDrawArrays(GL_LINES, 0, totalSegments);
	glDisableClientState(GL_COLOR_ARRAY);
}
