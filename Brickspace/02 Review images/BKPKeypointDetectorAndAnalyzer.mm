//
//  BKPKeypointDetectorAndAnalyzer.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/25/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPBrickSizeGuesser.h"
#import "BKPDetectorParameterInitializer.h"
#import "BKPKeypointBrickPair.h"
#import "BKPKeypointDetectorAndAnalyzer.h"
#import "BKPMatrixUIImageConverter.h"
#import <opencv2/opencv.hpp>

// Any debug options?
static BOOL printKeypointSearchDebug = NO;
static BOOL printColorDebug = NO;
static BOOL addDuplicatesIntentionally = NO;
static BOOL addBunchOfRandomKeypoints = NO;
static int addThisManyRandomKeypoints = 100;

// Which parameter sets to use?
static BOOL includeUpCloseParams = NO;
static BOOL includeAfarParams = YES;

@implementation BKPKeypointDetectorAndAnalyzer

+ (void)detectKeypoints:(NSMutableArray *)keypoints inImage:(UIImage *)image {
	[keypoints removeAllObjects];
	
	// Convert the image to the Mat[rix] format.
	cv::Mat imageForDetector;
	{
		cv::Mat sourceImage = [BKPMatrixUIImageConverter cvMatFromUIImage:image];
		cv::Mat imageGray;
		cvtColor(sourceImage, imageGray, CV_BGRA2GRAY);
		imageGray.convertTo(imageForDetector, CV_8UC1);
	}
	
	// Put together the list of parameter sets we want to use.
	NSArray *allParameterSetsToUse;
	{
		NSMutableArray *buildingParameterList = [NSMutableArray array];
		
		if (includeUpCloseParams)
			[buildingParameterList addObjectsFromArray:[BKPDetectorParameterInitializer getParametersForLegoUpClose]];

		if (includeAfarParams)
			[buildingParameterList addObjectsFromArray:[BKPDetectorParameterInitializer getParametersForLegoAfarWithStructure]];
		
		allParameterSetsToUse = [NSArray arrayWithArray:buildingParameterList];
	}
	
	if (printKeypointSearchDebug)
		NSLog(@"\n\nBeginning keypoint search.");
	
	// Run the detection for each parameter set.
	for (NSValue *parameterSet in allParameterSetsToUse) {
		cv::SimpleBlobDetector::Params parameters;
		[parameterSet getValue:&parameters];
		
		SimpleBlobDetector *blobDetector = new SimpleBlobDetector(parameters);
		
		vector<cv::KeyPoint> cvKeypoints;
		
		blobDetector->detect(imageForDetector, cvKeypoints);
		
		// Add all the keypoints to the array you were passed.
		unsigned long keypointCount = cvKeypoints.size();
		for (int k = 0; k < keypointCount; k++) {
			BKPKeypointBrickPair *newKpBPair = [[BKPKeypointBrickPair alloc] initWithKeypoint:cvKeypoints[k]];
			[keypoints addObject:newKpBPair];
		}
		
		if (printKeypointSearchDebug)
			NSLog(@"Found %lu more keypoints for a total of %lu.", keypointCount, (unsigned long)[keypoints count]);
	}
	
	if (addDuplicatesIntentionally) {
		// Create some keypoints that are right on top, to test the duplicate remover.
		
		cv::KeyPoint dupe1, dupe2;
		
		dupe1.pt.x = 0;
		dupe1.pt.y = 0;
		dupe1.size = 5;
		
		dupe2.pt.x = dupe1.pt.x;
		dupe2.pt.y = dupe1.pt.y;
		dupe2.size = dupe1.size * 2;
		
		BKPKeypointBrickPair *pair1, *pair2;
		pair1 = [[BKPKeypointBrickPair alloc] initWithKeypoint:dupe1];
		pair2 = [[BKPKeypointBrickPair alloc] initWithKeypoint:dupe2];
		
		[keypoints insertObject:pair1 atIndex:0];
		[keypoints addObject:pair2];
		
		if (printKeypointSearchDebug)
			NSLog(@"Added some intentional duplicates, so now we have %lu keypoints.", (unsigned long)[keypoints count]);
	}
	
	if (addBunchOfRandomKeypoints) {
		// Create a bunch of random keypoints, to test building models that need lots of bricks.
		for (int count = 0; count < addThisManyRandomKeypoints; count++) {
			cv::KeyPoint randomKp;
			randomKp.pt.x = arc4random_uniform(image.size.width);
			randomKp.pt.y = arc4random_uniform(image.size.height);
			
			int sizeLowerBound = 20, sizeUpperBound = 40;
			randomKp.size = arc4random_uniform(sizeUpperBound) + sizeLowerBound;
			
			[keypoints addObject:[[BKPKeypointBrickPair alloc] initWithKeypoint:randomKp]];
		}
		
		if (printKeypointSearchDebug)
			NSLog(@"Added %d random keypoints, so now we have %lu keypoints.", addThisManyRandomKeypoints, (unsigned long)[keypoints count]);
	}
	
	// Go ahead and sort the keypoints so you can scroll through them in a sensible order.
	[keypoints sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		cv::KeyPoint kp1 = [(BKPKeypointBrickPair *)obj1 keypoint];
		cv::KeyPoint kp2 = [(BKPKeypointBrickPair *)obj2 keypoint];
		
		if (kp1.pt.y < kp2.pt.y)
			return NSOrderedAscending;
		else if (kp1.pt.y > kp2.pt.y)
			return NSOrderedDescending;
		else if (kp1.pt.x < kp2.pt.x)
			return NSOrderedAscending;
		else if (kp1.pt.x > kp2.pt.x)
			return NSOrderedDescending;
		else
			return NSOrderedSame;
	}];
	
	// Remove any keypoints that are right on top of each other.
	if ([keypoints count] > 0) {
		int minimumDistanceBetweenKeypoints = 5;
		float (^distanceBetweenKeypoints)(BKPKeypointBrickPair*,BKPKeypointBrickPair*) = ^float(BKPKeypointBrickPair *kpbp1, BKPKeypointBrickPair *kpbp2) {
			cv::Point2f p1 = [kpbp1 keypoint].pt;
			cv::Point2f p2 = [kpbp2 keypoint].pt;
			
			return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
		};
		NSMutableSet *keypointsToRemove = [NSMutableSet set];
		
		for (int startingIndex = 0; startingIndex < [keypoints count] - 1; startingIndex++) {
			BKPKeypointBrickPair *startingKeypoint = keypoints[startingIndex];
			
			for (int compareIndex = startingIndex + 1; compareIndex < [keypoints count]; compareIndex++) {
				BKPKeypointBrickPair *compareKeypoint = keypoints[compareIndex];
				
				if (distanceBetweenKeypoints(startingKeypoint, compareKeypoint) < minimumDistanceBetweenKeypoints)
					[keypointsToRemove addObject:compareKeypoint];
			}
		}
		
		if (printKeypointSearchDebug && [keypointsToRemove count] > 0)
			NSLog(@"Removing %lu keypoints (of %lu) because they were too close to others.", (unsigned long)[keypointsToRemove count], (unsigned long)[keypoints count]);

		for (BKPKeypointBrickPair *keypoint in keypointsToRemove) {
			[keypoints removeObject:keypoint];
		}
		
		if (printKeypointSearchDebug && [keypointsToRemove count] > 0)
			NSLog(@"We are left with %lu keypoints.", (unsigned long)[keypoints count]);
	}
}

+ (void)assignBricksToKeypoints:(NSMutableArray *)keypoints
                      fromImage:(UIImage *)image
{
	// Create empty bricks, so we can have something to modify.
	for (BKPKeypointBrickPair *pair in keypoints) {
		// This is where the default brick size comes from.
		BKPBrick *plainBrick = [BKPBrick brickWithColor:BKPBrickColorBlack shortSide:2 longSide:4 andHeight:3];
		[pair setBrick:plainBrick];
	}
	
	
	// Set up the concurrent queue and group that will keep track of the assignments.
	dispatch_queue_t brickAssignmentQueue = dispatch_queue_create("com.ansonjablinski.brickAssignmentQueue", DISPATCH_QUEUE_CONCURRENT);
	dispatch_group_t brickAssignmentGroup = dispatch_group_create();
	

	// Create the image as a matrix, for use in the color assignment.
	cv::Mat imageMatrix = [BKPMatrixUIImageConverter cvMatFromUIImage:image];
	// Assign colors to bricks.
	for (BKPKeypointBrickPair *keypoint in keypoints) {
		dispatch_group_async(brickAssignmentGroup, brickAssignmentQueue, ^{
			[self async_assignColorToBrickInKeypoint:keypoint inImageMatrix:imageMatrix];
		});
	}
		
	
	dispatch_group_wait(brickAssignmentGroup, DISPATCH_TIME_FOREVER);
}

#pragma mark - Asynchronous helpers

// For the given keypoint, average the pixel intensities and find the nearest color.
+ (void)async_assignColorToBrickInKeypoint:(BKPKeypointBrickPair *)keypoint
                             inImageMatrix:(cv::Mat)matrix
{
	cv::KeyPoint kp = keypoint.keypoint;
	
	// Average pixel intensities for each color channel across entire keypoint circle.
	BOOL (^pixelIsInKeypointCircle)(int,int) = ^BOOL(int x, int y) {
		int kpCenterX = kp.pt.x;
		int kpCenterY = kp.pt.y;
		int kpRadius = kp.size / 2.;
		
		float pixelRadius = pow(kpCenterX - x, 2) + pow(kpCenterY - y, 2);
		
		return pixelRadius <= kpRadius;
	};
	
	int startX = kp.pt.x - kp.size / 2.;
	int stopX = startX + kp.size;
	int startY = kp.pt.y - kp.size / 2.;
	int stopY = startY + kp.size;
	
	double sumOfRed = 0;
	double sumOfGreen = 0;
	double sumOfBlue = 0;
	int numberOfPixels = 0;
	
	for (int currentX = startX; currentX <= stopX; currentX++) {
		for (int currentY = startY; currentY <= stopY; currentY++) {
			if (pixelIsInKeypointCircle(currentX, currentY)) {
				cv::Vec4b pixelIntensity = matrix.at<Vec4b>(currentY, currentX);
				sumOfRed += pixelIntensity.val[0];
				sumOfGreen += pixelIntensity.val[1];
				sumOfBlue += pixelIntensity.val[2];
				
				numberOfPixels++;
			}
		}
	}
	
	double averageRed = sumOfRed / numberOfPixels;
	double averageGreen = sumOfGreen / numberOfPixels;
	double averageBlue = sumOfBlue / numberOfPixels;
	
	if (printColorDebug) {
		NSLog(@"After adding up %d pixels,", numberOfPixels);
		NSLog(@"I found a brick with (R %f) (G %f) (B %f)", averageRed, averageGreen, averageBlue);
		NSLog(@"%p: That's a rounded color of [%3d %3d %3d]", keypoint, (int)averageRed, (int)averageGreen, (int)averageBlue);
		NSLog(@"%p: That's a hex color of # %X %X %X", keypoint, (unsigned int)averageRed, (unsigned int)averageGreen, (unsigned int)averageBlue);
		
		cv::Vec4b centerIntensity = matrix.at<Vec4b>(kp.pt.y, kp.pt.x);
		unsigned int zero = centerIntensity.val[0];
		unsigned int one = centerIntensity.val[1];
		unsigned int two = centerIntensity.val[2];
		NSLog(@"The center of the keypoint is [%3d %3d %3d], # %X%X%X", zero, one, two, zero, one, two);
	}
	
	
	// Compute distance from this average vector to each color vector,
	// as programmatically generated from the available color options.
	NSMutableArray *colorDistances = [NSMutableArray array];
	{
		double detectedRed = averageRed / 255.;
		double detectedGreen = averageGreen / 255.;
		double detectedBlue = averageBlue / 255.;
		
		int colorCount = [BKPBrickColorOptions colorCount];
		for (int ccIndex = 0; ccIndex < colorCount; ccIndex++) {
			UIColor *colorToCompare = [BKPBrickColorOptions colorForColor:(BKPBrickColor)ccIndex];
			CGFloat compareRed, compareGreen, compareBlue;
			[colorToCompare getRed:&compareRed green:&compareGreen blue:&compareBlue alpha:nil];
			
			double distanceToColor = sqrt(pow(detectedRed-compareRed,2) + pow(detectedGreen-compareGreen,2) + pow(detectedBlue-compareBlue,2));
			
			[colorDistances addObject:[NSNumber numberWithDouble:distanceToColor]];
		}
	}
	
	if (printColorDebug)
		NSLog(@"%p: %@", keypoint, colorDistances);
	
	// Assign the color with the shortest distance.
	NSUInteger closestColor = 0;
	{
		assert([colorDistances count] > 0);
		for (int currentIndex = 1; currentIndex < [colorDistances count]; currentIndex++) {
			NSNumber *distance = colorDistances[currentIndex];
			if ([distance compare:(colorDistances[closestColor])] == NSOrderedAscending)
				closestColor = currentIndex;
		}
	}
	
	if (printColorDebug)
		NSLog(@"%p: best guess for color is %lu", keypoint, (unsigned long)closestColor);
	
	[[keypoint brick] setColor:(BKPBrickColor)closestColor];
}

@end
