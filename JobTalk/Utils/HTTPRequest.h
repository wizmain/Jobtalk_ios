//
//  HTTPRequest.h
//  mClass
//
//  Created by 김규완 on 10. 11. 30..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface HTTPRequest : NSObject {
	NSURLResponse *response;
	NSString *result;
	id target;
	SEL selector;
    //NSMutableData *receiveData;
    NSMutableDictionary *selectorData;
    NSMutableDictionary *receiveData;//withTag때문에 NSMutableData를 NSMutableDictionary로 변경
    NSURLConnection *urlConnection;
}

- (BOOL)requestUrl:(NSString *)url bodyObject:(NSDictionary *)bodyObject httpMethod:(NSString *)httpMethod connectionDelegate:(id)aTarget withTag:(NSString *)tag;
- (BOOL)requestUrl:(NSString *)url bodyObject:(NSDictionary *)bodyObject httpMethod:(NSString *)httpMethod withTag:(NSString *)tag;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)setDelegate:(id)aTarget selector:(SEL)aSelector;
- (NSData *)requestUrlSync:(NSString *)url bodyObject:(NSDictionary *)bodyObject httpMethod:(NSString *)httpMethod error:(NSError *)error response:(NSHTTPURLResponse *)httpResponse;
- (void)cancel;

@property (nonatomic, retain) NSMutableDictionary *receiveData;
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, retain) NSString *result;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, retain) NSMutableDictionary *selectorData;

@end
