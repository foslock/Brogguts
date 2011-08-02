//
//  AnimatedImage.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/18/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "AnimatedImage.h"
#import "GameController.h"
#import "Image.h"

@implementation AnimatedImage
@synthesize animationSpeed;

- (void)dealloc {
    [subImageArray release];
    [super dealloc];
}

- (id)initWithFileName:(NSString*)filename withSubImageCount:(int)count {
    self = [super init];
    if (self) {
        NSMutableArray* tempArray = [[NSMutableArray alloc] init];
        currentSubImage = 0;
        animationCounter = 0.0f;
        animationSpeed = 1.0f;
        subImageCount = 0;
        for (int i = 0; i < count; i++) {
            NSString* newFileName = [[filename stringByDeletingPathExtension] stringByAppendingFormat:@"[%i]",i];
            Image* newImage = [[Image alloc] initWithImageNamed:[newFileName stringByAppendingString:@".png"] filter:GL_LINEAR];
            if (newImage) {
                [tempArray addObject:newImage];
                [newImage release];
                subImageCount++;
            }
        }
        subImageArray = [[NSArray alloc] initWithArray:tempArray];
        [tempArray release];
    }
    return self;
}

- (CGSize)imageSize {
    return [[subImageArray objectAtIndex:0] imageSize];
}

- (BOOL)isAnimating {
    if (animationSpeed != 0.0f) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isAnimationComplete {
    if (currentSubImage == subImageCount - 1) {
        return YES;
    } else {
        return NO;
    }
}

- (void)updateAnimatedImageWithDelta:(float)aDelta {
    if (animationCounter < 1.0f) {
        animationCounter += animationSpeed;
    } else if (animationCounter >= 1.0f) {
        animationCounter = 0.0f;
        currentSubImage++;
        if (currentSubImage >= subImageCount) {
            currentSubImage = 0;
        }
    }
}

- (void)renderCurrentSubImageAtPoint:(CGPoint)aPoint {
    if (subImageCount > 0) {
        Image* curImage = [subImageArray objectAtIndex:currentSubImage];
        [curImage renderCenteredAtPoint:aPoint scale:curImage.scale rotation:curImage.rotation];
    }
}

- (void)renderCurrentSubImageAtPoint:(CGPoint)aPoint withScale:(Scale2f)aScale withRotation:(float)aRot {
    if (subImageCount > 0) {
    Image* curImage = [subImageArray objectAtIndex:currentSubImage];
    [curImage renderCenteredAtPoint:aPoint scale:aScale rotation:aRot];
    }
}

- (void)setRenderLayer:(int)layer {
    for (Image* image in subImageArray) {
        [image setRenderLayer:layer];
    }
}

- (void)setScale:(Scale2f)scale {
    for (Image* image in subImageArray) {
        [image setScale:scale];
    }
}


@end
