//
//  FGViewController.m
//  Pods
//
//  Created by 易元 白 on 15/3/1.
//
//

#import "FGViewController.h"
#import "FGInternal.h"
#import "FGReuseItemPool.h"

#import <objc/runtime.h>

@interface FGViewController ()

@property (copy) FGOnGuiBlock onGuiBlock;

@property (nonatomic, assign) BOOL readyForPushViewControllers;

@property (nonatomic, strong) FGReuseItemPool *pool;

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

@end


@implementation FGViewController

@synthesize parentContext;

@synthesize readyForPushViewControllers;

@synthesize pool;

- (void) reloadGui
{
    [self.pool prepareUpdateItems];
    [FastGui callOnGui:^{
        [self onGui];
    } withContext:self];
    [self.pool finishUpdateItems:nil needRemove:^(UIView * view) {
        [view removeFromSuperview];
    }];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.pool = [[FGReuseItemPool alloc] init];
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

- (void) styleSheet
{
    
}

- (void)customViewControllerWithReuseId:(NSNumber *)reuseId initBlock:(FGInitCustomViewControllerBlock)initBlock
{
    if (readyForPushViewControllers){
        UIViewController *ctrl = initBlock(nil);
        [self presentViewController:ctrl animated:true completion:nil];
    }
}

- (id)customData:(void *)key data:(NSDictionary *)data
{
    return nil;
}

- (id)customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock: (FGStyleBlock) applyStyleBlock;
{
    __weak FGViewController *weakSelf = self;
    BOOL isNewView;
    
    
    UIView *view = [self.pool updateItem:reuseId initBlock:initBlock notifyBlock:^(){
        [weakSelf reloadGui];
    } outputIsNewView: &isNewView];
    
    if (isNewView){
        [self.view addSubview: view];
    }
    applyStyleBlock(view);
    
    if (resultBlock == nil){
        return nil;
    }else{
        return resultBlock(view);
    }
}

@end

