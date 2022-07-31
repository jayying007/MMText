//
//  ExcludePathViewController.m
//  TextKitLayout
//
//  Created by janezhuang on 2022/7/30.
//

#import "ExcludePathViewController.h"

@interface ExcludePathViewController () {
    CGPoint originCenter;
}
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UITextView *textView;

@end

@implementation ExcludePathViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *text = @"庆历四年春，滕子京谪守巴陵郡。越明年，政通人和，百废具兴，乃重修岳阳楼，增其旧制，刻唐贤今人诗赋于其上，属予作文以记之。 予观夫巴陵胜状，在洞庭一湖。衔远山，吞长江，浩浩汤汤，横无际涯，朝晖夕阴，气象万千，此则岳阳楼之大观也，前人之述备矣。然则北通巫峡，南极潇湘，迁客骚人，多会于此，览物之情，得无异乎？若夫淫雨霏霏，连月不开，阴风怒号，浊浪排空，日星隐曜，山岳潜形，商旅不行，樯倾楫摧，薄暮冥冥，虎啸猿啼。登斯楼也，则有去国怀乡，忧谗畏讥，满目萧然，感极而悲者矣。至若春和景明，波澜不惊，上下天光，一碧万顷，沙鸥翔集，锦鳞游泳，岸芷汀兰，郁郁青青。而或长烟一空，皓月千里，浮光跃金，静影沉璧，渔歌互答，此乐何极！登斯楼也，则有心旷神怡，宠辱偕忘，把酒临风，其喜洋洋者矣。嗟夫！予尝求古仁人之心，或异二者之为，何哉？不以物喜，不以己悲，居庙堂之高则忧其民，处江湖之远则忧其君。是进亦忧，退亦忧。然则何时而乐耶？其必曰“先天下之忧而忧，后天下之乐而乐”乎！噫！微斯人，吾谁与归？时六年九月十五日。";

    // Do any additional setup after loading the view.
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.view.bounds.size];
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:text];
    [textStorage addLayoutManager:layoutManager];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds textContainer:textContainer];
    textView.font = [UIFont systemFontOfSize:18];
    textView.textColor = UIColor.blackColor;
    [self.view addSubview:textView];
    self.textView = textView;
    
    //==================================================
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(120, 240, 80, 80)];
    imageView.userInteractionEnabled = YES;
    UIGraphicsBeginImageContextWithOptions(imageView.frame.size, NO, 3);
    [UIColor.systemTealColor setFill];
    [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 80, 80)] fill];
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.view addSubview:imageView];
    self.imageView = imageView;

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [imageView addGestureRecognizer:panGesture];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.textView.textContainer.exclusionPaths = @[ [self translatedCirclePath] ];
}

- (void)handlePan:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        originCenter = self.imageView.center;
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint tanslation = [panGesture translationInView:self.textView];
        self.imageView.center = CGPointMake(originCenter.x + tanslation.x, originCenter.y + tanslation.y);
        
        self.textView.textContainer.exclusionPaths = @[ [self translatedCirclePath] ];
    }
}
- (UIBezierPath *)translatedCirclePath {
    CGPoint originInTextView = [self.textView convertPoint:self.imageView.frame.origin fromView:self.view];
    CGPoint originInContainer = CGPointMake(originInTextView.x - self.textView.textContainerInset.left, originInTextView.y - self.textView.textContainerInset.top);
    return [UIBezierPath bezierPathWithOvalInRect:CGRectMake(originInContainer.x, originInContainer.y, 80, 80)];
}
@end
