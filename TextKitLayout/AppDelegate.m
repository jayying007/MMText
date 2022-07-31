//
//  AppDelegate.m
//  TextKitLayout
//
//  Created by janezhuang on 2022/7/30.
//

#import "AppDelegate.h"
#import "CircleTextViewController.h"
#import "ExcludePathViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize window = _window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"CircleText" image:[UIImage systemImageNamed:@"link"] tag:0];
    CircleTextViewController *vc1 = [[CircleTextViewController alloc] init];
    vc1.tabBarItem = item1;
    
    UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"ExcludePath" image:[UIImage systemImageNamed:@"link"] tag:0];
    ExcludePathViewController *vc2 = [[ExcludePathViewController alloc] init];
    vc2.tabBarItem = item2;
    
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [tabBarController setViewControllers:@[ vc1, vc2 ]];
    [tabBarController setSelectedIndex:0];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}



@end
