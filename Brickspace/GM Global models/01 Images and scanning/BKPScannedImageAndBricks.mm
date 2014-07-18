//
//  BKPScannedImageAndBricks.m
//  Scanning with Structure
//
//  Created by Anson Jablinski on 6/25/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPScannedImageAndBricks.h"
#import "BKPKeypointDetectorAndAnalyzer.h"
#import "BKPMatrixUIImageConverter.h"

@interface BKPScannedImageAndBricks () {
	UIImage *_sourceImage;
	STFloatDepthFrame *_depthFrame;
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
		// set up _sourceImage
		// this is from AVCam, avcVC.m, line 393+
		assert(buffer);
		NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:buffer];
		_sourceImage = [[UIImage alloc] initWithData:imageData];
		
		_depthFrame = nil;
		_processedImage = nil;
		_keypointBrickPairs = nil;
		
		[self setCurrentlyHighlightedKeypointIndex:-1];
		
		[self dispatchAsyncUpdateProcessedImage];
	}
	
	return self;
}

- (id)initWithSTColorBuffer:(CMSampleBufferRef)buffer
			  andDepthFrame:(STDepthFrame *)depthFrame {
	self = [super init];
	
	if (self) {
		// set up _sourceimage
		// this code from Structure's Viewer, vc.mm, line 281
		CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(buffer);
		CVPixelBufferLockBaseAddress(pixelBuffer, 0);
		size_t cols = CVPixelBufferGetWidth(pixelBuffer);
		size_t rows = CVPixelBufferGetHeight(pixelBuffer);
		unsigned char *ptr = (unsigned char*) CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
		NSData *data = [[NSData alloc] initWithBytes:ptr length:rows*cols*4];
		CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef) data);
		CGImageRef imageRef = CGImageCreate(cols, rows, 8, 8 * 4, cols * 4, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little, provider, NULL, NO, kCGRenderingIntentDefault);
		
		_sourceImage = [[UIImage alloc] initWithCGImage:imageRef];
		
		_depthFrame = [[STFloatDepthFrame alloc] init];
		[_depthFrame updateFromDepthFrame:depthFrame];
		
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
	//TODO: draw a temp image using openCV that says "working" or something, sheesh
	
	cv::Mat imageInProgress = [BKPMatrixUIImageConverter cvMatFromUIImage:_sourceImage];

	int fontFace = cv::FONT_HERSHEY_PLAIN;
	double fontScale = 2;
	cv::Scalar fontColor = Scalar(255, 255, 255);
	cv::string inProgressText = "Image in progress...";
	
	cv::putText(imageInProgress, inProgressText, cv::Point(42, 42), fontFace, fontScale, fontColor);
	
	return [BKPMatrixUIImageConverter UIImageFromCVMat:imageInProgress];
	
	/*
	int width = _sourceImage.size.width;
	int height = _sourceImage.size.height;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, width * 4, colorSpace, kCGImageAlphaNone);
	
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), _sourceImage.CGImage);

	CGImageRef grayscaleImage = CGBitmapContextCreateImage(context);
	
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	
	return [UIImage imageWithCGImage:grayscaleImage];
	 */
}

- (UIImage *)thumbnailImage {
	//TODO: implement thumbnail?
	return _processedImage;
}

#pragma mark - Keypoints: Adding and removing

// ADDING and REMOVING
// if there's a keypoint nearby, you can toggle it. if not, create a new one
// changes to the keypoints dispatch updateprocessedimage, async, to concurrent Q

- (void)addKeypointAtX:(float)x andY:(float)y {
	//TODO: implement adding keypoint
	// highlight the new keypoint (the last keypoint, assuming you add at the end)
}

- (void)removeKeypointNearestToX:(float)x andY:(float)y {
	//TODO: implement removing keypoint
	// highlight the next keypoint: self.currentlyhkpi = self.chkpi
		// this will trigger an array bounds check
}

#pragma mark - Keypoints: Editing and highlight manipulation

- (BKPKeypointBrickPair *)getCurrentlyHighlightedKeypointPair {
	// check for nil array
	if (!_keypointBrickPairs || [_keypointBrickPairs count] == 0)
		return nil;

	// shouldn't have to check for index out of bounds
		// (array index setter/getters take care of this)
	return _keypointBrickPairs[self.currentlyHighlightedKeypointIndex];
}

- (void)highlightNextKeypoint {
	self.currentlyHighlightedKeypointIndex++;

	// We need to update the processed image immediately.
//	[self dispatchAsyncUpdateProcessedImage];
	[self updateProcessedImage];
}

- (void)highlightPreviousKeypoint {
	self.currentlyHighlightedKeypointIndex--;

	// We need to update the processed image immediately.
//	[self dispatchAsyncUpdateProcessedImage];
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
		
		if (_depthFrame)
			[BKPKeypointDetectorAndAnalyzer assignBricksToKeypoints:_keypointBrickPairs fromImage:_sourceImage withDepthFrame:_depthFrame];
		else
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
	
//	circle(imageWithKeypointsDrawn, cv::Point(0,0), 15, Scalar(255,0,255), 4);
	
	// If depth is availaable, add the depth of the center point of each keypoint
		//TODO: depth frame is VGA; image is larger; grab the proper coordinates
	// note that this is just for fun now. do you want to include depth in the final UI? I'm not convinced.
	// Eventually, this whole block right here will be trashed.
	if (_depthFrame) {
		const float *depthData = [_depthFrame depthAsMillimeters];
		float (^depthAt)(int,int) = ^float(int x, int y) {
			return depthData[x + _depthFrame.width * y];
		};
		int fontFace = cv::FONT_HERSHEY_PLAIN;
		double fontScale = 2;
		cv::Scalar fontColor = Scalar(255, 255, 255);
		
		NSLog(@"Outputting keypoint / depth frame info:");
		for (int k = 0; k < [_keypointBrickPairs count]; k++) {
			cv::KeyPoint keypoint = [_keypointBrickPairs[k] keypoint];
			
			NSString *explanation = [NSString stringWithFormat:@"The keypoint is at (%f, %f). ", keypoint.pt.x, keypoint.pt.y];
			CGSize imageSize = [_sourceImage size];
			explanation = [explanation stringByAppendingFormat:@"The image is %f x %f. ", imageSize.width, imageSize.height];
			int desiredX = keypoint.pt.x * _depthFrame.width / imageSize.width;
			int desiredY = keypoint.pt.y * _depthFrame.height / imageSize.height;
			explanation = [explanation stringByAppendingFormat:@"We want the depth at (%d, %d), ", desiredX, desiredY];
			
			float depthAtPoint = depthAt(desiredX, desiredY);
			
			explanation = [explanation stringByAppendingFormat:@"which is %f.", depthAtPoint];
			NSLog(@"%@", explanation);
			
			NSString *depthNSString = [NSString stringWithFormat:@"%f cm", depthAtPoint / 10.0];
			string depthText = [depthNSString cStringUsingEncoding:NSASCIIStringEncoding];

			cv::putText(imageWithKeypointsDrawn, depthText, keypoint.pt, fontFace, fontScale, fontColor);
		}
		NSLog(@"Done outputting keypoint / depth frame info.");
		
		/*
		// dump that depth frame, plz
		int speedfactor = 40;
		for (int row = 0; row < 800; row += speedfactor) {
			for (int col = 0; col < 800; col += speedfactor) {
				NSLog(@"\t%f", depthAt(col, row));
			}
			NSLog(@"\txxx");
		}
		int stopAt = 800 * 800;
		for (int index = 0; index < stopAt; index += speedfactor) {
			NSLog(@"%f", depthData[index]);
		}
		NSLog(@"doneskies");*/
	}
	
	_processedImage = [BKPMatrixUIImageConverter UIImageFromCVMat:imageWithKeypointsDrawn];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ProcessedImageUpdated" object:self];
	
	// http://docs.opencv.org/modules/features2d/doc/common_interfaces_of_feature_detectors.html#keypoint
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
