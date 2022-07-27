//
//  MMTextView.m
//  MMTextView
//
//  Created by janezhuang on 2022/7/24.
//

#import "MMTextView.h"
#import "MMTextAttachment.h"
#import "MMAttachmentView.h"
#import "MMLayoutManager.h"

NSString *const kPasteboardName = @"GNTextView.Pasteboard";
NSString *const kPasteboardType = @"GNTextView.PasteboardType";
static NSString *const kAttachmentPlaceholderString = @"\uFFFC";

@interface MMTextView ()
@end

@implementation MMTextView

- (instancetype)initWithFrame:(CGRect)frame {
    NSTextContainer *textConatiner = [[NSTextContainer alloc] initWithSize:CGSizeMake(frame.size.width, CGFLOAT_MAX)];
    
    MMLayoutManager *layoutManager = [[MMLayoutManager alloc] init];
    [layoutManager addTextContainer:textConatiner];
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] init];
    [textStorage addLayoutManager:layoutManager];

    self = [super initWithFrame:frame textContainer:textConatiner];
    return self;
}

- (void)insertAttachment:(MMTextAttachment *)attachment {
    NSAttributedString *attrString = [self attributeTextFromCurrentConfig:kAttachmentPlaceholderString attachment:attachment];
    [self insertAttributedText:attrString];
}

- (void)insertAttributedText:(NSAttributedString *)attributedString {
    [self _appendAttachmentsWithAttributeText:attributedString];
    [self.textStorage beginEditing];
    
    [self.textStorage replaceCharactersInRange:self.selectedRange withAttributedString:attributedString];
    NSRange range = NSMakeRange(self.textStorage.editedRange.location + self.textStorage.editedRange.length, 0);
    
    [self.textStorage endEditing];
    //让光标移动到插入的位置之后
    self.selectedRange = range;
}
#pragma mark - UITextInput
- (void)insertText:(NSString *)text {
    NSAttributedString *attrString = [self attributeTextFromCurrentConfig:text attachment:nil];
    [self insertAttributedText:attrString];
}

- (void)deleteBackward {
    if (self.selectedRange.location > 0 || self.selectedRange.length > 0) {
        NSRange range = self.selectedRange;
        if (self.selectedRange.length == 0) {
            range = NSMakeRange(self.selectedRange.location - 1, 1);
        }

        [self _removeAttachmentsInRange:range];
        [super deleteBackward];
    }
}
#pragma mark - Menu
- (void)cut:(id)sender {
    [self copy:sender];
    [self replaceTextInRange:self.selectedRange withText:@""];
}

- (void)copy:(id)sender {
    NSAttributedString *attributedString = [self.textStorage attributedSubstringFromRange:self.selectedRange];
    //复制到自己的Pasteboard，能够粘贴到其他MMTextView上（保持样式）
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:kPasteboardName create:YES];
    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:attributedString requiringSecureCoding:YES error:&error];
    [pasteboard setData:data forPasteboardType:kPasteboardType];
    //复制到系统的Pasteboard，能够粘贴到其他TextView上（纯文本）
    NSMutableAttributedString *mutAttributedString = attributedString.mutableCopy;
    [mutAttributedString enumerateAttribute:NSAttachmentAttributeName
                               inRange:NSMakeRange(0, mutAttributedString.length)
                               options:NSAttributedStringEnumerationReverse
                            usingBlock:^(id value, NSRange range, BOOL * stop) {
                                if ([value isKindOfClass:[MMTextAttachment class]]) {
                                    MMTextAttachment *attachment = (MMTextAttachment *)value;
                                    [mutAttributedString replaceCharactersInRange:range
                                                              withString:attachment.placeholderText];
                                }
                            }];
    [UIPasteboard generalPasteboard].string = mutAttributedString.string;
}

- (void)paste:(id)sender {
    //先尝试自家的Pasteboard
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:kPasteboardName create:NO];
    NSData *data = [pasteboard dataForPasteboardType:kPasteboardType];
    NSError *error = nil;
    NSAttributedString *attributedString = [NSKeyedUnarchiver unarchivedObjectOfClass:NSAttributedString.class fromData:data error:&error];
    if (attributedString && attributedString.length > 0) {
        [self replaceTextInRange:self.selectedRange withAttributeText:attributedString];
        return;
    }
    //再用系统的Pasteboard
    NSString *text = [UIPasteboard generalPasteboard].string;
    [self replaceTextInRange:self.selectedRange withText:text];
}
#pragma mark - Internal
- (NSAttributedString *)attributeTextFromCurrentConfig:(NSString *)text attachment:(MMTextAttachment *)attachment {
    NSParagraphStyle *paragraphStyle = [NSParagraphStyle defaultParagraphStyle];
    
    NSMutableDictionary *attributes = @{
        NSFontAttributeName : self.font,
        NSParagraphStyleAttributeName : paragraphStyle,
    }.mutableCopy;
    if (attachment != nil) {
        [attributes setObject:attachment forKey:NSAttachmentAttributeName];
    }
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (void)_removeAttachmentsInRange:(NSRange)range {
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:range options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:[MMTextAttachment class]] == NO) {
            return;
        }
        
        MMTextAttachment *attachment = (MMTextAttachment *)value;
        MMAttachmentView *view = attachment.attachmentView;
        [view removeFromSuperview];
        // 不确定是否有用
        [self.layoutManager invalidateDisplayForCharacterRange:range];
    }];
}
//将attachmentView加到textView上
- (void)_appendAttachmentsWithAttributeText:(NSAttributedString *)attributedString {
    [attributedString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:MMTextAttachment.class] == NO) {
            return;
        }
        
        MMTextAttachment *attachment = (MMTextAttachment *)value;
        MMAttachmentView *view = attachment.attachmentView;
        view.hidden = YES;
        [self addSubview:view];
    }];
}

- (void)replaceTextInRange:(NSRange)range withText:(NSString *)text {
    NSAttributedString *attrString = [self attributeTextFromCurrentConfig:text attachment:nil];
    [self replaceTextInRange:range withAttributeText:attrString];
}

- (void)replaceTextInRange:(NSRange)range withAttributeText:(NSAttributedString *)attributedString {
    [self _removeAttachmentsInRange:range];
    [self _appendAttachmentsWithAttributeText:attributedString];
    [self.textStorage beginEditing];
    
    [self.textStorage replaceCharactersInRange:range withAttributedString:attributedString];
    
    [self.textStorage endEditing];
    
    self.selectedRange = NSMakeRange(self.textStorage.editedRange.location, 0);
}
@end
