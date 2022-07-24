//
//  CaretView.m
//  CustomTextInput
//
//  Created by janezhuang on 2022/7/23.
//

#import "CaretView.h"

static const NSTimeInterval InitialBlinkDelay = 0.7;
static const NSTimeInterval BlinkRate = 0.5;

@interface CaretView ()
@property (nonatomic) NSTimer *blinkTimer;
@end

@implementation CaretView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [CaretView caretColor];
    }
    return self;
}

- (void)dealloc {
    [_blinkTimer invalidate];
}

// Helper method to toggle hidden state of caret view.
- (void)blink {
    self.hidden = !self.hidden;
}

// UIView didMoveToSuperview override to set up blink timers after caret view created in superview.
- (void)didMoveToSuperview {
    self.hidden = NO;

    if (self.superview) {
        self.blinkTimer = [NSTimer scheduledTimerWithTimeInterval:BlinkRate target:self selector:@selector(blink) userInfo:nil repeats:YES];
        [self delayBlink];
    }
    else {
        [self.blinkTimer invalidate];
        self.blinkTimer = nil;
    }
}

// Helper method to set an initial blink delay
- (void)delayBlink {
    self.hidden = NO;
    [self.blinkTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:InitialBlinkDelay]];
}

// Class method that returns current caret color (in this sample the color cannot be changed).
+ (UIColor *)caretColor {
    static UIColor *caretColor = nil;
    if (caretColor == nil) {
        caretColor = [[UIColor alloc] initWithRed:0.25 green:0.50 blue:1.0 alpha:1.0];
    }
    return caretColor;
}
@end
