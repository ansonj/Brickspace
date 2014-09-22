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

+ (NSString *)niceDescriptionOfBricksInSet:(NSSet *)bricks
							 withTotalLine:(BOOL)includeTotal {
	/*
	 The rest of Brickspace considers two instances of BKPBricks with the same properties to be unequal.
	 In other words, two bricks with the exact same properties can both be in the same NSSet.
	 This makes it difficult to build a dictionary where each brick is a key for an NSNumber that counts its multiplicity in a set.
	 So, the dictionary I build here uses the bricks' descriptions as keys, which are identical for BKPBricks with identical properties.
	 */

	// Extract all brick objects from the set.
	NSMutableSet *bricksToSummarize = [NSMutableSet set];
	for (id object in bricks) {
		if ([object isMemberOfClass:[BKPPlacedBrick class]]) {
			[bricksToSummarize addObject:[object brick]];
		} else if ([object isMemberOfClass:[BKPBrick class]]) {
			[bricksToSummarize addObject:object];
		}
	}
	
	// Count up multiple bricks of the same type.
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
			
	// Output the result.
	NSString *result = [NSString string];
	int numberOfNewlinesToPrint = (int)[brickDescriptionsAndMultiplicities count] - 1;
	for (NSString *brickDescription in [brickDescriptionsAndMultiplicities allKeys]) {
		int count = [[brickDescriptionsAndMultiplicities objectForKey:brickDescription] intValue];
		result = [result stringByAppendingFormat:@"%dx - %@", count, brickDescription];
		
		if (numberOfNewlinesToPrint > 0) {
			result = [result stringByAppendingString:@"\n"];
			numberOfNewlinesToPrint--;
		}
	}
	
	if (includeTotal)
		result = [result stringByAppendingFormat:@"\n\n%lu bricks total", (unsigned long)[bricksToSummarize count]];
		
	return result;
}

@end
