//
//  HTTPRequest.m
//  mClass
//
//  Created by 김규완 on 10. 11. 30..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HTTPRequest.h"
#import "AlertUtils.h"
#import "Constant.h"
#import "Utils.h"
#import "URLConnectionWithTag.h"
#import "JSON.h"

@implementation HTTPRequest

@synthesize receiveData;
@synthesize response;
@synthesize result;
@synthesize target;
@synthesize selector;
@synthesize selectorData;

- (BOOL)requestUrl:(NSString *)url bodyObject:(NSDictionary *)bodyObject httpMethod:(NSString *)httpMethod connectionDelegate:(id)aTarget withTag:(NSString *)tag
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //tag땜에 추가--------------
    if (receiveData == nil) {//receiveData는 여러개의 데이타를 Key로 구분해서 담는 데이타이므로 한번만 초기화
        receiveData = [[NSMutableDictionary alloc] init];
    }
    
    if (tag == nil) {
        tag = @"default";
    }
    //------------------------
    
	//URLRequest 객체 생성
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:5.0f];
	//통신방식 정의 (POST, GET)
	[request setHTTPMethod:httpMethod];
	//bodyObject의 객체가 존재할 경우 QueryString형태로 변환
	if(bodyObject){
		//임시변수
		NSMutableArray *parts = [NSMutableArray array];
		NSString *part;
		id key;
		id value;
		
		//값을 하나하나 변환
		for (key in bodyObject) {
			value = [bodyObject objectForKey:key];
			part = [NSString stringWithFormat:@"%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
					[value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			[parts addObject:part];
		}
		
		//값들을 &로 연결하여 Body사용
		[request setHTTPBody:[[parts componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	//Request를 이용하여 실제 연결을 시도하는 NSURLConnection 인스턴스 생성
	//NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:request delegate:aTarget] autorelease];
    URLConnectionWithTag *connection = [[URLConnectionWithTag alloc] initWithRequest:request delegate:aTarget startImmediately:YES tag:tag];
    
	//정상적으로 연결되었으면
	if (connection) {
        
        urlConnection = connection;
        
		//데이터를 전송받을 멤버 변수 초기회
		//receiveData = [NSMutableData data];
        //tag와 함께 사용하기 위해서 
        [receiveData setObject:[[NSMutableData data] retain] forKey:connection.tag];
		return YES;
	}
	
	return NO;
}

- (BOOL)requestUrl:(NSString *)url bodyObject:(NSDictionary *)bodyObject httpMethod:(NSString *)httpMethod withTag:(NSString *)tag
{
    return [self requestUrl:url bodyObject:bodyObject httpMethod:httpMethod connectionDelegate:self withTag:tag];
}


- (NSData *)requestUrlSync:(NSString *)url bodyObject:(NSDictionary *)bodyObject httpMethod:(NSString *)httpMethod error:(NSError *)error response:(NSHTTPURLResponse *)httpResponse {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //URLRequest 객체 생성
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:10.0f];
	//통신방식 정의 (POST, GET)
	[request setHTTPMethod:httpMethod];
	//bodyObject의 객체가 존재할 경우 QueryString형태로 변환
	if(bodyObject){
		//임시변수
		NSMutableArray *parts = [NSMutableArray array];
		NSString *part;
		id key;
		id value;
		
		//값을 하나하나 변환
		for (key in bodyObject) {
			value = [bodyObject objectForKey:key];
			part = [NSString stringWithFormat:@"%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
					[value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			[parts addObject:part];
		}
		
		//값들을 &로 연결하여 Body사용
		[request setHTTPBody:[[parts componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding]];
	}
    
    //NSError* error = nil;
    //response 객체
	//NSHTTPURLResponse* httpResponse = nil;

    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&error];
    
    //오류 공지
	if (error != nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"에러!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"취소" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	//상태코드
	NSInteger state = [httpResponse statusCode];
	//콘텐츠타입
	//NSString *contentType = [[httpResponse allHeaderFields] objectForKey:@"Content-Type"];
	//NSLog(@"contentType = %@", contentType);
    
	//상태코드와 콘텐츠종류를 파악
	if (state >= 200 && state < 300) {
        //정상

    } else {
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"에러!" message:[NSString stringWithFormat:@"http state %d", state] delegate:nil cancelButtonTitle:@"취소" otherButtonTitles:nil];
		[alert show];
		[alert release];
        */
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    return responseData;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
	//데이터를 전송받기전에 호출되는 메서드, 우선 Response의 헤더만을 먼저 받아온다.
	//[receiveData setLength:0];
	self.response = aResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	//데이터를 전송받는 도중에 호출되는 메소드, 여러번에 나누어 호출될 수 있으므로 appendData를 사용한다.
	//[receiveData appendData:data];원래는 이건데 withTag때문에 NSDictionary로 변경되어서 
    //tag로 분리해서 데이타 받는다
    [[receiveData objectForKey:[(URLConnectionWithTag *)connection tag]] appendData:data];
    //NSLog(@"======data : %@", data);
    //NSLog(@"======receiveData : %@", receiveData);
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    urlConnection = nil;
	//에러가 발생하였을 경우 호출되는 메소드
	NSLog(@"Error: %@", [error localizedDescription]);
	AlertWithError(error);
}

- (void)cancel {
    if (urlConnection) {
        [urlConnection cancel];
        //target = nil;
        [self setDelegate:nil selector:nil];
        urlConnection = nil;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString *tag = (NSString *)[(URLConnectionWithTag *)connection tag];
    NSData *dataWithTag = [receiveData objectForKey:tag];
    
	//데이터 전송이 끝났을 때 호출되는 메서드, 전송받은 데이터를 NSString형태로 변환한다.
	//result = [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding];
    result = [[NSString alloc] initWithData:dataWithTag encoding:NSUTF8StringEncoding];
    
    if([tag isEqualToString:@"default"]){//기본 tag 즉 한번만 실행된 거면 그냥 NSString으로 반환
        if (target) {
            [target performSelector:selector withObject:result];
        }
    } else {//아니고 여러번 데이타 호출이면 (tag가 여러개이면) NSDictionary로 반환
        //NSDictionary *resultData = [[[NSDictionary alloc] initWithObjectsAndKeys:tag, @"tag", result, @"result", nil] autorelease];
        
        NSString *resultString = [NSString stringWithFormat:@"{\"resultData\":{\"tag\":\"%@\",\"result\":%@}}",tag, result];
        //NSString *resultString = [NSString stringWithFormat:@"{\"resultData\":{\"tag\":\"%@\",%@}}",tag, result];
        //SBJsonParser *jsonParser = [SBJsonParser new];
        
        //델리게이트가 설정되어 있다면 실행한다
        if (target) {
            //[target performSelector:selector withObject:resultData];
            [target performSelector:selector withObject:resultString];
        }
    }
    
    
    [connection release];
    urlConnection = nil;
    
}

- (void)setDelegate:(id)aTarget selector:(SEL)aSelector
{
	//데이터 수신이 완료된 후에 호출될 메서드의 정보를 담고 있는 셀렉터 설정
	self.target = aTarget;
	self.selector = aSelector;
}


- (void)dealloc
{
	[receiveData release];
	[response release];
	[result release];
	[super dealloc];
}

@end
