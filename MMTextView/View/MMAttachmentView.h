//
//  MMAttachmentView.h
//  MMTextView
//
//  Created by janezhuang on 2022/7/24.
//

#import <UIKit/UIKit.h>
#import "MMAttachmentData.h"

@interface MMAttachmentView : UIView
- (void)layoutContentView;

@property (nonatomic) MMAttachmentData *data;
@end

