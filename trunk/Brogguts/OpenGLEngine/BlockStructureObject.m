//
//  BlockStructure.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "BlockStructureObject.h"


@implementation BlockStructureObject

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectStructureBlockID withLocation:location isTraveling:traveling];
	if (self) {
		isCheckedForRadialEffect = NO;
	}
	return self;
}

@end
