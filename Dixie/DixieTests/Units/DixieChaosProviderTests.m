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

#import "DixieHeaders.h"
#import "ChaosProviderTestClass.h"

@interface DixieChaosProviderTests : XCTestCase
{
    Dixie* dixie;
}
@end

@implementation DixieChaosProviderTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    dixie = [Dixie new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [dixie revert];
    
    [super tearDown];
}

#pragma mark - Nil
-(void) testFluentNilChaosProvider
{
    DixieProfileEntry* profile = [DixieProfileEntry entry:[ChaosProviderTestClass class] selector:@selector(returnValue) chaosProvider:[DixieNilChaosProvider new]];
    
    dixie
        .Profile(profile)
        .Apply();
    
    id value = [[ChaosProviderTestClass new] returnValue];
    XCTAssert( value == nil , "Value should be nil");
}

#pragma mark - Non
-(void) testNonChaosProvider
{
    DixieProfileEntry* profile = [DixieProfileEntry entry:[ChaosProviderTestClass class] selector:@selector(returnValue) chaosProvider:[DixieNonChaosProvider new]];
    
    dixie
        .Profile(profile)
        .Apply();
    
    id value = [[ChaosProviderTestClass new] returnValue];
    XCTAssert([value isEqualToNumber:@2], "ChaosProviderTestClass should be kept unchanged");
}

-(void) testForwardChaosToNonChaosProvider
{
    DixieProfileEntry* profile = [DixieProfileEntry entry:[ChaosProviderTestClass class] selector:@selector(returnValue) chaosProvider:[DixieBlockChaosProvider block:^(DixieBaseChaosProvider *chaosProvider, id victim, DixieCallEnvironment *environment) {
        
        [chaosProvider forwardChaosOf:victim environment:environment to:[DixieNonChaosProvider new]];
        
    }]];
    
    dixie
        .Profile(profile)
        .Apply();
    
    NSDate* date = [NSDate date];
    XCTAssert(date, "NSDate should be kept unchanged");
}

#pragma mark - Constant
-(void) testConstantChaosProvider
{
    DixieProfileEntry* profile = [DixieProfileEntry entry:[ChaosProviderTestClass class] selector:@selector(returnValue) chaosProvider:[DixieConstantChaosProvider constant:@7]];
    
    dixie
        .Profile(profile)
        .Apply();
    
    id value = [[ChaosProviderTestClass new] returnValue];
    XCTAssert( [value isEqualToNumber:@7] , "Number should be 7");
}

#pragma mark - Composite
-(void) testCompositeChaosProvider
{
    DixieCompositeCondition* condition = [DixieCompositeCondition condition:0 value:@2 chaosProvider:[DixieNilChaosProvider new]];
    DixieCompositeChaosProvider* provider = [DixieCompositeChaosProvider conditions:@[condition]];
    DixieProfileEntry* profile = [DixieProfileEntry entry:[ChaosProviderTestClass class] selector:@selector(numberFromInteger:) chaosProvider:provider];
    
    dixie
        .Profile(profile)
        .Apply();
    
    id value = [[ChaosProviderTestClass new] numberFromInteger:2];
    
    XCTAssert(value == nil, "Value should be nil");
    
    value = [[ChaosProviderTestClass new] numberFromInteger:8];
    
    XCTAssert([value isEqualToNumber:@8], "Value should be created");
}

#pragma mark - Block
-(void) testBlockChaosProvider
{
    DixieBlockChaosProvider* provider = [DixieBlockChaosProvider block:^(DixieBaseChaosProvider* provider, id victim, DixieCallEnvironment *environment) {
        
        NSNumber* param = [environment.arguments firstObject];
        
        environment.returnValue = @(param.integerValue + 1);
        
    }];
    
    DixieProfileEntry* profile = [DixieProfileEntry entry:[ChaosProviderTestClass class] selector:@selector(numberFromInteger:) chaosProvider:provider];

    dixie
        .Profile(profile)
        .Apply();
    
    id value = [[ChaosProviderTestClass new] numberFromInteger:2];
    
    XCTAssert([value isEqualToNumber:@3] , "Value should be incremented");
}

#pragma mark - Random
-(void) testRandomIntChaosProvider
{
    DixieProfileEntry* profile = [DixieProfileEntry entry:[ChaosProviderTestClass class]
                                       selector:@selector(returnValue)
                                  chaosProvider:[DixieRandomChaosProvider randomProvider:[DixieRandomParamProvider providerWithUpperBound:100]]];
    
    dixie
        .Profile(profile)
        .Apply();

    id returnValue = [[ChaosProviderTestClass new] returnValue];
    id returnValue2 = [[ChaosProviderTestClass new] returnValue];
    
    XCTAssert(![returnValue isEqualToNumber:returnValue2], "Values should be random");
}

#pragma mark - Exception
-(void) testExceptionChaosProvider
{
    DixieProfileEntry* profile = [DixieProfileEntry entry:[ChaosProviderTestClass class]
                                       selector:@selector(returnValue)
                                  chaosProvider:[DixieExceptionChaosProvider exception:[NSException exceptionWithName:@"ChaosProviderException"
                                                                                                          reason:@"ExceptionChaosProvider was applied"
                                                                                                        userInfo:nil]]];
    dixie
        .Profile(profile)
        .Apply();
    
    XCTAssertThrowsSpecificNamed([[ChaosProviderTestClass new] returnValue], NSException, @"ChaosProviderException", @"Should throw a NSException");
}

#pragma mark - Sequential
-(void) testSequentalChaosProvider
{
    //GIVEN
    DixieProfileEntry* profile = [DixieProfileEntry entry:[ChaosProviderTestClass class]
                                                 selector:@selector(returnValue)
                                            chaosProvider:[DixieSequentialChaosProvider sequence:@[ [DixieNilChaosProvider new] , [DixieConstantChaosProvider constant:@2]]]];
    
    dixie
        .Profile(profile)
        .Apply();
    
    //WHEN
    id returnValue = [[ChaosProviderTestClass new] returnValue];
    id returnValue2 = [[ChaosProviderTestClass new] returnValue];
    
    //THEN
    XCTAssert(returnValue == nil && [returnValue2 isEqual:@2], @"Sequential should return nil for the first call and @2 for the second call");
}

-(void) testSequentialReturnsLastAtOutOfBounds
{
    //GIVEN
    DixieProfileEntry* profile = [DixieProfileEntry entry:[ChaosProviderTestClass class]
                                       selector:@selector(returnValue)
                                  chaosProvider:[DixieSequentialChaosProvider sequence:@[ [DixieNilChaosProvider new] , [DixieConstantChaosProvider constant:@2]]]];
    
    dixie
        .Profile(profile)
        .Apply();
    
    //WHEN
    [[ChaosProviderTestClass new] returnValue];
    [[ChaosProviderTestClass new] returnValue];
    id returnValue = [[ChaosProviderTestClass new] returnValue];

    //THEN
    XCTAssert([returnValue isEqual:@2], @"Sequential should return the result of the last chaos provider, when called more then the count of the defined providers");
}

#pragma mark - Variadic
-(void) testChaosForwardedToVariadic
{
    //GIVEN
    DixieBlockChaosProvider* blockProvider = [DixieBlockChaosProvider block:^(DixieBaseChaosProvider *chaosProvider, id victim, DixieCallEnvironment *environment) {
       
        [chaosProvider forwardChaosOf:victim environment:environment to:[DixieNonChaosProvider new]];
    }];
    
    DixieProfileEntry* entry = [DixieProfileEntry entry:[ChaosProviderTestClass class] selector:@selector(variadicMethod:) chaosProvider:blockProvider];

    dixie
        .Profile(entry)
        .Apply();
    
    ChaosProviderTestClass* testObject = [ChaosProviderTestClass new];
    
    //WHEN
    NSString* string = [testObject variadicMethod:@"key", @"haho", @2, nil];
    
    //THEN
    XCTAssert([string isEqualToString:@""], @"Original variadic function should be called");
}

@end
