//
//  TouchableObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/10/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CollidableObject.h"


@interface TouchableObject : CollidableObject {
	BOOL isTouchable;
	BOOL isCurrentlyTouched;
	BOOL isCurrentlyHoveredOver; // Private, true if a touch has entered and NOT left its bounding circle yet
	Circle touchableBounds;
}

@property (nonatomic, assign) BOOL isTouchable;
@property (nonatomic, assign) BOOL isCurrentlyTouched;
@property (nonatomic, assign) Circle touchableBounds;

- (id)initWithImage:(Image*)image withLocation:(CGPoint)location withObjectType:(int)objecttype;
- (void)touchesHoveredOver;
- (void)touchesHoveredLeft;
- (void)touchesBeganAtLocation:(CGPoint)location;
- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation;
- (void)touchesEndedAtLocation:(CGPoint)location;
- (void)touchesDoubleTappedAtLocation:(CGPoint)location;

@end
