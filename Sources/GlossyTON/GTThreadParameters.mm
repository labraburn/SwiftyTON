//
//  GTThreadParameters.m
//  
//
//  Created by Anton Spivak on 31.01.2022.
//

#import "GTThreadParameters.h"

@implementation GTThreadParameters

- (instancetype)initWithClient:(std::shared_ptr<tonlib::Client>)client
                       handler:(GTThreadParametersReceiveHandler)handler
{
    self = [super init];
    if (self != nil) {
        _client = client;
        _handler = [handler copy];
    }
    return self;
}

@end
