//
//  BKPCaptureMaster.h
//  Scanning Final
//
//  Created by Anson Jablinski on 7/2/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Structure/Structure.h>

@class AppleVideoPreviewView;

@protocol CaptureMasterResultsDelegate <NSObject>

- (void)previewingDidStart;
- (void)previewingDidStop;

// For the love of all that is green and good,
// do NOT try to performCapture before you receive previewingDidStart.

- (AVCaptureVideoOrientation)getInterfaceOrientation;

- (void)captureMasterDidOutputAVFColorBuffer:(CMSampleBufferRef)buffer;

- (void)captureMasterDidOutputSTColorBuffer:(CMSampleBufferRef)buffer
						andDepthFrame:(STDepthFrame *)depthFrame;

@end

@interface BKPCaptureMaster : NSObject

@property (weak, nonatomic) id<CaptureMasterResultsDelegate> delegate;
@property (weak, nonatomic) AppleVideoPreviewView *cameraPreviewView;

- (id)initWithCameraPreviewView:(AppleVideoPreviewView *)view;

- (void)startPreviewing;
- (void)stopPreviewing;
- (BOOL)isPreviewing;

- (void)performCapture;

@end
