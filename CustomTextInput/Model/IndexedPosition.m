//
//  IndexedPosition.m
//  CustomTextInput
//
//  Created by janezhuang on 2022/7/23.
//

#import "IndexedPosition.h"

@implementation IndexedPosition
+ (IndexedPosition *)positionWithIndex:(NSUInteger)index {
    IndexedPosition *pos = [[IndexedPosition alloc] init];
    pos.index = index;
    return pos;
}
@end
