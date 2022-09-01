//
//  GlossyTON.m
//  
//
//  Created by Anton Spivak on 31.01.2022.
//

#import "GlossyTON.h"
#import "GTTransaction.h"
#import "GTEncryptedData.h"

using tonlib_api::make_object;

std::string GTStringWithData(NSData * _Nonnull data) {
    if (data == nil || data.length == 0) {
        return std::string();
    } else {
        return std::string((const char *)data.bytes, ((const char *)data.bytes) + data.length);
    }
}

NSData * _Nonnull GTDataWithString(std::string & string) {
    if (string.size() == 0) {
        return [NSData data];
    } else {
        return [[NSData alloc] initWithBytes:string.data() length:string.size()];
    }
}

td::SecureString GTSecureStringWithData(NSData * _Nonnull data) {
    if (data == nil || data.length == 0) {
        return td::SecureString();
    } else {
        return td::SecureString((const char *)data.bytes, (size_t)data.length);
    }
}

NSString * _Nullable GTReadStringWithString(std::string & string) {
    if (string.size() == 0) {
        return @"";
    } else {
        return [[NSString alloc] initWithBytes:string.data() length:string.size() encoding:NSUTF8StringEncoding];
    }
}

NSData * _Nullable GTReadSecureStringWithString(td::SecureString & string) {
    if (string.size() == 0) {
        return [NSData data];
    } else {
        return [[NSData alloc] initWithBytes:string.data() length:string.size()];
    }
}

NSData * _Nullable GTDecryptedDataWithEncryptedData(tonlib::Client & client, NSData * _Nonnull encryptedData, NSData * _Nonnull secret) {
    auto query = make_object<tonlib_api::decrypt>(GTSecureStringWithData(encryptedData), GTSecureStringWithData(secret));
    tonlib_api::object_ptr<tonlib_api::Object> result = client.execute({
        INT16_MAX + 1, std::move(query)
    }).object;
    
    if (result->get_id() == tonlib_api::error::ID) {
        return nil;
    } else {
        tonlib_api::object_ptr<tonlib_api::data> value = tonlib_api::move_object_as<tonlib_api::data>(result);
        return GTReadSecureStringWithString(value->bytes_);
    }
}

NSData * _Nonnull GTEncryptedDataWithData(tonlib::Client & client, NSData * _Nonnull data, NSData * _Nonnull secret) {
    auto query = make_object<tonlib_api::encrypt>(GTSecureStringWithData(data), GTSecureStringWithData(secret));
    
    tonlib_api::object_ptr<tonlib_api::Object> result = client.execute({
        INT16_MAX + 1, std::move(query)
    }).object;
    
    tonlib_api::object_ptr<tonlib_api::data> value = tonlib_api::move_object_as<tonlib_api::data>(result);
    return GTReadSecureStringWithString(value->bytes_);
}

GTTransactionMessage * _Nullable GTTransactionMessageCreate(tonlib_api::object_ptr<tonlib_api::raw_message> &message) {
    if (message == nullptr) {
        return nil;
    }
    
    NSString *source = GTReadStringWithString(message->source_->account_address_);
    NSString *destination = GTReadStringWithString(message->destination_->account_address_);
    
    id<GTTransactionMessageContents> contents = nil;
    if (message->msg_data_->get_id() == tonlib_api::msg_dataRaw::ID) {
        auto msgData = tonlib_api::move_object_as<tonlib_api::msg_dataRaw>(message->msg_data_);
        contents = [[GTTransactionMessageContentsRawData alloc] initWithData:GTDataWithString(msgData->body_)];
    } else if (message->msg_data_->get_id() == tonlib_api::msg_dataText::ID) {
        auto msgData = tonlib_api::move_object_as<tonlib_api::msg_dataText>(message->msg_data_);
        NSString *text = GTReadStringWithString(msgData->text_);
        if (text == nil) {
            contents = [[GTTransactionMessageContentsPlainText alloc] initWithText:@""];
        } else {
            contents = [[GTTransactionMessageContentsPlainText alloc] initWithText:text];
        }
    } else if (message->msg_data_->get_id() == tonlib_api::msg_dataDecryptedText::ID) {
        auto msgData = tonlib_api::move_object_as<tonlib_api::msg_dataDecryptedText>(message->msg_data_);
        NSString *text = GTReadStringWithString(msgData->text_);
        if (text == nil) {
            contents = [[GTTransactionMessageContentsPlainText alloc] initWithText:@""];
        } else {
            contents = [[GTTransactionMessageContentsPlainText alloc] initWithText:text];
        }
    } else if (message->msg_data_->get_id() == tonlib_api::msg_dataEncryptedText::ID) {
        auto msgData = tonlib_api::move_object_as<tonlib_api::msg_dataEncryptedText>(message->msg_data_);
        GTEncryptedData *encryptedData = [[GTEncryptedData alloc] initWithSourceAccountAddress:source
                                                                                          data:GTDataWithString(msgData->text_)];
        contents = [[GTTransactionMessageContentsEncryptedText alloc] initWithEncryptedData:encryptedData];
    } else {
        contents = [[GTTransactionMessageContentsRawData alloc] initWithData:[NSData data]];
    }
    
    if (source == nil || destination == nil) {
        return nil;
    }
    
    return [[GTTransactionMessage alloc] initWithValue:message->value_
                                                fwdFee:message->fwd_fee_
                                                ihrFee:message->ihr_fee_
                                                source:source
                                           destination:destination
                                              contents:contents
                                              bodyHash:GTDataWithString(message->body_hash_)];
}
