//
//  TextAnimationLabel.m
//  MMText
//
//  Created by janezhuang on 2023/2/21.
//

#import "MMTextAnimationLabel.h"
#import "MMTextDefine.h"
#import "MMTextLayerAnimation.h"

@interface MMTextAnimationLabel () <NSLayoutManagerDelegate>
@end

@implementation MMTextAnimationLabel {
    NSTextStorage *m_textStorage;
    NSLayoutManager *m_textLayoutManager;
    NSTextContainer *m_textContainer;
    
    NSMutableArray *m_oldCharacterTextLayers;
    NSMutableArray *m_newCharacterTextLayers;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        m_textStorage = [[NSTextStorage alloc] initWithString:@""];
        
        m_textContainer = [[NSTextContainer alloc] initWithSize:self.bounds.size];
        m_textContainer.maximumNumberOfLines = self.numberOfLines;
        m_textContainer.lineBreakMode = self.lineBreakMode;
        
        m_textLayoutManager = [[NSLayoutManager alloc] init];
        m_textLayoutManager.delegate = self;
        [m_textStorage addLayoutManager:m_textLayoutManager];
        [m_textLayoutManager addTextContainer:m_textContainer];
        
        m_oldCharacterTextLayers = [NSMutableArray array];
        m_newCharacterTextLayers = [NSMutableArray array];
    }
    return self;
}
#pragma mark - Override
- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    [super setLineBreakMode:lineBreakMode];
    m_textContainer.lineBreakMode = lineBreakMode;
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    [super setNumberOfLines:numberOfLines];
    m_textContainer.maximumNumberOfLines = numberOfLines;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    m_textContainer.size = bounds.size;
}

- (void)setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];
    [self setText:m_textStorage.string];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    
    let attributedText = [self internalAttributedTextWithString:text];
    self.attributedText = attributedText;
}

- (NSAttributedString *)attributedText {
    return m_textStorage;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [m_textStorage setAttributedString:attributedText];
    
    [self animateTextLayers];
}
#pragma mark - Private
- (void)animateTextLayers {
    // animate hide old character
    for (CATextLayer *textLayer in m_oldCharacterTextLayers) {
        let duration = (arc4random() % 100) / 120.0 + 0.3;
        let delay = arc4random_uniform(100) / 500;
        let distance = arc4random() % 50 + 30;
        let angle = arc4random() / M_PI_2 - M_PI_4;

        var transform = CATransform3DMakeTranslation(0, distance, 0);
        transform = CATransform3DRotate(transform, angle, 0, 0, 1);

        [MMTextLayerAnimation animateWithLayer:textLayer duration:duration delay:delay animations:^(CATextLayer * _Nonnull layer) {
            layer.transform = transform;
            layer.opacity = 0.0;
        } completion:^(BOOL finished) {
            [textLayer removeFromSuperlayer];
        }];
    }
    // animate show new character
    for (CATextLayer *textLayer in m_newCharacterTextLayers) {
        let duration = arc4random() % 200 / 100.0 + 0.3;
        let delay = 0.1;
        
        [MMTextLayerAnimation animateWithLayer:textLayer duration:duration delay:delay animations:^(CATextLayer * _Nonnull layer) {
            layer.opacity = 1.0;
        } completion:nil];
    }
}

- (void)updateCharacterTextLayers {
    [self resetOldCharacterTextLayers];
    [m_newCharacterTextLayers removeAllObjects];

    let wordRange = NSMakeRange(0, m_textStorage.string.length);
    let attributedString = [self internalAttributedTextWithString:m_textStorage.string];
    let layoutRect = [m_textLayoutManager usedRectForTextContainer:m_textContainer];
    var index = wordRange.location;
    let totalLength = NSMaxRange(wordRange);
    while (index < totalLength) {
        let glyphRange = NSMakeRange(index, 1);
        let characterRange = [m_textLayoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:nil];
        let textContainer = [m_textLayoutManager textContainerForGlyphAtIndex:index effectiveRange:nil];
        var glyphRect = [m_textLayoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
        
        let kerningRange = [m_textLayoutManager rangeOfNominallySpacedGlyphsContainingIndex:index];
        if (kerningRange.location == index && kerningRange.length > 1) {
            if (m_newCharacterTextLayers.count > 0) {
                // 如果前一个textlayer的frame.size.width不变大的话，当前的textLayer会遮挡住字体的一部分，比如“You”的Y右上角会被切掉一部分
                let previousLayer = (CATextLayer *)m_newCharacterTextLayers[m_newCharacterTextLayers.count - 1];
                var frame = previousLayer.frame;
                frame.size.width += CGRectGetMaxX(glyphRect) - CGRectGetMaxX(frame);
                previousLayer.frame = frame;
            }
        }
        
        //中间垂直
        glyphRect.origin.y += (self.bounds.size.height / 2) - (layoutRect.size.height / 2);
        
        let textLayer = [[CATextLayer alloc] init];
        textLayer.frame = glyphRect;
        textLayer.string = [attributedString attributedSubstringFromRange:characterRange];
        textLayer.opacity = 0;
        [self.layer addSublayer:textLayer];
        [m_newCharacterTextLayers addObject:textLayer];
        
        index += characterRange.length;
    }
}

- (NSMutableAttributedString *)internalAttributedTextWithString:(NSString *)str {
    if (str == nil) {
        return nil;
    }

    let wordRange = NSMakeRange(0, str.length);
    let attributedText = [[NSMutableAttributedString alloc] initWithString:str];
    let paragraphyStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphyStyle.alignment = self.textAlignment;
    
    [attributedText setAttributes:@{ NSForegroundColorAttributeName : self.textColor,
                                     NSFontAttributeName : self.font,
                                     NSParagraphStyleAttributeName : paragraphyStyle } range:wordRange];
    return attributedText;
}

- (void)resetOldCharacterTextLayers {
    // ensure the old textLayer is remove.
    for (CATextLayer *textLayer in m_oldCharacterTextLayers) {
        [textLayer removeFromSuperlayer];
    }
    m_oldCharacterTextLayers = [m_newCharacterTextLayers copy];
}
#pragma mark - NSLayoutMangerDelegate
- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag {
    [self updateCharacterTextLayers];
}
@end
