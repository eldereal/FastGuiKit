//
//  FGViewGrid.h
//  train-helper
//
//  Created by 易元 白 on 15/3/12.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FastGui.h"
#import "FGStyle.h"

@interface FastGui (FGViewGrid)

+ (void) beginGridWithColumns: (NSUInteger) cols rows: (NSUInteger) rows;

+ (void) beginGridWithColumns: (NSUInteger) cols rows: (NSUInteger) rows styleClass: (NSString *) styleClass;

+ (void) endGrid;

+ (void) emptyGrid;

+ (void) gridRowSpan: (NSUInteger) rowSpan colSpan: (NSUInteger) colSpan;

+ (void) gridRowSpan: (NSUInteger) rowSpan;

+ (void) gridColSpan: (NSUInteger) colSpan;

@end

@interface FGStyle (FGViewGrid)

+ (void) gridSpacing: (CGFloat) gridSpacing;

+ (void) gridSpacingX: (CGFloat) gridSpacingX;

+ (void) gridSpacingY: (CGFloat) gridSpacingY;

@end