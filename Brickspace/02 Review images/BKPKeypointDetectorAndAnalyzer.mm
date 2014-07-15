//
//  BKPKeypointDetectorAndAnalyzer.m
//  Scanning with Structure
//
//  Created by Anson Jablinski on 6/25/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPKeypointDetectorAndAnalyzer.h"

#import <opencv2/opencv.hpp>
#import "BKPMatrixUIImageConverter.h"

#import "BKPKeypointBrickPair.h"

@implementation BKPKeypointDetectorAndAnalyzer

+ (void)detectKeypoints:(NSMutableArray *)keypoints inImage:(UIImage *)image {
	[keypoints removeAllObjects];
	
	// run the blob detector, as per usual
	cv::Mat imageForDetector;
	{
		cv::Mat sourceImage = [BKPMatrixUIImageConverter cvMatFromUIImage:image];
		cv::Mat imageGray;
		cvtColor(sourceImage, imageGray, CV_BGRA2GRAY);
		imageGray.convertTo(imageForDetector, CV_8UC1);
	}
	
	cv::SimpleBlobDetector::Params params;
	params.thresholdStep = 5;
	params.minThreshold = 0;
	params.maxThreshold = 220;
	params.minRepeatability = 4;
	params.minDistBetweenBlobs = 0;
	params.filterByColor = NO;
	params.blobColor = 0;
	params.filterByArea = YES;
	params.minArea =  5000;
	params.maxArea = 10000; // used to be FLT_MAX
	params.filterByCircularity = NO;
	params.minCircularity = 0; // bum value
	params.maxCircularity = FLT_MAX;
	params.filterByInertia = NO;
	params.minInertiaRatio = 0; // bum value
	params.maxInertiaRatio = 1; // bum value
	params.filterByConvexity = NO;
	params.minConvexity = 0; // bum value
	params.maxConvexity = FLT_MAX;
	
	SimpleBlobDetector *blobDetector = new SimpleBlobDetector(params);
	
	vector<cv::KeyPoint> cvKeypoints;
	
	blobDetector->detect(imageForDetector, cvKeypoints);
	
	// stick all the keypoints into the array you were passed
	unsigned long keypointCount = cvKeypoints.size();
	for (int k = 0; k < keypointCount; k++) {
		BKPKeypointBrickPair *newKpBPair = [[BKPKeypointBrickPair alloc] initWithKeypoint:cvKeypoints[k]];
		[keypoints addObject:newKpBPair];
	}
	
	// go ahead and sort the keypoints so you can scroll through them in a sensible order
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
	
	NSLog(@"Hello! I found %lu keypoints for a total of %lu.", keypointCount, (unsigned long)[keypoints count]);
}

+ (void)assignBricksToKeypoints:(NSMutableArray *)keypoints
					  fromImage:(UIImage *)image
{
	[self assignBricksToKeypoints:keypoints fromImage:image withDepthFrame:nil];
}

+ (void)assignBricksToKeypoints:(NSMutableArray *)keypoints
					  fromImage:(UIImage *)image
				 withDepthFrame:(STFloatDepthFrame *)depthFrame
{
	// Create empty bricks, so we can have something to concurrently modify
	for (BKPKeypointBrickPair *pair in keypoints) {
		BKPBrick *plainBrick = [BKPBrick brickWithColor:BKPBrickColorBlack shortSide:1 longSide:1 andHeight:1];
		[pair setBrick:plainBrick];
	}
	
	
	// Set up the concurrent queue and group that will keep track of the assignments
	dispatch_queue_t brickAssignmentQueue = dispatch_queue_create("com.ansonjablinski.brickAssignmentQueue", DISPATCH_QUEUE_CONCURRENT);
	dispatch_group_t brickAssignmentGroup = dispatch_group_create();
	

	// Create the image as a matrix, for use in the color assignment
	cv::Mat imageMatrix = [BKPMatrixUIImageConverter cvMatFromUIImage:image];
	// Assign colors to bricks
	for (BKPKeypointBrickPair *keypoint in keypoints) {
		dispatch_group_async(brickAssignmentGroup, brickAssignmentQueue, ^{
			[self async_assignColorToBrickInKeypoint:keypoint inImageMatrix:imageMatrix];
		});
	}
	
	
	// We may or may not have a depth frame.
	if (depthFrame) {
		for (BKPKeypointBrickPair *keypoint in keypoints) {
			dispatch_group_async(brickAssignmentGroup, brickAssignmentQueue, ^{
				[self async_assignSizeToBrickInKeypoint:keypoint inImageMatrix:imageMatrix withDepthFrame:depthFrame];
			});
		}
	}
		
	
	dispatch_group_wait(brickAssignmentGroup, DISPATCH_TIME_FOREVER);
}

#pragma mark - Asynchronous helpers

+ (void)async_assignColorToBrickInKeypoint:(BKPKeypointBrickPair *)keypoint
							 inImageMatrix:(cv::Mat)matrix
{
	// random colors for now
//	[[keypoint brick] setColor:[BKPBrickColorOptions randomColor]];
//	return;
	
	// Official method 1: average pixel intensities, compute nearest color
	cv::KeyPoint kp = keypoint.keypoint;
	
	// average pixel intensities for each color channel across entire keypoint circle
	BOOL (^pixelIsInKeypointCircle)(int,int) = ^BOOL(int x, int y) {
		int kpCenterX = kp.pt.x;
		int kpCenterY = kp.pt.y;
		int kpRadius = kp.size / 2.;
		
		float pixelRadius = pow(kpCenterX - x, 2) + pow(kpCenterY - y, 2);
		
		return pixelRadius <= kpRadius;
	};
	
	NSString *(^colorFromVec)(cv::Vec4b) = ^NSString*(cv::Vec4b vector) {
		unsigned int zero = vector.val[0];
		unsigned int one = vector.val[1];
		unsigned int two = vector.val[2];
		return [NSString stringWithFormat:@"[%3d %3d %3d], # %X%X%X", zero, one, two, zero, one, two];
	};
	
	int startX = kp.pt.x - kp.size / 2.;
	int stopX = startX + kp.size;
	int startY = kp.pt.y - kp.size / 2.;
	int stopY = startY + kp.size;
	
	double sumOfRed = 0;
	double sumOfGreen = 0;
	double sumOfBlue = 0;
	int numberOfPixels = 0;
	
//	NSLog(@"The keypoint is at (%f, %f) with size %f.", kp.pt.x, kp.pt.y, kp.size);
//	NSLog(@"I'll be searching X:%d-%d and Y:%d-%d.", startX, stopX, startY, stopY);
//	NSLog(@"That's %d pixels in total.", (stopX-startX)*(stopY-startY));
	for (int currentX = startX; currentX <= stopX; currentX++) {
		for (int currentY = startY; currentY <= stopY; currentY++) {
			if (pixelIsInKeypointCircle(currentX, currentY)) {
				cv::Vec4b pixelIntensity = matrix.at<Vec4b>(currentY, currentX);
				sumOfRed += pixelIntensity.val[0];
				sumOfGreen += pixelIntensity.val[1];
				sumOfBlue += pixelIntensity.val[2];
				
//				NSLog(@"Pixel %5d at (%3d, %3d) has color %@", numberOfPixels, currentX, currentY, colorFromVec(pixelIntensity));
				
				numberOfPixels++;
			}
		}
	}
	
	double averageRed = sumOfRed / numberOfPixels;
	double averageGreen = sumOfGreen / numberOfPixels;
	double averageBlue = sumOfBlue / numberOfPixels;
	
	////// DEBUG
//	NSLog(@"After adding up %d pixels,", numberOfPixels);
//	NSLog(@"I found a brick with (R %f) (G %f) (B %f)", averageRed, averageGreen, averageBlue);
	NSLog(@"%p: That's a rounded color of [%3d %3d %3d]", keypoint, (int)averageRed, (int)averageGreen, (int)averageBlue);
	NSLog(@"%p: That's a hex color of # %X %X %X", keypoint, (unsigned int)averageRed, (unsigned int)averageGreen, (unsigned int)averageBlue);
	
//	cv::Vec4b centerIntensity = matrix.at<Vec4b>(kp.pt.y, kp.pt.x);
//	NSLog(@"The center of the keypoint is %@", colorFromVec(centerIntensity));
	////// END DEBUG
	
	
	// compute distance from this avg vector to each color vector, as programmatically generated from the available color options
	NSMutableArray *colorDistances = [NSMutableArray array];
	{
		double detectedRed = averageRed / 255.;
		double detectedGreen = averageGreen / 255.;
		double detectedBlue = averageBlue / 255.;
		
		int colorCount = [BKPBrickColorOptions colorCount];
		for (int ccIndex = 0; ccIndex < colorCount; ccIndex++) {
			UIColor *colorToCompare = [BKPBrickColorOptions colorForColor:(BKPBrickColor)ccIndex];
			float compareRed, compareGreen, compareBlue;
			[colorToCompare getRed:&compareRed green:&compareGreen blue:&compareBlue alpha:nil];
			
			double distanceToColor = sqrt(pow(detectedRed-compareRed,2) + pow(detectedGreen-compareGreen,2) + pow(detectedBlue-compareBlue,2));
			
			[colorDistances addObject:[NSNumber numberWithDouble:distanceToColor]];
		}
	}
	
	NSLog(@"%p: %@", keypoint, colorDistances);
	
	// assign the color with the shortest distance
	NSUInteger closestColor = 0;
	{
		assert([colorDistances count] > 0);
		for (int currentIndex = 1; currentIndex < [colorDistances count]; currentIndex++) {
			NSNumber *distance = colorDistances[currentIndex];
			if ([distance compare:(colorDistances[closestColor])] == NSOrderedAscending)
				closestColor = currentIndex;
		}
	}
	NSLog(@"%p: A winrar is %d", keypoint, closestColor);
	[[keypoint brick] setColor:(BKPBrickColor)closestColor];
}

+ (void)async_assignSizeToBrickInKeypoint:(BKPKeypointBrickPair *)keypoint
							inImageMatrix:(cv::Mat)matrix
						   withDepthFrame:(STFloatDepthFrame *)depthFrame
{
	//TODO: depth frame is VGA; image is larger; grab the proper coordinates (this time, it counts)
	
	// random brick sizes for now
	BKPBrick *brick = [keypoint brick];
	[brick setShortSideLength:3];
	[brick setLongSideLength:3];
	[brick setHeight:3];
}

@end

// http://docs.opencv.org/modules/features2d/doc/common_interfaces_of_feature_detectors.html#keypoint
