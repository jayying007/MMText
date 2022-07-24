//
//  IndexedPosition.h
//  CustomTextInput
//
//  Created by janezhuang on 2022/7/23.
//

#import <UIKit/UIKit.h>

@interface IndexedPosition : UITextPosition
@property (nonatomic) NSUInteger index;
+ (IndexedPosition *)positionWithIndex:(NSUInteger)index;
@end
