//
//  FGTableView.h
//  train-helper
//
//  Created by 易元 白 on 15/3/15.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FastGui.h"
#import "FGContext.h"
#import "FGStyle.h"

@interface FastGui(FGTable)

+ (void) beginTable;

+ (void) beginTableWithStyleClass: (NSString *) styleClass;

+ (void) beginTableWithNextCustomView;

+ (void) tableSectionHeaderWithTitle: (NSString *) title;

+ (void) tableSectionHeaderWithNextCustomView;

+ (void) tableSectionFooterWithTitle: (NSString *) title;

+ (void) tableSectionFooterWithNextCustomView;

+ (void) tableHeaderWithNextCustomView;

+ (void) tableFooterWithNextCustomView;

+ (void) tableCellWithText: (NSString *) title;

+ (void) tableCellWithText: (NSString *) title withImage: (UIImage *) image;

+ (BOOL) tableRefreshControl: (BOOL) isRefreshing;

+ (void) endTable;
@end

@interface FGStyle(FGTable)

+ (void)tableSeparatorStyle:(UITableViewCellSeparatorStyle) style;

@end
