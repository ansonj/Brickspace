//
//  AppleVideoPreviewView.m
//  Scanning with Structure
//
//  Created by Anson Jablinski on 6/23/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "AppleVideoPreviewView.h"
#import <AVFoundation/AVFoundation.h>

@implementation AppleVideoPreviewView

+ (Class)layerClass {
	return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
	return [(AVCaptureVideoPreviewLayer *)[self layer] session];
}

- (void)setSession:(AVCaptureSession *)session
{
	[(AVCaptureVideoPreviewLayer *)[self layer] setSession:session];
}

@end
