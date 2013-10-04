/*
 *	ViewController.h
 *	NinevehGLTest
 *	
 *	Created by Benjamin Kobjolke on 03.10.13.
 *	Copyright 2013 __MyCompanyName__. All rights reserved.
 */

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NGLViewDelegate>
{
@private
	NGLMesh *_mesh;
	NGLCamera *_camera;
}

@end
