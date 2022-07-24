//
//  ViewController.m
//  CustomTextInput
//
//  Created by janezhuang on 2022/7/22.
//

#import "ViewController.h"
#import "EditableCoreTextView.h"

@interface ViewController ()
@property (nonatomic) EditableCoreTextView *textView;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textView = [[EditableCoreTextView alloc] initWithFrame:CGRectMake(60, 120, 200, 200)];
    self.textView.backgroundColor = UIColor.lightGrayColor;
    [self.view addSubview:self.textView];
}
@end
