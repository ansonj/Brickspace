//
//  BKP_GDManager.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/6/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKP_GDManager.h"
#import "BKPGenericDesign.h"

// add individual designs to this
#import "BKP_GD_BasicTower.h"

@implementation BKP_GDManager

+ (NSArray *)availableDesigns {
	NSMutableArray *allDesigns = [NSMutableArray array];
	
	// add individual designs to this, in desired presentation order
	[allDesigns addObject:[BKP_GD_BasicTower class]];
	
	// don't change the rest
	NSMutableArray *availableDesigns = [NSMutableArray array];
	for (id<BKPGenericDesign> design in allDesigns) {
		if ([design shouldBeOfferedToUser])
			[availableDesigns addObject:design];
	}

	return [NSArray arrayWithArray:availableDesigns];
}

@end
