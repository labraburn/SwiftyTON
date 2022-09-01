//
//  GTPreparedQuery.m
//  
//
//  Created by Anton Spivak on 17.02.2022.
//

#import "GTPreparedQuery.h"

@implementation GTPreparedQuery

- (instancetype)initWithQueryID:(int64_t)queryID
         validUntilTimeInterval:(int64_t)validUntilTimeInterval
                           body:(NSData *)body
                       bodyHash:(NSData *)bodyHash
{
    self = [super init];
    if (self != nil) {
        _queryID = queryID;
        _validUntilTimeInterval = validUntilTimeInterval;
        _body = [body copy];
        _bodyHash = [bodyHash copy];
    }
    return self;
}

@end
