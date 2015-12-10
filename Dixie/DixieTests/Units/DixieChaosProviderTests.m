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
#import "NSObject+DixieRunTimeHelper.h"

@interface DixieChaosProviderTests : XCTestCase <ChaosProviderTestClassDelegate>
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
        
        environment.returnValue = (__bridge void *)(@(param.integerValue + 1));
        
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

-(void) testVariadicStubbed
{
    //GIVEN
    DixieConstantChaosProvider *provider = [DixieConstantChaosProvider constant:@"Hello"];
    DixieProfileEntry *entry = [DixieProfileEntry entry:[ChaosProviderTestClass class] selector:@selector(variadicMethod:) chaosProvider:provider];
    
    dixie.Profile(entry).Apply();
    
    //WHEN
    NSString *string = [[ChaosProviderTestClass new] variadicMethod:@"key",@2,nil];
    
    //THEN
    XCTAssert([string isEqualToString:@"Hello"], @"Wrong return value for variadic stubbing");
}

#pragma mark - Primitives
-(void) testChaosForPrimitiveReturnType
{
    //GIVEN
    int intValue = 11;
    DixieBlockChaosProvider* blockProvider = [DixieBlockChaosProvider block:^(DixieBaseChaosProvider *chaosProvider, id victim, DixieCallEnvironment *environment) {
        
        environment.returnValue = (void *)&intValue;
    }];
    
    DixieProfileEntry* entry = [DixieProfileEntry entry:[ChaosProviderTestClass class] selector:@selector(returnIntValue) chaosProvider:blockProvider];
    
    dixie
    .Profile(entry)
    .Apply();
    
    ChaosProviderTestClass* testObject = [ChaosProviderTestClass new];
    
    //WHEN
    int returnedIntValue = [testObject returnIntValue];
    
    //THEN
    XCTAssert(returnedIntValue == 11, @"New int value should be returned");
}

-(void) testChaosPrimitiveParameterIsForwarded
{
    //GIVEN
    DixieBlockChaosProvider* blockProvider = [DixieBlockChaosProvider block:^(DixieBaseChaosProvider *chaosProvider, id victim, DixieCallEnvironment *environment) {
        
        NSNumber *newNumber = @11;
        storeOriginal(@11, int, 11);
        NSMutableArray *myArguments = [environment.arguments mutableCopy];
        myArguments[0] = newNumber;
        environment.arguments = myArguments;
        
        [chaosProvider forwardChaosOf:victim environment:environment to:[DixieNonChaosProvider new]];
    }];
    
    DixieProfileEntry* entry = [DixieProfileEntry entry:[ChaosProviderTestClass class] selector:@selector(numberFromInteger:) chaosProvider:blockProvider];
    
    dixie
    .Profile(entry)
    .Apply();
    
    ChaosProviderTestClass* testObject = [ChaosProviderTestClass new];
    
    //WHEN
    NSNumber *number = [testObject numberFromInteger:42];
    
    //THEN
    XCTAssert([number isEqualToNumber:@11], @"New int value should be returned");
}

#pragma mark - Method type fuzzing
-(void) testPropertyGetterSetterChanged
{
    //GIVEN
    DixieBlockChaosProvider *setterBlockProvider = [DixieBlockChaosProvider block:^(DixieBaseChaosProvider *chaosProvider, id victim, DixieCallEnvironment *environment) {
        //THEN
        XCTAssert(environment.arguments.firstObject == self, @"First argument is invalid");
    }];
    
    DixieBlockChaosProvider *getterBlockProvider = [DixieBlockChaosProvider block:^(DixieBaseChaosProvider *chaosProvider, id victim, DixieCallEnvironment *environment) {
        environment.returnValue = (__bridge void *)(self);
    }];
    
    DixieProfileEntry *setterEntry = [DixieProfileEntry entry:[ChaosProviderTestClass class] selector:@selector(setTestDelegate:) chaosProvider:setterBlockProvider];
    DixieProfileEntry *getterEntry = [DixieProfileEntry entry:[ChaosProviderTestClass class] selector:@selector(testDelegate) chaosProvider:getterBlockProvider];
    
    ChaosProviderTestClass *testObject = [ChaosProviderTestClass new];

    //WHEN
    dixie.Profile(setterEntry).Apply();
    
    [testObject setTestDelegate:self];
    
    dixie.RevertIt(setterEntry);
    
    [testObject setTestDelegate:nil];
    
    dixie.Profile(getterEntry).Apply();
    
    //THEN
    XCTAssert(testObject.testDelegate == self, @"Getter property invalid");
}

-(void) testPrivateMethodChanged
{
    //GIVEN
    short original = 2;
    NSNumber *number = @2;
    storeOriginal(number, short, original);
    DixieConstantChaosProvider *provider = [DixieConstantChaosProvider constant:number];
    
    dixie
        .Profile([DixieProfileEntry entry:[ChaosProviderTestClass class] selector:NSSelectorFromString(@"_veryPrivateMethod") chaosProvider:provider])
        .Apply();
    
    //WHEN
    NSNumber *value = [[ChaosProviderTestClass new] valueForKeyPath:@"_veryPrivateMethod"];
    
    //THEN
    XCTAssert([value isEqualToNumber:@2], @"Private method is not changed");
}

-(void) testUltimateMethodChanged
{
    //GIVEN
    DixieNilChaosProvider *provider = [DixieNilChaosProvider new];
    DixieProfileEntry *entry = [DixieProfileEntry entry:[ChaosProviderTestClass class] selector:@selector(arg1:arg2:arg3:arg4:arg5:arg6:arg7:arg8:arg9:arg10:) chaosProvider:provider];
    
    dixie.Profile(entry).Apply();
    
    //WHEN
    int arg6 = 2;
    id value = [[ChaosProviderTestClass new] arg1:@2 arg2:2 arg3:2.0 arg4:2.f arg5:2 arg6:&arg6 arg7:NO arg8:'a' arg9:5 arg10:67l];
    
    //THEN
    XCTAssert(value == nil,@"Ultimate method not changed");
}

-(void) testUseBlockParameterOfMethod
{
    //GIVEN
    __block BOOL called = NO;
    dispatch_block_t aBlock = ^{called = YES;};
    
    DixieBlockChaosProvider *blockProvider = [DixieBlockChaosProvider block:^(DixieBaseChaosProvider *chaosProvider, id victim, DixieCallEnvironment *environment) {
        dispatch_block_t block = environment.arguments[2];
        
        block();
    }];
    DixieProfileEntry *entry = [DixieProfileEntry entry:[ChaosProviderTestClass class] selector:@selector(setNumber:object:block:) chaosProvider:blockProvider];
    
    dixie.Profile(entry).Apply();
    
    //WHEN
    [[ChaosProviderTestClass new] setNumber:2 object:@2 block:aBlock];
    
    //THEN
    XCTAssert(called == YES, @"Block parameter of method is not called");
}

-(void) testUseBlockReturnType
{
    //GIVEN
    DixieConstantChaosProvider *provider = [DixieConstantChaosProvider constant:[^int(double d, BOOL b){return (int)b;} copy]];
    DixieProfileEntry *entry = [DixieProfileEntry entry:[ChaosProviderTestClass class] selector:@selector(block) chaosProvider:provider];
    
    dixie.Profile(entry).Apply();
    
    //WHEN
    TestBlockType block = [[ChaosProviderTestClass new] block];
    
    //THEN
    XCTAssert(block(0.4,YES) == 1, @"Wrong block returned");
}

-(void) testCategoryMethodChanged
{
    //GIVEN
    unsigned int k = 103;
    NSNumber *number = @(k);
    storeOriginal(number, unsigned int, k);
    DixieProfileEntry *entry = [DixieProfileEntry entry:[ChaosProviderTestClass class] selector:@selector(randomIntFrom:) chaosProvider:[DixieConstantChaosProvider constant:number]];
    
    dixie.Profile(entry).Apply();
    
    //WHEN
    unsigned int n = [[ChaosProviderTestClass new] randomIntFrom:4];
    
    //THEN
    XCTAssert(n == k, @"Category method is not changed");
}

- (void)testProtocolParamUsed
{
    //GIVEN
    __block BOOL answer = NO;
    DixieBlockChaosProvider *setterBlockProvider = [DixieBlockChaosProvider block:^(DixieBaseChaosProvider *chaosProvider, id victim, DixieCallEnvironment *environment) {
        answer = [(id<ChaosProviderTestClassDelegate>)environment.arguments.firstObject isItTrue];
    }];
    DixieProfileEntry *setterEntry = [DixieProfileEntry entry:[ChaosProviderTestClass class] selector:@selector(setTestDelegate:) chaosProvider:setterBlockProvider];
    dixie.Profile(setterEntry).Apply();
    
    //WHEN
    [[ChaosProviderTestClass new] setTestDelegate:self];
    
    //THEN
    XCTAssert(answer == YES, @"Protocol parameter could not be used");
}

#pragma mark - ChaosProviderTestClassDelegate
-(BOOL) isItTrue
{
    return YES;
}
@end
