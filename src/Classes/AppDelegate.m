//
//  AppDelegate.m
//  AppScaffold
//

#import "AppDelegate.h"
#import "Game.h"
#import "NGLViewExtended.h"
#import "Toast+UIView.h"

// --- c functions ---

void onUncaughtException(NSException *exception)
{
    NSLog(@"uncaught exception: %@", exception.description);
}

// ---

@implementation AppDelegate {
    NGLMesh *_mesh;
    NGLCamera *_camera;
    
    BOOL _shouldRotate;
    BOOL _hasTexture;
    BOOL _animateLight;
    BOOL _useCubeMesh;
    BOOL _showDebug;
    
    NSDictionary *_carSettings;
    NSDictionary *_cubeSettings;
    
    NGLTexture *_carTexture;
    NGLTexture *_cubeTexture;
    
    NGLView *_nglView;
}

@synthesize window = _window, viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&onUncaughtException);
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    _window = [[UIWindow alloc] initWithFrame:screenBounds];
    
    _viewController = [[SPViewController alloc] init];
    
    // Enable some common settings here:
    //
    // _viewController.showStats = YES;
    // _viewController.multitouchEnabled = YES;
    _viewController.preferredFramesPerSecond = 60;
    
    [_viewController startWithRoot:[Game class] supportHighResolutions:YES doubleOnPad:YES];
    _viewController.showStats = TRUE;
    
    [_window setRootViewController:_viewController];
    [_window makeKeyAndVisible];
    
    // Following the UIKit specifications, this method should not call the super.
	
	// Creates the NGLView manually (without XIB), with the screen's size and sets its delegate.
    
    _nglView = [[NGLView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //_nglView = [[NGLViewExtended alloc] initWithFrame:CGRectMake(100, 300, 400, 500)];
    _nglView.backgroundColor = [UIColor clearColor];
    nglGlobalColorFormat(NGLColorFormatRGBA);
    nglGlobalFlush();
    _nglView.userInteractionEnabled = FALSE;
    
	_nglView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_nglView.delegate = self;

    
	// Sets the NGLView as the root view of this View Controller hierarchy.
	[Sparrow.currentController.view addSubview:_nglView];
    
    _carSettings = [NSDictionary dictionaryWithObjectsAndKeys:
							  kNGLMeshCentralizeYes, kNGLMeshKeyCentralize,
							  @"0.7", kNGLMeshKeyNormalize,
							  nil];
	
    _cubeSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                    kNGLMeshCentralizeYes, kNGLMeshKeyCentralize,
                    @"0.3", kNGLMeshKeyNormalize,
                    nil];
    
	_mesh = [[NGLMesh alloc] initWithFile:@"2007chevyavalanche.obj" settings:_carSettings delegate:nil];
    _carTexture = [NGLTexture texture2DWithFile:@"2007chevyavalanche.png"];
    _cubeTexture = [NGLTexture texture2DWithFile:@"cube.mtl"];
	_camera = [[NGLCamera alloc] initWithMeshes:_mesh, nil];
	[_camera autoAdjustAspectRatio:YES animated:YES];
	
	
    UISwitch *switchRotation = [[UISwitch alloc] initWithFrame:CGRectMake(15, 115, 0, 0)];
    [switchRotation addTarget:self action:@selector(onSwitchRotationValueChanged) forControlEvents:UIControlEventValueChanged];
    [Sparrow.currentController.view addSubview:switchRotation];

    UISwitch *switchTexture = [[UISwitch alloc] initWithFrame:CGRectMake(115, 115, 0, 0)];
    [switchTexture addTarget:self action:@selector(onSwitchTextureValueChanged) forControlEvents:UIControlEventValueChanged];
    [Sparrow.currentController.view addSubview:switchTexture];
    
    UISwitch *switchLight = [[UISwitch alloc] initWithFrame:CGRectMake(215, 115, 0, 0)];
    [switchLight addTarget:self action:@selector(onSwitchLightValueChanged) forControlEvents:UIControlEventValueChanged];
    [Sparrow.currentController.view addSubview:switchLight];
    
    UISwitch *switchMesh = [[UISwitch alloc] initWithFrame:CGRectMake(315, 115, 0, 0)];
    [switchMesh addTarget:self action:@selector(onSwitchMeshValueChanged) forControlEvents:UIControlEventValueChanged];
    [Sparrow.currentController.view addSubview:switchMesh];
    
    UISwitch *switchDebug = [[UISwitch alloc] initWithFrame:CGRectMake(415, 115, 0, 0)];
    [switchDebug addTarget:self action:@selector(onSwitchDebugValueChanged) forControlEvents:UIControlEventValueChanged];
    [Sparrow.currentController.view addSubview:switchDebug];
    
    UISwitch *switchSparrowAnimation = [[UISwitch alloc] initWithFrame:CGRectMake(515, 115, 0, 0)];
    [switchSparrowAnimation addTarget:self action:@selector(onSwitchSparrowAnimationValueChanged) forControlEvents:UIControlEventValueChanged];
    [Sparrow.currentController.view addSubview:switchSparrowAnimation];


    return YES;
}

- (void) onSwitchSparrowAnimationValueChanged {
    [_viewController.view makeToast:@"Enable / disable Sparrow animation" duration:3.0 position:@"center"];
    
    [[Game instance] toggleAnimation];
}

- (void) onSwitchDebugValueChanged {
    
    [_viewController.view makeToast:@"Switch between Sparrow and NinevehGL Debug" duration:3.0 position:@"center"];
    
    _showDebug = !_showDebug;
    
    if(_showDebug) {
        [[NGLDebug debugMonitor] startWithView:_nglView];
        _viewController.showStats = FALSE;
    } else {
        [[NGLDebug debugMonitor] stopDebug];
        _viewController.showStats = TRUE;
    }
}
- (void)onSwitchMeshValueChanged {
    
    [_viewController.view makeToast:@"Change 3D Mesh" duration:3.0 position:@"center"];
    
    _useCubeMesh = !_useCubeMesh;
    
    [_camera removeAllMeshes];
     _mesh = nil;
    
    if(_useCubeMesh) {
        _mesh = [[NGLMesh alloc] initWithFile:@"cube.obj" settings:_cubeSettings delegate:nil];
    } else {
        _mesh = [[NGLMesh alloc] initWithFile:@"2007chevyavalanche.obj" settings:_carSettings delegate:nil];
    }
    
    if(_hasTexture) {
        if(_useCubeMesh) {

        } else {
            NGLMaterial *cMaterial = [NGLMaterial material];
            cMaterial.diffuseMap = _carTexture;
            _mesh.material = cMaterial;
        }
        
    } else {
        NGLMaterial *cMaterial = [NGLMaterial material];
        cMaterial.diffuseMap = nil;
        _mesh.material = cMaterial;
    }
    [_camera addMesh:_mesh];
}

- (void)onSwitchLightValueChanged {
    [_viewController.view makeToast:@"Enable / disable light animation" duration:3.0 position:@"center"];
    
    _animateLight = !_animateLight;
}

- (void)onSwitchTextureValueChanged {
    
    [_viewController.view makeToast:@"Enable / disable texture" duration:3.0 position:@"center"];
    
    _hasTexture = !_hasTexture;
    
    if(_hasTexture) {
        
        if(_useCubeMesh) {
            [_camera removeAllMeshes];
            _mesh = nil;
            _mesh = [[NGLMesh alloc] initWithFile:@"cube.obj" settings:_cubeSettings delegate:nil];
             [_camera addMesh:_mesh];
            
        } else {
            NGLMaterial *cMaterial = [NGLMaterial material];
            cMaterial.diffuseMap = _carTexture;
            _mesh.material = cMaterial;
        }
    } else {
        _mesh.material = nil;
    }
    
    [_mesh compileCoreMesh];

}

- (void)onSwitchRotationValueChanged {
    
    [_viewController.view makeToast:@"Enable / disable rotation" duration:3.0 position:@"center"];
    
    _shouldRotate = !_shouldRotate;
}

static float increment = 0.0f;

- (void) drawView {
    if(_shouldRotate) {
        _mesh.rotateY += 1.0f;
    }
    
    if(_animateLight) {
        NGLLight *defaultLight = [NGLLight defaultLight];
        defaultLight.x = sinf(increment * 0.05f) * 1.0f;
        defaultLight.y = sinf(increment * 0.05f) * 1.0f;
        ++increment;
    }
	//_mesh.rotateX -= 0.5f;
	
	[_camera drawCamera];
}

@end
