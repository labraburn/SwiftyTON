//
//  GTPreparedQuery.h
//  
//
//  Created by Anton Spivak on 17.02.2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTPreparedQuery : NSObject

@property (nonatomic, assign, readonly) int64_t queryID;
@property (nonatomic, assign, readonly) int64_t validUntilTimeInterval;

@property (nonatomic, copy, readonly) NSData *body;
@property (nonatomic, copy, readonly) NSData *bodyHash;

- (instancetype)initWithQueryID:(int64_t)queryID
         validUntilTimeInterval:(int64_t)validUntilTimeInterval
                           body:(NSData *)body
                       bodyHash:(NSData *)bodyHash;

@end

NS_ASSUME_NONNULL_END
