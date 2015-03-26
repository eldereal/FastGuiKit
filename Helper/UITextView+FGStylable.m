//
//  UITextView+FGStylable.m
//  train-helper
//
//  Created by 易元 白 on 15/3/22.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "UITextView+FGStylable.h"
#import "FGStyle.h"

@implementation UITextView (FGStylable)

- (void)styleWithColor:(UIColor *)color
{
    self.textColor = color;
}

- (void)styleWithFontSize:(NSNumber *)fontSize
{
    self.font = [self.font fontWithSize: [fontSize floatValue]];
}

@end
