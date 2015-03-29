//
//  FGInternal.h
//  FastGuiKit
//
//  Created by 易元 白 on 15/3/3.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FGViewController.h"

typedef UIViewController *(^FGWeakViewControllerStorage)();

@interface FGInternal : NSObject

+ (NSString *) callerPositionAsReuseId;

+ (NSString *) herePositionAsReuseId;

+ (NSString *) memoryPositionAsReuseIdOfObject: (id) obj;

+ (NSString *) staticReuseId: (__strong NSString **) pointer;

@end

