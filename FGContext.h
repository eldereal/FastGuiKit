//
//  FGContext.h
//  FastGuiKit
//
//  Created by 易元 白 on 15/3/2.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGTypes.h"



@protocol FGContext <NSObject>

@required

@property (nonatomic, strong) id<FGContext> parentContext;

/**
 * present a custom view controller if possible.
 */
- (void) customViewControllerWithReuseId: (NSString *) reuseId initBlock: (FGInitCustomViewControllerBlock) initBlock;

/**
 * display a custom view with context's layout.
 */
- (id) customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock: (FGGetCustomViewResultBlock) resultBlock applyStyleBlock: (FGStyleBlock) applyStyleBlock;

- (id)customData:(void*) key data:(NSDictionary *)data;

- (void) reloadGui;

- (void) styleSheet;

@end
