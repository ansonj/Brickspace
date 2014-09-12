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
	// Get just the bricks that are in the image
	NSMutableSet *actualBricks = [NSMutableSet set];
	for (id object in bricks) {
		if ([object isMemberOfClass:[BKPPlacedBrick class]]) {
			[actualBricks addObject:[object brick]];
		} else if ([object isMemberOfClass:[BKPBrick class]]) {
			[actualBricks addObject:object];
		}
	}
	
	// Count up multiple bricks of the same type
	NSMutableDictionary *pieceCount = [NSMutableDictionary dictionary];
	for (BKPBrick *brick in actualBricks) {
		BKPBrick *brickInPieceCount = nil;
		for (BKPBrick *brickSearch in [pieceCount allKeys]) {
			BOOL bricksAreEqual = ([brick color] == [brickSearch color]);
			bricksAreEqual = bricksAreEqual && ([brick shortSideLength] == [brickSearch shortSideLength]);
			bricksAreEqual = bricksAreEqual && ([brick longSideLength] == [brickSearch longSideLength]);
			bricksAreEqual = bricksAreEqual && ([brick height] == [brickSearch height]);
			
			if (bricksAreEqual) {
				brickInPieceCount = brickSearch;
				break;
			}
		}
		
		if (brickInPieceCount) {
			int currentCount = [[pieceCount objectForKey:brickInPieceCount] intValue];
			NSNumber *newCount = [NSNumber numberWithInt:(currentCount + 1)];
			[pieceCount setObject:newCount forKey:brickInPieceCount];
		} else {
			[pieceCount setObject:[NSNumber numberWithInt:1] forKey:brick];
		}
	}
		
	// Output the result
	NSString *result = [NSString string];
	
	for (BKPBrick *brick in [pieceCount allKeys]) {
		int count = [[pieceCount objectForKey:brick] intValue];
		//???: hack -- the NSNumber is sometimes null?!? difficult to reproduce
		if (!count)
			count = 1;
		result = [result stringByAppendingFormat:@"%dx - %@\n", count, brick];
	}
	
	result = [result stringByAppendingFormat:@"\n%lu bricks total", [actualBricks count]];
		
	return result;
}

@end
