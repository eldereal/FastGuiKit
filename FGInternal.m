//
//  FGInternal.m
//  FastGuiKit
//
//  Created by 易元 白 on 15/3/3.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FGInternal.h"

@implementation FGInternal


/**
 * return the direct caller's position as reuse id
 */
+ (NSString *) callerPositionAsReuseId
{
    //return [NSThread callStackSymbols][2];
    NSArray *arr = [NSThread callStackReturnAddresses];
    NSNumber *val = arr[2];
    return [NSString stringWithFormat:@"_caller@%lx", val.longValue];
}

+ (NSString *)herePositionAsReuseId
{
    NSArray *arr = [NSThread callStackReturnAddresses];
    NSNumber *val = arr[1];
    return [NSString stringWithFormat:@"_caller@%lx", val.longValue];
}

+ (NSString *)memoryPositionAsReuseIdOfObject:(id)obj
{
    return [NSString stringWithFormat:@"_object@%lx", (unsigned long) obj];
}

@end
