//
//  FGTableViewController.h
//  FastGuiKit
//
//  Created by 易元 白 on 15/3/5.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FastGui.h"
#import "FGTable.h"

@interface FastGui (FGTableViewController)

+ (void) tableViewController: (FGOnGuiBlock) onGui;

+ (void) tableViewController: (FGOnGuiBlock) onGui styleClass: (NSString *) styleClass;

@end

@interface FGTableViewController : UITableViewController

- (NSString *) tableViewStyleClass;

- (void) onGui;

- (void) styleSheet;

@end


