//
//  FGTableViewController.m
//  FastGuiKit
//
//  Created by 易元 白 on 15/3/5.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//
#import <objc/runtime.h>
#import "FGTableViewController.h"
#import "FGInternal.h"


@interface FGTableViewController()<FGContext>

@property (copy) FGOnGuiBlock onGuiBlock;

@property (nonatomic, assign) BOOL readyForPushViewControllers;

@property (nonatomic, copy) NSString * tableViewStyleClass;

- (instancetype) initWithOnGuiBlock: (FGOnGuiBlock) block styleClass:(NSString *)styleClass;

@end



@implementation FastGui (FGTabBarController)

+ (void) tableViewController:(FGOnGuiBlock)onGui
{
    [self tableViewControllerWithReuseId:[FGInternal callerPositionAsReuseId] onGui:onGui styleClass:nil];
}

+ (void)tableViewController:(FGOnGuiBlock)onGui styleClass:(NSString *)styleClass
{
    [self tableViewControllerWithReuseId:[FGInternal callerPositionAsReuseId] onGui:onGui styleClass:styleClass];
}

+ (void)tableViewControllerWithReuseId: (NSString *)reuseId onGui:(FGOnGuiBlock)onGui styleClass:(NSString *)styleClass
{
    [FastGui customViewControllerWithReuseId:reuseId initBlock:^UIViewController *(UIViewController *reuseCtrl) {
        FGTableViewController * ctrl = (FGTableViewController *) reuseCtrl;
        if (ctrl == nil){
            ctrl = [[FGTableViewController alloc] initWithOnGuiBlock: onGui styleClass: styleClass];
        }else{
            ctrl.onGuiBlock = onGui;
        }
        return ctrl;
    }];
}

@end

@implementation FGTableViewController

@synthesize parentContext;

@synthesize readyForPushViewControllers;

- (instancetype)initWithOnGuiBlock:(FGOnGuiBlock)block styleClass:(NSString *)styleClass
{
    self.onGuiBlock = block;
    self.tableViewStyleClass = styleClass;
    return [super init];
}

- (void)reloadGui
{
    [FastGui beginTableWithNextCustomView];
    [FastGui customViewWithClass:self.tableViewStyleClass reuseId:[FGInternal memoryPositionAsReuseIdOfObject: self.tableView] initBlock:^UIView *(UIView *reuseView) {
        return self.tableView;
    } resultBlock:nil];
    [self onGui];
    [FastGui endTable];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.readyForPushViewControllers = false;
    [FastGui reloadGuiSyncWithContext:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.readyForPushViewControllers = true;
    [FastGui setRootContext: self];
    [FastGui reloadGui];
}

- (void) onGui
{
    if(self.onGuiBlock != nil){
        @try {
            self.onGuiBlock();
        }
        @catch (NSException *exception) {
            printf("Unhandled exception: %s", [exception.description UTF8String]);
        }
    }
}

- (void)styleSheet
{
    [parentContext styleSheet];
}

- (void)customViewControllerWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewControllerBlock)initBlock
{
    if (self.navigationController != nil){
        UIViewController *ctrl = initBlock(nil);
        [self.navigationController pushViewController:ctrl animated:YES];
    }else if (readyForPushViewControllers){
        UIViewController *ctrl = initBlock(nil);
        [self presentViewController:ctrl animated:true completion:nil];
    }
}

- (void)dismissViewController
{
    if (self.navigationController != nil){
        [self.navigationController popViewControllerAnimated:YES];
    }else if (self.readyForPushViewControllers){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (id)customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock:(FGStyleBlock)applyStyleBlock
{
    if ([reuseId isEqualToString:[FGInternal memoryPositionAsReuseIdOfObject:self.tableView]]) {
        //add tableView to self, nothing need to do;
        UITableView * table = (UITableView *) initBlock(self.tableView);
        applyStyleBlock(table);
        if (resultBlock == nil) {
            return nil;
        }else{
            return resultBlock(table);
        }
    }
    printf("Unmatched context, Do you have called to 'EndTable' without matching 'BeginTable'?\n");
    return nil;
}

- (id)customData:(void *)key data:(NSDictionary *)data
{
    return nil;
}

@end
