//
//  FGViewGrid.m
//  train-helper
//
//  Created by 易元 白 on 15/3/12.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FGViewGrid.h"
#import "FGInternal.h"
#import "FGViewPool.h"

#define INDEX(row, col, cols) (row * cols + col)

@interface FGViewGridCell : NSObject

@property (nonatomic, assign) NSUInteger rowSpan;

@property (nonatomic, assign) NSUInteger colSpan;

@property (nonatomic, strong) UIView * view;

@end


@interface FGViewGrid : UIView<FGContext, FGStylable>

- (void) styleWithCustomKey:(NSString *)key value:(id)value;


@property (nonatomic, assign) NSUInteger rows;

@property (nonatomic, assign) NSUInteger cols;

@property (nonatomic, strong) FGViewPool *pool;

@property (nonatomic, strong) NSMutableArray *grids;

@property (nonatomic, strong) FGViewGridCell * nextCell;


@property (nonatomic, assign) CGFloat gridSpacingX;

@property (nonatomic, assign) CGFloat gridSpacingY;



@end


@implementation FGStyle(FGViewGrid)

+ (void) gridSpacing: (CGFloat) gridSpacing
{
    [self gridSpacingX: gridSpacing];
    [self gridSpacingY: gridSpacing];
}

+ (void) gridSpacingX: (CGFloat) gridSpacingX
{
    [self customStyle:@"gridSpacingX" value: [NSNumber numberWithFloat:gridSpacingX]];
}

+ (void) gridSpacingY: (CGFloat) gridSpacingY
{
    [self customStyle:@"gridSpacingY" value: [NSNumber numberWithFloat:gridSpacingY]];
}

@end

static void * EndGridMethodKey = &EndGridMethodKey;
static void * EmptyGridMethodKey = &EmptyGridMethodKey;
static void * NextGridRowColSpanMethodKey = &NextGridRowColSpanMethodKey;
static NSString * NextGridRowSpanDataKey = @"FGViewGridNextGridRowSpanDataKey";
static NSString * NextGridColSpanDataKey = @"FGViewGridNextGridColSpanDataKey";

@implementation FastGui(FGViewGrid)

+ (void) beginGridWithColumns: (NSUInteger) cols rows: (NSUInteger) rows
{
    [self beginGridWithReuseId:[FGInternal callerPositionAsReuseId] columns:cols rows:rows styleClass:nil];
}

+ (void) beginGridWithColumns: (NSUInteger) cols rows: (NSUInteger) rows styleClass: (NSString *) styleClass
{
    [self beginGridWithReuseId:[FGInternal callerPositionAsReuseId] columns:cols rows:rows styleClass:styleClass];
}

+ (void) beginGridWithReuseId: (NSString *)reuseId columns: (NSUInteger) cols rows: (NSUInteger) rows styleClass: (NSString *) styleClass
{
    FGViewGrid *grid = [FastGui customViewWithClass: styleClass reuseId: reuseId initBlock:^UIView *(UIView *reuseView, FGNotifyCustomViewResultBlock notifyResult) {
        FGViewGrid *view = (FGViewGrid *) reuseView;
        if (view == nil) {
            view = [[FGViewGrid alloc] init];
            view.pool = [[FGViewPool alloc] init];
            view.grids = [NSMutableArray array];
        }
        view.cols = cols;
        view.rows = rows;
        [view.grids removeAllObjects];
        for (int row = 0; row < rows; row ++) {
            for (int col = 0; col < cols; col ++) {
                [view.grids addObject: [NSNull null]];
            }
        }
        [view.pool prepareUpdateViews];
        view.nextCell = nil;
        return view;
    } resultBlock:^id(UIView *view) {
        return view;
    }];
    [self pushContext: grid];
}

+ (void) endGrid
{
    [FastGui customData:EndGridMethodKey data:nil];
}

+ (void)emptyGrid
{
    [FastGui customData:EmptyGridMethodKey data:nil];
}

+ (void)nextGridRowSpan:(NSUInteger)rowSpan colSpan:(NSUInteger)colSpan
{
    [FastGui customData:NextGridRowColSpanMethodKey data:@{NextGridRowSpanDataKey: [NSNumber numberWithUnsignedInteger: rowSpan], NextGridColSpanDataKey: [NSNumber numberWithUnsignedInteger: colSpan]}];
}

+ (void)nextGridRowSpan:(NSUInteger)rowSpan
{
    [FastGui customData:NextGridRowColSpanMethodKey data:@{NextGridRowSpanDataKey: [NSNumber numberWithUnsignedInteger: rowSpan]}];
}

+ (void)nextGridColSpan:(NSUInteger)colSpan
{
    [FastGui customData:NextGridRowColSpanMethodKey data:@{NextGridColSpanDataKey: [NSNumber numberWithUnsignedInteger: colSpan]}];
}

@end

@implementation FGViewGrid

@synthesize parentContext;

- (void)reloadGui
{
    [parentContext reloadGui];
}

- (void) styleSheet
{
    [parentContext styleSheet];
}

- (void) styleWithCustomKey:(NSString *)key value:(id)value
{
    if ([key isEqualToString:@"gridSpacingX"]) {
        self.gridSpacingX = [(NSNumber *)value floatValue];
    }else if([key isEqualToString:@"gridSpacingY"]){
        self.gridSpacingY = [(NSNumber *)value floatValue];
    }
}

- (id)customData:(void *)key data:(NSDictionary *)data
{
    if (key == EndGridMethodKey) {
        [self endGrid];
    }else if(key == EmptyGridMethodKey){
        [self emptyGrid];
    }else if(key == NextGridRowColSpanMethodKey){
        [self nextGridRowSpan:data[NextGridRowSpanDataKey] colSpan:data[NextGridColSpanDataKey]];
    }
    else{
        return [parentContext customData:key data:data];
    }
    return nil;
}

- (void) endGrid
{
    [self.pool finishUpdateViews:nil needRemove:^(UIView *view) {
        [view removeFromSuperview];
    }];
    [FastGui popContext];
}

- (void)customViewControllerWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewControllerBlock)initBlock
{
    [parentContext customViewControllerWithReuseId:reuseId initBlock:initBlock];
}

- (BOOL) findNextRowIndex: (NSUInteger *)outRow colIndex: (NSUInteger *)outCol
{
    for (NSUInteger row = 0; row < self.rows; row++) {
        for (NSUInteger col = 0; col < self.cols; col++) {
            if(self.grids[INDEX(row, col, self.cols)] == [NSNull null]){
                *outRow = row;
                *outCol = col;
                return YES;
            }
        }
    }
    return NO;
}

- (void) nextGridRowSpan: (NSNumber *) rowSpan colSpan: (NSNumber *) colSpan
{
    if (self.nextCell == nil) {
        self.nextCell = [[FGViewGridCell alloc] init];
        self.nextCell.rowSpan = 1;
        self.nextCell.colSpan = 1;
    }
    if (rowSpan != nil) {
        self.nextCell.rowSpan = [rowSpan unsignedIntegerValue];
    }
    if (colSpan != nil) {
        self.nextCell.colSpan = [colSpan unsignedIntegerValue];
    }
}

- (id) customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock:(FGStyleBlock)applyStyleBlock
{
    
    FGViewGridCell *nextCell = self.nextCell;
    self.nextCell = nil;
    if (nextCell == nil) {
        nextCell = [[FGViewGridCell alloc] init];
        nextCell.rowSpan = 1;
        nextCell.colSpan = 1;
    }
    
    NSUInteger row, col;
    if (![self findNextRowIndex:&row colIndex:&col]) {
        printf("Too many views are added to the grid");
        return nil;
    }
    
    __weak FGViewGrid *weakSelf = self;
    BOOL isNew;
    UIView *view = [self.pool updateView:reuseId initBlock:initBlock notifyBlock:^{
        [weakSelf reloadGui];
    } outputIsNewView: &isNew];
    if (isNew) {
        [self addSubview:view];
    }
    applyStyleBlock(view);
    
    CGFloat gridWidth = (self.frame.size.width - self.gridSpacingX * (self.cols - 1)) / self.cols;
    CGFloat gridHeight = (self.frame.size.height - self.gridSpacingY * (self.rows - 1)) / self.rows;
    
    view.frame = CGRectMake((gridWidth + self.gridSpacingX) * col, (gridHeight + self.gridSpacingY) * row, (gridWidth + self.gridSpacingX) * nextCell.colSpan - self.gridSpacingX , (gridHeight + self.gridSpacingY) * nextCell.rowSpan - self.gridSpacingY);
    
    nextCell.view = view;
    
    for (NSUInteger r = row; r < row + nextCell.rowSpan; r ++) {
        for (NSUInteger c = col; c < col + nextCell.colSpan; c ++) {
            self.grids[INDEX(r, c, self.cols)] = nextCell;
        }
    }
    
    if (resultBlock == nil) {
        return nil;
    }else{
        return resultBlock(view);
    }
}

- (void) emptyGrid
{
    FGViewGridCell *nextCell = self.nextCell;
    self.nextCell = nil;
    if (nextCell == nil) {
        nextCell = [[FGViewGridCell alloc] init];
        nextCell.rowSpan = 1;
        nextCell.colSpan = 1;
    }
    NSUInteger row, col;
    if (![self findNextRowIndex:&row colIndex:&col]) {
        printf("Too many views are added to the grid");
        return;
    }
    
    for (NSUInteger r = row; r < row + nextCell.rowSpan; r ++) {
        for (NSUInteger c = col; c < col + nextCell.colSpan; c ++) {
            self.grids[INDEX(r, c, self.cols)] = nextCell;
        }
    }
}

@end

@implementation FGViewGridCell


@end
