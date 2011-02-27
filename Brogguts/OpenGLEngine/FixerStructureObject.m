//
//  FixerStructureObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "FixerStructureObject.h"


@implementation FixerStructureObject

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectStructureFixerID withLocation:location isTraveling:traveling];
	if (self) {
		isCheckedForRadialEffect = YES;
	}
	return self;
}

@end
