//
//  FastGui+UIButton.h
//  train-helper
//
//  Created by 易元 白 on 15/3/27.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FastGUI.h"

@interface FastGui (UIButton)

+ (void) buttonWithTitle: (NSString *) title styleClass: (NSString *)styleClass onClick: (FGVoidBlock) onClick;

+ (BOOL) buttonWithTitle: (NSString *) title styleClass: (NSString *)styleClass;

+ (BOOL) toggleButtonWithTitle: (NSString *) title;

+ (BOOL) toggleButtonWithTitle: (NSString *) title styleClass: (NSString *)styleClass;

+ (BOOL) toggleButtonWithTitle: (NSString *) title selectedTitle: (NSString *) selectedTitle;

+ (BOOL) toggleButtonWithTitle: (NSString *) title selectedTitle: (NSString *) selectedTitle styleClass: (NSString *)styleClass;

+ (BOOL) toggleButtonWithSelected: (BOOL) selected title: (NSString *) title;

+ (BOOL) toggleButtonWithSelected: (BOOL) selected title: (NSString *) title styleClass: (NSString *)styleClass;

+ (BOOL) toggleButtonWithSelected: (BOOL) selected title: (NSString *) title selectedTitle: (NSString *) selectedTitle;

+ (BOOL) toggleButtonWithSelected: (BOOL) selected title: (NSString *) title selectedTitle: (NSString *) selectedTitle styleClass: (NSString *)styleClass;

+ (void) imageButtonWithName: (NSString *) imageName styleClass: (NSString *)styleClass onClick: (FGVoidBlock) onClick;

+ (void) imageButtonWithName: (NSString *) imageName onClick: (FGVoidBlock) onClick;

+ (BOOL) imageButtonWithName: (NSString *) imageName styleClass: (NSString *)styleClass;

+ (BOOL) imageButtonWithName: (NSString *) imageName;


@end
