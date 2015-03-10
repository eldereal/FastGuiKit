//
//  FGTableViewController.h
//  FastGuiKit
//
//  Created by 易元 白 on 15/3/5.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FastGui.h"
#import "FGContext.h"

@interface FastGui (FGTableViewController)

+ (void) tableViewController: (FGOnGuiBlock) onGui;

+ (void) tableSectionHeader: (NSString *) title;

+ (void) tableSectionFooter: (NSString *) title;

+ (BOOL) tableCell: (NSString *) title;

@end

@interface FGTableViewController : UITableViewController<FGContext>

- (void) onGui;

@end


