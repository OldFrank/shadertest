//
//  ColorTrackingViewController.h
//  ColorTracking
//
//
//  The source code for this application is available under a BSD license.  See License.txt for details.
//
//  Created by Brad Larson on 10/7/2010.
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>
#import "ColorTrackingCamera.h"
#import "ColorTrackingGLView.h"

//typedef enum { PASSTHROUGH_VIDEO, SIMPLE_THRESHOLDING, POSITION_THRESHOLDING, OBJECT_TRACKING} ColorTrackingDisplayMode;
typedef enum { PASSTHROUGH_VIDEO, SIMPLE_THRESHOLDING, POSITION_THRESHOLDING, CALIBRATION} ColorTrackingDisplayMode;


@interface ColorTrackingViewController : UIViewController <ColorTrackingCameraDelegate>
{
	ColorTrackingCamera *camera;
	UIScreen *screenForDisplay;
	ColorTrackingGLView *glView;
	CALayer *trackingDot;
		
	ColorTrackingDisplayMode displayMode;
	
	BOOL shouldReplaceThresholdColor;
	CGPoint currentTouchPoint;
	GLfloat thresholdSensitivity;
	GLfloat thresholdColor[3];
	GLfloat myFloater;
	
	GLuint directDisplayProgram, thresholdProgram, positionProgram;
	GLuint videoFrameTexture;
	
	GLubyte *rawPositionPixels;
	
	CFURLRef		soundFileURLRef;
	SystemSoundID	soundFileObject;
}

@property(readonly) ColorTrackingGLView *glView;

@property (nonatomic, retain) UILabel *overlay;

@property (readwrite)	CFURLRef		soundFileURLRef;
@property (readonly)	SystemSoundID	soundFileObject;

// Initialization and teardown
- (id)initWithScreen:(UIScreen *)newScreenForDisplay;

// OpenGL ES 2.0 setup methods
- (BOOL)loadVertexShader:(NSString *)vertexShaderName fragmentShader:(NSString *)fragmentShaderName forProgram:(GLuint *)programPointer;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

// Display mode switching
- (void)handleSwitchOfDisplayMode:(id)sender;

// Image processing
- (CGPoint)centroidFromTexture:(GLubyte *)pixels;

@end

