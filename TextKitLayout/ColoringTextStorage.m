//
//  ColoringTextStorage.m
//  TextKitLayout
//
//  Created by janezhuang on 2022/8/4.
//

#import "ColoringTextStorage.h"

@interface ColoringTextStorage () {
    NSMutableAttributedString *_backingStore;
    BOOL _dynamicTextNeedsUpdate;
}

@end

@implementation ColoringTextStorage
- (instancetype)init {
    self = [super init];
    if (self) {
        _backingStore = [[NSMutableAttributedString alloc] init];
    }
    return self;
}

- (NSString *)string {
    return [_backingStore string];
}

- (NSDictionary<NSAttributedStringKey,id> *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range {
    return [_backingStore attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    [_backingStore replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters|NSTextStorageEditedAttributes range:range changeInLength:str.length - range.length];
    _dynamicTextNeedsUpdate = YES;
}

- (void)setAttributes:(NSDictionary<NSAttributedStringKey,id> *)attrs range:(NSRange)range {
    [_backingStore setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (void)processEditing {
    if (_dynamicTextNeedsUpdate) {
        _dynamicTextNeedsUpdate = NO;
        [self performReplacementsForCharacterChangeInRange:[self editedRange]];
    }
    [super processEditing];
}

- (void)performReplacementsForCharacterChangeInRange:(NSRange)changedRange {
    NSRange extendedRange = NSUnionRange(changedRange, [[_backingStore string] lineRangeForRange:NSMakeRange(changedRange.location, 0)]);
    extendedRange = NSUnionRange(changedRange, [[_backingStore string] lineRangeForRange:NSMakeRange(NSMaxRange(changedRange), 0)]);
    
    [self applyTokenAttributesToRange:extendedRange];
}

- (void)applyTokenAttributesToRange:(NSRange)searchRange {
    NSDictionary *defaultAttributes = [self.tokens objectForKey:@"defaultTokenName"];
    
    [[_backingStore string] enumerateSubstringsInRange:searchRange options:NSStringEnumerationByWords usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        NSDictionary *attributesForToken = [self.tokens objectForKey:substring];
        if (!attributesForToken) {
            attributesForToken = defaultAttributes;
        }
        
        if (attributesForToken) {
            [self addAttributes:attributesForToken range:substringRange];
        }
    }];
}
@end
