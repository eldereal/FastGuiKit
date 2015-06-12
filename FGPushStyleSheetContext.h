//
//  FGPushStyleSheetContext.h
//  train-helper
//
//  Created by 易元 白 on 15/3/17.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FastGui.h"
#import "FGStyle.h"

@interface FastGui(FGPushStyleSheetContext)

+ (void) beginUseStyleSheet:(id<FGStyleSheet>) styleSheet;

+ (void) beginUseStyleSheet:(id<FGStyleSheet>) styleSheet isolated: (BOOL) isolated;

+ (void) beginUseStyleSheetWithBlock:(FGVoidBlock) styleSheet;

+ (void) beginUseStyleSheetWithBlock:(FGVoidBlock) styleSheet isolated: (BOOL) isolated;

+ (void) endUseStyleSheet;

@end


