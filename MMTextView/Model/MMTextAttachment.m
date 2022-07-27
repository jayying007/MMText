//
//  MMTextAttachment.m
//  MMTextView
//
//  Created by janezhuang on 2022/7/24.
//

#import "MMTextAttachment.h"
#import "MMAttachmentView.h"
#import "MMImageAttachmentView.h"
#import "MMFileAttachmentView.h"

#import "NSObject+YYModel.h"

@interface MMTextAttachment ()
@property (nonatomic) AttachmentType type;
@property (nonatomic) MMAttachmentView *attachmentView;
@end

@implementation MMTextAttachment
- (instancetype)initWithType:(AttachmentType)type contentSize:(CGSize)contentSize {
    self = [super init];
    if (self) {
        self.type = type;
        Class cls = [MMTextAttachment attachmentViewClassForType:type];
        if (cls == nil) {
            return nil;
        }
        self.attachmentView = [[cls alloc] init];
        
        self.contentSize = contentSize;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt32:self.type forKey:@"type"];
    [coder encodeCGSize:self.contentSize forKey:@"contentSize"];
    [coder encodeObject:self.placeholderText forKey:@"placeholderText"];
    
    NSData *archivedData = [self.data yy_modelToJSONData];
    [coder encodeObject:archivedData forKey:@"attachmentData"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.type = [coder decodeInt32ForKey:@"type"];
        Class cls = [MMTextAttachment attachmentViewClassForType:self.type];
        if (cls == nil) {
            return nil;
        }
        self.attachmentView = [[cls alloc] init];

        self.contentSize = [coder decodeCGSizeForKey:@"contentSize"];
        self.placeholderText = [coder decodeObjectForKey:@"placeholderText"];
        
        NSData *unarchivedData = [coder decodeObjectForKey:@"attachmentData"];
        self.data = [MMAttachmentData yy_modelWithJSON:unarchivedData];
    }
    return self;
}

- (void)dealloc {
    [self.attachmentView removeFromSuperview];
}
#pragma mark - NSTextAttachmentContainer
//重写，避免输出默认背景图
- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex {
    return nil;
}
#pragma mark - Property
- (void)setContentSize:(CGSize)contentSize {
    _contentSize = contentSize;
    self.bounds = CGRectMake(0, 0, _contentSize.width, _contentSize.height);
}

- (void)setData:(MMAttachmentData *)data {
    _data = data;
    self.attachmentView.data = data;
}

- (MMAttachmentView *)attachmentView {
    return _attachmentView;
}

+ (Class)attachmentViewClassForType:(AttachmentType)type {
    switch (type) {
        case AttachmentType_Image:
            return MMImageAttachmentView.class;
        case AttachmentType_File:
            return MMFileAttachmentView.class;
        default:
            return nil;
    }
}

+ (BOOL)supportsSecureCoding {
    return YES;
}
@end
