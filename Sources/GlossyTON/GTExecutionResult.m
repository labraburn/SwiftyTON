//
//  GTExecutionResult.m
//  
//
//  Created by Anton Spivak on 16.02.2022.
//

#import "GTExecutionResult.h"

@implementation GTExecutionResult

- (instancetype)initWithCode:(int32_t)code
                       stack:(NSArray<GTExecutionStackValue> *)stack
{
    self = [super init];
    if (self != nil) {
        _code = code;
        _stack = [stack copy];
    }
    return self;
}

@end

@implementation GTExecutionResultDecimal

- (instancetype)initWithValue:(NSString *)value
{
    self = [super init];
    if (self != nil) {
        _value = [value copy];
    }
    return self;
}

@end

@implementation GTExecutionResultSlice

- (instancetype)initWithHEX:(NSData *)hex;
{
    self = [super init];
    if (self != nil) {
        _hex = [hex copy];
    }
    return self;
}

@end

@implementation GTExecutionResultCell

- (instancetype)initWithHEX:(NSData *)hex;
{
    self = [super init];
    if (self != nil) {
        _hex = [hex copy];
    }
    return self;
}

@end

@implementation GTExecutionResultEnumeration

- (instancetype)initWithEnumeration:(NSArray<GTExecutionStackValue> *)enumeration
{
    self = [super init];
    if (self != nil) {
        _enumeration = [enumeration copy];
    }
    return self;
}

@end
