//
//  BKPMatrixUIImageConverter.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/3/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPMatrixUIImageConverter.h"

@implementation BKPMatrixUIImageConverter

/*
 This implementation code is adapted from http://docs.opencv.org/doc/tutorials/ios/image_manipulation/image_manipulation.html
 This is a basic image processing tutorial that shows how to convert from cv::Mat to UIImage and back using OpenCV.
 The tutorial was written by Charu Hans.
 The code is also provided as a sample in the OpenCV docs (where????)
 */

+ (Mat)cvMatFromUIImage:(UIImage *)image {
	CGImage *cgiImage = [image CGImage];
	CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgiImage);
	CGFloat cols = [image size].width;
	CGFloat rows = [image size].height;
	
	Mat matrix(rows, cols, CV_8UC4);
	
	CGContextRef contextRef = CGBitmapContextCreate(matrix.data, cols, rows, 8, matrix.step[0], colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault);
	
	CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), cgiImage);
	CGContextRelease(contextRef);
	
	return matrix;
}

+ (UIImage *)UIImageFromCVMat:(cv::Mat)matrix {
	NSData *data = [NSData dataWithBytes:matrix.data length:(matrix.elemSize() * matrix.total())];
	CGColorSpaceRef colorSpace;
	
	if (matrix.elemSize() == 1)
		colorSpace = CGColorSpaceCreateDeviceGray();
	else
		colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
	
	CGImageRef imageRef = CGImageCreate(matrix.cols, matrix.rows, 8, 8*matrix.elemSize(), matrix.step[0], colorSpace, kCGImageAlphaNone | kCGBitmapByteOrderDefault, provider, NULL, NO, kCGRenderingIntentDefault);
	
	UIImage *image = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpace);
	
	return image;
}

@end
