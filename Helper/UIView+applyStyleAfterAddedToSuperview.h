//
//  UIView+applyStyleAfterAddedToSuperview.h
//  train-helper
//
//  Created by 易元 白 on 15/3/14.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGTypes.h"



@interface UIView(applyStyleAfterAddedToSuperview)

- (void) applyStyleAfterAddedToSuperviewWithBlock: (FGStyleBlock) applyStyleBlock;

@end
