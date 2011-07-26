//
//  ColorTrackingCamera.h
//  ColorTracking
//
//
//  The source code for this application is available under a BSD license.  See License.txt for details.
//
//  Created by Brad Larson on 10/9/2010.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@class ColorTrackingAppDelegate;
@class ColorTrackingViewController;

@protocol ColorTrackingCameraDelegate;

@interface ColorTrackingCamera : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
{
	AVCaptureVideoPreviewLayer *videoPreviewLayer;
	AVCaptureSession *captureSession;
	AVCaptureDeviceInput *videoInput;
	AVCaptureVideoDataOutput *videoOutput;
	AVCaptureDevice *backFacingCamera;
}

@property(nonatomic, assign) id<ColorTrackingCameraDelegate> delegate;
@property(readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;

- (void)startObserver;

@end

@protocol ColorTrackingCameraDelegate
- (void)cameraHasConnected;
- (void)processNewCameraFrame:(CVImageBufferRef)cameraFrame;
@end
