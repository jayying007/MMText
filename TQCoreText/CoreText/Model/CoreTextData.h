//
//  CoreTextData.h
//  TQCoreText
//
//  Created by janezhuang on 2022/7/9.
//

#import <Foundation/Foundation.h>

@interface CoreTextData : NSObject

@property (assign, nonatomic) CTFrameRef ctFrame;
@property (assign, nonatomic) CGFloat height;
@property (strong, nonatomic) NSAttributedString *content;

@property (strong, nonatomic) NSArray * imageArray;
@property (strong, nonatomic) NSArray * linkArray;
@end

