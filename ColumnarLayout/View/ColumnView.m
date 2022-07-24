//
//  ColumnView.m
//  ColumnarLayout
//
//  Created by janezhuang on 2022/7/17.
//

#import "ColumnView.h"
#import <CoreText/CoreText.h>

@implementation ColumnView

// Create a path in the shape of a donut.
static void AddSquashedDonutPath(CGMutablePathRef path, const CGAffineTransform *m, CGRect rect) {
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
 
    CGFloat radiusH = width / 3.0;
    CGFloat radiusV = height / 3.0;
 
    CGPathMoveToPoint(path, m, rect.origin.x, rect.origin.y + height - radiusV);
    CGPathAddQuadCurveToPoint(path, m, rect.origin.x, rect.origin.y + height,
                               rect.origin.x + radiusH, rect.origin.y + height);
    CGPathAddLineToPoint(path, m, rect.origin.x + width - radiusH,
                               rect.origin.y + height);
    CGPathAddQuadCurveToPoint(path, m, rect.origin.x + width,
                               rect.origin.y + height,
                               rect.origin.x + width,
                               rect.origin.y + height - radiusV);
    CGPathAddLineToPoint(path, m, rect.origin.x + width,
                               rect.origin.y + radiusV);
    CGPathAddQuadCurveToPoint(path, m, rect.origin.x + width, rect.origin.y,
                               rect.origin.x + width - radiusH, rect.origin.y);
    CGPathAddLineToPoint(path, m, rect.origin.x + radiusH, rect.origin.y);
    CGPathAddQuadCurveToPoint(path, m, rect.origin.x, rect.origin.y,
                               rect.origin.x, rect.origin.y + radiusV);
    CGPathCloseSubpath(path);
 
    CGPathAddEllipseInRect(path, m,
                            CGRectMake( rect.origin.x + width / 2.0 - width / 5.0,
                            rect.origin.y + height / 2.0 - height / 5.0,
                            width / 5.0 * 2.0, height / 5.0 * 2.0));
}

- (CFArrayRef)createColumnsWithColumnCount:(int)columnCount {
    int column;
 
    CGRect columnRects[columnCount];
    // Set the first column to cover the entire view.
    columnRects[0] = self.bounds;
 
    // Divide the columns equally across the frame's width.
    CGFloat columnWidth = CGRectGetWidth(self.bounds) / columnCount;
    for (column = 0; column < columnCount - 1; column++) {
        CGRectDivide(columnRects[column], &columnRects[column],
                     &columnRects[column + 1], columnWidth, CGRectMinXEdge);
    }
 
   // Inset all columns by a few pixels of margin.
    for (column = 0; column < columnCount; column++) {
        columnRects[column] = CGRectInset(columnRects[column], 8.0, 15.0);
    }
 
    // Create an array of layout paths, one for each column.
    CFMutableArrayRef array =
                     CFArrayCreateMutable(kCFAllocatorDefault,
                                  columnCount, &kCFTypeArrayCallBacks);
 
    for (column = 0; column < columnCount; column++) {
        CGMutablePathRef path = CGPathCreateMutable();
        //第一列用个不规则图形
        if (column == 0) {
            AddSquashedDonutPath(path, NULL, columnRects[column]);
        } else {
            CGPathAddRect(path, NULL, columnRects[column]);
        }
        CFArrayInsertValueAtIndex(array, column, path);
        CFRelease(path);
    }

    return array;
}

- (void)drawRect:(CGRect)rect {
    // Initialize a graphics context in iOS.
    CGContextRef context = UIGraphicsGetCurrentContext();
 
    // Flip the context coordinates in iOS only.
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
 
    // Set the text matrix.
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
 
    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(
                                      (CFAttributedStringRef)self.attributedString);
 
    // Call createColumnsWithColumnCount function to create an array of
    // three paths (columns).
    CFArrayRef columnPaths = [self createColumnsWithColumnCount:3];
 
    CFIndex pathCount = CFArrayGetCount(columnPaths);
    CFIndex startIndex = 0;
    int column;
 
    // Create a frame for each column (path).
    for (column = 0; column < pathCount; column++) {
        // Get the path for this column.
        CGPathRef path = (CGPathRef)CFArrayGetValueAtIndex(columnPaths, column);
 
        // Create a frame for this column and draw it.
        CTFrameRef frame = CTFramesetterCreateFrame(
                             framesetter, CFRangeMake(startIndex, 0), path, NULL);
        CTFrameDraw(frame, context);
 
        // Start the next frame at the first character not visible in this frame.
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        startIndex += frameRange.length;
        CFRelease(frame);
        
        //绘制分割线
        if (column > 0) {
            CGRect boundingBox = CGPathGetPathBoundingBox(path);
            
            CGContextSetStrokeColorWithColor(context, UIColor.blueColor.CGColor);
            CGContextSetLineWidth(context, 2);
            CGFloat length = 4;
            CGContextSetLineDash(context, 1, &length, 1);
            
            CGMutablePathRef linePath = CGPathCreateMutable();
            CGPathMoveToPoint(linePath, NULL, boundingBox.origin.x - 8, boundingBox.origin.y);
            CGPathAddLineToPoint(linePath, NULL, boundingBox.origin.x - 8, boundingBox.origin.y + boundingBox.size.height);
            CGContextAddPath(context, linePath);
            CGContextStrokePath(context);
        }
    }
    CFRelease(columnPaths);
    CFRelease(framesetter);
}

@end
