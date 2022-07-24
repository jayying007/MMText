//
//  MMTextView.h
//  CustomTextInput
//
//  Created by janezhuang on 2022/7/22.
//

#import <UIKit/UIKit.h>

@interface CoreTextView : UIView
@property (nonatomic) NSString *contentText;
@property (nonatomic) UIFont *font; // Font used for text content.
/// 因为EditableCoreTextView相当于容器，实际绘制是CoreTextView，所以要把markedTextRange、selectedTextRange等信息传递给CoreTextView
@property (nonatomic) NSRange markedTextRange;
@property (nonatomic) NSRange selectedTextRange;
@property (nonatomic, getter=isEditing) BOOL editing; // Is view in "editing" mode or not (affects drawn results).

- (CGRect)firstRectForRange:(NSRange)range;
- (CGRect)caretRectForIndex:(int)index;
- (NSInteger)closestIndexToPoint:(CGPoint)point;
@end

