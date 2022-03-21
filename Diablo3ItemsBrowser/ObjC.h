//
//  ObjC.h
//  Diablo3ItemsBrowser
//
//  Created by Коптев Олег Станиславович on 21.03.2022.
//

#ifndef ObjC_h
#define ObjC_h

#import <Foundation/Foundation.h>

@interface ObjC : NSObject

+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error;

@end

#endif /* ObjC_h */
