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

- (void) styleWithLineHeight: (CGFloat)lineHeight
{
    if (self.attributedText == nil) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.minimumLineHeight = lineHeight;
        style.maximumLineHeight = lineHeight;
        self.attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:@{NSParagraphStyleAttributeName: style}];
    }else{
        NSRange currentRange;
        NSParagraphStyle * style = [self.attributedText attribute:NSParagraphStyleAttributeName atIndex:0 longestEffectiveRange:&currentRange inRange:NSMakeRange(0, self.attributedText.length)];
        if(style == nil || style.minimumLineHeight != lineHeight || style.maximumLineHeight != lineHeight || currentRange.location != 0 || currentRange.length != self.attributedText.length){
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.minimumLineHeight = lineHeight;
            style.maximumLineHeight = lineHeight;
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
            [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, self.attributedText.length)];
            self.attributedText = str;
        }
    }
}

- (void)styleWithTextAlign:(NSTextAlignment)textAlign
{
    self.textAlignment = textAlign;
}

@end
