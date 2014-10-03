//
//  BKPCaptureMaster.h
//  Brickspace
//
//  Created by Anson Jablinski on 7/2/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@class AppleVideoPreviewView;

@protocol CaptureMasterResultsDelegate <NSObject>

- (void)previewingDidStart;
- (void)previewingDidStop;

- (void)captureMasterStatusChanged;

- (AVCaptureVideoOrientation)getInterfaceOrientation;

- (void)captureMasterDidOutputAVFColorBuffer:(CMSampleBufferRef)buffer;

@end


@interface BKPCaptureMaster : NSObject

@property (weak, nonatomic) id<CaptureMasterResultsDelegate> delegate;
@property (weak, nonatomic) AppleVideoPreviewView *cameraPreviewView;

- (id)initWithCameraPreviewView:(AppleVideoPreviewView *)view;

- (void)startPreviewing;
- (void)stopPreviewing;
- (BOOL)isPreviewing;

- (NSString *)captureMasterStatusString;

- (void)performCapture;

@end
