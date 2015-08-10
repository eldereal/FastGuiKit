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
#import "UIView+FGStylable.h"

@interface WebImageView : UIImageView

@property (nonatomic, strong) NSLayoutConstraint * aspectConstraint;

@end

@implementation FastGui(SDWebImage)

+ (void) webImageWithUrl: (NSURL*) url
{
    [self webImageWithReuseId: [FGInternal callerPositionAsReuseId] url:url placeholderImage:nil autoAspect:NO styleClass:nil];
}

+ (void) webImageWithUrl: (NSURL*) url placeholderImage: (UIImage *) placeHolderImage
{
    [self webImageWithReuseId: [FGInternal callerPositionAsReuseId] url:url placeholderImage:placeHolderImage autoAspect:NO styleClass:nil];
}

+ (void) webImageWithUrl: (NSURL*) url styleClass: (NSString *) styleClass
{
    [self webImageWithReuseId: [FGInternal callerPositionAsReuseId] url:url placeholderImage:nil  autoAspect:NO styleClass:styleClass];
}

+ (void)webImageWithUrl:(NSURL *)url autoAspect:(BOOL)autoAspect styleClass:(NSString *)styleClass
{
    [self webImageWithReuseId: [FGInternal callerPositionAsReuseId] url:url placeholderImage:nil autoAspect:autoAspect styleClass:styleClass];
}

+ (void) webImageWithUrl: (NSURL*) url placeholderImage: (UIImage *) placeHolderImage styleClass: (NSString *) styleClass
{
    [self webImageWithReuseId: [FGInternal callerPositionAsReuseId] url:url placeholderImage:placeHolderImage autoAspect:NO styleClass:styleClass];
}

+ (void) webImageWithReuseId: (NSString *) reuseId url: (NSURL*) url placeholderImage: (UIImage *) placeHolderImage autoAspect: (BOOL) autoAspect styleClass: (NSString *) styleClass
{
    [FastGui customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        WebImageView *img = (WebImageView *) reuseView;
        if (img == nil) {
            img = [[WebImageView alloc] init];
        }
        if (autoAspect) {
            [img sd_setImageWithURL:url placeholderImage:placeHolderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (!image) {
                    return;
                }
                float aspect = image.size.height / image.size.width;
                img.aspectConstraint = [img updateConstraint:img.aspectConstraint view1:img attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:img attribute:NSLayoutAttributeWidth multiplier:aspect constant:0 priority:UILayoutPriorityDefaultLow - 1];
            }];
        }else{
            [img sd_setImageWithURL:url placeholderImage:placeHolderImage];
        }
        return img;
    } resultBlock: nil];
}

@end


@implementation WebImageView


@end