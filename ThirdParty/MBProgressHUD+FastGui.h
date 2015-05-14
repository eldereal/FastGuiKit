//
//  MBProgressHUD+FastGui.h
//  exibitour
//
//  Created by 易元 白 on 15/5/14.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FastGui.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface FastGui(MBProgressHUD)

+ (void) progressHUDWithProgress: (NSProgress *) progress label: (NSString *) label styleClass: (NSString *) styleClass;

@end
