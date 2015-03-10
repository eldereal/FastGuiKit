//
//  FGViewController.m
//  Pods
//
//  Created by 易元 白 on 15/3/1.
//
//

#import "FGViewController.h"
#import "FGInternal.h"
#import "FGViewPool.h"

@interface FGViewController ()

@property (copy) FGOnGuiBlock onGuiBlock;

@property (nonatomic, assign) BOOL readyForPushViewControllers;

@property (nonatomic, assign) CGRect currentFrame;
@property (nonatomic, assign) BOOL currentFrameAnimated;

@property (nonatomic, strong) FGViewPool *pool;

- (void) withFrame: (CGRect) rect animated: (BOOL) animated;

@end

@implementation FastGui (FGViewController)

+ (void) viewController: (FGOnGuiBlock)onGui
{
    [self viewController:onGui withReuseId:[FGInternal callerPositionAsReuseId]];
}

+ (void) viewController: (FGOnGuiBlock) onGui withReuseId:(NSString *)reuseId
{
    [FastGui customViewControllerWithReuseId:reuseId initBlock:^UIViewController *(UIViewController *ctrl) {
        if (ctrl == nil || ![ctrl isKindOfClass:[FGViewController class]]){
            ctrl = [[FGViewController alloc] init];
        }
        FGViewController *fgctrl = (FGViewController *)ctrl;
        fgctrl.onGuiBlock = onGui;
        [fgctrl reloadGui];
        return ctrl;
    }];
}

+ (void)withFrame:(CGRect)rect
{
    [self withFrame: rect animated: false];
}

+ (void)withFrame:(CGRect)rect animated:(BOOL)animated
{
    id ctx = [FastGui context];
    if ([ctx isKindOfClass:[FGViewController class]]) {
        FGViewController *ctrl = ctx;
        [ctrl withFrame: rect animated:animated];
    }
}

@end


@implementation FGViewController

@synthesize readyForPushViewControllers;

@synthesize currentFrame, currentFrameAnimated;

@synthesize pool;

- (void) reloadGui
{
    [self.pool prepareUpdateViews];
    [FastGui callWithContext:self block:^{
        [self onGui];
    }];
    [self.pool finishUpdateViews:^(UIView * view) {
        [self.view addSubview:view];
    } needRemove:^(UIView * view) {
        [view removeFromSuperview];
    }];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.pool = [[FGViewPool alloc] init];
    self.readyForPushViewControllers = false;
    [self reloadGui];
}

- (void) viewDidAppear:(BOOL)animated
{
    self.readyForPushViewControllers = true;
    [self reloadGui];
}

- (void) onGui
{
    if(self.onGuiBlock != nil){
        self.onGuiBlock();
    }
}

- (void)customViewControllerWithReuseId:(NSNumber *)reuseId initBlock:(FGInitCustomViewControllerBlock)initBlock
{
    if (readyForPushViewControllers){
        UIViewController *ctrl = initBlock(nil);
        [self presentViewController:ctrl animated:true completion:nil];
    }
}

- (void) withFrame: (CGRect) rect animated: (BOOL) animated;
{
    self.currentFrame = rect;
    self.currentFrameAnimated = animated;
}

- (id)customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock
{
    __weak FGViewController *weakSelf = self;
    BOOL isNewView;
    
    
    UIView *view = [self.pool updateView:reuseId initBlock:initBlock notifyBlock:^(){
        [weakSelf reloadGui];
    } outputIsNewView: &isNewView];
    
    if (!isNewView && currentFrameAnimated) {
        [UIView beginAnimations:@"currentFrameAnimation" context:nil];
        view.frame = currentFrame;
        [UIView commitAnimations];
    }else{
        view.frame = currentFrame;
    }
    
    if (resultBlock == nil){
        return nil;
    }else{
        return resultBlock(view);
    }
}

@end
