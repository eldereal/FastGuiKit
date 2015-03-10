//
//  FGTabBarController.h
//  FastGuiKit
//
//  Created by 易元 白 on 15/3/2.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "FastGui.h"
#import "FGContext.h"

@interface FastGui (FGTabBarController)

+ (void) tabBarController: (FGOnGuiBlock) onGui;
+ (BOOL) tabBarItem: (NSString *)name iconNamed: (NSString *)iconName;

@end


@interface FGTabBarController : UITabBarController<FGContext>

- (void) onGui;

- (void) reloadGui;

@end
