//
//  FastGui+UIButton.h
//  train-helper
//
//  Created by 易元 白 on 15/3/27.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FastGUI.h"

@interface FastGui (UIButton)

+ (BOOL) buttonWithTitle: (NSString *) title styleClass: (NSString *)styleClass;

+ (BOOL) toggleButtonWithTitle: (NSString *) title;

+ (BOOL) toggleButtonWithTitle: (NSString *) title styleClass: (NSString *)styleClass;

+ (BOOL) toggleButtonWithTitle: (NSString *) title selectedTitle: (NSString *) selectedTitle;

+ (BOOL) toggleButtonWithTitle: (NSString *) title selectedTitle: (NSString *) selectedTitle styleClass: (NSString *)styleClass;

+ (BOOL) toggleButtonWithSelected: (BOOL) selected title: (NSString *) title;

+ (BOOL) toggleButtonWithSelected: (BOOL) selected title: (NSString *) title styleClass: (NSString *)styleClass;

+ (BOOL) toggleButtonWithSelected: (BOOL) selected title: (NSString *) title selectedTitle: (NSString *) selectedTitle;

+ (BOOL) toggleButtonWithSelected: (BOOL) selected title: (NSString *) title selectedTitle: (NSString *) selectedTitle styleClass: (NSString *)styleClass;

+ (BOOL) imageButtonWithName: (NSString *) imageName styleClass: (NSString *)styleClass;

+ (BOOL) imageButtonWithName: (NSString *) imageName withTitle: (NSString *) title styleClass: (NSString *)styleClass;
@end

@interface FGStyle(UIButton)

+ (void) imageButtonImageTextSpacing: (CGFloat) spacing;

@end
