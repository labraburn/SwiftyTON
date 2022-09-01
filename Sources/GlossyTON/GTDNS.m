//
//  GTDNS.m
//  
//
//  Created by Anton Spivak on 09.07.2022.
//

#import "GTDNS.h"

#pragma mark - GTDNSEntryText

@implementation GTDNSEntryText

- (instancetype)initWithText:(NSString *)text
{
    self = [super init];
    if (self) {
        _text = [text copy];
    }
    return self;
}

@end

#pragma mark - GTDNSEntrySMCAddress

@implementation GTDNSEntrySMCAddress

- (instancetype)initWithAddress:(NSString *)address
{
    self = [super init];
    if (self) {
        _address = [address copy];
    }
    return self;
}

@end

#pragma mark - GTDNSEntryNextResolver

@implementation GTDNSEntryNextResolver

- (instancetype)initWithAddress:(NSString *)address
{
    self = [super init];
    if (self) {
        _address = [address copy];
    }
    return self;
}

@end

#pragma mark - GTDNS

@implementation GTDNS

- (instancetype)initWithName:(NSString *)name
                     entries:(NSArray<GTDNSEntry> *)entries
{
    self = [super init];
    if (self) {
        _name = [name copy];
        _entries = [entries copy];
    }
    return self;
}

@end
