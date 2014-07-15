//
//  BKPScannedImageCollection.m
//  Scanning with Structure
//
//  Created by Anson Jablinski on 6/25/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPScannedImageCollection.h"

#import "BKPScannedImageAndBricks.h"

@implementation BKPScannedImageCollection

#pragma mark - Convenience constructor

+ (id)emptyCollection {
	return [[BKPScannedImageCollection alloc] init];
}

#pragma mark - Actual implementation

@synthesize imageCollection;

- (id)init {
	self = [super init];
	
	if (self) {
		imageCollection = [NSMutableArray array];
	}
	
	return self;
}

- (NSSet *)allBricksFromAllImages {
	NSMutableSet *allBricks = [NSMutableSet set];
	
	for (BKPScannedImageAndBricks *image in imageCollection) {
		NSSet *bricksInImage = [image bricksFromImage];

		for (BKPBrick *brick in bricksInImage) {
			[allBricks addObject:brick];
		}
	}
	
	return [NSSet setWithSet:allBricks];
}

@end

/*
 BKPScannedImageCollection
 // holds a mutable array of scannedimages
 // 	is the table view's data source
*/