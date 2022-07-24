//
//  IndexedRange.m
//  CustomTextInput
//
//  Created by janezhuang on 2022/7/23.
//

#import "IndexedRange.h"
#import "IndexedPosition.h"

@implementation IndexedRange
+ (IndexedRange *)rangeWithNSRange:(NSRange)nsrange {
    if (nsrange.location == NSNotFound) {
        return nil;
    }

    IndexedRange *range = [[IndexedRange alloc] init];
    range.range = nsrange;
    return range;
}
 
- (UITextPosition *)start {
    return [IndexedPosition positionWithIndex:self.range.location];
}
 
- (UITextPosition *)end {
    return [IndexedPosition positionWithIndex:NSMaxRange(self.range)];
}
 
- (BOOL)isEmpty {
    return (self.range.length == 0);
}
@end
