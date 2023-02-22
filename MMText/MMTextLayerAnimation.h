//
//  TextLayerAnimation.h
//  MMText
//
//  Created by janezhuang on 2023/2/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMTextLayerAnimation : NSObject

+ (void)animateWithLayer:(CATextLayer *)layer duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay animations:(void (^)(CATextLayer *layer))animations completion:(void (^ __nullable)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END
