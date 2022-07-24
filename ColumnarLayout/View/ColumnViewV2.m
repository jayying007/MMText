//
//  ColumnViewV2.m
//  ColumnarLayout
//
//  Created by janezhuang on 2022/7/17.
//

#import "ColumnViewV2.h"

@implementation ColumnViewV2

- (void)drawRect:(CGRect)rect {
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self.attributedString];
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    
    CGFloat width = self.bounds.size.width / 3.0;
    for (int i = 0; i < 3; i++) {
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(width, self.bounds.size.height)];
        if (i == 0) {
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(i * width + width / 4, 32, width / 2, self.bounds.size.height / 2)];
            textContainer.exclusionPaths = @[ bezierPath ];
        }
        [layoutManager addTextContainer:textContainer];
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(i * width, 0, width, self.bounds.size.height) textContainer:textContainer];
        textView.backgroundColor = UIColor.clearColor;
        [self addSubview:textView];
    }
}

@end
