//
//  IndexedRange.h
//  CustomTextInput
//
//  Created by janezhuang on 2022/7/23.
//

#import <UIKit/UIKit.h>

@interface IndexedRange : UITextRange
@property (nonatomic) NSRange range;
+ (IndexedRange *)rangeWithNSRange:(NSRange)range;
@end
