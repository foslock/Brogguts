//
//  TiledButtonObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/27/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TiledButtonObject.h"
#import "Image.h"
#import "ImageRenderSingleton.h"

#define BUTTON_UNSCALED_SIZE 24.0f
#define BUTTON_SCALED_SIZE 8.0f
#define BUTTON_INSET_AMOUNT 4.0f

@implementation TiledButtonObject
@synthesize isPushable, isPushed, wasJustReleased;

// This rect must have an EVEN width and height both above 48 pixels
- (id)initWithRect:(CGRect)buttonRect;
{
    int width = CLAMP(buttonRect.size.width, (2*BUTTON_UNSCALED_SIZE), FLT_MAX);
    int height = CLAMP(buttonRect.size.height, (2*BUTTON_UNSCALED_SIZE), FLT_MAX);
    
    drawRect = CGRectMake(buttonRect.origin.x,
                          buttonRect.origin.y,
                          width + (width % (int)BUTTON_SCALED_SIZE),
                          height + (height % (int)BUTTON_SCALED_SIZE));
    CGPoint point = CGPointMake(drawRect.origin.x + drawRect.size.width / 2,
                                drawRect.origin.y + drawRect.size.height / 2);
    self = [super initWithImage:nil withLocation:point withObjectType:kObjectTiledButtonID];
    if (self) {
        isTouchable = YES;
        isPushed = NO;
        isPushable = YES;
        topLeft = [[Image alloc] initWithImageNamed:@"buttontopleft.png" filter:GL_LINEAR];
        topMiddle = [[Image alloc] initWithImageNamed:@"buttontopmiddle.png" filter:GL_LINEAR];       // Scaled
        topRight = [[Image alloc] initWithImageNamed:@"buttontopright.png" filter:GL_LINEAR];
        
        // Middle Row
        middleLeft = [[Image alloc] initWithImageNamed:@"buttonmiddleleft.png" filter:GL_LINEAR];      // Scaled
        middleMiddle = [[Image alloc] initWithImageNamed:@"buttonmiddle.png" filter:GL_LINEAR];    // Scaled
        middleRight = [[Image alloc] initWithImageNamed:@"buttonmiddleright.png" filter:GL_LINEAR];     // Scaled
        
        // Bottom Row
        bottomLeft = [[Image alloc] initWithImageNamed:@"buttonbotleft.png" filter:GL_LINEAR];
        bottomMiddle = [[Image alloc] initWithImageNamed:@"buttonbotmiddle.png" filter:GL_LINEAR];    // Scaled
        bottomRight = [[Image alloc] initWithImageNamed:@"buttonbotright.png" filter:GL_LINEAR];
        
        images = [[NSMutableArray alloc] initWithCapacity:9];
        [images addObject:topLeft];
        [images addObject:topMiddle];
        [images addObject:topRight];
        [images addObject:middleLeft];
        [images addObject:middleMiddle];
        [images addObject:middleRight];
        [images addObject:bottomLeft];
        [images addObject:bottomMiddle];
        [images addObject:bottomRight];
        for (Image* image in images) {
            [image setRenderLayer:kLayerHUDBottomLayer];
            [image setAlwaysRender:YES];
        }
    }
    
    return self;
}

- (Circle)touchableBounds {
    Circle circle;
    circle.x = objectLocation.x;
    circle.y = objectLocation.y;
    circle.radius = drawRect.size.width;
    return circle;
}

- (void)setRenderLayer:(GLuint)layer {
    renderLayer = layer;
    for (Image* image in images) {
        [image setRenderLayer:renderLayer];
        [image setAlwaysRender:YES];
    }
}

- (void)setDrawRect:(CGRect)rect {
    if (!isPushed) {
        drawRect = rect;
    } else {
        drawRect = CGRectInset(rect, BUTTON_INSET_AMOUNT, BUTTON_INSET_AMOUNT);
    }
}

- (void)setIsPushable:(BOOL)pushable {
    isPushable = pushable;
}

- (void)setIsPushed:(BOOL)pushed {
    if (pushed && !isPushed) {
        isPushed = pushed;
        for (Image* image in images) {
            [image setColor:Color4fMake(0.5f, 0.5f, 0.5f, 1.0f)];
        }
    } else if (!pushed && isPushed) {
        isPushed = pushed;
        for (Image* image in images) {
            [image setColor:Color4fMake(1.0f, 1.0f, 1.0f, 1.0f)];
        }
    }
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
    [super renderCenteredAtPoint:aPoint withScrollVector:vector];
    // Render the top row of images
    
    CGPoint botLeftPoint = CGPointMake(drawRect.origin.x + (BUTTON_UNSCALED_SIZE / 2),
                                       drawRect.origin.y + (BUTTON_UNSCALED_SIZE / 2));
    
    CGPoint botRightPoint = CGPointMake(drawRect.origin.x + drawRect.size.width - (BUTTON_UNSCALED_SIZE / 2),
                                        drawRect.origin.y + (BUTTON_UNSCALED_SIZE / 2));
    
    CGPoint topLeftPoint = CGPointMake(drawRect.origin.x + (BUTTON_UNSCALED_SIZE / 2),
                                       drawRect.origin.y + drawRect.size.height - (BUTTON_UNSCALED_SIZE / 2));
    
    CGPoint topRightPoint = CGPointMake(drawRect.origin.x + drawRect.size.width - (BUTTON_UNSCALED_SIZE / 2),
                                        drawRect.origin.y + drawRect.size.height - (BUTTON_UNSCALED_SIZE / 2));
    
    CGPoint middlePoint = CGPointMake(drawRect.origin.x + (drawRect.size.width / 2),
                                      drawRect.origin.y + (drawRect.size.height / 2));
    
    [topLeft renderCenteredAtPoint:topLeftPoint withScrollVector:vector];
    [topRight renderCenteredAtPoint:topRightPoint withScrollVector:vector];
    [bottomLeft renderCenteredAtPoint:botLeftPoint withScrollVector:vector];
    [bottomRight renderCenteredAtPoint:botRightPoint withScrollVector:vector];
    
    float xMiddleScale = CLAMP(drawRect.size.width - (2 * BUTTON_UNSCALED_SIZE), 0, FLT_MAX);
    float yMiddleScale = CLAMP(drawRect.size.height - (2 * BUTTON_UNSCALED_SIZE), 0, FLT_MAX);
    [middleMiddle setScale:Scale2fMake(xMiddleScale + 2, yMiddleScale + 2)];
    
    for (int i = 0; i <= (int)(xMiddleScale / BUTTON_SCALED_SIZE); i++) {
        CGPoint point = CGPointMake(botLeftPoint.x + (BUTTON_UNSCALED_SIZE / 2) + (i * BUTTON_SCALED_SIZE) - 1,
                                    botLeftPoint.y);
        [bottomMiddle renderCenteredAtPoint:point withScrollVector:vector];
    }
    
    for (int i = 0; i <= (int)(xMiddleScale / BUTTON_SCALED_SIZE); i++) {
        CGPoint point = CGPointMake(topLeftPoint.x + (BUTTON_UNSCALED_SIZE / 2) + (i * BUTTON_SCALED_SIZE) - 1,
                                    topLeftPoint.y);
        [topMiddle renderCenteredAtPoint:point withScrollVector:vector];
    }
    
    for (int i = 0; i <= (int)(yMiddleScale / BUTTON_SCALED_SIZE); i++) {
        CGPoint point = CGPointMake(topLeftPoint.x,
                                    topLeftPoint.y - (BUTTON_UNSCALED_SIZE / 2) - (i * BUTTON_SCALED_SIZE));
        [middleLeft renderCenteredAtPoint:point withScrollVector:vector];
    }
    
    for (int i = 0; i <= (int)(yMiddleScale / BUTTON_SCALED_SIZE); i++) {
        CGPoint point = CGPointMake(topRightPoint.x,
                                    topRightPoint.y - (BUTTON_UNSCALED_SIZE / 2) - (i * BUTTON_SCALED_SIZE));
        [middleRight renderCenteredAtPoint:point withScrollVector:vector];
    }
    
    [middleMiddle renderCenteredAtPoint:middlePoint withScrollVector:vector];
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    if (wasJustReleased) {
        wasJustReleased = NO;
    }
}

- (void)touchesBeganAtLocation:(CGPoint)location {
    if (!CGRectContainsPoint(drawRect, location)) {
        return;
    }
    if (!isPushable) {
        return;
    }
    [self setIsPushed:YES];
}

- (void)touchesEndedAtLocation:(CGPoint)location {
    if (!isPushable) {
        return;
    }
    if (CGRectContainsPoint(drawRect, location) && isPushed) {
        wasJustReleased = YES;
    }
    [self setIsPushed:NO];
}

- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation {
    if (!isPushable) {
        return;
    }
    if (!CGRectContainsPoint(drawRect, toLocation)) {
        [self setIsPushed:NO];
    }
}

- (void)dealloc
{
    [topLeft release];
    [topMiddle release];
    [topRight release];
    [middleLeft release];
    [middleMiddle release];
    [middleRight release];
    [bottomLeft release];
    [bottomMiddle release];
    [bottomRight release];
    [images release];
    [super dealloc];
}

@end
