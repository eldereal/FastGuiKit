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

- (void) styleWithFontSize:(NSNumber *)fontSize
{
    self.titleLabel.font = [self.titleLabel.font fontWithSize: [fontSize floatValue]];
}

- (void)styleWithFontWeight:(FGStyleFontWeight)fontWeight
{
    if (fontWeight == FGStyleFontWeightNormal) {
        self.titleLabel.font = [UIFont fontWithDescriptor:[self.titleLabel.font.fontDescriptor fontDescriptorWithSymbolicTraits:0] size:0];
    }else{
        self.titleLabel.font = [UIFont fontWithDescriptor:[self.titleLabel.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:0];
    }
}

- (void)styleWithTextAlign:(NSTextAlignment)textAlign
{
    self.titleLabel.textAlignment = textAlign;
}


@end
