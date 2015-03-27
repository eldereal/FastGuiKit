//
//  UIButton+FGStylable.m
//  train-helper
//
//  Created by 易元 白 on 15/3/19.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "UIButton+FGStylable.h"

@implementation UIButton (FGStylable)

- (void)styleWithColor:(UIColor *)color
{
    self.tintColor = color;
    [self setTitleColor:color forState:UIControlStateNormal];
}

@end
