//
//  ViewController.m
//  MMTextView
//
//  Created by janezhuang on 2022/7/24.
//

#import "ViewController.h"
#import "MMTextView.h"
#import "MMTextAttachment.h"
#import "MMAttachmentData.h"
#import "UIView+Frame.h"

@interface ViewController ()
@property (nonatomic) MMTextView *textView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.lightGrayColor;
    // Do any additional setup after loading the view.
    self.textView = [[MMTextView alloc] initWithFrame:CGRectMake(0, 120, self.view.width, 360)];
    self.textView.font = [UIFont systemFontOfSize:20];
    self.textView.spellCheckingType = UITextSpellCheckingTypeNo;
    [self.view addSubview:self.textView];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"Add File" style:UIBarButtonItemStylePlain target:self action:@selector(addFile)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Add Image" style:UIBarButtonItemStylePlain target:self action:@selector(addImage)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)addFile {
    MMTextAttachment *textAttachment = [[MMTextAttachment alloc] initWithType:AttachmentType_File contentSize:CGSizeMake(self.textView.width, 60)];
    textAttachment.placeholderText = @"[文件]";
    MMAttachmentData *data = [[MMAttachmentData alloc] init];
    data.imageUrl = @"mainA";
    data.title = @"朽木·露琪亚";
    data.desc = @"六番队队长朽木白哉的妹妹";
    textAttachment.data = data;
    
    [self.textView insertAttachment:textAttachment];
}

- (void)addImage {
    MMTextAttachment *textAttachment = [[MMTextAttachment alloc] initWithType:AttachmentType_Image contentSize:CGSizeMake(120, 120)];
    textAttachment.placeholderText = @"[图片]";
    MMAttachmentData *data = [[MMAttachmentData alloc] init];
    data.imageUrl = @"dog";
    textAttachment.data = data;
    
    [self.textView insertAttachment:textAttachment];
}
@end
