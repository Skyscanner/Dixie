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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "RandomChaosProvider.h"

@interface RandomParamProviderTests : XCTestCase
{
    RandomParamProvider* _paramProvider;
}
@end

@implementation RandomParamProviderTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    _paramProvider = [RandomParamProvider providerWithUpperBound:1000];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testProviderDoesNotReturnAlwaysSameValue {

    //GIVEN
    [_paramProvider setSeed:0];
    
    //WHEN
    NSNumber* value1 = [_paramProvider parameter];
    NSNumber* value2 = [_paramProvider parameter];
    NSNumber* value3 = [_paramProvider parameter];
    
    NSArray* numbers = @[value1, value2, value3];
    
    //THEN
    NSSet* uniqueValues = [NSSet setWithArray:numbers];
    
    XCTAssert(uniqueValues.allObjects.count == numbers.count, @"Some of the values are the same");
}

- (void)testProviderReturnsSameSequenceForSameSeed {
    
    //GIVEN
    [_paramProvider setSeed:0];
    RandomParamProvider* anotherProvider = [RandomParamProvider providerWithUpperBound:1000];
    [anotherProvider setSeed:0];
    
    //WHEN
    NSMutableArray* sequence = [NSMutableArray array];
    NSMutableArray* anotherSequence = [NSMutableArray array];
    
    for (int i = 0; i < 3; i++) {
        
        [sequence addObject:[_paramProvider parameter]];
        [anotherSequence addObject:[anotherProvider parameter]];
        
    }
    
    //THEN
    XCTAssert([sequence isEqualToArray:anotherSequence], @"Random generator should return same sequence with same starting seed");
}

@end
