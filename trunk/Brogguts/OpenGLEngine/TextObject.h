//
//  TextObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/11/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollidableObject.h"

@class BitmapFont;

@interface TextObject : CollidableObject {
	BOOL isTextHidden;			// If the text is hidden (won't be drawn)
	BOOL scrollWithBounds;	// If the text should scroll with the screen
	int fontID;				// ID of the font to render in
	NSString* objectText;	// Text of the object
	float timeLeft;			// Time (in frames) the object has left alive
	float fadeTime;			// Time that the object will start to fade
	Color4f fontColor;		// Color the font will be drawn with
	Scale2f fontScale;		// Scale the font will be drawn with
}
@property (nonatomic, assign) BOOL isTextHidden;
@property (nonatomic, assign) BOOL scrollWithBounds;
@property (nonatomic, assign) int fontID;
@property (nonatomic, assign) Color4f fontColor;
@property (nonatomic, assign) Scale2f fontScale;
@property (copy) NSString* objectText;

// Set duration to -1 for indefinite duration
- (id)initWithFontID:(int)fontid Text:(NSString*)string withLocation:(CGPoint)location withDuration:(float)duration;

- (void)renderWithFont:(BitmapFont*)font;
- (void)renderWithFont:(BitmapFont*)font withScrollVector:(Vector2f)scroll;

@end
