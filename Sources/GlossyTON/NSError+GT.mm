//
//  NSError+GT.m
//  
//
//  Created by Anton Spivak on 31.01.2022.
//

#import "NSError+GT.h"

@implementation NSError (GT)

+ (NSError *)errorWithTONError:(tonlib_api::object_ptr<tonlib_api::error> &)error {
    NSString *description = [[NSString alloc] initWithUTF8String:error->message_.c_str()];
    return [self errorWithTONMessage:description];
}

+ (NSError *)errorWithTONMessage:(NSString *)message {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey : message
    };
    return [NSError errorWithDomain:GTTONErrorDomain code:0 userInfo:userInfo];
}

+ (NSError *)errorWithCancelledMessage {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey : @"CANCELLED"
    };
    return [NSError errorWithDomain:GTTONErrorDomain code:GTTONErrorCodeCancelled userInfo:userInfo];
}

@end
