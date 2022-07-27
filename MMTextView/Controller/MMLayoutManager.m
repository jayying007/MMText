//
//  MMLayoutManager.m
//  MMTextView
//
//  Created by janezhuang on 2022/7/24.
//

#import "MMLayoutManager.h"
#import "MMTextAttachment.h"
#import "MMAttachmentView.h"

@implementation MMLayoutManager
- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin {
    [super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
    
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                 inRange:glyphsToShow
                                 options:0
                              usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:MMTextAttachment.class] == NO) {
            return;
        }
        MMTextAttachment *attachment = (MMTextAttachment *)value;
        MMAttachmentView *view = attachment.attachmentView;

        NSTextContainer *textContainer = [self textContainerForGlyphAtIndex:range.location effectiveRange:NULL];
        CGRect rect = [self boundingRectForGlyphRange:range inTextContainer:textContainer];
        rect.origin.x += origin.x;
        rect.origin.y += origin.y;
        rect.size.width = MIN(attachment.contentSize.width, textContainer.size.width - textContainer.lineFragmentPadding * 2);

        view.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, attachment.contentSize.height);
        [view layoutContentView];
        view.hidden = NO;
        // 为了让SelectionView能覆盖在MMAttachmentView上面
        [view.superview sendSubviewToBack:view];
    }];
}
@end
