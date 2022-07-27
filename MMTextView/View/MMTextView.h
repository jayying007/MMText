//
//  MMTextView.h
//  MMTextView
//
//  Created by janezhuang on 2022/7/24.
//

#import <UIKit/UIKit.h>

@class MMTextAttachment;

@interface MMTextView : UITextView

- (void)insertAttachment:(MMTextAttachment *)attachment;
@end

