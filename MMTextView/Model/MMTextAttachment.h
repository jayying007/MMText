//
//  MMTextAttachment.h
//  MMTextView
//
//  Created by janezhuang on 2022/7/24.
//

#import <UIKit/UIKit.h>

@class MMAttachmentView;
@class MMAttachmentData;

typedef NS_ENUM(UInt32, AttachmentType) {
    AttachmentType_Image = 1,
    AttachmentType_File = 2,
};

@interface MMTextAttachment : NSTextAttachment

- (instancetype)initWithType:(AttachmentType)type contentSize:(CGSize)contentSize;

@property (nonatomic, readonly) AttachmentType type;
@property (nonatomic, readonly) MMAttachmentView *attachmentView;
@property (nonatomic) CGSize contentSize;
/// 用于一些无法显示MMAttachmentView的场景，替代文本
@property (nonatomic) NSString *placeholderText;
@property (nonatomic) MMAttachmentData *data;
@end

