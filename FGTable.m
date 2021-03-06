//
//  FGTableView.m
//  train-helper
//
//  Created by 易元 白 on 15/3/15.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//
#import <objc/runtime.h>
#import <REKit/REKit.h>
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/BlocksKit+UIKit.h>

#import "FGTable.h"

#import "FGStyle.h"
#import "FGReuseItemPool.h"
#import "FGInternal.h"
#import "FGNullViewContext.h"
#import "UIView+voidBlockHolder.h"
#import "UIView+applyStyleAfterAddedToSuperview.h"
#import "UIView+FGStylable.h"
#import "UIView+changingResult.h"


typedef NS_ENUM(NSUInteger, FGTableViewContextMode)
{
    FGTableViewContextModeCell,
    FGTableViewContextModeSectionHeader,
    FGTableViewContextModeSectionFooter,
    FGTableViewContextModeRefreshControl,
    FGTableViewContextModeHeader,
    FGTableViewContextModeFooter,
};

@interface FGTableViewContext : FGNullViewContext

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) FGTableViewContextMode mode;

@property (nonatomic, assign) BOOL hasTableHeaderView;

@property (nonatomic, assign) BOOL hasTableFooterView;

- (void) beginTable;

- (void) endTable;

@end

@interface FGTableData : NSObject<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) FGReuseItemPool *pool;

@property (nonatomic, strong) NSMutableArray *data;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, assign) BOOL headerAffixEnabled;

@property (nonatomic, assign) BOOL notifyScrollToBottom;

@property (nonatomic, assign) BOOL scrollToBottom;

@end

@interface UITableView(FGTable)

@property (nonatomic, strong) FGTableData *fg_tableData;

@end

@protocol FGTableItem <NSObject>

@required

@property (nonatomic, weak) UIView *innerView;

@property (nonatomic, assign) CGFloat cellHeight;

@end

@protocol StyleWithHasSeparator<NSObject>

- (void) tableCellHasSeparator:(BOOL)hasSeparator;

@end

@interface UITableViewCell(FGTable)<FGWithReuseId, FGTableItem, StyleWithHasSeparator>


@end

@interface UITableViewHeaderFooterView(FGTable)<FGWithReuseId, FGTableItem>

@property (nonatomic, assign) BOOL isHeader;

@end

@interface FGTableBootstrapContext :NSObject<FGContext>

@end

@interface FGTableHeaderWrapperView : UIView

@property (nonatomic, strong) UIView * contentView;

@property (nonatomic, weak) UITableView * tableView;

- (void) updateContentView: (UIView *) contentView;

@end

static void * EndTableMethodKey = &EndTableMethodKey;

static void * TableSectionHeaderWithNextCustomViewMethodKey = &TableSectionHeaderWithNextCustomViewMethodKey;

static void * TableSectionFooterWithNextCustomViewMethodKey = &TableSectionFooterWithNextCustomViewMethodKey;

static void * RefreshControlMethodKey = &RefreshControlMethodKey;

static void * TableHeaderWithNextCustomViewMethodKey = &TableHeaderWithNextCustomViewMethodKey;

static void * TableFooterWithNextCustomViewMethodKey = &TableFooterWithNextCustomViewMethodKey;

static void * TableScrollToBottomMethodKey = &TableScrollToBottomMethodKey;

@implementation FastGui (FGTable)

+ (void)beginTable
{
    [self beginTableWithNextCustomView];
    [self customViewWithClass:nil reuseId:[FGInternal callerPositionAsReuseId] initBlock:^UIView *(UIView *reuseView) {
        if (reuseView != nil) {
            return reuseView;
        }else{
            return [[UITableView alloc] init];
        }
    } resultBlock: nil];
}

+ (void) beginTableWithStyleClass:(NSString *) styleClass
{
    [self beginTableWithNextCustomView];
    [self customViewWithClass:styleClass reuseId:[FGInternal callerPositionAsReuseId] initBlock:^UIView *(UIView *reuseView) {
        if (reuseView != nil) {
            return reuseView;
        }else{
            return [[UITableView alloc] init];
        }
    } resultBlock: nil];
}

+ (void) beginTableWithNextCustomView
{
    FGTableBootstrapContext *context = [[FGTableBootstrapContext alloc] init];
    [FastGui pushContext: context];
}

+ (void) endTable
{
    [FastGui customData:EndTableMethodKey data:nil];
}

+ (void)tableSectionHeaderWithNextCustomView
{
    [FastGui customData:TableSectionHeaderWithNextCustomViewMethodKey data:nil];
}

+ (void)tableSectionHeaderWithTitle:(NSString *)title
{
    [FastGui tableSectionHeaderWithNextCustomView];
    [FastGui customViewWithClass:nil reuseId:[FGInternal callerPositionAsReuseId] initBlock:^UIView *(UIView *reuseView) {
        UITableViewHeaderFooterView *view =(UITableViewHeaderFooterView*)reuseView;
        if (view == nil) {
            view = [[UITableViewHeaderFooterView alloc] init];
        }
        view.textLabel.text = title;
        return view;
    } resultBlock: nil];
}

+ (void)tableSectionFooterWithNextCustomView
{
    [FastGui customData:TableSectionFooterWithNextCustomViewMethodKey data:nil];
}

+ (void)tableSectionFooterWithTitle:(NSString *)title
{
    [FastGui tableSectionFooterWithNextCustomView];
    [FastGui customViewWithClass:nil reuseId:[FGInternal callerPositionAsReuseId] initBlock:^UIView *(UIView *reuseView) {
        UITableViewHeaderFooterView *view =(UITableViewHeaderFooterView*)reuseView;
        if (view == nil) {
            view = [[UITableViewHeaderFooterView alloc] init];
        }
        view.textLabel.text = title;
        return view;
    } resultBlock: nil];
}

static NSString * tableRefreshControlReuseId;

+ (BOOL)tableRefreshControl: (BOOL) isRefreshing
{
    [FastGui customData:RefreshControlMethodKey data:nil];
    NSNumber *res = [self customViewWithClass:nil reuseId:[FGInternal staticReuseId:&tableRefreshControlReuseId] initBlock:^UIView *(UIView *reuseView) {
        UIRefreshControl *refresh = (UIRefreshControl *) reuseView;
        if (refresh == nil) {
            refresh = [[UIRefreshControl alloc] init];
            [refresh bk_addEventHandler:^(id sender) {
                UIRefreshControl *refresh = (UIRefreshControl *) sender;
                [refresh reloadGuiChangingResult:[NSNumber numberWithBool:refresh.refreshing]];
            } forControlEvents:UIControlEventValueChanged];
        }
        if (refresh.changingResult == nil) {
            if (isRefreshing && !refresh.refreshing) {
                [refresh beginRefreshing];
            }else if(!isRefreshing && refresh.refreshing){
                [refresh endRefreshing];
            }
        }
        return refresh;
    } resultBlock:^id(UIView *view) {
        UIRefreshControl *refresh = (UIRefreshControl *) view;
        if (refresh.changingResult != nil) {
            return refresh.changingResult;
        }else{
            return [NSNumber numberWithBool:refresh.refreshing];
        }
    }];
    return [res boolValue];
}

+ (BOOL)tableRefreshControl
{
    [FastGui customData:RefreshControlMethodKey data:nil];
    NSNumber *res = [self customViewWithClass:nil reuseId:[FGInternal staticReuseId:&tableRefreshControlReuseId] initBlock:^UIView *(UIView *reuseView) {
        UIRefreshControl *refresh = (UIRefreshControl *) reuseView;
        if (refresh == nil) {
            refresh = [[UIRefreshControl alloc] init];
            [refresh bk_addEventHandler:^(id sender) {
                UIRefreshControl *refresh = (UIRefreshControl *) sender;
                [refresh reloadGuiChangingResult:[NSNumber numberWithBool:refresh.refreshing]];
            } forControlEvents:UIControlEventValueChanged];
        }
        return refresh;
    } resultBlock:^id(UIView *view) {
        UIRefreshControl *refresh = (UIRefreshControl *) view;
        if (refresh.changingResult != nil) {
            return refresh.changingResult;
        }else{
            return [NSNumber numberWithBool:refresh.refreshing];
        }
    }];
    return [res boolValue];
}

+ (void)tableCellWithText:(NSString *)title
{
    
}

+ (void)tableCellWithText:(NSString *)title withImage:(UIImage *)image
{
    
}

+ (BOOL) tableScrollToBottom
{
    return [(NSNumber *) [self customData:TableScrollToBottomMethodKey data:nil] boolValue];
}

+ (void)tableHeaderWithNextCustomView
{
    [self customData:TableHeaderWithNextCustomViewMethodKey data:nil];
}

+ (void)tableFooterWithNextCustomView
{
    [self customData:TableFooterWithNextCustomViewMethodKey data:nil];
}


@end

@implementation FGTableViewContext

@synthesize parentContext;

- (void)reloadGui
{
    [parentContext reloadGui];
}

- (void)styleSheet
{
    [parentContext styleSheet];
}

- (void)customViewControllerWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewControllerBlock)initBlock
{
    [parentContext customViewControllerWithReuseId:reuseId initBlock:initBlock];
}

- (void)dismissViewController
{
    [parentContext dismissViewController];
}

- (void)beginTable
{
    [self.tableView.fg_tableData.pool prepareUpdateItems];
    self.hasTableHeaderView = NO;
    self.hasTableFooterView = NO;
}

- (void) overrideSizeStyle: (id<FGTableItem>) cell
{
//    [cell.innerView setTranslatesAutoresizingMaskIntoConstraints: NO];
    [cell.innerView respondsToSelector:@selector(styleWithLeft:) withKey:nil usingBlock:^(id receiver, CGFloat left){
        printf("'left' style will be ignored for tableview's cells. If you need layout this view, you can wrap this view with a group.\n");
    }];
    [cell.innerView respondsToSelector:@selector(styleWithRight:) withKey:nil usingBlock:^(id receiver, CGFloat right){
        printf("'right' style will be ignored for tableview's cells. If you need layout this view, you can wrap this view with a group.\n");
    }];
    [cell.innerView respondsToSelector:@selector(styleWithTop:) withKey:nil usingBlock:^(id receiver, CGFloat top){
        printf("'top' style will be ignored for tableview's cells. If you need layout this view, you can wrap this view with a group.\n");
    }];
    [cell.innerView respondsToSelector:@selector(styleWithBottom:) withKey:nil usingBlock:^(id receiver, CGFloat bottom){
        printf("'bottom' style will be ignored for tableview's cells. If you need layout this view, you can wrap this view with a group.\n");
    }];
    [cell.innerView respondsToSelector:@selector(styleWithWidth:) withKey:nil usingBlock:^(id receiver, CGFloat width){
        printf("'width' style will be ignored for tableview's cells. If you need layout this view, you can wrap this view with a group.\n");
    }];
    [cell.innerView respondsToSelector:@selector(styleWithHeight:) withKey:nil usingBlock:^(id receiver, CGFloat height){
        cell.cellHeight = height;
    }];
}

- (id)customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock:(FGStyleBlock)applyStyleBlock
{
    if (self.mode == FGTableViewContextModeCell) {
        UITableViewCell *cell = (UITableViewCell *)[self.tableView.fg_tableData.pool updateItem:reuseId initBlock:^id<FGWithReuseId>(id<FGWithReuseId> reuseItem) {
            UITableViewCell *cell = (UITableViewCell *) reuseItem;
            UIView *oldView = cell.innerView;
            UIView *newView = initBlock(oldView);
            if ([newView isKindOfClass:[UITableViewCell class]]){
                cell = (UITableViewCell *) newView;
            }else{
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] init];
                    cell.backgroundColor = [UIColor clearColor];
                    [FGStyle updateStyleOfView:cell.contentView withBlock:^(UIView *view) {
                        [FGStyle left:0];
                        [FGStyle right:0];
                        [FGStyle top:0];
                        [FGStyle bottom:0];
                    }];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                if (newView != oldView) {
                    [oldView removeFromSuperview];
                    [cell.contentView addSubview:newView];
                }
            }

            cell.innerView = newView;
            
            [self overrideSizeStyle:cell];
            
            applyStyleBlock(cell.innerView);
            CGRect rect = CGRectMake(0, 0, self.tableView.frame.size.width, cell.cellHeight);
            if (cell.innerView != cell) {
                cell.innerView.frame = rect;
                cell.contentView.frame = rect;
            }
            
//            [cell applyStyleAfterAddedToSuperviewWithBlock:^(UIView *view) {
//                UITableViewCell *cell = (UITableViewCell *)view;
//                applyStyleBlock(cell.innerView);
//                if (cell.innerView != cell) {
//                    cell.innerView.frame = CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
//                }
//                
//            }];
            
            return cell;
        } outputIsNewView:NULL];
        if (resultBlock == nil) {
            return nil;
        }else{
            return resultBlock(cell.innerView);
        }
    }else if (self.mode == FGTableViewContextModeSectionHeader || self.mode == FGTableViewContextModeSectionFooter) {
        UITableViewHeaderFooterView *cell = (UITableViewHeaderFooterView *)[self.tableView.fg_tableData.pool updateItem:reuseId initBlock:^id<FGWithReuseId>(id<FGWithReuseId> reuseItem) {
            UITableViewHeaderFooterView *cell = (UITableViewHeaderFooterView *) reuseItem;
            UIView *oldView = cell.innerView;
            UIView *newView = initBlock(oldView);
            if ([newView isKindOfClass:[UITableViewHeaderFooterView class]]){
                cell = (UITableViewHeaderFooterView *) newView;
            }else{
                if (cell == nil) {
                    cell = [[UITableViewHeaderFooterView alloc] init];
                    cell.backgroundView = [[UIView alloc] init];
                    cell.backgroundView.backgroundColor = [UIColor clearColor];
                }
                if (newView != oldView) {
                    [oldView removeFromSuperview];
                    [cell.contentView addSubview:newView];
                }
            }
            cell.innerView = newView;
            cell.isHeader = self.mode == FGTableViewContextModeSectionHeader;
            [self overrideSizeStyle:cell];
            
            applyStyleBlock(cell.innerView);
            
            [cell applyStyleAfterAddedToSuperviewWithBlock:^(UIView *view) {
                UITableViewCell *cell = (UITableViewCell *)view;
                applyStyleBlock(cell.innerView);
                if (cell.innerView != cell) {
                    cell.innerView.frame = CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
                }
            }];
            
            return cell;
        } outputIsNewView:NULL];
        self.mode = FGTableViewContextModeCell;
        if (resultBlock == nil) {
            return nil;
        }else{
            return resultBlock(cell.innerView);
        }
    }
    else if(self.mode == FGTableViewContextModeRefreshControl)
    {
        UIRefreshControl *oldRc = self.tableView.fg_tableData.refreshControl;
        if (![oldRc.reuseId isEqualToString:reuseId]) {
            [oldRc removeFromSuperview];
            oldRc = nil;
        }
        UIRefreshControl *rc = (UIRefreshControl *) initBlock(oldRc);
        if (rc != oldRc) {
            [oldRc removeFromSuperview];
            [self.tableView addSubview:rc];
            rc.reuseId = reuseId;
            self.tableView.fg_tableData.refreshControl = rc;
        }
        applyStyleBlock(rc);
        self.mode = FGTableViewContextModeCell;
        if (resultBlock == nil) {
            return nil;
        }else{
            return resultBlock(rc);
        }
    }else if(self.mode == FGTableViewContextModeHeader)
    {
        self.hasTableHeaderView = YES;
        FGTableHeaderWrapperView *headerView = (FGTableHeaderWrapperView *)self.tableView.tableHeaderView;
        if (![headerView isKindOfClass:[FGTableHeaderWrapperView class]]) {
            headerView = nil;
        }
        UIView *oldView = headerView.contentView;
        if (![oldView.reuseId isEqualToString:reuseId]) {
            oldView = nil;
        }
        UIView *newView = initBlock(oldView);
        if (newView != oldView) {
            newView.reuseId = reuseId;
            newView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, newView.frame.size.height);
            [newView sizeStyleSetFrame];
            [newView positionStyleDisabledWithTip:@"you cannot set position of table header view"];
        }
        applyStyleBlock(newView);
        if (headerView == nil) {
            headerView = [[FGTableHeaderWrapperView alloc] init];
        }
        headerView.tableView = self.tableView;
        [headerView updateContentView:newView];
        self.tableView.tableHeaderView = headerView;
        self.mode = FGTableViewContextModeCell;
        if (resultBlock == nil) {
            return nil;
        }else{
            return resultBlock(newView);
        }
    }else if(self.mode == FGTableViewContextModeFooter)
    {
        self.hasTableFooterView = YES;
        UIView *oldView = self.tableView.tableFooterView;
        if (![oldView.reuseId isEqualToString:reuseId]) {
            oldView = nil;
        }
        UIView *newView = initBlock(oldView);
        if (newView != oldView) {
            newView.reuseId = reuseId;
            newView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, newView.frame.size.height);
            [newView sizeStyleSetFrame];
            [newView positionStyleDisabledWithTip:@"you cannot set position of table footer view"];
        }
        applyStyleBlock(newView);
        self.tableView.tableFooterView = newView;
        
        self.mode = FGTableViewContextModeCell;
        if (resultBlock == nil) {
            return nil;
        }else{
            return resultBlock(newView);
        }
    }
    else{
        return nil;
    }
}

- (id)customData:(void *)key data:(NSDictionary *)data
{
    if (key == EndTableMethodKey) {
        [self endTable];
    }
    else if(key == TableSectionHeaderWithNextCustomViewMethodKey)
    {
        self.mode = FGTableViewContextModeSectionHeader;
    }
    else if(key == TableSectionFooterWithNextCustomViewMethodKey)
    {
        
        self.mode = FGTableViewContextModeSectionFooter;
    }
    else if(key == RefreshControlMethodKey)
    {
        self.mode = FGTableViewContextModeRefreshControl;
    }
    else if(key == TableHeaderWithNextCustomViewMethodKey)
    {
        self.mode = FGTableViewContextModeHeader;
    }
    else if(key == TableFooterWithNextCustomViewMethodKey)
    {
        self.mode = FGTableViewContextModeFooter;
    }
    else if(key == TableScrollToBottomMethodKey)
    {
        self.tableView.fg_tableData.notifyScrollToBottom = YES;
        return [NSNumber numberWithBool:self.tableView.fg_tableData.scrollToBottom];
    }
    else
    {
        return [parentContext customData:key data:data];
    }
    return nil;
}

- (void) endTable
{
    __block BOOL needReloadTable = NO;
    [self.tableView.fg_tableData.pool finishUpdateItems:^(UIView *view){
        needReloadTable = YES;
    } needRemove:^(UIView*view){
        needReloadTable = YES;
    }];
    if (needReloadTable) {
        NSMutableArray *data = self.tableView.fg_tableData.data;
        [data removeAllObjects];
        
        NSMutableArray *currentSection;
        for (UIView *view in self.tableView.fg_tableData.pool.items) {
            if ([view isKindOfClass:[UITableViewCell class]]) {
                if (currentSection == nil) {
                    currentSection = [NSMutableArray arrayWithObjects:[NSNull null], [NSNull null], nil];
                }
                [currentSection addObject: view];
            }else if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
                UITableViewHeaderFooterView *headerOrFooter = (UITableViewHeaderFooterView *)view;
                if (headerOrFooter.isHeader) {
                    if (currentSection != nil) {
                        [data addObject: currentSection];
                    }
                    currentSection = [NSMutableArray arrayWithObjects:headerOrFooter, [NSNull null], nil];
                }else{
                    if (currentSection == nil) {
                        currentSection = [NSMutableArray arrayWithObjects:[NSNull null], [NSNull null], nil];
                    }
                    currentSection[1] = headerOrFooter;
                }
            }
        }
        if (currentSection != nil) {
            [data addObject: currentSection];
        }
        [self.tableView reloadData];
    }
    if (!self.hasTableHeaderView && self.tableView.tableHeaderView != nil) {
        self.tableView.tableHeaderView = nil;
    }
    if (!self.hasTableFooterView && self.tableView.tableFooterView != nil) {
        self.tableView.tableFooterView = nil;
    }
    [FastGui popContext];
}

@end

static void * ReuseIdPropertyKey = &ReuseIdPropertyKey;
static void * InnerViewPropertyKey = &InnerViewPropertyKey;
static void * CellHeightPropertyKey = &CellHeightPropertyKey;

@implementation UITableViewCell (FGTable)


- (void)setReuseId:(NSString *)reuseId
{
    objc_setAssociatedObject(self, ReuseIdPropertyKey, reuseId, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)reuseId
{
    return objc_getAssociatedObject(self, ReuseIdPropertyKey);
}

- (void)setInnerView:(UIView *)innerView
{
    objc_setAssociatedObject(self, InnerViewPropertyKey, innerView, OBJC_ASSOCIATION_ASSIGN);
}

- (UIView *)innerView
{
    return objc_getAssociatedObject(self, InnerViewPropertyKey);
}

- (void)setCellHeight:(CGFloat)cellHeight
{
    objc_setAssociatedObject(self, CellHeightPropertyKey,[NSNumber numberWithFloat: cellHeight], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)cellHeight
{
    NSNumber *cellHeight = objc_getAssociatedObject(self, CellHeightPropertyKey);
    return cellHeight == nil ? 44 : [cellHeight floatValue];
}

- (void)tableCellHasSeparator:(BOOL)hasSeparator
{
    for (UIView *view in self.subviews) {
        if(view.frame.size.height * [UIScreen mainScreen].scale == 1){
            view.hidden = !hasSeparator;
        }
    }
}

@end

@implementation FGTableData

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pool = [[FGReuseItemPool alloc] init];
        self.data = [NSMutableArray array];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.data.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sec = self.data[section];
    return sec.count - 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sec = self.data[indexPath.section];
    return sec[indexPath.item + 2];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *sec = self.data[section];
    id item = sec[0];
    if (item == [NSNull null]) {
        return nil;
    }else{
        return item;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSArray *sec = self.data[section];
    id item = sec[1];
    if (item == [NSNull null]) {
        return nil;
    }else{
        return item;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *) [self tableView:tableView viewForHeaderInSection:section];
    return header.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *) [self tableView:tableView viewForFooterInSection:section];
    return footer.cellHeight;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UITableView *tableView = (UITableView *) scrollView;
    CGFloat scrollPos = tableView.contentOffset.y;
    if (self.headerAffixEnabled) {
        CGFloat scrollPos = tableView.contentOffset.y;
        FGTableHeaderWrapperView *wrapper = (FGTableHeaderWrapperView *) tableView.tableHeaderView;
        if ([wrapper isKindOfClass:[FGTableHeaderWrapperView class]]) {
            if(scrollPos < 0){
                wrapper.contentView.frame = CGRectMake(0, scrollPos, tableView.tableHeaderView.frame.size.width, tableView.tableHeaderView.frame.size.height);
            }else{
                wrapper.contentView.frame = CGRectMake(0, 0, tableView.tableHeaderView.frame.size.width, tableView.tableHeaderView.frame.size.height);
            }
            if (self.refreshControl != nil) {
                self.refreshControl.bounds = CGRectMake(self.refreshControl.bounds.origin.x, -wrapper.contentView.frame.size.height, self.refreshControl.bounds.size.width, self.refreshControl.bounds.size.height);
            }
        }else{
            if (self.refreshControl != nil) {
                self.refreshControl.bounds = CGRectMake(self.refreshControl.bounds.origin.x, 0, self.refreshControl.bounds.size.width, self.refreshControl.bounds.size.height);
            }
        }
        
    }else{
        if (self.refreshControl != nil) {
            self.refreshControl.bounds = CGRectMake(self.refreshControl.bounds.origin.x, 0, self.refreshControl.bounds.size.width, self.refreshControl.bounds.size.height);
        }
    }
    CGFloat contentHeight = tableView.contentSize.height;
    CGFloat bottomPos = scrollPos + tableView.frame.size.height;
    BOOL scrollToBottom = bottomPos >= contentHeight;
    if (!self.scrollToBottom && scrollToBottom && self.notifyScrollToBottom) {
        [FastGui reloadGui];
    }
    self.scrollToBottom = scrollToBottom;
}

@end

@implementation UITableView(FGTable)

static void * FGTableDataPropertyKey = &FGTableDataPropertyKey;

- (FGTableData *)fg_tableData
{
    return objc_getAssociatedObject(self, FGTableDataPropertyKey);
}

- (void)setFg_tableData:(FGTableData *)fg_tableData
{
    objc_setAssociatedObject(self, FGTableDataPropertyKey, fg_tableData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UITableViewHeaderFooterView (FGTable)

static void * IsHeaderPropertyKey = &IsHeaderPropertyKey;

- (void)setReuseId:(NSString *)reuseId
{
    objc_setAssociatedObject(self, ReuseIdPropertyKey, reuseId, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)reuseId
{
    return objc_getAssociatedObject(self, ReuseIdPropertyKey);
}

- (void)setInnerView:(UIView *)innerView
{
    objc_setAssociatedObject(self, InnerViewPropertyKey, innerView, OBJC_ASSOCIATION_ASSIGN);
}

- (UIView *)innerView
{
    return objc_getAssociatedObject(self, InnerViewPropertyKey);
}

- (void)setCellHeight:(CGFloat)cellHeight
{
    objc_setAssociatedObject(self, CellHeightPropertyKey,[NSNumber numberWithFloat: cellHeight], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)cellHeight
{
    NSNumber *cellHeight = objc_getAssociatedObject(self, CellHeightPropertyKey);
    return cellHeight == nil ? 22 : [cellHeight floatValue];
}

- (BOOL)isHeader
{
    return objc_getAssociatedObject(self, IsHeaderPropertyKey) == nil;
}

- (void)setIsHeader:(BOOL)isHeader
{
    NSObject *value = isHeader ? nil : [[NSObject alloc] init];
    objc_setAssociatedObject(self, IsHeaderPropertyKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation FGTableBootstrapContext

@synthesize parentContext;

- (void)reloadGui
{
    [parentContext reloadGui];
}

- (void)styleSheet
{
    [parentContext styleSheet];
}

- (id)customData:(void *)key data:(NSDictionary *)data
{
    if (key == EndTableMethodKey) {
        printf("You must generate a UITableView after call beginTableWithNextCustomView. But you have called to EndTable. No table will be generated.\n");
        [FastGui popContext];
        return nil;
    }
    return [parentContext customData:key data:data];
}

- (void)customViewControllerWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewControllerBlock)initBlock
{
    return [parentContext customViewControllerWithReuseId:reuseId initBlock:initBlock];
}

- (void)dismissViewController
{
    [parentContext dismissViewController];
}

- (id)customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock:(FGStyleBlock)applyStyleBlock
{
    UIView *view = [self.parentContext customViewWithReuseId:reuseId initBlock:initBlock resultBlock:^id(UIView *view) {
        return view;
    } applyStyleBlock:applyStyleBlock];
    if (![view isKindOfClass:[UITableView class]]) {
        printf("You must generate a UITableView after call beginTableWithNextCustomView, but a view with (%s) is given. This view will be ignored\n", [NSStringFromClass([view class]) UTF8String]);
    }
    UITableView *table = (UITableView *) view;
    if (table.fg_tableData == nil) {
        table.fg_tableData = [[FGTableData alloc] init];
        table.delegate = table.fg_tableData;
        table.dataSource = table.fg_tableData;
    }
    FGTableViewContext *ctx = [[FGTableViewContext alloc] init];
    ctx.tableView = table;
    
    [FastGui popContext];
    [FastGui pushContext: ctx];
    [ctx beginTable];
    
    if (resultBlock == nil) {
        return nil;
    }else{
        return resultBlock(view);
    }
}



@end

@implementation FGStyle (FGTable)

+ (void)tableSeparatorStyle:(UITableViewCellSeparatorStyle) style
{
    [FGStyle customStyleWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[UITableView class]]) {
            UITableView *table = (UITableView *) view;
            table.separatorStyle = style;
        }
    }];
}

+ (void)tableHeaderAffixTop: (BOOL) enableAffix
{
    [FGStyle customStyleWithBlock:^(UIView *view) {
        FGTableData *tableData;
        if ([view isKindOfClass:[UITableView class]] && (tableData = ((UITableView *)view).fg_tableData) != nil) {
            tableData.headerAffixEnabled = enableAffix;
        }
    }];
    
}

+ (void) tableCellHasSeparator:(BOOL)hasSeparator
{
    [FGStyle customStyleWithBlock:^(UIView *view) {
        if ([view respondsToSelector:@selector(tableCellHasSeparator:)]) {
            [(id<StyleWithHasSeparator>) view tableCellHasSeparator:hasSeparator];
        }
    }];
}

@end

@implementation FGTableHeaderWrapperView

- (void) updateContentView:(UIView *)contentView
{
    if (self.contentView != contentView) {
        [self.contentView removeFromSuperview];
        [self addSubview:contentView];
        self.contentView = contentView;
        self.frame = CGRectMake(0, 0, self.tableView.frame.size.width, (int)self.contentView.frame.size.height);
        self.contentView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, (int)self.contentView.frame.size.height);
    }
}

@end

