//
//  UIView+changingResult.h
//  train-helper
//
//  Created by 易元 白 on 15/3/19.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (changingResult)

@property (nonatomic, strong) id changingResult;

- (void) reloadGuiChangingResult: (id) newResult;

@end
