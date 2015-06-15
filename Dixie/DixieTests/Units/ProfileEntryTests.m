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
#import "TestClass.h"
#import "SubTestClass.h"
#import "NSDateProfile.h"

@interface ProfileEntryTests : XCTestCase

@end

@implementation ProfileEntryTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEntriesCreated {

    NSArray* excludes = @[NSStringFromSelector(@selector(signature))];
    NSArray* entries = [DixieProfileEntry entries:[DixieChaosContext class] excludes:excludes chaosProvider:[DixieNilChaosProvider new]];
    
    BOOL hasExcluded = YES;
    NSString* selectorName;
    
    for (DixieProfileEntry* entry in entries) {
        
        selectorName = NSStringFromSelector(entry.methodInfo.selector);
        if ([excludes containsObject:selectorName]) {
            
            hasExcluded = NO;
            break;
            
        }
        
    }
    
    XCTAssert(hasExcluded, "There should not be a profile entry with excluded selector:%@", selectorName);
}

-(void) testExcludedClassSelectorsNotIncludedInProfileEntries
{
    //Given
    Class classToExclude = [TestClass class];
    NSArray* excludedSelectors = [DixieRunTimeHelper selectorsForClass:classToExclude];
    
    //When
    NSArray* entries = [DixieProfileEntry entries:[SubTestClass class] excludeSelectorsOfClass:classToExclude chaosProvider:[DixieNilChaosProvider new]];
    
    //Then
    BOOL areEntriesCorrect = YES;
    for (DixieProfileEntry* entry in entries) {
        
        NSString* selectorName = NSStringFromSelector(entry.methodInfo.selector);
        if ([excludedSelectors containsObject:selectorName]) {
            
            areEntriesCorrect = NO;
            break;
            
        }
    }
    
    XCTAssertTrue(areEntriesCorrect, @"ProfileEntry method did not excluded the selectors of the class");
}

#pragma mark - Pre-defined entries
#pragma NSDateProfile

-(void) testDateProfileIsCorrect
{
    //GIVEN
    NSDateProfile* profile = [NSDateProfile new];
    
    //WHEN
    BOOL isTargetClassCorrect = [profile.methodInfo.targetClass isSubclassOfClass:[NSDate class]];
    BOOL isSelectorCorrect = [NSStringFromSelector( profile.methodInfo.selector ) isEqualToString:NSStringFromSelector(@selector(date))];
    BOOL isChaosProviderCorrect = [profile.chaosProvider isKindOfClass:[DixieConstantChaosProvider class]];
    
    XCTAssert(isTargetClassCorrect && isSelectorCorrect && isChaosProviderCorrect, @"NSDateProfile should target +[NSDate date] with a ConstantChaosProvider");
}

@end
