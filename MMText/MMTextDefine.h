//
//  MMTextDefine.h
//  MMText
//
//  Created by janezhuang on 2023/2/21.
//

#ifndef MMTextDefine_h
#define MMTextDefine_h

#if defined(__cplusplus)
#define let auto const
#elif defined(__OBJC__)
#define let const __auto_type
#endif

#if defined(__cplusplus)
#define var auto
#elif defined(__OBJC__)
#define var __auto_type
#endif

#define weakify(VAR) __weak typeof(VAR) _weak_ = VAR;
#define strongify(VAR) __strong typeof(VAR) VAR = _weak_;

#endif /* MMTextDefine_h */
