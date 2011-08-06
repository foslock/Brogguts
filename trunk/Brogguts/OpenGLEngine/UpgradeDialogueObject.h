//
//  UpgradeDialogueObject.h
//  OpenGLEngine
//
//  Created by James Lockwood on 8/6/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "DialogueObject.h"

@class TiledButtonObject;
@class StructureObject;

@interface UpgradeDialogueObject : DialogueObject {
    int objectUpgradeID;
    
    TiledButtonObject* confirmButton;
    TiledButtonObject* cancelButton;
    
    StructureObject* upgradesStructure;
}

@property (nonatomic, retain) StructureObject* upgradesStructure;

- (id)initWithUpgradeID:(int)upgradeID;

@end
