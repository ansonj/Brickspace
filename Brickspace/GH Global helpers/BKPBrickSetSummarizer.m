//
//  BKPBrickSetSummarizer.m
//  Brickspace
//
//  Created by Anson Jablinski on 9/12/2014.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPBrickSetSummarizer.h"

#import "BKPPlacedBrick.h"

@implementation BKPBrickSetSummarizer

+ (NSString *)niceDescriptionOfBricksInSet:(NSSet *)bricks {
	/*
	 I tried making a dictionary of brick keys, with objects being the number of instances of that brick in the set.
	 But once you define a hash function / isEqual for the bricks, then you can't have multiples in a set anymore.
	 This breaks everything... so instead of operating on the bricks themselves, I'm going to operate on their descriptions.
	 Hack * 1000000?
	 */

	// Extract all brick objects from the set
	NSMutableSet *bricksToSummarize = [NSMutableSet set];
	for (id object in bricks) {
		if ([object isMemberOfClass:[BKPPlacedBrick class]]) {
			[bricksToSummarize addObject:[object brick]];
		} else if ([object isMemberOfClass:[BKPBrick class]]) {
			[bricksToSummarize addObject:object];
		}
	}
	
	// Count up multiple bricks of the same type
	NSMutableDictionary *brickDescriptionsAndMultiplicities = [NSMutableDictionary dictionary];
	for (BKPBrick *brick in bricksToSummarize) {
		NSString *brickDescription = [brick description];
		if ([brickDescriptionsAndMultiplicities objectForKey:brickDescription]) {
			int currentCount = [[brickDescriptionsAndMultiplicities objectForKey:brickDescription] intValue];
			NSNumber *newCount = [NSNumber numberWithInt:(currentCount + 1)];
			[brickDescriptionsAndMultiplicities setObject:newCount forKey:brickDescription];
		} else {
			[brickDescriptionsAndMultiplicities setObject:@1 forKey:brickDescription];
		}
	}
			
	// Output the result
	NSString *result = [NSString string];
	
	for (NSString *brickDescription in [brickDescriptionsAndMultiplicities allKeys]) {
		int count = [[brickDescriptionsAndMultiplicities objectForKey:brickDescription] intValue];
		result = [result stringByAppendingFormat:@"%dx - %@\n", count, brickDescription];
	}
	
	result = [result stringByAppendingFormat:@"\n%lu bricks total", [bricksToSummarize count]];
		
	return result;
}

@end
