//
//  MMFileAttachmentView.m
//  MMTextView
//
//  Created by janezhuang on 2022/7/24.
//

#import "MMFileAttachmentView.h"

@interface MMFileAttachmentView ()
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *descLabel;
@end

@implementation MMFileAttachmentView
- (UIImageView *)imageView {
    if (_imageView == nil) {
        UIImage *image = [UIImage imageNamed:self.data.imageUrl];
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.layer.borderWidth = 1;
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = self.data.title;
        _titleLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)descLabel {
    if (_descLabel == nil) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.text = self.data.desc;
        _descLabel.font = [UIFont systemFontOfSize:14];
        _descLabel.textColor = UIColor.lightTextColor;
        [self addSubview:_descLabel];
    }
    return _descLabel;
}

- (void)layoutContentView {
    self.backgroundColor = UIColor.systemPinkColor;
    
    self.imageView.frame = CGRectMake(16, 4, 0, self.height - 8);
    self.imageView.width = self.imageView.height;
    
    [self.titleLabel sizeToFit];
    self.titleLabel.origin = CGPointMake(self.imageView.right + 16, 8);
    
    [self.descLabel sizeToFit];
    self.descLabel.origin = CGPointMake(self.titleLabel.left, self.titleLabel.bottom + 4);
}
@end
