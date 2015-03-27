//
//  UILabel+FGStylable.m
//  exibitour
//
//  Created by 易元 白 on 15/3/26.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//

#import "UILabel+FGStylable.h"

@implementation UILabel (FGStylable)

- (void)styleWithColor:(UIColor *)color
{
    self.textColor = color;
}

- (void) styleWithFontSize:(NSNumber *)fontSize
{
    self.font = [self.font fontWithSize: [fontSize floatValue]];
}

- (void)styleWithFontWeight:(FGStyleFontWeight)fontWeight
{
    if (fontWeight == FGStyleFontWeightNormal) {
        self.font = [UIFont fontWithDescriptor:[self.font.fontDescriptor fontDescriptorWithSymbolicTraits:0] size:0];
    }else{
        self.font = [UIFont fontWithDescriptor:[self.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:0];
    }
}

@end
