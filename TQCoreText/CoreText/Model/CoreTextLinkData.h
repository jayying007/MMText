//
//  CoreTextLinkData.h
//  TQCoreText
//
//  Created by janezhuang on 2022/7/10.
//

#import <Foundation/Foundation.h>

@interface CoreTextLinkData : NSObject

@property (strong, nonatomic) NSString * title;
@property (strong, nonatomic) NSString * url;
@property (assign, nonatomic) NSRange range;

@end
