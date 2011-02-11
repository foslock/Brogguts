//
//  ControllableObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/11/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchableObject.h"

@interface ControllableObject : TouchableObject {

}

- (id)initWithImage:(Image*)image withLocation:(CGPoint)location withObjectType:(int)objecttype;


@end
