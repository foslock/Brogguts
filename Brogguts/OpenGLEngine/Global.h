//
//  Global.h
//  OpenGLEngine
//
//

#import <OpenGLES/ES1/gl.h>
#import "Structures.h"

#pragma mark -
#pragma mark Macros

// Macro which returns a random value between -1 and 1
#define RANDOM_MINUS_1_TO_1() ((random() / (GLfloat)0x3fffffff )-1.0f)

// Macro which returns a random number between 0 and 1
#define RANDOM_0_TO_1() ((random() / (GLfloat)0x7fffffff ))

// Macro which converts degrees into radians
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

// Macro which converts radians into degrees
#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 180.0 / M_PI)

// Macro that allows you to clamp a value within the defined bounds
#define CLAMP(X, A, B) ((X < A) ? A : ((X > B) ? B : X))

#pragma mark -
#pragma mark Inline Functions

// Returns YES is the point provided is inside the closed poly defined by
// the vertices provided
static inline BOOL isPointInPoly(int sides, float *px, float *py, CGPoint point) {
	int sideCount;
	int totalSides = sides - 1;
	BOOL inside = NO;
	
	for (sideCount = 0; sideCount < sides; sideCount++) {
		if ((py[sideCount] < point.y && py[totalSides] >= point.y) ||
			(py[totalSides] < point.y && py[sideCount] >= point.y)) {
			if (px[sideCount] + (point.y - py[sideCount]) / (py[totalSides] - py[sideCount]) * (px[totalSides] - px[sideCount]) < point.x) {
				inside = !inside;
			}
		}
	}
	return inside;
}

// Returns YES if the rectangle and circle interset each other.  This include the circle being fulling inside
// the rectangle.
static inline BOOL RectIntersectsCircle(CGRect aRect, Circle aCircle) {
	
	float testX = aCircle.x;
	float testY = aCircle.y;
	
	if (testX < aRect.origin.x)
		testX = aRect.origin.x;
	if (testX > (aRect.origin.x + aRect.size.width))
		testX = (aRect.origin.x + aRect.size.width);
	if (testY < aRect.origin.y)
		testY = aRect.origin.y;
	if (testY > (aRect.origin.y + aRect.size.height))
		testY = (aRect.origin.y + aRect.size.height);
	
	return ((aCircle.x - testX) * (aCircle.x - testX) + (aCircle.y - testY) * (aCircle.y - testY)) < aCircle.radius * aCircle.radius;		
}

// Returns YES if the two circles provided intersect each other
static inline BOOL CircleIntersectsCircle(Circle aCircle1, Circle aCircle2) {
	float dx = aCircle2.x - aCircle1.x;
	float dy = aCircle2.y - aCircle1.y;
	float radii = aCircle1.radius + aCircle2.radius;
	
	return ((dx * dx) + (dy * dy)) < radii * radii;
}

static inline CGPoint GetMidpointFromPoints(CGPoint startLocation, CGPoint endLocation) {
	float dx = endLocation.x - startLocation.x;
	float dy = endLocation.y - startLocation.y;
	return CGPointMake(startLocation.x + (dx / 2), startLocation.y + (dy / 2));
}

static inline float GetDistanceBetweenPoints(CGPoint startLocation, CGPoint endLocation) {
	float dx = fabsf(endLocation.x - startLocation.x);
	float dy = fabsf(endLocation.y - startLocation.y);
	return sqrtf((dx * dx) + (dy * dy));
}

static inline BOOL AreCGPointsEqual(CGPoint p1, CGPoint p2) {
	return ( ((int)p1.x == (int)p2.x) && ((int)p1.y == (int)p2.y) );
}

static inline BOOL CircleContainsPoint(Circle circle, CGPoint point) {
	if (GetDistanceBetweenPoints(CGPointMake(circle.x, circle.y), point) <= circle.radius) {
		return YES;
	}
	return NO;
}

// Return a Color4f structure populated with 1.0's
static const Color4f Color4fOnes = {1.0f, 1.0f, 1.0f, 1.0f};

// Return a zero populated Vector2f
static const Vector2f Vector2fZero = {0.0f, 0.0f};

// Return a Scale2f structure populated with the provided floats
static inline Scale2f Scale2fMake(float x, float y) {
    return (Scale2f) {x, y};
}

// Return a populated Vector2d structure from the floats passed in
static inline Vector2f Vector2fMake(GLfloat x, GLfloat y) {
	return (Vector2f) {x, y};
}

static inline CGPoint vm(GLfloat x, GLfloat y) {
	return (CGPoint) {x, y};
}

// Return a Color4f structure populated with the color values passed in
static inline Color4f Color4fMake(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {
	return (Color4f) {red, green, blue, alpha};
}

// Return a Vector2f containing v multiplied by s
static inline Vector2f Vector2fMultiply(Vector2f v, GLfloat s) {
	return (Vector2f) {v.x * s, v.y * s};
}

// Return a Vector2f containing v1 + v2
static inline Vector2f Vector2fAdd(Vector2f v1, Vector2f v2) {
	return (Vector2f) {v1.x + v2.x, v1.y + v2.y};
}

// Return a Vector2f containing v1 - v2
static inline Vector2f Vector2fSub(Vector2f v1, Vector2f v2) {
	return (Vector2f) {v1.x - v2.x, v1.y - v2.y};
}

// Return the dot product of v1 and v2
static inline GLfloat Vector2fDot(Vector2f v1, Vector2f v2) {
	return (GLfloat) v1.x * v2.x + v1.y * v2.y;
}

// Return the length of the vector v
static inline GLfloat Vector2fLength(Vector2f v) {
	return (GLfloat) sqrtf(Vector2fDot(v, v));
}

// Return a Vector2f containing a normalized vector v
static inline Vector2f Vector2fNormalize(Vector2f v) {
	return Vector2fMultiply(v, 1.0f/Vector2fLength(v));
}
