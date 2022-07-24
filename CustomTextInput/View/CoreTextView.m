//
//  MMTextView.m
//  CustomTextInput
//
//  Created by janezhuang on 2022/7/22.
//

#import "CoreTextView.h"
#import "CaretView.h"
#import <CoreText/CoreText.h>

#pragma mark - Range intersection function
/*
 Helper function to obtain the intersection of two ranges (for handling selection range across multiple line ranges in drawRangeAsSelection).
 */
NSRange RangeIntersection(NSRange first, NSRange second) {
    NSRange result = NSMakeRange(NSNotFound, 0);

    // Ensure first range does not start after second range.
    if (first.location > second.location) {
        NSRange tmp = first;
        first = second;
        second = tmp;
    }

    // Find the overlap intersection range between first and second.
    if (second.location < first.location + first.length) {
        result.location = second.location;
        NSUInteger end = MIN(first.location + first.length, second.location + second.length);
        result.length = end - result.location;
    }

    return result;
}

@interface CoreTextView ()
/// Cached Core Text framesetter.
@property (nonatomic) CTFramesetterRef framesetter;
/// Cached Core Text frame.
@property (nonatomic) CTFrameRef ctFrame;

@property (nonatomic) NSDictionary *attributes;
@property (nonatomic) CaretView *caretView;
@end

@implementation CoreTextView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentText = @"";
        _caretView = [[CaretView alloc] initWithFrame:CGRectZero];
        self.layer.geometryFlipped = YES;  // For ease of interaction with the CoreText coordinate system.
        self.font = [UIFont systemFontOfSize:18];
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeRedraw;
        
        self.markedTextRange = NSMakeRange(NSNotFound, 0);
        self.selectedTextRange = NSMakeRange(0, 0);
    }
    return self;
}
// Standard UIView drawRect override that uses Core Text to draw our text contents.
- (void)drawRect:(CGRect)rect {
    // First draw selection / marked text, then draw text.
    [self drawRangeAsSelection:_selectedTextRange];
    [self drawRangeAsSelection:_markedTextRange];

    CTFrameDraw(_ctFrame, UIGraphicsGetCurrentContext());
}

// Helper method for drawing the current selection range (as a simple filled rect).
- (void)drawRangeAsSelection:(NSRange)selectionRange {
    // If not in editing mode, do not draw selection rectangles.
    if (!self.editing) {
        return;
    }

    // If the selection range is empty, do not draw.
    if (selectionRange.length == 0 || selectionRange.location == NSNotFound) {
        return;
    }

    // Set the fill color to the selection color.
    [[CoreTextView selectionColor] setFill];

    /*
     Iterate over the lines in our CTFrame, looking for lines that intersect with the given selection range, and draw a selection rect for each intersection.
     */
    CFArrayRef lines = CTFrameGetLines(_ctFrame);
    CFIndex linesCount = CFArrayGetCount(lines);

    for (CFIndex linesIndex = 0; linesIndex < linesCount; linesIndex++) {
        CTLineRef line = (CTLineRef) CFArrayGetValueAtIndex(lines, linesIndex);
        CFRange lineRange = CTLineGetStringRange(line);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSRange intersection = RangeIntersection(range, selectionRange);
        if (intersection.location != NSNotFound && intersection.length > 0) {
            //TODO: 未解之谜，后几行代码将xStart和xEnd的值修改了
            // The text range for this line intersects our selection range.
            CGFloat xStart = CTLineGetOffsetForStringIndex(line, intersection.location, NULL);
            CGFloat xEnd = CTLineGetOffsetForStringIndex(line, intersection.location + intersection.length, NULL);
            CGPoint origin;
            // Get coordinate and bounds information for the intersection text range.
            CTFrameGetLineOrigins(_ctFrame, CFRangeMake(linesIndex, 1), &origin);
            CGFloat ascent, descent;
            CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
            // Create a rect for the intersection and draw it with selection color.
            CGRect selectionRect = CGRectMake(xStart, origin.y - descent, xEnd - xStart, ascent + descent);
            UIRectFill(selectionRect);
        }
    }
}
#pragma mark - Public
/*
 Public method to create a rect for a given range in the text contents.
 Called by our EditableTextRange to implement the required UITextInput:firstRectForRange method.
 */
- (CGRect)firstRectForRange:(NSRange)range; {
    int index = range.location;
    NSArray *lines = (NSArray *)CTFrameGetLines(_ctFrame);
    for (int i = 0; i < [lines count]; i++) {
        CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
        CFRange lineRange = CTLineGetStringRange(line);
        // localIndex代表这个range在lineRange上的偏移值
        int localIndex = index - (int)lineRange.location;
        if (localIndex >= 0 && localIndex < lineRange.length) {
            int finalIndex = MIN(lineRange.location + lineRange.length,
                range.location + range.length);
            CGFloat xStart = CTLineGetOffsetForStringIndex(line, index, NULL);
            CGFloat xEnd = CTLineGetOffsetForStringIndex(line, finalIndex, NULL);
            CGPoint origin;
            CTFrameGetLineOrigins(_ctFrame, CFRangeMake(i, 1), &origin);
            CGFloat ascent, descent;
            CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
 
            return CGRectMake(xStart, origin.y - descent, xEnd - xStart, ascent + descent);
        }
    }
    return CGRectNull;
}

/*
 Public method to determine the CGRect for the insertion point or selection, used when creating or updating the simple caret view instance.
 */
- (CGRect)caretRectForIndex:(int)index {
    // Special case, no text.
    if (self.contentText.length == 0) {
        CGPoint origin = CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds) - self.font.ascender);
        // Note: using fabs() for typically negative descender from fonts.

        return CGRectMake(origin.x, origin.y - fabs(self.font.descender), 3, self.font.ascender + fabs(self.font.descender));
    }

    // Iterate over our CTLines, looking for the line that encompasses the given range.
    CFArrayRef lines = CTFrameGetLines(_ctFrame);
    CFIndex linesCount = CFArrayGetCount(lines);


    // Special case, insertion point at final position in text after newline.
    if (index == self.contentText.length && [self.contentText characterAtIndex:(index - 1)] == '\n') {
        CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lines, linesCount -1);
        CFRange range = CTLineGetStringRange(line);
        CGFloat xPos = CTLineGetOffsetForStringIndex(line, range.location, NULL);
        CGPoint origin;
        CGFloat ascent, descent;
        CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
        CTFrameGetLineOrigins(_ctFrame, CFRangeMake(linesCount - 1, 1), &origin);
        // Place point after last line, including any font leading spacing if applicable.
        origin.y -= self.font.leading;
        origin.y -= self.font.lineHeight; //移动到下一行

        return CGRectMake(xPos, origin.y - descent, 3, ascent + descent);
    }

    // Regular case, caret somewhere within our text content range.
    for (CFIndex linesIndex = 0; linesIndex < linesCount; linesIndex++) {
        CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lines, linesIndex);
        CFRange range = CTLineGetStringRange(line);
        NSInteger localIndex = index - range.location;
        if (localIndex >= 0 && localIndex <= range.length) {
            // index is in the range for this line.
            CGFloat xPos = CTLineGetOffsetForStringIndex(line, index, NULL);
            CGPoint origin;
            CGFloat ascent, descent;
            CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
            CTFrameGetLineOrigins(_ctFrame, CFRangeMake(linesIndex, 1), &origin);

            // Make a small "caret" rect at the index position.
            return CGRectMake(xPos, origin.y - descent, 3, ascent + descent);
        }
    }

    return CGRectNull;
}

// Public method to find the text range index for a given CGPoint.
- (NSInteger)closestIndexToPoint:(CGPoint)point {
    /*
     Use Core Text to find the text index for a given CGPoint by iterating over the y-origin points for each line, finding the closest line, and finding the closest index within that line.
     */
    CFArrayRef lines = CTFrameGetLines(_ctFrame);
    CFIndex linesCount = CFArrayGetCount(lines);
    CGPoint origins[linesCount];

    CTFrameGetLineOrigins(_ctFrame, CFRangeMake(0, linesCount), origins);

    for (CFIndex linesIndex = 0; linesIndex < linesCount; linesIndex++) {
        if (point.y > origins[linesIndex].y) {
            // This line origin is closest to the y-coordinate of our point; now look for the closest string index in this line.
            CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lines, linesIndex);
            return CTLineGetStringIndexForPosition(line, point); //这个point不需要转为相对当前line吗？
        }
    }

    return self.contentText.length;
}
#pragma mark -
// Helper method to update our text storage when the text content has changed.
- (void)textChanged {
    // Build the attributed string from our text data and string attribute data,
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.contentText attributes:self.attributes];

    // Create the Core Text framesetter using the attributed string.
    if (_framesetter != NULL) {
        CFRelease(_framesetter);
    }
    _framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);

    [self updateCTFrame];
    [self setNeedsDisplay];
}

- (void)updateCTFrame {
    // Create the Core Text frame using our current view rect bounds.
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];

    if (_ctFrame != NULL) {
        CFRelease(_ctFrame);
    }
    _ctFrame = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, 0), [path CGPath], NULL);
}

// Helper method to update caretView when insertion point/selection changes.
- (void)selectionChanged {
    // If not in editing mode, we don't show the caret.
    if (!self.editing) {
        [self.caretView removeFromSuperview];
        return;
    }

    /*
     If there is no selection range (always true for this sample), find the insert point rect and create a caretView to draw the caret at this position.
     */
    if (self.selectedTextRange.length == 0) {
        self.caretView.frame = [self caretRectForIndex:self.selectedTextRange.location];
        if (self.caretView.superview == nil) {
            [self addSubview:self.caretView];
            [self setNeedsDisplay];
        }
        // Set up a timer to "blink" the caret.
//        [self.caretView delayBlink];
    }
    else {
        // If there is an actual selection, don't draw the insertion caret.
        [self.caretView removeFromSuperview];
        [self setNeedsDisplay];
    }

    if (self.markedTextRange.location != NSNotFound) {
        [self setNeedsDisplay];
    }
}
#pragma mark - Property accessor overrides
/*
 When setting the font, we need to additionally create and set the Core Text font object that corresponds to the UIFont being set.
 */
- (void)setFont:(UIFont *)newFont {
    if (newFont != _font) {
        _font = newFont;

        // Find matching CTFont via name and size.
        CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)_font.fontName, _font.pointSize, NULL);

        // Set CTFont instance in our attributes dictionary, to be set on our attributed string.
        self.attributes = @{ (NSString *)kCTFontAttributeName : (__bridge id)ctFont };

        CFRelease(ctFont);

        [self textChanged];
    }
}

/*
 We need to call textChanged after setting the new property text to update layout.
 */
- (void)setContentText:(NSString *)text {
    _contentText = [text copy];
    [self textChanged];
}

/*
 Set accessors should call selectionChanged to update view if necessary.
 */
- (void)setMarkedTextRange:(NSRange)range {
    if (!NSEqualRanges(range, _markedTextRange)) {
        _markedTextRange = range;
        [self selectionChanged];
    }
}

- (void)setSelectedTextRange:(NSRange)range {
    if (!NSEqualRanges(range, _selectedTextRange)) {
        _selectedTextRange = range;
        [self selectionChanged];
    }
}

- (void)setEditing:(BOOL)editing {
    if (_editing != editing) {
        _editing = editing;
        [self selectionChanged];
    }
}
#pragma mark - Selection and caret colors
// Class method that returns current selection color (in this sample the color cannot be changed).
+ (UIColor *)selectionColor {
    static UIColor *selectionColor = nil;
    if (selectionColor == nil) {
        selectionColor = [[UIColor alloc] initWithRed:0.25 green:0.50 blue:1.0 alpha:0.50];
    }
    return selectionColor;
}
@end
