//
//  MMImageAttachmentView.m
//  MMTextView
//
//  Created by janezhuang on 2022/7/24.
//

#import "MMImageAttachmentView.h"

@interface MMImageAttachmentView ()
@property (nonatomic) UIImageView *imageView;
@end

@implementation MMImageAttachmentView
- (UIImageView *)imageView {
    if (_imageView == nil) {
        UIImage *image = [UIImage imageNamed:self.data.imageUrl];
        _imageView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (void)layoutContentView {
    self.imageView.frame = self.bounds;
}
@end
