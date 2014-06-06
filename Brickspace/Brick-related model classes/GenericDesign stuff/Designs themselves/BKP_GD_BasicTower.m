//
//  BKP_GD_BasicTower.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/6/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKP_GD_BasicTower.h"

@implementation BKP_GD_BasicTower

+ (BOOL)shouldBeOfferedToUser {
	return YES;
}

+ (NSString *)name {
	return @"Basic Tower";
}

+ (BOOL)canBeBuiltFromBrickSet:(BKPBrickSet *)inputBricks {
	return [inputBricks brickCount] >= 2;
}


+ (float)percentUtilizedIfBuiltWithSet:(BKPBrickSet *)inputBricks {
	assert([self canBeBuiltFromBrickSet:inputBricks]);
	
	return 100;
}

@end
