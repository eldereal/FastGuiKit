//
//  FastGUI.h
//  Pods
//
//  Created by 易元 白 on 15/3/1.
//
//

#import "FGContext.h"
#import "FGTypes.h"


@interface FastGui : NSObject

+ (void) callOnGui: (FGOnGuiBlock) onGui withContext: (id<FGContext>) context;


+ (void) pushContext: (id<FGContext>) context;

+ (void) popContext;

/**
 * present a custom view controller if possible.
 */
+ (void) customViewControllerWithReuseId: (NSString *) reuseId initBlock: (FGInitCustomViewControllerBlock) initBlock;

/**
 * display a custom view with context's layout.
 */
+ (id) customViewWithReuseId: (NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock: (FGGetCustomViewResultBlock) resultBlock;

+ (id) customData:(void*) key data:(NSDictionary *)data;

+ (void) reloadGui;


@end
