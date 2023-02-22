//
//  TextLayerAnimation.m
//  MMText
//
//  Created by janezhuang on 2023/2/21.
//

#import "MMTextLayerAnimation.h"
#import "MMTextDefine.h"

let kTextAnimationGroupKey = @"textAniamtionGroupKey";

@interface MMTextLayerAnimation () <CAAnimationDelegate>
@property (nonatomic) void(^completeBlock)(BOOL);
@end

@implementation MMTextLayerAnimation
+ (void)animateWithLayer:(CATextLayer *)layer duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay animations:(void (^)(CATextLayer * _Nonnull))animations completion:(void (^)(BOOL))completion {
    let animationObj = [MMTextLayerAnimation new];
    animationObj.completeBlock = completion;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        let oldLayer = [MMTextLayerAnimation animatableLayerCopy:layer];
        let newLayer = layer;
        // 改变Layer的properties，同时关闭implicit animation
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        animations(newLayer);
        [CATransaction commit];
        
        var animationGroup = [animationObj groupAnimationWithLayerChanges:oldLayer newLayer:newLayer];
        if (animationGroup != nil) {
            animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animationGroup.beginTime = CACurrentMediaTime();
            animationGroup.duration = duration;
            animationGroup.delegate = animationObj;
            // CATextLayer --> CAAnimationGroup --> delegate(TextLayerAnimation) --> CATextLayer
            // 这里CALayer内部拷贝了一份CAAnimationGroup，所以没有导致循环引用
            [layer addAnimation:animationGroup forKey:kTextAnimationGroupKey];
        } else if (completion) {
            completion(YES);
        }
    });
}
#pragma mark -
- (CAAnimationGroup *)groupAnimationWithLayerChanges:(CALayer *)oldLayer newLayer:(CALayer *)newLayer {
    var animations = [NSMutableArray array];
    var animationGroup = (CAAnimationGroup *)nil;
    
    if (CGPointEqualToPoint(oldLayer.position, newLayer.position) == NO) {
        let basicAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        basicAnimation.fromValue = [NSValue valueWithCGPoint:oldLayer.position];
        basicAnimation.toValue = [NSValue valueWithCGPoint:newLayer.position];
        [animations addObject:basicAnimation];
    }
    
    if (CATransform3DEqualToTransform(oldLayer.transform, newLayer.transform) == NO) {
        let basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        basicAnimation.fromValue = [NSValue valueWithCATransform3D:oldLayer.transform];
        basicAnimation.toValue = [NSValue valueWithCATransform3D:newLayer.transform];
        [animations addObject:basicAnimation];
    }
    
    if (CGRectEqualToRect(oldLayer.bounds, newLayer.bounds) == NO) {
        let basicAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
        basicAnimation.fromValue = [NSValue valueWithCGRect:oldLayer.bounds];
        basicAnimation.toValue = [NSValue valueWithCGRect:newLayer.bounds];
        [animations addObject:basicAnimation];
    }
    
    if (oldLayer.opacity != newLayer.opacity) {
        let basicAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        basicAnimation.fromValue = [NSNumber numberWithFloat:oldLayer.opacity];
        basicAnimation.toValue = [NSNumber numberWithFloat:newLayer.opacity];
        [animations addObject:basicAnimation];
    }
    
    if (animations.count > 0) {
        animationGroup = [[CAAnimationGroup alloc] init];
        animationGroup.animations = animations;
    }
    return animationGroup;
}

+ (CALayer *)animatableLayerCopy:(CALayer *)layer {
    let layerCopy = [CALayer new];
    layerCopy.opacity = layer.opacity;
    layerCopy.bounds = layer.bounds;
    layerCopy.transform = layer.transform;
    layerCopy.position = layer.position;
    return layerCopy;
}
#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.completeBlock) {
        self.completeBlock(flag);
    }
}
@end
