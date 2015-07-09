//
//  FGViewController.h
//  Pods
//
//  Created by 易元 白 on 15/3/1.
//
//

#import <UIKit/UIKit.h>
#import "FastGui.h"
#import "FGContext.h"
#import "FGTypes.h"

@interface FastGui (FGViewController)

+ (void) viewController: (FGOnGuiBlock) onGui;

+ (void) viewController: (FGOnGuiBlock) onGui styleClass: (NSString *) styleClass;

@end

@interface FGViewController : UIViewController

- (NSString *) viewStyleClass;

- (void) onGui;

- (void) styleSheet;

@end
