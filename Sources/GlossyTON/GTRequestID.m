//
//  GTRequestID.m
//  
//
//  Created by Anton Spivak on 01.04.2022.
//

#import "GTRequestID.h"

@interface GTRequestID ()

@property (nonatomic, strong, readonly) NSNumber *number;

@end

@implementation GTRequestID

- (instancetype)initWithNumber:(NSNumber *)number {
    self = [super init];
    if (self != nil) {
        _number = number;
    }
    return self;
}

@end
