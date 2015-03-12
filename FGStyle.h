//
//  FGStyle.h
//  train-helper
//
//  Created by 易元 白 on 15/3/10.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGTypes.h"

@protocol FGStylable <NSObject>

@optional

- (void) styleWithFontSize: (NSNumber *) fontSize;

- (void) styleWithColor: (UIColor *) color;

- (void) styleWithBackgroundColor: (UIColor *) backgroundColor;

- (void) styleWithCustomKey: (NSString *) key value: (id) value;

- (void) beginUpdateStyle;

- (void) endUpdateStyle;

@end

@interface FGStyle : NSObject

+ (void) updateStyleOfView: (UIView *) view withBlock: (FGStyleBlock) block;

+ (void) left: (CGFloat) left;

+ (void) top: (CGFloat) top;

+ (void) bottom: (CGFloat) bottom;

+ (void) right: (CGFloat) right;

+ (void) width: (CGFloat) width;

+ (void) height: (CGFloat) height;

+ (void) fontSize: (CGFloat) fontSize;

+ (void) color: (UIColor *) color;

+ (void) backgroundColor: (UIColor *) backgroundColor;

+ (void) border: (UIColor *) borderColor width: (CGFloat) borderWidth;

+ (void) borderRadius: (CGFloat) borderRadius;

+ (void) customStyle: (NSString *) key value: (id) value;

@end
