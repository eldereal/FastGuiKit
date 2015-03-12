//
//  FGBasicViews.h
//  exibitour
//
//  Created by 易元 白 on 15/3/9.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//

#import "FastGui.h"


@interface FastGui(FGBasicViews)

+ (void) block;

+ (void) blockWithStyleClass: (NSString *)styleClass;

+ (void) blockWithColor:(UIColor *)color;

+ (void) blockWithColor:(UIColor *)color styleClass: (NSString *)styleClass;

+ (void) labelWithText: (NSString *) text;

+ (void) labelWithText: (NSString *) text styleClass: (NSString *)styleClass;

+ (void) labelWithReuseId:(NSString *)reuseId text: (NSString *)text styleClass: (NSString *)styleClass;

+ (void) imageWithName: (NSString *) name;

+ (void) imageWithName: (NSString *) name styleClass: (NSString *)styleClass;

+ (void)imageWithReuseId:(NSString *)reuseId imageNamed: (NSString *)name styleClass: (NSString *)styleClass;

+ (BOOL) toggleButtonWithTitle: (NSString *) title;

+ (BOOL) toggleButtonWithTitle: (NSString *) title selectedTitle: (NSString *) selectedTitle;


@end
