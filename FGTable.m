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

@interface FGTableViewContext : NSObject<FGContext, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) FGReuseItemPool *pool;

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *data;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, assign) FGTableViewContextMode mode;

- (void) beginTable;

- (void) endTable;

@end

@interface UITableView(FGTable)

@property (nonatomic, strong) FGTableViewContext *context;

@end

@protocol FGTableItem <NSObject>

@required

@property (nonatomic, weak) UIView *innerView;

@property (nonatomic, assign) CGFloat cellHeight;

@end

@interface UITableViewCell(FGTable)<FGWithReuseId, FGTableItem>


@end

@interface UITableViewHeaderFooterView(FGTable)<FGWithReuseId, FGTableItem>

@property (nonatomic, assign) BOOL isHeader;

@end

@interface FGTableBootstrapContext :NSObject<FGContext>

@end

static void * EndTableMethodKey = &EndTableMethodKey;

static void * TableSectionHeaderWithNextCustomViewMethodKey = &TableSectionHeaderWithNextCustomViewMethodKey;

static void * TableSectionFooterWithNextCustomViewMethodKey = &TableSectionFooterWithNextCustomViewMethodKey;

static void * RefreshControlMethodKey = &RefreshControlMethodKey;

static void * TableHeaderWithNextCustomViewMethodKey = &TableHeaderWithNextCustomViewMethodKey;

static void * TableFooterWithNextCustomViewMethodKey = &TableFooterWithNextCustomViewMethodKey;

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

+ (BOOL)tableRefreshControl: (BOOL) isRefreshing
{
    [FastGui customData:RefreshControlMethodKey data:nil];
    NSNumber *res = [self customViewWithClass:nil reuseId:[FGInternal herePositionAsReuseId] initBlock:^UIView *(UIView *reuseView) {
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

+ (void)tableCellWithText:(NSString *)title
{
    
}

+ (void)tableCellWithText:(NSString *)title withImage:(UIImage *)image
{
    
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
    [self.pool prepareUpdateItems];
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
        UITableViewCell *cell = (UITableViewCell *)[self.pool updateItem:reuseId initBlock:^id<FGWithReuseId>(id<FGWithReuseId> reuseItem) {
            UITableViewCell *cell = (UITableViewCell *) reuseItem;
            UIView *oldView = cell.innerView;
            UIView *newView = initBlock(oldView);
            if ([newView isKindOfClass:[UITableViewCell class]]){
                cell = (UITableViewCell *) newView;
            }else{
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] init];
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
        UITableViewHeaderFooterView *cell = (UITableViewHeaderFooterView *)[self.pool updateItem:reuseId initBlock:^id<FGWithReuseId>(id<FGWithReuseId> reuseItem) {
            UITableViewHeaderFooterView *cell = (UITableViewHeaderFooterView *) reuseItem;
            UIView *oldView = cell.innerView;
            UIView *newView = initBlock(oldView);
            if ([newView isKindOfClass:[UITableViewHeaderFooterView class]]){
                cell = (UITableViewHeaderFooterView *) newView;
            }else{
                if (cell == nil) {
                    cell = [[UITableViewHeaderFooterView alloc] init];
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
        UIRefreshControl *oldRc = self.refreshControl;
        if (![oldRc.reuseId isEqualToString:reuseId]) {
            [oldRc removeFromSuperview];
            oldRc = nil;
        }
        UIRefreshControl *rc = (UIRefreshControl *) initBlock(oldRc);
        if (rc != oldRc) {
            [oldRc removeFromSuperview];
            [self.tableView addSubview:rc];
            rc.reuseId = reuseId;
            self.refreshControl = rc;
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
        UIView *oldView = self.tableView.tableHeaderView;
        if (![oldView.reuseId isEqualToString:reuseId]) {
            oldView = nil;
        }
        UIView *newView = initBlock(oldView);
        if (newView != oldView) {
            self.tableView.tableHeaderView = newView;
            newView.reuseId = reuseId;
        }
        applyStyleBlock(newView);
        self.mode = FGTableViewContextModeCell;
        if (resultBlock == nil) {
            return nil;
        }else{
            return resultBlock(newView);
        }
    }else if(self.mode == FGTableViewContextModeFooter)
    {
        UIView *oldView = self.tableView.tableFooterView;
        if (![oldView.reuseId isEqualToString:reuseId]) {
            oldView = nil;
        }
        UIView *newView = initBlock(oldView);
        if (newView != oldView) {
            self.tableView.tableFooterView = newView;
            newView.reuseId = reuseId;
        }
        applyStyleBlock(newView);
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
    else
    {
        return [parentContext customData:key data:data];
    }
    return nil;
}

- (void) endTable
{
    __block BOOL needReloadTable = NO;
    [self.pool finishUpdateItems:^(UIView *view){
        needReloadTable = YES;
    } needRemove:^(UIView*view){
        needReloadTable = YES;
    }];
    if (needReloadTable) {
        if (self.data == nil) {
            self.data = [NSMutableArray array];
        }else{
            [self.data removeAllObjects];
        }
        NSMutableArray *currentSection;
        for (UIView *view in self.pool.items) {
            if ([view isKindOfClass:[UITableViewCell class]]) {
                if (currentSection == nil) {
                    currentSection = [NSMutableArray arrayWithObjects:[NSNull null], [NSNull null], nil];
                }
                [currentSection addObject: view];
            }else if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
                UITableViewHeaderFooterView *headerOrFooter = (UITableViewHeaderFooterView *)view;
                if (headerOrFooter.isHeader) {
                    if (currentSection != nil) {
                        [self.data addObject: currentSection];
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
            [self.data addObject: currentSection];
        }
        [self.tableView reloadData];
    }
    [FastGui popContext];
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

@end

@implementation UITableView(FGTable)

static void * ContextPropertyKey = &ContextPropertyKey;

- (FGTableViewContext *)context
{
    return objc_getAssociatedObject(self, ContextPropertyKey);
}

- (void)setContext:(FGTableViewContext *)context
{
    objc_setAssociatedObject(self, ContextPropertyKey, context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
    UIView *view = [parentContext customViewWithReuseId:reuseId initBlock:initBlock resultBlock:^id(UIView *view) {
        return view;
    } applyStyleBlock:applyStyleBlock];
    if (![view isKindOfClass:[UITableView class]]) {
        printf("You must generate a UITableView after call beginTableWithNextCustomView, but a view with (%s) is given. This view will be ignored\n", [NSStringFromClass([view class]) UTF8String]);
    }
    UITableView *table = (UITableView *) view;
    if (table.context == nil) {
        table.context = [[FGTableViewContext alloc] init];
        table.context.pool = [[FGReuseItemPool alloc] init];
        table.context.tableView = table;
    }
    table.delegate = table.context;
    table.dataSource = table.context;
    
    [FastGui popContext];
    [FastGui pushContext:table.context];
    [table.context beginTable];
    
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

@end

