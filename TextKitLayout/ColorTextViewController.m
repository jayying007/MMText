//
//  LineBreakViewController.m
//  TextKitLayout
//
//  Created by janezhuang on 2022/8/3.
//

#import "ColorTextViewController.h"
#import "ColoringTextStorage.h"

@interface ColorTextViewController ()

@end

@implementation ColorTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(self.view.bounds.size.width, CGFLOAT_MAX)];

    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    ColoringTextStorage *textStorage = [[ColoringTextStorage alloc] init];
    
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds textContainer:textContainer];
    textView.textContainerInset = UIEdgeInsetsMake(88, 8, 44, 8);
    [self.view addSubview:textView];
    
    textStorage.tokens = @{
        @"Alice" : @{ NSForegroundColorAttributeName : UIColor.redColor},
        @"Rabbit" : @{ NSForegroundColorAttributeName : UIColor.orangeColor},
        @"defaultTokenName": @{ NSForegroundColorAttributeName : UIColor.blackColor }
    };
    
    [textStorage beginEditing];
    NSString *text = @"The all-new MacBook Air, Alice by the Apple M2 chip. Learn more and Alice now. Buy eligible Mac or iPad with education Rabbit and get an Apple Gift Card. Terms apply. Chat for shopping help。Free shipping or pickup。";
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:text attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:18] }];
    [textStorage setAttributedString:attrString];
    [textStorage endEditing];
}
@end
