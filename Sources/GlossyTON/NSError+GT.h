//
//  NSError+GT.h
//  
//
//  Created by Anton Spivak on 31.01.2022.
//

#import <Foundation/Foundation.h>
#import "GlossyTON.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSError (GT)

+ (NSError *)errorWithTONError:(tonlib_api::object_ptr<tonlib_api::error> &)error;
+ (NSError *)errorWithTONMessage:(NSString *)message;
+ (NSError *)errorWithCancelledMessage;

@end

NS_ASSUME_NONNULL_END
