//
//  TextObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/11/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollidableObject.h"

#define TEXT_SHADOW_OFFSET_X 2.0f
#define TEXT_SHADOW_OFFSET_Y 2.0f

@class BitmapFont;

@interface TextObject : CollidableObject {
    BOOL drawsInRect;
    CGRect textRect;        // If drawing in a rect, this is the rect to draw text in
	BOOL isTextHidden;		// If the text is hidden (won't be drawn)
	BOOL scrollWithBounds;	// If the text should scroll with the screen
	int fontID;				// ID of the font to render in
	NSString* objectText;	// Text of the object
	float timeLeft;			// Time (in frames) the object has left alive
	float fadeTime;			// Time that the object will start to fade
	Color4f fontColor;		// Color the font will be drawn with
	Scale2f fontScale;		// Scale the font will be drawn with
    
    float textWidthLimit;   // Limits the text to be drawn to a certain width (0.0 means no limit)
}

@property (nonatomic, assign) CGRect textRect;
@property (nonatomic, assign) BOOL isTextHidden;
@property (nonatomic, assign) BOOL scrollWithBounds;
@property (nonatomic, assign) int fontID;
@property (nonatomic, assign) Color4f fontColor;
@property (nonatomic, assign) Scale2f fontScale;
@property (nonatomic, assign) float textWidthLimit;
@property (copy) NSString* objectText;

// Set duration to -1 for indefinite duration
- (id)initWithFontID:(int)fontid Text:(NSString*)string withLocation:(CGPoint)location withDuration:(float)duration;
- (id)initWithFontID:(int)fontid Text:(NSString*)string withRect:(CGRect)rect withDuration:(float)duration;

- (void)renderWithFont:(BitmapFont*)font;
- (void)renderWithFont:(BitmapFont*)font withScrollVector:(Vector2f)scroll centered:(BOOL)centered;

@end
