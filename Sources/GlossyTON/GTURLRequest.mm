//
//  GTURLRequest.m
//  
//
//  Created by Anton Spivak on 31.01.2022.
//

#import "GTURLRequest.h"

@implementation GTURLRequest

- (instancetype)initWithData:(NSData *)data
              didFinishBlock:(GTURLRequestDidFinishBlock)didFinishBlock
{
    self = [super init];
    if (self != nil) {
        _data = data;
        _didFinishBlock = [didFinishBlock copy];
    }
}

@end
