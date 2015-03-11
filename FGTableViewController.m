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


typedef NS_ENUM(NSInteger, FGTableViewCellActions) {
    FGTableViewCellActionsNone,
    FGTableViewCellActionsSelect,
};

static void * TableSectionHeaderMethodKey = &TableSectionHeaderMethodKey;
static void * TableSectionFooterMethodKey = &TableSectionFooterMethodKey;

static NSString * TableSectionHeaderFooterTitleDataKey = @"FGTableViewControllerTableSectionHeaderFooterTitleDataKey";

static void * ActionResultPropertyKey = &ActionResultPropertyKey;


@interface UITableViewCell (FGTableViewController)

@property FGTableViewCellActions actionResult;

@end

@implementation UITableViewCell (FGTableViewController)

- (FGTableViewCellActions)actionResult
{
    NSNumber *num = objc_getAssociatedObject(self, ActionResultPropertyKey);
    return num.integerValue;
}

- (void)setActionResult:(FGTableViewCellActions)actionResult
{
    NSNumber *num = [NSNumber numberWithInteger:actionResult];
    objc_setAssociatedObject(self, ActionResultPropertyKey, num, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@interface FGTableViewController()

- (void) tableSectionHeader: (NSString *) title;

- (void) tableSectionFooter: (NSString *) title;

@property (copy) FGOnGuiBlock onGuiBlock;


@property (nonatomic, strong) NSPointerArray *items;
@property (nonatomic, strong) NSPointerArray *oldItems;

@property (nonatomic, strong) NSMutableArray* sections;
@property (nonatomic, strong) NSMutableArray* currentSection;
@property (nonatomic, assign) BOOL readyForPushViewControllers;

@end



@implementation FastGui (FGTabBarController)

+ (void) tableViewController:(FGOnGuiBlock)onGui
{
    NSString *reuseId = [FGInternal callerPositionAsReuseId];
    [FastGui customViewControllerWithReuseId:reuseId initBlock:^UIViewController *(UIViewController *ctrl) {
        if (ctrl == nil || ![ctrl isKindOfClass:[FGTableViewController class]]){
            ctrl = [[FGTableViewController alloc] init];
        }
        FGTableViewController * fgctrl = (FGTableViewController *) ctrl;
        fgctrl.onGuiBlock = onGui;
        [fgctrl reloadGui];
        return fgctrl;
    }];
}

+ (void) tableSectionHeader: (NSString *) title
{
    [self customData:TableSectionHeaderMethodKey data:@{TableSectionHeaderFooterTitleDataKey: title}];
}

+ (void) tableSectionFooter: (NSString *) title
{
    [self customData:TableSectionFooterMethodKey data:@{TableSectionHeaderFooterTitleDataKey: title}];
}

+ (BOOL) tableCell:(NSString *)title
{
    NSString *reuseId = [FGInternal callerPositionAsReuseId];
    id ret = [FastGui customViewWithClass: nil reuseId:reuseId initBlock:^UIView *(UIView *view, FGNotifyCustomViewResultBlock notify, FGStyleBlock applyStyle) {
        if (view == nil){
            printf("tableCell(%s): %s\n", [reuseId UTF8String], [title UTF8String]);
            view = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
        }
        applyStyle(view);
        UITableViewCell *cell = ((UITableViewCell *)view);
        //printf("reuse title: %s, actual title: %s\n", [cell.textLabel.text UTF8String], [title UTF8String]);
        
        if(cell.notifyHolder == nil){
            cell.notifyHolder = [FGNotifyCustomViewResultHolder holderWithBlock: notify];
        }else{
            cell.notifyHolder.block = notify;
        }
        cell.textLabel.text = title;
        
        return view;
    } resultBlock:^id(UIView *view) {
        UITableViewCell *cell = ((UITableViewCell *)view);
        return [NSNumber numberWithInteger: cell.actionResult];
    }];
    
    if([ret isKindOfClass:[NSNumber class]]){
        FGTableViewCellActions act = (FGTableViewCellActions)(((NSNumber *)ret).integerValue);
        return act == FGTableViewCellActionsSelect;
    }else{
        return false;
    }
}

@end

@implementation FGTableViewController

@synthesize parentContext;

@synthesize readyForPushViewControllers;

@synthesize items, oldItems;

@synthesize sections, currentSection;

- (void)reloadGui
{
    [FastGui callOnGui:^{
        NSPointerArray *temp = self.oldItems;
        self.oldItems = self.items;
        while (temp.count > 0) {
            [temp removePointerAtIndex: 0];
        }
        self.items = temp;
        [self.oldItems compact];
        
        [self.sections removeAllObjects];
        self.currentSection = [NSMutableArray arrayWithObjects:[NSNull null], [NSNull null], nil];
        [self onGui];
        if (currentSection.count > 2 || currentSection[0] != [NSNull null] || currentSection[1] != [NSNull null]) {
            [sections addObject:currentSection];
        }
        
        [self.tableView reloadData];
    } withContext:self];
}

- (void)viewDidLoad
{
    self.readyForPushViewControllers = false;
    self.oldItems = [NSPointerArray weakObjectsPointerArray];
    self.items = [NSPointerArray weakObjectsPointerArray];
    
    self.sections = [NSMutableArray array];
    
    [self reloadGui];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.readyForPushViewControllers = true;
    [self reloadGui];
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

- (id)customData:(void *)key data:(NSDictionary *)data
{
    if (key == TableSectionHeaderMethodKey){
        [self tableSectionHeader:data[TableSectionHeaderFooterTitleDataKey]];
    }else if(key == TableSectionFooterMethodKey){
        [self tableSectionFooter:data[TableSectionHeaderFooterTitleDataKey]];
    }
    return nil;
}

- (void) tableSectionHeader:(NSString *)title
{
    if (currentSection.count > 2 || currentSection[0] != [NSNull null] || currentSection[1] != [NSNull null]) {
        [sections addObject:currentSection];
        currentSection = [NSMutableArray arrayWithObjects:title, [NSNull null], nil];
    }else{
        currentSection[0] = title;
    }
}

- (void) tableSectionFooter:(NSString *)title
{
    currentSection[1] = title;
}

- (id) customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock:(FGStyleBlock)applyStyleBlock
{
    UIView *foundReuseView = nil;
    for (NSUInteger i = 0; i < self.oldItems.count; i++) {
        UIView *view = [self.oldItems pointerAtIndex:i];
        if (view != nil && [view.reuseId isEqualToString:reuseId]) {
            foundReuseView = view;
            for (NSUInteger j = 0; j<=i; j++) {
                [self.oldItems removePointerAtIndex:j];
            }
            break;
        }
    }
    __weak FGTableViewController *weakSelf = self;
    UIView *view = initBlock(foundReuseView, ^(){
        [weakSelf reloadGui];
    }, applyStyleBlock);
    view.reuseId = reuseId;
    [self.items addPointer:(__bridge void *)(view)];
    
    if([view isKindOfClass:[UITableViewCell class]]){
        [self.currentSection addObject: view];
    }
    if (resultBlock == nil){
        return nil;
    }else{
        return resultBlock(view);
    }
}

- (void)customViewControllerWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewControllerBlock)initBlock
{
    if (readyForPushViewControllers){
        UIViewController *ctrl = initBlock(nil);
        [self presentViewController:ctrl animated:true completion:nil];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sections.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIndex
{
    NSMutableArray *section = self.sections[sectionIndex];
    if(section[0] != [NSNull null]){
        return section[0];
    }else{
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)sectionIndex
{
    NSMutableArray *section = self.sections[sectionIndex];
    if(section[1] != [NSNull null]){
        return section[1];
    }else{
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    NSMutableArray *section = self.sections[sectionIndex];
    return section.count - 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *section = self.sections[indexPath.section];
    return section[indexPath.item + 2];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *section = self.sections[indexPath.section];
    UITableViewCell *cell = section[indexPath.item + 2];
    cell.actionResult = FGTableViewCellActionsSelect;
    [cell.notifyHolder notify];
    cell.actionResult = FGTableViewCellActionsNone;
    return nil;
}

- (void)styleSheet
{
    
}

@end
