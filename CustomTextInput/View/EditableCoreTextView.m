//
//  EditableCoreTextView.m
//  CustomTextInput
//
//  Created by janezhuang on 2022/7/23.
//

#import "EditableCoreTextView.h"
#import "CoreTextView.h"
#import "IndexedPosition.h"
#import "IndexedRange.h"

@interface EditableCoreTextView ()
@property (nonatomic) CoreTextView *textView;
@property (nonatomic) NSMutableString *text;
@end

@implementation EditableCoreTextView

@synthesize markedTextStyle = _markedTextStyle;
@synthesize inputDelegate = _inputDelegate;
@synthesize tokenizer = _tokenizer;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        // Add tap gesture recognizer to let the user enter editing mode.
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapGestureRecognizer];

        // Create our tokenizer and text storage.
        self.text = [[NSMutableString alloc] init];
        // Create and set up the APLSimpleCoreTextView that will do the drawing.
        CoreTextView *textView = [[CoreTextView alloc] initWithFrame:CGRectInset(self.bounds, 5, 5)];
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        textView.contentText = @"";
        textView.userInteractionEnabled = NO;
        [self addSubview:textView];
        self.textView = textView;
    }
    return self;
}
#pragma mark - Custom user interaction
/**
 UIResponder protocol override.
 Our view can become first responder to receive user text input.
 */
- (BOOL)canBecomeFirstResponder {
    return YES;
}

/**
 UIResponder protocol override.
 Called when our view is being asked to resign first responder state (in this sample by using the "Done" button).
 */
- (BOOL)resignFirstResponder {
    // Flag that underlying APLSimpleCoreTextView is no longer in edit mode
    self.textView.editing = NO;
    return [super resignFirstResponder];
}

/**
 Our tap gesture recognizer selector that enters editing mode, or if already in editing mode, updates the text insertion point.
 */
- (void)tap:(UITapGestureRecognizer *)tap {
    if ([self isFirstResponder]) {
        // Already in editing mode, set insertion point (via selectedTextRange).
        [self.inputDelegate selectionWillChange:self];

        // Find and update insertion point in underlying APLSimpleCoreTextView.
        NSInteger index = [self.textView closestIndexToPoint:[tap locationInView:self.textView]];
        self.textView.markedTextRange = NSMakeRange(NSNotFound, 0);
        self.textView.selectedTextRange = NSMakeRange(index, 0);

        // Let inputDelegate know selection has changed.
        [self.inputDelegate selectionDidChange:self];
    }
    else {
        // Flag that underlying APLSimpleCoreTextView is now in edit mode.
        self.textView.editing = YES;
        // Become first responder state (which shows software keyboard, if applicable).
        [self becomeFirstResponder];
    }
}
#pragma mark - UIKeyInput

/**
 UIKeyInput protocol required method.
 A Boolean value that indicates whether the text-entry objects have any text.
 */
- (BOOL)hasText {
    return (self.text.length != 0);
}

/**
 UIKeyInput protocol required method.
 Insert a character into the displayed text. Called by the text system when the user has entered simple text.
 */
- (void)insertText:(NSString *)text {
    NSRange selectedNSRange = _textView.selectedTextRange;
    NSRange markedTextRange = _textView.markedTextRange;
 
    if (markedTextRange.location != NSNotFound) {
        [_text replaceCharactersInRange:markedTextRange withString:text];
        selectedNSRange.location = markedTextRange.location + text.length;
        selectedNSRange.length = 0;
        markedTextRange = NSMakeRange(NSNotFound, 0);
    }
    else if (selectedNSRange.length > 0) {
        [_text replaceCharactersInRange:selectedNSRange withString:text];
        selectedNSRange.length = 0;
        selectedNSRange.location += text.length;
    }
    else {
        [_text insertString:text atIndex:selectedNSRange.location];
        selectedNSRange.location += text.length;
    }

    _textView.contentText = _text;
    _textView.markedTextRange = markedTextRange;
    _textView.selectedTextRange = selectedNSRange;
}

/**
 UIKeyInput protocol required method.
 Delete a character from the displayed text. Called by the text system when the user is invoking a delete (e.g. pressing the delete software keyboard key).
 */
- (void)deleteBackward {
    NSRange selectedNSRange = self.textView.selectedTextRange;
    NSRange markedTextRange = self.textView.markedTextRange;

    /*
     Note: While this sample does not provide a way for the user to create marked or selected text, the following code still checks for these ranges and acts accordingly.
     */
    if (markedTextRange.location != NSNotFound) {
        // There is marked text, so delete it.
        [self.text deleteCharactersInRange:markedTextRange];
        selectedNSRange.location = markedTextRange.location;
        selectedNSRange.length = 0;
        markedTextRange = NSMakeRange(NSNotFound, 0);
    }
    else if (selectedNSRange.length > 0) {
        // Delete the selected text.
        [self.text deleteCharactersInRange:selectedNSRange];
        selectedNSRange.length = 0;
    }
    else if (selectedNSRange.location > 0) {
        // Delete one char of text at the current insertion point.
        selectedNSRange.location--;
        selectedNSRange.length = 1;
        [self.text deleteCharactersInRange:selectedNSRange];
        selectedNSRange.length = 0;
    }

    // Update underlying APLSimpleCoreTextView.
    self.textView.contentText = self.text;
    self.textView.markedTextRange = markedTextRange;
    self.textView.selectedTextRange = selectedNSRange;
}
#pragma mark - UITextInput methods
#pragma mark UITextInput - Replacing and Returning Text
/**
 UITextInput protocol required method.
 Called by text system to get the string for a given range in the text storage.
 */
- (NSString *)textInRange:(UITextRange *)range {
    IndexedRange *r = (IndexedRange *)range;
    return [_text substringWithRange:r.range];
}
 
/**
 UITextInput protocol required method.
 Called by text system to replace the given text storage range with new text.
 */
- (void)replaceRange:(UITextRange *)range withText:(NSString *)text {
    IndexedRange *r = (IndexedRange *)range;
    NSRange selectedNSRange = _textView.selectedTextRange;
    if ((r.range.location + r.range.length) <= selectedNSRange.location) {
        selectedNSRange.location -= (r.range.length - text.length);
    } else {
        // Need to also deal with overlapping ranges.
    }
    [_text replaceCharactersInRange:r.range withString:text];
    
    _textView.contentText = _text;
    _textView.selectedTextRange = selectedNSRange;
}
#pragma mark UITextInput - Working with Marked and Selected Text
/**
 UITextInput selectedTextRange property accessor overrides (access/update underlaying APLSimpleCoreTextView)
 */
- (UITextRange *)selectedTextRange {
    return [IndexedRange rangeWithNSRange:self.textView.selectedTextRange];
}

- (void)setSelectedTextRange:(UITextRange *)range {
    IndexedRange *indexedRange = (IndexedRange *)range;
    self.textView.selectedTextRange = indexedRange.range;
}
/**
 UITextInput markedTextRange property accessor overrides (access/update underlaying APLSimpleCoreTextView).
 */
- (UITextRange *)markedTextRange {
    /*
     Return nil if there is no marked text.
     */
    NSRange markedTextRange = self.textView.markedTextRange;
    if (markedTextRange.length == 0) {
        return nil;
    }
    
    return [IndexedRange rangeWithNSRange:markedTextRange];
}

/**
 UITextInput protocol required method.
 Insert the provided text and marks it to indicate that it is part of an active input session.
 */
- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange {
    NSRange selectedNSRange = self.textView.selectedTextRange;
    NSRange markedTextRange = self.textView.markedTextRange;

    if (markedTextRange.location != NSNotFound) {
        if (!markedText) {
            markedText = @"";
        }
        // Replace characters in text storage and update markedText range length.
        [self.text replaceCharactersInRange:markedTextRange withString:markedText];
        markedTextRange.length = markedText.length;
    }
    else if (selectedNSRange.length > 0) {
        // There currently isn't a marked text range, but there is a selected range,
        // so replace text storage at selected range and update markedTextRange.
        [self.text replaceCharactersInRange:selectedNSRange withString:markedText];
        markedTextRange.location = selectedNSRange.location;
        markedTextRange.length = markedText.length;
    }
    else {
        // There currently isn't marked or selected text ranges, so just insert
        // given text into storage and update markedTextRange.
        [self.text insertString:markedText atIndex:selectedNSRange.location];
        markedTextRange.location = selectedNSRange.location;
        markedTextRange.length = markedText.length;
    }

    // Updated selected text range and underlying APLSimpleCoreTextView.
    selectedNSRange = NSMakeRange(selectedRange.location + markedTextRange.location, selectedRange.length);

    self.textView.contentText = self.text;
    self.textView.markedTextRange = markedTextRange;
    self.textView.selectedTextRange = selectedNSRange;
}

/**
 UITextInput protocol required method.
 Unmark the currently marked text.
 */
- (void)unmarkText {
    NSRange markedTextRange = self.textView.markedTextRange;
    if (markedTextRange.location == NSNotFound) {
        return;
    }
    // Unmark the underlying APLSimpleCoreTextView.markedTextRange.
    markedTextRange.location = NSNotFound;
    self.textView.markedTextRange = markedTextRange;
}
#pragma mark UITextInput - Computing Text Ranges and Text Positions
// UITextInput beginningOfDocument property accessor override.
- (UITextPosition *)beginningOfDocument {
    // For this sample, the document always starts at index 0 and is the full length of the text storage.
    return [IndexedPosition positionWithIndex:0];
}


// UITextInput endOfDocument property accessor override.
- (UITextPosition *)endOfDocument {
    // For this sample, the document always starts at index 0 and is the full length of the text storage.
    return [IndexedPosition positionWithIndex:self.text.length];
}


/*
 UITextInput protocol required method.
 Return the range between two text positions using our implementation of UITextRange.
 */
- (UITextRange *)textRangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition {
    // Generate IndexedPosition instances that wrap the to and from ranges.
    IndexedPosition *fromIndexedPosition = (IndexedPosition *)fromPosition;
    IndexedPosition *toIndexedPosition = (IndexedPosition *)toPosition;
    NSRange range = NSMakeRange(MIN(fromIndexedPosition.index, toIndexedPosition.index), ABS(toIndexedPosition.index - fromIndexedPosition.index));

    return [IndexedRange rangeWithNSRange:range];
}


/**
 UITextInput protocol required method.
 Returns the text position at a given offset from another text position using our implementation of UITextPosition.
 */
- (UITextPosition *)positionFromPosition:(UITextPosition *)position offset:(NSInteger)offset {
    // Generate IndexedPosition instance, and increment index by offset.
    IndexedPosition *indexedPosition = (IndexedPosition *)position;
    NSInteger end = indexedPosition.index + offset;
    // Verify position is valid in document.
    if (end > self.text.length || end < 0) {
        return nil;
    }

    return [IndexedPosition positionWithIndex:end];
}


/**
 UITextInput protocol required method.
 Returns the text position at a given offset in a specified direction from another text position using our implementation of UITextPosition.
 */
- (UITextPosition *)positionFromPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset {
    // Note that this sample assumes left-to-right text direction.
    IndexedPosition *indexedPosition = (IndexedPosition *)position;
    NSInteger newPosition = indexedPosition.index;

    switch ((NSInteger)direction) {
        case UITextLayoutDirectionRight:
            newPosition += offset;
            break;
        case UITextLayoutDirectionLeft:
            newPosition -= offset;
            break;
        UITextLayoutDirectionUp:
        UITextLayoutDirectionDown:
            // This sample does not support vertical text directions.
            break;
    }

    // Verify new position valid in document.
    if (newPosition < 0) {
        newPosition = 0;
    }
    if (newPosition > self.text.length) {
        newPosition = self.text.length;
    }

    return [IndexedPosition positionWithIndex:newPosition];
}
#pragma mark UITextInput - Evaluating Text Positions
/**
 UITextInput protocol required method.
 Return how one text position compares to another text position.
 */
- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other {
    IndexedPosition *indexedPosition = (IndexedPosition *)position;
    IndexedPosition *otherIndexedPosition = (IndexedPosition *)other;

    // For this sample, simply compare position index values.
    if (indexedPosition.index < otherIndexedPosition.index) {
        return NSOrderedAscending;
    }
    if (indexedPosition.index > otherIndexedPosition.index) {
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

/**
 UITextInput protocol required method.
 Return the number of visible characters between one text position and another text position.
 */
- (NSInteger)offsetFromPosition:(UITextPosition *)from toPosition:(UITextPosition *)toPosition {
    IndexedPosition *fromIndexedPosition = (IndexedPosition *)from;
    IndexedPosition *toIndexedPosition = (IndexedPosition *)toPosition;
    return (toIndexedPosition.index - fromIndexedPosition.index);
}
#pragma mark UITextInput - Text Layout, writing direction and position related methods
/**
 UITextInput protocol method.
 Return the text position that is at the farthest extent in a given layout direction within a range of text.
 */
- (UITextPosition *)positionWithinRange:(UITextRange *)range farthestInDirection:(UITextLayoutDirection)direction {
    // Note that this sample assumes left-to-right text direction.
    IndexedRange *indexedRange = (IndexedRange *)range;
    NSInteger position;

    /*
     For this sample, we just return the extent of the given range if the given direction is "forward" in a left-to-right context (UITextLayoutDirectionRight or UITextLayoutDirectionDown), otherwise we return just the range position.
     */
    switch (direction) {
        case UITextLayoutDirectionUp:
        case UITextLayoutDirectionLeft:
            position = indexedRange.range.location;
            break;
        case UITextLayoutDirectionRight:
        case UITextLayoutDirectionDown:
            position = indexedRange.range.location + indexedRange.range.length;
            break;
    }

    // Return text position using our UITextPosition implementation.
    // Note that position is not currently checked against document range.
    return [IndexedPosition positionWithIndex:position];
}

/**
 UITextInput protocol required method.
 Return a text range from a given text position to its farthest extent in a certain direction of layout.
 */
- (UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction {
    // Note that this sample assumes left-to-right text direction.
    IndexedPosition *pos = (IndexedPosition *)position;
    NSRange result;

    switch (direction) {
        case UITextLayoutDirectionUp:
        case UITextLayoutDirectionLeft:
            result = NSMakeRange(pos.index - 1, 1);
            break;
        case UITextLayoutDirectionRight:
        case UITextLayoutDirectionDown:
            result = NSMakeRange(pos.index, 1);
            break;
    }

    // Return range using our UITextRange implementation.
    // Note that range is not currently checked against document range.
    return [IndexedRange rangeWithNSRange:result];
}

/**
 UITextInput protocol required method.
 Return the base writing direction for a position in the text going in a specified text direction.
 */
- (NSWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction {
    // This sample assumes left-to-right text direction and does not support bi-directional or right-to-left text.
    return NSWritingDirectionLeftToRight;
}

/**
 UITextInput protocol required method.
 Set the base writing direction for a given range of text in a document.
 */
- (void)setBaseWritingDirection:(NSWritingDirection)writingDirection forRange:(UITextRange *)range {
    // This sample assumes left-to-right text direction and does not support bi-directional or right-to-left text.
}
#pragma mark UITextInput - Geometry methods
/**
 UITextInput protocol required method.
 Return the first rectangle that encloses a range of text in a document.
 */
- (CGRect)firstRectForRange:(UITextRange *)range {
    IndexedRange *r = (IndexedRange *)range;
    // Use underlying APLSimpleCoreTextView to get rect for range.
    CGRect rect = [self.textView firstRectForRange:r.range];
    // Convert rect to our view coordinates.
    return [self convertRect:rect fromView:self.textView];
}

/*
 UITextInput protocol required method.
 Return a rectangle used to draw the caret at a given insertion point.
 */
- (CGRect)caretRectForPosition:(UITextPosition *)position {
    IndexedPosition *pos = (IndexedPosition *)position;
    // Get caret rect from underlying APLSimpleCoreTextView.
    CGRect rect =  [self.textView caretRectForIndex:pos.index];
    // Convert rect to our view coordinates.
    return [self convertRect:rect fromView:self.textView];
}
#pragma mark UITextInput - Hit testing
/*
 UITextInput protocol required method.
 Return the position in a document that is closest to a specified point.
 */
- (UITextPosition *)closestPositionToPoint:(CGPoint)point {
    NSInteger index = [_textView closestIndexToPoint:point];
    return [IndexedPosition positionWithIndex:(NSUInteger)index];
}

/*
 UITextInput protocol required method.
 Return the position in a document that is closest to a specified point in a given range.
 */
- (UITextPosition *)closestPositionToPoint:(CGPoint)point withinRange:(UITextRange *)range {
    // Not implemented in this sample. Could utilize underlying APLSimpleCoreTextView:closestIndexToPoint:point.
    return nil;
}

/*
 UITextInput protocol required method.
 Return the character or range of characters that is at a given point in a document.
 */
- (UITextRange *)characterRangeAtPoint:(CGPoint)point {
    // Not implemented in this sample. Could utilize underlying APLSimpleCoreTextView:closestIndexToPoint:point.
    return nil;
}

/*
 UITextInput protocol required method.
 Return an array of UITextSelectionRects.
 */
- (NSArray *)selectionRectsForRange:(UITextRange *)range {
    // Not implemented in this sample.
    return nil;
}
@end
