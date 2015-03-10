//
//  FGTabBarController.m
//  FastGuiKit
//
//  Created by 易元 白 on 15/3/2.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FGTabBarController.h"
#import "FGInternal.h"

@interface FGTabBarController ()

- (BOOL) tabBarItem: (NSString *)name iconNamed: (NSString *)iconName reuseId: (NSString *) reuseId;

@property (copy) FGOnGuiBlock onGuiBlock;

@end

@implementation FastGui (FGTabBarController)

/**
 * display a tab bar. return YES if the tab is selected
 * if this method returns YES, you can call controller methods
 * (such as [FastGui navigationController:]). The fist following call to any controller methods
 */

+ (BOOL) tabBarItem: (NSString *)name iconNamed: (NSString *)iconName
{
//    id ctx = [FastGui context];
//    if ([ctx isKindOfClass:[FGTabBarController class]]) {
//        FGTabBarController *ctrl = ctx;
//        return [ctrl tabBarItem:name iconNamed:iconName reuseId:[FGInternal callerPositionAsReuseId]];
//    }
    return false;
}

+ (void) tabBarController: (FGOnGuiBlock) onGui
{
    NSString *reuseId = [FGInternal callerPositionAsReuseId];
    [FastGui customViewControllerWithReuseId:reuseId initBlock:^UIViewController *(UIViewController *ctrl) {
        if (ctrl == nil || ![ctrl isKindOfClass:[FGTabBarController class]]){
            ctrl = [[FGTabBarController alloc] init];
        }
        FGTabBarController * fgctrl = (FGTabBarController *) ctrl;
        fgctrl.onGuiBlock = onGui;
        [fgctrl reloadGui];
        return fgctrl;
    }];
}

@end

@implementation FGTabBarController

@synthesize parentContext;

- (void)reloadGui
{
    [FastGui callOnGui:^{
        [self onGui];
    } withContext:self];
}

- (void)viewDidLoad
{
    [self reloadGui];
}

- (void)viewDidAppear:(BOOL)animated
{
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
    
}

- (id)customViewWithReuseId:(NSNumber *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock
{
    return nil;
}

- (BOOL)tabBarItem:(NSString *)name iconNamed:(NSString *)iconName reuseId:(NSString *)reuseId
{
    return false;
}


@end
