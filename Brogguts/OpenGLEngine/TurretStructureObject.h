//
//  TurretStructure.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StructureObject.h"

#define TURRET_MAX_LASER_WIDTH 6.0f

@interface TurretStructureObject : StructureObject {
	// Attacking vars
    Image* turretGunImage;
	int attackCooldownTimer;
	CGPoint attackLaserTargetPosition;
	int attributeAttackCooldown;
	int attributeWeaponsDamage;
	int attributeAttackRange;
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling;

- (void)attackTarget;

@end
