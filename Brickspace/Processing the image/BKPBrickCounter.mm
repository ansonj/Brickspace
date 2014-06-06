//
//  BKPBrickCounter.m
//  Brickspace Stage I
//
//  Created by Anson Jablinski on 6/2/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPBrickCounter.h"
// OpenCV
#import <opencv2/features2d/features2d.hpp>
using namespace cv;
// helper for cv::Mat and UIImage conversion (both ways)
#import "BKPMatrixUIImageConverter.h"
// helper for setting detector parameters
#import "BKPDetectorParameterInitializer.h"

/*
 prepareProcessedImage -- examine the input image. run opencv's detector. draw circles. save to processedImage. This will be called many times during tweaking.
 countedSetOfBricks -- given the keypoints, create a BKPBrickSet that has the counted and colored bricks in it. This will be called ONCE when the user moves to the next stage.
 In future versions, the set of bricks will have to exist earlier, and we'll just add to it with each scan / capture from video, and then return it at the end when the user moves on.
*/

@interface BKPBrickCounter ()
- (void)prepareProcessedImage;
@end

@implementation BKPBrickCounter {
	Mat imageDataForDetector;
	Ptr<FeatureDetector> blobDetector;
	vector<KeyPoint> keypoints;
	
	BOOL processedImageIsReady;
	
}

@synthesize sourceImage, processedImage;

#pragma mark - Public methods (primary)

- (id)init {
	return [self initWithSourceImage:nil];
}

- (id)initWithSourceImage:(UIImage *)newSourceImage {
	self = [super init];
	
	if (self) {
		[self setSourceImage:newSourceImage];
		
		[BKPDetectorParameterInitializer setParameters:BKPDPIParameterSetLego1 forCounter:self];
		
	}
	
	return self;
}

- (UIImage *)processedImage {
	if (!processedImageIsReady)
		[self prepareProcessedImage];
	
	return processedImage;
}

- (BKPBrickSet *)countedSetOfBricks {
	BKPBrickSet *setOfBricks = [[BKPBrickSet alloc] init];
	for (int count = 0; count < [self numberOfBricksDetected]; count++)
		[setOfBricks addBrick:[BKPBrick brickWithColor:BKPBrickColorRed height:BKPBrickHeightFull andSize:BKPBrickSize2x4]];
	return setOfBricks;
}

- (unsigned long)numberOfBricksDetected {
	return keypoints.size();
}

#pragma mark - Parameter synthesis and mutators

@synthesize det_thresholdStep = _det_thresholdStep;
@synthesize det_minThreshold = _det_minThreshold;
@synthesize det_maxThreshold = _det_maxThreshold;
@synthesize det_minRepeatability = _det_minRepeatability;
@synthesize det_minDistBetweenBlobs = _det_minDistBetweenBlobs;
@synthesize det_filterByColor = _det_filterByColor;
@synthesize det_blobColor = _det_blobColor;
@synthesize det_filterByArea = _det_filterByArea;
@synthesize det_minArea = _det_minArea;
@synthesize det_maxArea = _det_maxArea;
@synthesize det_filterByCircularity = _det_filterByCircularity;
@synthesize det_minCircularity = _det_minCircularity;
@synthesize det_maxCircularity = _det_maxCircularity;
@synthesize det_filterByInertia = _det_filterByInertia;
@synthesize det_minInertiaRatio = _det_minInertiaRatio;
@synthesize det_maxInertiaRatio = _det_maxInertiaRatio;
@synthesize det_filterByConvexity = _det_filterByConvexity;
@synthesize det_minConvexity = _det_minConvexity;
@synthesize det_maxConvexity = _det_maxConvexity;

- (void)setDet_thresholdStep:(float)newValue {
	_det_thresholdStep = newValue;
	processedImageIsReady = NO;
}


- (void)setDet_minThreshold:(float)newValue {
	_det_minThreshold = newValue;
	processedImageIsReady = NO;
}


- (void)setDet_maxThreshold:(float)newValue {
	_det_maxThreshold = newValue;
	processedImageIsReady = NO;
}


- (void)setDet_minRepeatability:(size_t)newValue {
	_det_minRepeatability = newValue;
	processedImageIsReady = NO;
}


- (void)setDet_minDistBetweenBlobs:(float)newValue {
	_det_minDistBetweenBlobs = newValue;
	processedImageIsReady = NO;
}


- (void)setDet_filterByColor:(bool)newValue {
	_det_filterByColor = newValue;
	processedImageIsReady = NO;
}


- (void)setDet_blobColor:(unsigned)newValue {
	_det_blobColor = newValue;
	processedImageIsReady = NO;
}


- (void)setDet_filterByArea:(bool)newValue {
	_det_filterByArea = newValue;
	processedImageIsReady = NO;
}


- (void)setDet_minArea:(float)newValue {
	_det_minArea = newValue;
	processedImageIsReady = NO;
}


- (void)setDet_maxArea:(float)newValue {
	_det_maxArea = newValue;
	processedImageIsReady = NO;
}


- (void)setDet_filterByCircularity:(bool)newValue {
	_det_filterByCircularity = newValue;
	processedImageIsReady = NO;
}


- (void)setDet_minCircularity:(float)newValue {
	_det_minCircularity = newValue;
	processedImageIsReady = NO;
}


- (void)setDet_maxCircularity:(float)newValue {
	_det_maxCircularity = newValue;
	processedImageIsReady = NO;
}


- (void)setDet_filterByInertia:(bool)newValue {
	_det_filterByInertia = newValue;
	processedImageIsReady = NO;
}


- (void)setDet_minInertiaRatio:(float)newValue {
	_det_minInertiaRatio = newValue;
	processedImageIsReady = NO;
}


- (void)setDet_maxInertiaRatio:(float)newValue {
	_det_maxInertiaRatio = newValue;
	processedImageIsReady = NO;
}


- (void)setDet_filterByConvexity:(bool)newValue {
	_det_filterByConvexity = newValue;
	processedImageIsReady = NO;
}


- (void)setDet_minConvexity:(float)newValue {
	_det_minConvexity = newValue;
	processedImageIsReady = NO;
}


- (void)setDet_maxConvexity:(float)newValue {
	_det_maxConvexity = newValue;
	processedImageIsReady = NO;
}

#pragma mark - Private methods

- (void)prepareProcessedImage {
	Mat sourceImageData = [BKPMatrixUIImageConverter cvMatFromUIImage:sourceImage];
	// FindContours support only 8uC1 and 32sC1 images in function cvStartFindContours
	Mat imageDataGray;
	cvtColor(sourceImageData, imageDataGray, CV_RGB2GRAY);
	imageDataGray.convertTo(imageDataForDetector, CV_8UC1);
	
	// build detector and use it
	SimpleBlobDetector::Params parameters;
	parameters.thresholdStep = self.det_thresholdStep;
	parameters.minThreshold = self.det_minThreshold;
	parameters.maxThreshold = self.det_maxThreshold;
	parameters.minRepeatability = self.det_minRepeatability;
	parameters.minDistBetweenBlobs = self.det_minDistBetweenBlobs;
	parameters.filterByColor = self.det_filterByColor;
	parameters.blobColor = self.det_blobColor;
	parameters.filterByArea = self.det_filterByArea;
	parameters.minArea = self.det_minArea;
	parameters.maxArea = self.det_maxArea;
	parameters.filterByCircularity = self.det_filterByCircularity;
	parameters.minCircularity = self.det_minCircularity;
	parameters.maxCircularity = self.det_maxCircularity;
	parameters.filterByInertia = self.det_filterByInertia;
	parameters.minInertiaRatio = self.det_minInertiaRatio;
	parameters.maxInertiaRatio = self.det_maxInertiaRatio;
	parameters.filterByConvexity = self.det_filterByConvexity;
	parameters.minConvexity = self.det_minConvexity;
	parameters.maxConvexity = self.det_maxConvexity;
	blobDetector = new SimpleBlobDetector(parameters);
	
	blobDetector->detect(imageDataForDetector, keypoints);
	
	// draw the keypoints
	//http://docs.opencv.org/modules/features2d/doc/drawing_function_of_keypoints_and_matches.html
	Mat imageWithKeypointsDrawn;
	unsigned long keypointCount = keypoints.size();
	sourceImageData.copyTo(imageWithKeypointsDrawn);
	for (int k = 0; k < keypointCount; k++) {
		circle(imageWithKeypointsDrawn, keypoints[k].pt, keypoints[k].size, Scalar(255,255,0), 3);
	}

	processedImage = [BKPMatrixUIImageConverter UIImageFromCVMat:imageWithKeypointsDrawn];
	
	processedImageIsReady = YES;
}




@end
