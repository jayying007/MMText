//
//  ViewController.m
//  ColumnarLayout
//
//  Created by janezhuang on 2022/7/17.
//

#import "ViewController.h"
#import "ColumnView.h"
#import "ColumnViewV2.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ColumnView *columnView = [[ColumnView alloc] initWithFrame:CGRectMake(0, 160, self.view.bounds.size.width, 160)];
    columnView.backgroundColor = UIColor.lightGrayColor;
    columnView.attributedString = [[NSAttributedString alloc] initWithString:@"Hello, World! I know nothing in the world that has as much power as a word. Sometimes I write one, and I look at it, until it begins to shine." attributes:@{
        NSFontAttributeName : [UIFont systemFontOfSize:18],
        NSForegroundColorAttributeName : UIColor.redColor,
    }];
    [self.view addSubview:columnView];
    
    ColumnViewV2 *columnView2 = [[ColumnViewV2 alloc] initWithFrame:CGRectMake(0, 400, self.view.bounds.size.width, 160)];
    columnView2.backgroundColor = UIColor.lightGrayColor;
    columnView2.attributedString = [[NSAttributedString alloc] initWithString:@"Hello, World! I know nothing in the world that has as much power as a word. Sometimes I write one, and I look at it, until it begins to shine." attributes:@{
        NSFontAttributeName : [UIFont systemFontOfSize:18],
        NSForegroundColorAttributeName : UIColor.redColor,
    }];
    [self.view addSubview:columnView2];
}

@end
