//
// Dixie
// Copyright 2015 Skyscanner Limited
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
// You may obtain a copy of the License at:
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and limitations under the License.

#import <XCTest/XCTest.h>
#import "DixieRunTimeHelper.h"
#import "TestClass.h"

@interface DixieRunTimeHelper(UnitTest)
+(NSArray*) argumentsFor:(NSMethodSignature*)signature originalArguments:(va_list)arguments;
+(id) objectFromNext:(va_list)arguments type:(const char*)argType outputArgumentList:(out void *)oVa_List;
+(id) blockForSignature:(NSMethodSignature*)signature block:(DixieImplementationBlock)block;
@end

@interface RunTimeHelperTests : XCTestCase

@end

@implementation RunTimeHelperTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCorrectImplementationCalled
{
    //Given
    DixieMethodInfo* info = [DixieMethodInfo infoWithClass:[TestClass class] selector:@selector(returnValue)];
    DixieChaosContext* context = [[DixieChaosContext alloc] init:0 methodInfo:info];
    
    //When
    __block BOOL isIMPCalled = NO;
    id(*implementation)(id,SEL)  = (id(*)(id,SEL))[DixieRunTimeHelper implementationWithChaosContext:context environment:^(id victim, DixieCallEnvironment *environment) {
        isIMPCalled = YES;
    }];
    
    implementation([TestClass new], @selector(returnValue));
                      
    XCTAssert(isIMPCalled, @"Correct IMP should be returned");
}

-(void)testImplementationIsCalled
{
    //Given
    DixieMethodInfo* info = [DixieMethodInfo infoWithClass:[TestClass class] selector:@selector(returnValue)];
    DixieChaosContext* context = [[DixieChaosContext alloc] init:0 methodInfo:info];
    DixieCallEnvironment* environment = [DixieCallEnvironment new];
    IMP implementation = [[TestClass new] methodForSelector:@selector(returnValue)];
    
    //When
    [DixieRunTimeHelper callImplementation:implementation on:[TestClass new] chaosContext:context environment:environment];
    
    //Then
    XCTAssert([(NSNumber *)environment.returnValue isEqualToNumber:@2], @"IMP should be called correctly");
}

-(void)testClassVoidImplementationIsCalled
{
    //Given
    DixieMethodInfo* info = [DixieMethodInfo infoWithClass:[TestClass class] selector:@selector(classDoNothing)];
    DixieChaosContext* context = [[DixieChaosContext alloc] init:0 methodInfo:info];
    DixieCallEnvironment* environment = [DixieCallEnvironment new];
    IMP implementation = [[TestClass class] methodForSelector:@selector(classDoNothing)];
    
    //When
    @try {
        [DixieRunTimeHelper callImplementation:implementation on:[TestClass class] chaosContext:context environment:environment];
    }
    @catch (NSException *exception) {
        
        //Then
        XCTFail(@"Class void implementation should be called");
    }
}

- (void)testValuesCorrectlyConverted {
    
    //Given - Hack to create va_list
    id(^testBlock)(const char*, ...) = ^id(const char* encoding, ...){
        
        va_list arguments;
        va_start(arguments, encoding);
        
        id object = [DixieRunTimeHelper objectFromNext:arguments type:encoding outputArgumentList:arguments];
        
        va_end(arguments);
        
        return object;
        
    };
    
    XCTAssert([testBlock(@encode(char),'c') isEqualToNumber:@('c')], @"%c converted wrongly", 'c');
    XCTAssert([testBlock(@encode(int),2) isEqualToNumber:@2], @"%d converted wrongly", 2);
    XCTAssert([testBlock(@encode(BOOL),YES) isEqualToNumber:@YES], @"%d converted wrongly", YES);
    XCTAssert([testBlock(@encode(long),12345678L) isEqualToNumber:@12345678L], @"%ld converted wrongly", 12345678L);
    XCTAssert([testBlock(@encode(float), 4.5f) isEqualToNumber:@4.5f], @"%f converted wrongly", 4.5f);
    XCTAssert([testBlock(@encode(double),5.0) isEqualToNumber:@5.0], @"%lf converted wrongly", 5.0);
    XCTAssert([testBlock(@encode(char*),"temp") isEqualToString:@"temp"], @"%s converted wrongly", "temp");
    XCTAssert([testBlock(@encode(Class),[NSNumber class]) isEqualToString:@"NSNumber"], @"%@ converted wrongly", [NSNumber class]);
    XCTAssert([testBlock(@encode(SEL),@selector(testValuesCorrectlyConverted)) isEqualToString:@"testValuesCorrectlyConverted"], @"%@ converted wrongly", NSStringFromSelector(@selector(testValuesCorrectlyConverted)));
    
}

//Structs are currently not supported, so DixieRunTimeHelper will fail and adds an NSNull into the arguments array
-(void) testArgumentObjectsCreatedCorrectly
{
    //Given - Hack to create va_list
    ^(NSString* first, ...){
        
        NSArray* expectedValues = @[
                                    @('c'),
                                    [NSNull null]
                                    ];
        
        va_list arguments;
        va_start(arguments, first);
        
        NSMethodSignature* signature = [[TestClass new] methodSignatureForSelector:@selector(setChar:frame:)];
        
        //When
        NSArray* values = [DixieRunTimeHelper argumentsFor:signature originalArguments:arguments];
        
        va_end(arguments);
        
        //Then
        XCTAssert([expectedValues isEqualToArray:values], @"Values should be corrected into objects");
        
    }(@"Input value:",'c', CGRectMake(0, 0, 0, 0));
}

-(void) testArgumentObjectsCretedCorrectlyForBlock
{
    //Given
    NSMethodSignature* signature = [[TestClass new] methodSignatureForSelector:@selector(setNumber:object:block:)];
    
    //When
    void(^block)(id,...) = [DixieRunTimeHelper blockForSignature:signature block:^(id victim, DixieCallEnvironment *environment) {
    
        //Then
        XCTAssert([environment.arguments[0] intValue] == 2, @"First parameter should be an int");
        XCTAssert([environment.arguments[1] isEqualToNumber:@2], @"Second parameter should be an int");
        BOOL(^thirdParameter)(void) = environment.arguments[2];
        XCTAssert(thirdParameter(), @"Third parameter should be a block");
    }];
    
    //For blocks, do NOT send the selector
    block([TestClass new],2,@2,[^{return YES;} copy]);
}

-(void) testVoidBlockReturned
{
    //Given
    NSMethodSignature* signature = [[TestClass new] methodSignatureForSelector:@selector(doNothing)];
    
    //When
    void(^block)(id,...) = [DixieRunTimeHelper blockForSignature:signature block:^(id victim, DixieCallEnvironment *environment) {}];

    //Then
    @try {
        block([TestClass new], @selector(doNothing));
    }
    @catch (NSException *exception) {
        XCTFail(@"Correct void block should be returned");
    }
}

-(void) testIdReturnBlockReturned
{
    //Given
    NSMethodSignature* signature = [[TestClass new] methodSignatureForSelector:@selector(returnValue)];
    
    //When
    id(^block)(id, ...) = [DixieRunTimeHelper blockForSignature:signature block:^(id victim, DixieCallEnvironment *environment) {
        environment.returnValue = (__bridge void *)(@2);
    }];
    
    //Then
    @try {
        id returnValue = block([TestClass new], @selector(returnValue));
        
        XCTAssert([returnValue isEqualToNumber:@2], @"Correct id value should be returned");
    }
    @catch (NSException *exception) {
        XCTFail(@"Correct void block should be returned");
    }
}

-(void) testIntReturnBlockReturned
{
    //Given
    NSMethodSignature* signature = [[TestClass new] methodSignatureForSelector:@selector(returnIntValue)];
    
    //When
    int intValue = 11;
    int(^block)(id, ...) = [DixieRunTimeHelper blockForSignature:signature block:^(id victim, DixieCallEnvironment *environment) {
        environment.returnValue = (void *)&intValue;
    }];
    
    //Then
    @try {
        int returnValue = block([TestClass new], @selector(returnValue));
        
        XCTAssert(returnValue == 11, @"Correct int value should be returned");
    }
    @catch (NSException *exception) {
        XCTFail(@"Correct void block should be returned");
    }
}

-(void) testCorrectSelectorsReturnedForClass
{
    //Given
    Class testClass = [TestClass class];
    NSArray* expectedSelector = @[
                                  NSStringFromSelector(@selector(doNothing)),
                                  NSStringFromSelector(@selector(returnValue)),
                                  NSStringFromSelector(@selector(setChar:frame:))
                                  ];
    
    //When
    NSArray* selectors = [DixieRunTimeHelper selectorsForClass:testClass];
    
    //Then
    for (id selectorString in expectedSelector) {
        XCTAssert([selectors containsObject:selectorString], @"Selectors should contain: %@", selectorString);
    }
}

-(void) testMethodStructIsReturned
{
    //Given
    DixieMethodInfo* info = [DixieMethodInfo infoWithClass:[TestClass class] selector:@selector(returnValue)];
    
    //When
    Method m = [DixieRunTimeHelper methodForMethodInfo:info];
    
    //Then
    XCTAssert(m != NULL, @"Method returned");
}

-(void) testCorrectMethodTypeEncodingReturned
{
    //Given
    DixieMethodInfo* info = [DixieMethodInfo infoWithClass:[TestClass class] selector:@selector(returnValue)];
    
    //When
    const char* encoding = [DixieRunTimeHelper methodTypeEncodingForMethodInfo:info];
    
    //Then
    XCTAssert(strcmp(encoding, "@@:") , @"Correct method type encoding should be returned");
}

-(void) testClassMethodIsDifferent
{
    //Given
    DixieMethodInfo* classInfo = [DixieMethodInfo infoWithClass:[NSURL class] selector:@selector(URLWithString:)];
    DixieMethodInfo* instanceInfo = [DixieMethodInfo infoWithClass:[NSURL class] selector:@selector(initWithURL:)];
    
    //When
    Class returnedClass = [DixieRunTimeHelper classForMethodInfo:classInfo];
    Class returnedInstanceClass = [DixieRunTimeHelper classForMethodInfo:instanceInfo];
    
    //Then
    XCTAssert(returnedClass != returnedInstanceClass, @"Class method should have different target class");
}

@end
