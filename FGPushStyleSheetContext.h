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

+ (void) beginUseStyleSheets:(NSArray *) styleSheets;

+ (void) endUseStyleSheet;

+ (void) endUseStyleSheets;

@end


