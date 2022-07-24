//
//  ViewController.m
//  TextMask
//
//  Created by janezhuang on 2022/7/16.
//

#import "ViewController.h"
#import <CoreText/CoreText.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.lightGrayColor;
    // Do any additional setup after loading the view.
    UIImage *image = [UIImage imageNamed:@"main.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = self.view.bounds;
    imageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imageView];
    
    CAShapeLayer *shapeLayer = [self generateShapeLayerWithText:@"Jayying" width:320];
    shapeLayer.borderWidth = 1;
    shapeLayer.frame = CGRectMake(0, 0, 320, 320);
    shapeLayer.position = imageView.center;
    imageView.layer.mask = shapeLayer;
}

- (CTFontRef)getFontWithSize:(CGFloat)fontSize {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:@"STHeitiSC-Light" forKey:(id)kCTFontFamilyNameAttribute];
    [attributes setObject:@(fontSize) forKey:(id)kCTFontSizeAttribute];
    
    CTFontDescriptorRef fontDescriptor = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attributes);
    CTFontRef font = CTFontCreateWithFontDescriptor(fontDescriptor, 0, NULL);
    return font;
}
// 可以尝试CTTypesetterSuggestLineBreak
- (CGFloat)bestFontSizeToFitText:(NSString *)text width:(CGFloat)width {
    CFIndex count = text.length;
    UniChar characters[count];
    CGGlyph glyphs[count];
    [text getCharacters:characters];
    
    CGFloat fontSize = 10;
    while (true) {
        CTFontRef font = [self getFontWithSize:fontSize];
        //字符转字形，注意这里假设了字符与字形是一对一的，而实际情况有可能不是这样。
        CTFontGetGlyphsForCharacters(font, characters, glyphs, count);
        //获取每个字形的宽度
        CGSize advances[count];
        CTFontGetAdvancesForGlyphs(font, kCTFontOrientationDefault, glyphs, advances, count);
        //这里只是演示，实际可以在循环中跳出、用二分等方式进行优化
        CGFloat glyphsWidth = 0;
        for (int i = 0; i < count; i++) {
            glyphsWidth += advances[i].width;
        }
        
        if (glyphsWidth > width) {
            break;
        }
        fontSize++;
    }
    
    return fontSize;
}

- (CAShapeLayer *)generateShapeLayerWithText:(NSString *)text width:(CGFloat)width {
    CGFloat fontSize = [self bestFontSizeToFitText:text width:width];
    CTFontRef font = [self getFontWithSize:fontSize];
    //字符转字形，注意这里假设了字符与字形是一对一的，而实际情况有可能不是这样。
    CFIndex count = text.length;
    UniChar characters[count];
    CGGlyph glyphs[count];
    [text getCharacters:characters];
    CTFontGetGlyphsForCharacters(font, characters, glyphs, count);
    
    CGMutablePathRef composePath = CGPathCreateMutable();
    //获取每个字形的宽度
    CGSize advances[count];
    CTFontGetAdvancesForGlyphs(font, kCTFontOrientationDefault, glyphs, advances, count);
    //核心排版步骤
    CGFloat offsetX = 0;
    CGFloat ascent = CTFontGetAscent(font);
    for (int i = 0; i < count; i++) {
        CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformIdentity, offsetX, ascent);
        transform = CGAffineTransformScale(transform, 1, -1);
        
        CGPathRef path = CTFontCreatePathForGlyph(font, glyphs[i], &transform);
        CGPathAddPath(composePath, NULL, path);
        
        offsetX += advances[i].width;
    }
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.path = composePath;
    return shapeLayer;
}
@end
