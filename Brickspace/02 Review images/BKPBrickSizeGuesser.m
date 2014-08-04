//
//  BKPBrickSizeGuesser.m
//  Brickspace
//
//  Created by Anson Jablinski on 8/4/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//	The silliest spaghetti class you ever did see.
//

#import "BKPBrickSizeGuesser.h"

@implementation BKPBrickSizeGuesser

+ (int)brickLongSideLengthIfShortSideIs2AndVolumeIs:(float)volume {
	double score2x1, score2x2, score2x3, score2x4;
	score2x1 = ABS(volume - avg2x1);
	score2x2 = ABS(volume - avg2x2);
	score2x3 = ABS(volume - avg2x3);
	score2x4 = ABS(volume - avg2x4);
	
	double bestScore = MIN(MIN(score2x1, score2x2), MIN(score2x3, score2x4));
	
	if (bestScore == score2x1)
		return 1;
	else if (bestScore == score2x2)
		return 2;
	else if (bestScore == score2x3)
		return 3;
	else // 2x4 will be the default case
		return 4;
}

# pragma mark - Helpers

static double avg2x1;
static double avg2x2;
static double avg2x3;
static double avg2x4;

+ (void)load {
	avg2x1 = [self averageOfNSNumbersInArray:[self data2x1]];
	avg2x2 = [self averageOfNSNumbersInArray:[self data2x2]];
	avg2x3 = [self averageOfNSNumbersInArray:[self data2x3]];
	avg2x4 = [self averageOfNSNumbersInArray:[self data2x4]];
	
//	NSLog(@"2x1 %.0f\t2x2 %.0f\t2x3 %.0f\t2x4 %.0f", avg2x1, avg2x2, avg2x3, avg2x4);
}

+ (double)averageOfNSNumbersInArray:(NSArray *)array {
	double result = 0;
	unsigned long count = [array count];
	
	for (id object in array) {
		if ([object isKindOfClass:[NSNumber class]]) {
			result += [object doubleValue];
		} else {
			count--;
		}
	}
	
	return result / count;
}

+ (NSArray *)data2x1 {
	return @[@1010.72, @1154.89, @1162.54, @1165.20, @1442.46];
}

+ (NSArray *)data2x2 {
	return @[@1329.53, @1426.41, @1709.62, @1858.33];
}

+ (NSArray *)data2x3 {
	return @[@2724.99, @2980.98, @3095.13, @3165.68, @3228.99];
}

+ (NSArray *)data2x4 {
	return @[@2163.38, @3203.94, @3395.28, @3477.24, @3490.70, @3557.25, @3598.26, @3661.18, @3665.95, @3787.94, @3850.46, @4048.33, @4123.17, @4190.74, @4609.89];
}

@end
