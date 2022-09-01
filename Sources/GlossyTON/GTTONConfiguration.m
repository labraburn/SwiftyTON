//
//  GTTONConfiguration.m
//  
//
//  Created by Anton Spivak on 31.01.2022.
//

#import "GTTONConfiguration.h"

@implementation GTTONConfiguration

- (instancetype)initWithNetworkName:(NSString *)networkName
                         JSONString:(NSString *)JSONString
                        keystoreURL:(NSURL *)keystoreURL
                            logging:(GTTONConfigurationLogging)logging
{
    self = [super init];
    if (self != nil) {
        _networkName = [networkName copy];
        _JSONString = [JSONString copy];
        _keystoreURL = [keystoreURL copy];
        _logging = logging;
    }
    return self;
}

@end
