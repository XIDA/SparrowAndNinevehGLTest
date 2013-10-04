//
//  AppDelegate.h
//  AppScaffold
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, NGLViewDelegate>
{
	UIWindow *_window;
	SPViewController *_viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) SPViewController *viewController;

@end
