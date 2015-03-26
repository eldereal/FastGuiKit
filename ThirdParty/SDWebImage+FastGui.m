//
//  SDWebImage+FastGui.m
//  train-helper
//
//  Created by 易元 白 on 15/3/14.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//
#import <SDWebImage/UIImageView+WebCache.h>
#import "SDWebImage+FastGui.h"
#import "FGInternal.h"

@implementation FastGui(SDWebImage)

+ (void) webImageWithUrl: (NSURL*) url
{
    [self webImageWithReuseId: [FGInternal callerPositionAsReuseId] url:url placeholderImage:nil styleClass:nil];
}

+ (void) webImageWithUrl: (NSURL*) url placeholderImage: (UIImage *) placeHolderImage
{
    [self webImageWithReuseId: [FGInternal callerPositionAsReuseId] url:url placeholderImage:placeHolderImage styleClass:nil];
}

+ (void) webImageWithUrl: (NSURL*) url styleClass: (NSString *) styleClass
{
    [self webImageWithReuseId: [FGInternal callerPositionAsReuseId] url:url placeholderImage:nil styleClass:styleClass];
}

+ (void) webImageWithUrl: (NSURL*) url placeholderImage: (UIImage *) placeHolderImage styleClass: (NSString *) styleClass
{
    [self webImageWithReuseId: [FGInternal callerPositionAsReuseId] url:url placeholderImage:placeHolderImage styleClass:styleClass];
}

+ (void) webImageWithReuseId: (NSString *) reuseId url: (NSURL*) url placeholderImage: (UIImage *) placeHolderImage styleClass: (NSString *) styleClass
{
    [FastGui customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        UIImageView *img = (UIImageView *) reuseView;
        if (img == nil) {
            img = [[UIImageView alloc] init];
        }
        [img sd_setImageWithURL:url placeholderImage:placeHolderImage];
        return img;
    } resultBlock: nil];
}

@end
