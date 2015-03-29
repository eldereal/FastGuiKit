//
//  UITextField+FGStylable.m
//  exibitour
//
//  Created by 易元 白 on 15/3/29.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//

#import "UITextField+FGStylable.h"

@implementation UITextField (FGStylable)

- (void)styleWithColor:(UIColor *)color
{
    self.textColor = color;
}

- (void)styleWithFontSize:(NSNumber *)fontSize
{
    self.font = [self.font fontWithSize: [fontSize floatValue]];
}

- (void)styleWithTextAlign:(NSTextAlignment)textAlign
{
    self.textAlignment = textAlign;
}

@end
