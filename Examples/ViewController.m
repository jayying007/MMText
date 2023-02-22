//
//  ViewController.m
//  Examples
//
//  Created by janezhuang on 2023/2/22.
//

#import "ViewController.h"
#import <MMText/MMText.h>

@interface ViewController ()
@property (nonatomic) MMTextAnimationLabel *textEffectLabel;
@property (nonatomic) NSArray *textArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.grayColor;
    // Do any additional setup after loading the view.
    _textArray = @[
        @"What is design?",
        @"Design Code By Swift",
        @"Design is not just",
        @"what it looks like",
        @"and feels like.",
        @"Hello,Swift",
        @"is how it works.",
        @"- Steve Jobs",
        @"Older people",
        @"sit down and ask,",
        @"'What is it?'",
        @"but the boy asks,",
        @"'What can I do with it?'.",
        @"- Steve Jobs",
        @"Swift",
        @"Objective-C",
        @"iPhone", @"iPad", @"Mac Mini",
        @"MacBook Pro", @"Mac Pro"
    ];
    
    _textEffectLabel = [[MMTextAnimationLabel alloc] initWithFrame:CGRectMake(0, 240, self.view.bounds.size.width, 120)];
    _textEffectLabel.font = [UIFont systemFontOfSize:36];
    _textEffectLabel.numberOfLines = 4;
    _textEffectLabel.textAlignment = NSTextAlignmentCenter;
    _textEffectLabel.text = @"Hello World";
    _textEffectLabel.textColor = UIColor.whiteColor;
    [self.view addSubview:_textEffectLabel];
    
    
    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        uint32_t index = arc4random_uniform((uint32_t)self.textArray.count);
        self.textEffectLabel.text = self.textArray[index];
    }];
}


@end
