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

// For parameter sets for the detector
#import "BKPDetectorParameterInitializer.h"

// For accessing depth data
#import <Structure/Structure.h>

// For estimating brick size
#import "BKPBrickSizeGuesser.h"

static BOOL printKeypointSearchDebug = NO;
static BOOL printColorDebug = NO;
static BOOL addDuplicatesIntentionally = NO;
static BOOL addBunchOfRandomKeypoints = NO;
static int addThisManyRandomKeypoints = 100;

// Which parameters to use?
static BOOL includeUpCloseParams = NO;
static BOOL includeAfarParams = YES;

@implementation BKPKeypointDetectorAndAnalyzer

+ (void)detectKeypoints:(NSMutableArray *)keypoints inImage:(UIImage *)image {
	[keypoints removeAllObjects];
	
	// convert the image to how we need it
	cv::Mat imageForDetector;
	{
		cv::Mat sourceImage = [BKPMatrixUIImageConverter cvMatFromUIImage:image];
		cv::Mat imageGray;
		cvtColor(sourceImage, imageGray, CV_BGRA2GRAY);
		imageGray.convertTo(imageForDetector, CV_8UC1);
	}
	
	// put together the list of parameter sets we want to use
	NSArray *allParameterSetsToUse = [NSArray array];
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
	
	// run the detection for each parameter set
	for (NSValue *parameterSet in allParameterSetsToUse) {
		cv::SimpleBlobDetector::Params parameters;
		[parameterSet getValue:&parameters];
		
		SimpleBlobDetector *blobDetector = new SimpleBlobDetector(parameters);
		
		vector<cv::KeyPoint> cvKeypoints;
		
		blobDetector->detect(imageForDetector, cvKeypoints);
		
		// stick all the keypoints into the array you were passed
		unsigned long keypointCount = cvKeypoints.size();
		for (int k = 0; k < keypointCount; k++) {
			BKPKeypointBrickPair *newKpBPair = [[BKPKeypointBrickPair alloc] initWithKeypoint:cvKeypoints[k]];
			[keypoints addObject:newKpBPair];
		}
		
		if (printKeypointSearchDebug)
			NSLog(@"Found %lu more keypoints for a total of %lu.", keypointCount, (unsigned long)[keypoints count]);
	}
	
	if (addDuplicatesIntentionally) {
		// Create some keypoints that are right on top, to test the duplicate remover
		
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
		// Create a bunch of random keypoints, to have things to build
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
	
	// Remove any keypoints that are right on top of each other
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
	[self assignBricksToKeypoints:keypoints fromImage:image withDepthFrame:nil];
}

+ (void)assignBricksToKeypoints:(NSMutableArray *)keypoints
					  fromImage:(UIImage *)image
				 withDepthFrame:(STFloatDepthFrame *)depthFrame
{
	// Create empty bricks, so we can have something to concurrently modify
	for (BKPKeypointBrickPair *pair in keypoints) {
		BKPBrick *plainBrick = [BKPBrick brickWithColor:BKPBrickColorBlack shortSide:2 longSide:4 andHeight:3];
		//!!!: This is where the default brick size comes from
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
	
	if (printColorDebug) {
		////// DEBUG
		//	NSLog(@"After adding up %d pixels,", numberOfPixels);
		//	NSLog(@"I found a brick with (R %f) (G %f) (B %f)", averageRed, averageGreen, averageBlue);
		NSLog(@"%p: That's a rounded color of [%3d %3d %3d]", keypoint, (int)averageRed, (int)averageGreen, (int)averageBlue);
		NSLog(@"%p: That's a hex color of # %X %X %X", keypoint, (unsigned int)averageRed, (unsigned int)averageGreen, (unsigned int)averageBlue);
		
		//	cv::Vec4b centerIntensity = matrix.at<Vec4b>(kp.pt.y, kp.pt.x);
		//	NSLog(@"The center of the keypoint is %@", colorFromVec(centerIntensity));
		////// END DEBUG
	}
	
	
	// compute distance from this avg vector to each color vector, as programmatically generated from the available color options
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
	if (printColorDebug)
		NSLog(@"%p: A winrar is %lu", keypoint, (unsigned long)closestColor);
	[[keypoint brick] setColor:(BKPBrickColor)closestColor];
}

+ (void)async_assignSizeToBrickInKeypoint:(BKPKeypointBrickPair *)keypoint
							inImageMatrix:(cv::Mat)matrix
						   withDepthFrame:(STFloatDepthFrame *)depthFrame
{
	// This method is only entered if we have a depth frame.
	// If there is no depth frame, the default brick sizes, set in assignBricksToKeypoints, are unchanged.
	
	// Prepare to grab depth data
	const float *depthData = [depthFrame depthAsMillimeters];
	float (^depthFromFrameAt)(int,int) = ^float(int x, int y) {
		return depthData[x + depthFrame.width * y];
	};
	int (^depthXfromImageX)(float) = ^int(float imageX) {
		//!!!: here are the hard-coded offsets
		// they are in these two blocks because we need to use them for the camera intrinsics math
		return ((int)imageX) + -62;
		// don't need this anymore b/c the image and df are same size (VGA)
//		return imageX * depthFrame.width / matrix.size().width;
	};
	int (^depthYfromImageY)(float) = ^int(float imageY) {
		return ((int)imageY) + -11;
//		return imageY * depthFrame.height / matrix.size().height;
	};
	float (^depthAtImageCoords)(float,float) = ^float(float x, float y) {
		int depthFrameX = depthXfromImageX(x);
		int depthFrameY = depthYfromImageY(y);
		
		return depthFromFrameAt(depthFrameX, depthFrameY);
	};
	
	
	BOOL debugLots = NO;
	BOOL debugSummary = YES;
	BOOL debugFrameData = NO;
		
	// Get the basic info from the keypoint
	float kp_x = keypoint.keypoint.pt.x;
	float kp_y = keypoint.keypoint.pt.y;
	float kp_size = keypoint.keypoint.size;
	
	// Pick the bounds for the area of interest around the brick
	int df_xMin, df_xMax, df_yMin, df_yMax;
	{
		int areaOfInterestPadding = 25;
		df_xMin = depthXfromImageX(kp_x - kp_size) - areaOfInterestPadding;
		df_xMax = depthXfromImageX(kp_x + kp_size) + areaOfInterestPadding;
		df_yMin = depthYfromImageY(kp_y - kp_size) - areaOfInterestPadding;
		df_yMax = depthYfromImageY(kp_y + kp_size) + areaOfInterestPadding;
		
		// Don't try to go out of bounds
		df_xMin = MAX(df_xMin, 0);
		df_xMax = MIN(df_xMax, depthFrame.width - 1); // minus 1 just in case
		df_yMin = MAX(df_yMin, 0);
		df_yMax = MIN(df_yMax, depthFrame.height - 1);
	}
	if (debugLots) {
		NSLog(@"\nI'm examining the depth frame from X(%d - %d) Y(%d - %d).", df_xMin, df_xMax, df_yMin, df_yMax);
		NSLog(@"The center of the depth frame is at (%d, %d).", (df_xMin+df_xMax)/2, (df_yMin+df_yMax)/2);
	}
	
	// Find the threshold, between the table depths and the brick depths
	float thresholdDepth;
	{
		// Find the min and max
		float minDepth = FLT_MAX;
		float maxDepth = FLT_MIN;
		for (int current_df_x = df_xMin; current_df_x <= df_xMax; current_df_x++) {
			for (int current_df_y = df_yMin; current_df_y <= df_yMax; current_df_y++) {
				float depth = depthFromFrameAt(current_df_x, current_df_y);
				if (!isnan(depth)) {
					minDepth = MIN(minDepth, depth);
					maxDepth = MAX(maxDepth, depth);
				}
			}
		}
		
		// The threshold is the midpoint between the min and max, or the average if you like.
		thresholdDepth = (minDepth + maxDepth) / 2.;
	}
	if (debugLots)
		NSLog(@"The threshold sits at %.2f mm.", thresholdDepth);
	
	// Find the height of the brick, in millimeters
	float brickHeight;
	{
		double sumOfTableDepths = 0;
		double sumOfBrickDepths = 0;
		int countOfTableDepths = 0;
		int countOfBrickDepths = 0;
		
		// Fill in the above values
		for (int current_df_x = df_xMin; current_df_x <= df_xMax; current_df_x++) {
			for (int current_df_y = df_yMin; current_df_y <= df_yMax; current_df_y++) {
				
				float depth = depthFromFrameAt(current_df_x, current_df_y);
				
				if (!isnan(depth)) {
					if (depth > thresholdDepth) {
						sumOfTableDepths += depth;
						countOfTableDepths++;
					} else {
						sumOfBrickDepths += depth;
						countOfBrickDepths++;
					}
				}
			}
		}
		
		// Compute the averages
		double averageTableDepth = sumOfTableDepths / countOfTableDepths;
		double averageBrickDepth = sumOfBrickDepths / countOfBrickDepths;
		
		// The brick height is the difference
		brickHeight = averageTableDepth - averageBrickDepth;
		
		if (false) {
			NSLog(@"Brick height calculation:");
			NSLog(@"\tI counted %d points in the table for a sum of %f.", countOfTableDepths, sumOfTableDepths);
			NSLog(@"\tI counted %d points in the brick for a sum of %f.", countOfBrickDepths, sumOfBrickDepths);
			NSLog(@"\tThe average table depth is thus %f mm.", averageTableDepth);
			NSLog(@"\tThe average brick depth is thus %f mm.", averageBrickDepth);
			NSLog(@"\tThe difference of these two is %f mm.", brickHeight);
		}
	}
	if (debugLots)
		NSLog(@"Looks like the brick is %.2f mm high.", brickHeight);
	
	// Figure out how far apart each depth pixel is in the real world
	// Or, figure out the real-world volume that each depth pixel represents
	float rw_xDist, rw_yDist;
	{
		// This stuff comes from ScanDepthRender
		float QVGA_COLS = 320;
		float QVGA_ROWS = 240;
		float QVGA_F_X = 305.73;
		float QVGA_F_Y = 305.62;
		float QVGA_C_X = 159.69;
		float QVGA_C_Y = 119.86;
		float cols = 640;
		float rows = 480;
		float _fx = QVGA_F_X/QVGA_COLS*cols;
		float _fy = QVGA_F_Y/QVGA_ROWS*rows;
		float _cx = QVGA_C_X/QVGA_COLS*cols;
		float _cy = QVGA_C_Y/QVGA_ROWS*rows;
		
		// Middle of keypoint, in depth frame
		// This is where we are going to calculate the depth pixel area
		int df_x0 = (df_xMin + df_xMax) / 2.;
		int df_y0 = (df_yMin + df_yMax) / 2.;
		int df_x1 = df_x0 + 1;
		int df_y1 = df_y0 + 1;
		// Get the depths for (0,0) (1,0) and (0,1)
		float depth_0_0 = depthFromFrameAt(df_x0, df_y0);
		float depth_1_0 = depthFromFrameAt(df_x1, df_y0);
		float depth_0_1 = depthFromFrameAt(df_x0, df_y1);
		// If any of these depths are NaN, we need to try a different spot.
		while (isnan(depth_0_0) || isnan(depth_0_1) || isnan(depth_1_0)) {
			// Hopefully, we won't be moving too far away from the center of the brick.
			df_x0++;
			df_y0++;
			df_x1++;
			df_y1++;
			depth_0_0 = depthFromFrameAt(df_x0, df_y0);
			depth_1_0 = depthFromFrameAt(df_x1, df_y0);
			depth_0_1 = depthFromFrameAt(df_x0, df_y1);
		}
				
		// Calculate some real-world coordinates
		// This is some of my stuff plus some of his stuff
		float rw_x0 = depth_0_0 * (df_x0	- _cx	) / _fx;
		float rw_x1 = depth_1_0 * (df_x1	- _cx	) / _fx;
		float rw_y0 = depth_0_0 * (_cy		- df_y0	) / _fy;
		float rw_y1 = depth_0_1 * (_cy		- df_y1	) / _fy;
		
		/*
		// FIX THIS:
		// you need to pull 0,0 and 1,0 and 0,1
		// right now you are testing against the diagonal, which is probably inflating sizes!!!!!!
		// also NaN lol
		float x0 = centerDepth0 * (df_x0		- _cx) / _fx;
		float x1 = centerDepth1 * (df_x0 + 1	- _cx) / _fx;
		float y0 = centerDepth0 * (_cy - df_y0		) / _fy;
		float y1 = centerDepth1 * (_cy - df_y0 + 1	) / _fy;
		 */
		
		rw_xDist = ABS(rw_x1 - rw_x0);
		rw_yDist = ABS(rw_y1 - rw_y0);
	}
	if (debugLots)
		NSLog(@"Each depth pixel spans %.2f x %.2f mm, or %.2f mm^2.", rw_xDist, rw_yDist, rw_xDist*rw_yDist);
	
	// Count the number of depth frame pixels that are below the threshold (in the brick)
	int countOfBrickDepthPixels = 0;
	{
		for (int current_df_x = df_xMin; current_df_x <= df_xMax; current_df_x++) {
			for (int current_df_y = df_yMin; current_df_y <= df_yMax; current_df_y++) {
				float depth = depthFromFrameAt(current_df_x, current_df_y);
				
				if (!isnan(depth) && depth < thresholdDepth)
					countOfBrickDepthPixels++;
			}
		}
	}
	if (debugLots)
		NSLog(@"There are %d depth pixels below the threshold (in the brick).", countOfBrickDepthPixels);
	
	// Calculate the volume of the brick
	float brickVolume = brickHeight * rw_xDist * rw_yDist * countOfBrickDepthPixels;
	if (debugLots)
		NSLog(@"The brick volume is approximately %f mm^3.", brickVolume);
	
//	NSLog(@"Wikipedia says it should be %f mm^3.", (9.6*7.8*7.8*2*4));
		
	if (debugSummary) {
		NSLog(@"%.2f mm high, %.2f x %.2f mm, %d pixels in depth = %.2f mm^3 volume", brickHeight, rw_xDist, rw_yDist, countOfBrickDepthPixels, brickVolume);
	}
	
	if (debugFrameData) {
		int resultXmin = INT_MAX;
		int resultXmax = INT_MIN;
		int resultYmin = resultXmin;
		int resultYmax = resultXmax;
		float resultZmin = FLT_MAX;
		float resultZmax = FLT_MIN;
		
		for (int x = df_xMin; x <= df_xMax; x++) {
			for (int y = df_yMin; y <= df_yMax; y++) {
				float depthVal = depthFromFrameAt(x, y);

				if (isnan(depthVal))
					continue;
				
				NSLog(@"(x, y, depth): %d\t%d\t%f", x, y, depthVal);
				
				// update min, max
				{
					resultXmin = MIN(resultXmin, x);
					resultXmax = MAX(resultXmax, x);
					resultYmin = MIN(resultYmin, y);
					resultYmax = MAX(resultYmax, y);
					resultZmin = MIN(resultZmin, depthVal);
					resultZmax = MAX(resultZmax, depthVal);
				}
			}
		}
		NSLog(@"X(%d - %d) Y(%d - %d) Z(%.1f - %.1f)", resultXmin, resultXmax, resultYmin, resultYmax, resultZmin, resultZmax);
		
	}
	
	// random brick sizes for now
	BKPBrick *brick = [keypoint brick];
	[brick setShortSideLength:2];
	[brick setLongSideLength:[BKPBrickSizeGuesser brickLongSideLengthIfShortSideIs2AndVolumeIs:brickVolume]];
	[brick setHeight:3];
}

@end

// http://docs.opencv.org/modules/features2d/doc/common_interfaces_of_feature_detectors.html#keypoint
