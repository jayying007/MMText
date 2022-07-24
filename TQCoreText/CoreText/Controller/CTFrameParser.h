//
//  CTFrameParser.h
//  TQCoreText
//
//  Created by janezhuang on 2022/7/9.
//

#import <Foundation/Foundation.h>
#import "CTFrameParserConfig.h"
#import "CoreTextData.h"

@interface CTFrameParser : NSObject

+ (NSMutableDictionary *)attributesWithConfig:(CTFrameParserConfig *)config;

+ (CoreTextData *)parseContent:(NSString *)content config:(CTFrameParserConfig*)config;
+ (CoreTextData *)parseAttributedContent:(NSAttributedString *)content config:(CTFrameParserConfig*)config;
+ (CoreTextData *)parseTemplateFile:(NSString *)path config:(CTFrameParserConfig*)config;

@end
