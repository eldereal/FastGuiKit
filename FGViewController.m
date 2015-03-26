//
//  FGViewController.m
//  Pods
//
//  Created by 易元 白 on 15/3/1.
//
//

#import "FGViewController.h"
#import "FGInternal.h"
#import "FGStyle.h"
#import "FGViewGroup.h"
#import "FGDecorationViewContext.h"
#import "FGPushStyleSheetContext.h"

#import <objc/runtime.h>
#import <REKit/REKit.h>
#import "UIView+FGStylable.h"

@interface FGViewController () <FGContext>

@property (copy) FGOnGuiBlock onGuiBlock;

@property (nonatomic, assign) BOOL readyForPushViewControllers;

- (instancetype) initWithOnGuiBlock: (FGOnGuiBlock) block styleClass: (NSString *) styleClass;

@property (nonatomic, weak) UIView *layoutView;

@property (nonatomic, copy) NSString *viewStyleClass;

@end

@implementation FastGui (FGViewController)

+ (void)viewController:(FGOnGuiBlock)onGui
{
    [self viewController:onGui withReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil];
}

+ (void) viewController: (FGOnGuiBlock)onGui styleClass: (NSString *) styleClass
{
    [self viewController:onGui withReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass];
}

+ (void) viewController: (FGOnGuiBlock) onGui withReuseId:(NSString *)reuseId styleClass: (NSString *) styleClass
{
    [FastGui customViewControllerWithReuseId:reuseId initBlock:^UIViewController *(UIViewController *reuseCtrl) {
        FGViewController *ctrl = (FGViewController*)reuseCtrl;
        if (ctrl == nil){
            ctrl = [[FGViewController alloc] initWithOnGuiBlock:onGui styleClass:styleClass];
        }else{
            ctrl.onGuiBlock = onGui;
        }
        return ctrl;
    }];
}

@end


@implementation FGViewController{
    BOOL _automaticallyAdjustsScrollViewInsets;
}

- (BOOL) automaticallyAdjustsScrollViewInsets{
    return _automaticallyAdjustsScrollViewInsets;
}

- (void) setAutomaticallyAdjustsScrollViewInsets:(BOOL)automaticallyAdjustsScrollViewInsets
{
    _automaticallyAdjustsScrollViewInsets = automaticallyAdjustsScrollViewInsets;
}

@synthesize parentContext;

- (instancetype)initWithOnGuiBlock:(FGOnGuiBlock)block styleClass: (NSString *) styleClass
{
    self.onGuiBlock = block;
    self.viewStyleClass = styleClass;
    return [super init];
}

- (void) reloadGui
{
    [FastGui beginGroupWithNextView];
    [FastGui customViewWithClass:self.viewStyleClass reuseId:[FGInternal memoryPositionAsReuseIdOfObject: self.view] initBlock:^UIView *(UIView *reuseView) {
        if (reuseView == nil) {
            reuseView = self.view;
            [reuseView positionStyleDisabledWithTip:@"this is the root view of the view controller"];
            [reuseView sizeStyleDisabledWithTip:@"this is the root view of the view controller"];
        }
        return reuseView;
    } resultBlock:nil];
    [FastGui beginGroupWithNextView];
    UIView *layoutView = [FastGui customViewWithClass:nil reuseId:[FGInternal herePositionAsReuseId] initBlock:^UIView *(UIView *reuseView) {
        if (reuseView == nil) {
            reuseView = [[UIView alloc] init];
            reuseView.translatesAutoresizingMaskIntoConstraints = NO;
        }
        return reuseView;
    } resultBlock:^id(UIView *view) {
        return view;
    }];
    
    layoutView.topConstraint = [self.view updateConstraint:layoutView.topConstraint view1:layoutView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    layoutView.bottomConstraint = [self.view updateConstraint:layoutView.bottomConstraint view1:layoutView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    layoutView.leftConstraint = [self.view updateConstraint:layoutView.leftConstraint view1:layoutView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    layoutView.rightConstraint = [self.view updateConstraint:layoutView.rightConstraint view1:layoutView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    [self onGui];
    
    [FastGui endGroup];
    [FastGui endGroup];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.readyForPushViewControllers = false;
    [FastGui reloadGuiSyncWithContext:self];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.readyForPushViewControllers = true;
    [FastGui pushContext: self];
    [FastGui reloadGui];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [FastGui popContext];
}

- (void) onGui
{
    if(self.onGuiBlock != nil){
        self.onGuiBlock();
    }
}

- (void) styleSheet
{
    [parentContext styleSheet];
}

- (void)customViewControllerWithReuseId:(NSNumber *)reuseId initBlock:(FGInitCustomViewControllerBlock)initBlock
{
    if (self.navigationController != nil){
        UIViewController *ctrl = initBlock(nil);
        [self.navigationController pushViewController:ctrl animated:YES];
    }else if (self.readyForPushViewControllers){
        UIViewController *ctrl = initBlock(nil);
        [self presentViewController:ctrl animated:true completion:nil];
    }
}

- (void)dismissViewController
{
    if (self.navigationController != nil){
        [self.navigationController popViewControllerAnimated:YES];
    }else if (self.readyForPushViewControllers){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (id)customData:(void *)key data:(NSDictionary *)data
{
    return nil;
}

- (id)customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock: (FGStyleBlock) applyStyleBlock;
{
    if ([reuseId isEqualToString: [FGInternal memoryPositionAsReuseIdOfObject: self.view]]) {
        UIView *view = initBlock(self.view);
        applyStyleBlock(view);
        if (resultBlock == nil){
            return nil;
        }else{
            return resultBlock(view);
        }
    }
    printf("Unmatched context, Do you have called to 'EndGroup' without matching 'BeginGroup'?\n");
    return nil;
}

//- (void) overrideTopBottomStyle: (UIView *) view;
//{
//    __weak FGViewController *weakSelf = self;
//    [view respondsToSelector:@selector(styleWithTop:) withKey:nil usingBlock:^(id receiver, CGFloat top){
//        UIView * selfView = receiver;
//        
//        [selfView setTranslatesAutoresizingMaskIntoConstraints:NO];
//        if (selfView.superview != nil) {
//            if (!isnan(top)) {
//                if (selfView.topConstraint == nil) {
//                    selfView.topConstraint = [NSLayoutConstraint constraintWithItem:selfView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem: weakSelf.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1 constant:top];
//                    [weakSelf.view addConstraint:selfView.topConstraint];
//                }else{
//                    selfView.topConstraint.constant = top;
//                }
//            }else{
//                if (selfView.topConstraint != nil) {
//                    [weakSelf.view removeConstraint: selfView.topConstraint];
//                    selfView.topConstraint = nil;
//                }
//            }
//        }
//
//    }];
//    
//    [view respondsToSelector:@selector(styleWithBottom:) withKey:nil usingBlock:^(id receiver, CGFloat bottom){
//        UIView * selfView = receiver;
//        
//        [selfView setTranslatesAutoresizingMaskIntoConstraints:NO];
//        if (selfView.superview != nil) {
//            if (!isnan(bottom)) {
//                if (selfView.bottomConstraint == nil) {
//                    selfView.bottomConstraint = [NSLayoutConstraint constraintWithItem:selfView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem: weakSelf.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:-bottom];
//                    [weakSelf.view addConstraint:selfView.bottomConstraint];
//                }else{
//                    selfView.bottomConstraint.constant = -bottom;
//                }
//            }else{
//                if (selfView.bottomConstraint != nil) {
//                    [weakSelf.view removeConstraint: selfView.bottomConstraint];
//                    selfView.bottomConstraint = nil;
//                }
//            }
//        }
//        
//    }];
//}

@end
