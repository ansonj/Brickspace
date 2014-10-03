//
//  BKPScannedImageAndBricks.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/25/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPKeypointDetectorAndAnalyzer.h"
#import "BKPMatrixUIImageConverter.h"
#import "BKPScannedImageAndBricks.h"

@interface BKPScannedImageAndBricks () {
	UIImage *_sourceImage;
	UIImage *_processedImage;
	
	NSMutableArray *_keypointBrickPairs;
}

- (void)updateProcessedImage;

@property (nonatomic) int currentlyHighlightedKeypointIndex;

@end

@implementation BKPScannedImageAndBricks

#pragma mark - Initialization

- (id)init {
	return nil;
}

- (id)initWithAVFColorBuffer:(CMSampleBufferRef)buffer {
	self = [super init];
	
	if (self) {
		// Set up _sourceImage.
		// This is based on Apple's AVCam sample project, AVCamViewController.m:393
		assert(buffer);
		NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:buffer];
		_sourceImage = [[UIImage alloc] initWithData:imageData];
		
		_processedImage = nil;
		_keypointBrickPairs = nil;
		
		[self setCurrentlyHighlightedKeypointIndex:-1];
		
		[self dispatchAsyncUpdateProcessedImage];
	}
	
	return self;
}

#pragma mark - Getting UIImage(s)

- (UIImage *)sourceImage {
	return _sourceImage;
}

- (UIImage *)processedImage {
	if (_processedImage)
		return _processedImage;
		
	// If the processed image is ready, return it. Otherwise, return a temporary image.
	
	cv::Mat imageInProgress = [BKPMatrixUIImageConverter cvMatFromUIImage:_sourceImage];

	int fontFace = cv::FONT_HERSHEY_PLAIN;
	double fontScale = 2;
	cv::Scalar fontColor = Scalar(255, 255, 255);
	cv::string inProgressText = "Image in progress...";
	
	cv::putText(imageInProgress, inProgressText, cv::Point(42, 42), fontFace, fontScale, fontColor);
	
	return [BKPMatrixUIImageConverter UIImageFromCVMat:imageInProgress];
}

- (UIImage *)thumbnailImage {
	//TODO: implement thumbnail?
	return _processedImage;
}

#pragma mark - Keypoints: Adding and removing

// Adding and removing keypoints via tapping the image are on my to-do list.

- (void)addKeypointAtX:(float)x andY:(float)y {
	//TODO: implement adding keypoint
	// Highlight the new keypoint (the last keypoint, assuming you add at the end).
}

- (void)removeKeypointNearestToX:(float)x andY:(float)y {
	//TODO: implement removing keypoint
	// Highlight the next keypoint.
		// self.currentlyhkpi = self.chkpi will trigger an array bounds check
}

- (void)removeCurrentlyHighlightedKeypoint {
	if ([_keypointBrickPairs count] > 1) {
		[_keypointBrickPairs removeObjectAtIndex:self.currentlyHighlightedKeypointIndex];
		[self dispatchAsyncUpdateProcessedImage];
	}
}

#pragma mark - Keypoints: Editing and highlight manipulation

- (BKPKeypointBrickPair *)getCurrentlyHighlightedKeypointPair {
	if (!_keypointBrickPairs || [_keypointBrickPairs count] == 0)
		return nil;

	// We shouldn't have to check for index out of bounds here.
		// (the array index setter/getters take care of this)
	return _keypointBrickPairs[self.currentlyHighlightedKeypointIndex];
}

- (void)highlightNextKeypoint {
	self.currentlyHighlightedKeypointIndex++;

	// Since this method is likely called from the UI, we need to update the processed image immediately.
	[self updateProcessedImage];
}

- (void)highlightPreviousKeypoint {
	self.currentlyHighlightedKeypointIndex--;

	// Since this method is likely called from the UI, we need to update the processed image immediately.
	[self updateProcessedImage];
}

@synthesize currentlyHighlightedKeypointIndex = _currentlyHighlightedKeypointIndex;

- (void)setCurrentlyHighlightedKeypointIndex:(int)currentlyHighlightedKeypointIndex {
	// If there are no keypoints, set to -1.
	if (!_keypointBrickPairs || [_keypointBrickPairs count] == 0) {
		_currentlyHighlightedKeypointIndex = -1;
		return;
	}
	
	// If you're too low, set to the rightmost keypoint in array.
	if (currentlyHighlightedKeypointIndex < 0) {
		_currentlyHighlightedKeypointIndex = (int)[_keypointBrickPairs count] - 1;
		return;
	}
	
	// If you're over the end of the array, go back to the first element.
	if (currentlyHighlightedKeypointIndex >= [_keypointBrickPairs count]) {
		_currentlyHighlightedKeypointIndex = 0;
		return;
	}
	
	// Otherwise, we're good.
	_currentlyHighlightedKeypointIndex = currentlyHighlightedKeypointIndex;
}

- (int)currentlyHighlightedKeypointIndex {
	if (!_keypointBrickPairs || [_keypointBrickPairs count] == 0)
		_currentlyHighlightedKeypointIndex = -1;

	else if (_currentlyHighlightedKeypointIndex < 0 && [_keypointBrickPairs count] > 0)
		_currentlyHighlightedKeypointIndex = 0;
	
	else if (_currentlyHighlightedKeypointIndex >= [_keypointBrickPairs count])
		_currentlyHighlightedKeypointIndex = (int)[_keypointBrickPairs count] - 1;
		
	return _currentlyHighlightedKeypointIndex;
}

#pragma mark - Reset the processed image

- (void)resetProcessedImage {
	_keypointBrickPairs = nil;
	[self dispatchAsyncUpdateProcessedImage];
}

#pragma mark - Update the processed image (the important one)

- (void)dispatchAsyncUpdateProcessedImage {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self updateProcessedImage];
	});
}

- (void)updateProcessedImage {
	if (!_keypointBrickPairs) {
		_keypointBrickPairs = [NSMutableArray array];
		[BKPKeypointDetectorAndAnalyzer detectKeypoints:_keypointBrickPairs inImage:_sourceImage];
		
		[BKPKeypointDetectorAndAnalyzer assignBricksToKeypoints:_keypointBrickPairs fromImage:_sourceImage];
	}
	
	cv::Mat sourceImageData = [BKPMatrixUIImageConverter cvMatFromUIImage:_sourceImage];
	
	cv::Mat imageWithKeypointsDrawn;
	cv::Scalar plainKeypointColor = Scalar(255, 255, 255);
	cv::Scalar highlightedKeypointColor = Scalar(255, 255, 0);
	sourceImageData.copyTo(imageWithKeypointsDrawn);
	for (int k = 0; k < [_keypointBrickPairs count]; k++) {
		cv::KeyPoint keypoint = [_keypointBrickPairs[k] keypoint];
		circle(imageWithKeypointsDrawn, keypoint.pt, keypoint.size, plainKeypointColor, 3);
		
		if (k == self.currentlyHighlightedKeypointIndex)
			circle(imageWithKeypointsDrawn, keypoint.pt, keypoint.size + 4, highlightedKeypointColor, 3);
	}
	
	_processedImage = [BKPMatrixUIImageConverter UIImageFromCVMat:imageWithKeypointsDrawn];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ProcessedImageUpdated" object:self];
}

#pragma mark - At last, get the bricks from the image

- (NSSet *)bricksFromImage {
	if (!_keypointBrickPairs || [_keypointBrickPairs count] == 0)
		return [NSSet set];
	
	NSMutableSet *bricks = [NSMutableSet set];
	
	for (BKPKeypointBrickPair *keypointPair in _keypointBrickPairs) {
		[bricks addObject:[keypointPair brick]];
	}
	
	return [NSSet setWithSet:bricks];
}

@end
