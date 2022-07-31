//
//  CircleTextContainer.m
//  TextKitLayout
//
//  Created by janezhuang on 2022/7/30.
//

#import "CircleTextContainer.h"

@implementation CircleTextContainer
- (CGRect)lineFragmentRectForProposedRect:(CGRect)proposedRect atIndex:(NSUInteger)characterIndex writingDirection:(NSWritingDirection)baseWritingDirection remainingRect:(CGRect *)remainingRect {
    CGRect rect = [super lineFragmentRectForProposedRect:proposedRect atIndex:characterIndex writingDirection:baseWritingDirection remainingRect:remainingRect];

    CGFloat containerWidth = self.size.width;
    CGFloat containerHeight = self.size.height;
    CGFloat diameter = MIN(containerWidth, containerHeight);
    CGFloat radius = diameter / 2;
    
    //行中心到容器中心的距离
    CGFloat yDistance = fabs(rect.origin.y + rect.size.height / 2 - radius);
    if (yDistance > radius) {
        return CGRectZero;
    }
    
    
    //勾股定理。。
    CGFloat lineWidth = 2 * sqrt(radius * radius - yDistance * yDistance);
    
    CGFloat xOffset = (containerWidth - lineWidth) / 2;
    
    rect.origin.x += xOffset;
    rect.size.width = lineWidth;
    return rect;
}
@end
