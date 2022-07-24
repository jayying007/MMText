//
//  CoreTextImageData.h
//  TQCoreText
//
//  Created by janezhuang on 2022/7/10.
//

#import <Foundation/Foundation.h>

@interface CoreTextImageData : NSObject

@property (strong, nonatomic) NSString * name;
@property (nonatomic) int position;

// 此坐标是 CoreText 的坐标系，而不是UIKit的坐标系
@property (nonatomic) CGRect imagePosition;

@end

