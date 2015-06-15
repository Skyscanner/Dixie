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

#import "DixieHeaders.h"
#import <XCTest/XCTest.h>
#import "NSURLProfile.h"

#import "TestPuppetMaker.h"
#import "NSURLProfile.h"

@interface DixieAPITests : XCTestCase
{
    Dixie* dixie;
}
@end

@implementation DixieAPITests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    dixie  = [Dixie new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [dixie revert];
}

-(void) testPuppetMakerCreatePuppetCalled
{
    //GIVEN
    TestPuppetMaker* puppetMaker = [TestPuppetMaker new];
    
    //WHEN
    dixie
        .PuppetMaker(puppetMaker)
        .Profile([NSURLProfile new])
        .Apply();
    
    //THEN
    XCTAssert(puppetMaker.isCreateCalled == YES, @"CreatePuppet protocol function should be called");
}

-(void) testPuppetMakerMultiplePuppetCreationReverted
{
    //GIVEN
    NSURLProfile* profile = [NSURLProfile new];
    
    //WHEN
    dixie
    .Profile(profile)
    .Apply();

    dixie.Apply();
    dixie.RevertIt(profile);
    
    //THEN
    XCTAssert([[NSURL URLWithString:@"http://www.something.net"].absoluteString isEqualToString:@"http://www.something.net"], @"Multiple puppet creation should be reverted");
}

-(void) testPuppetMakerDismissPuppetCalled
{
    //GIVEN
    TestPuppetMaker* puppetMaker = [TestPuppetMaker new];
    dixie
        .PuppetMaker(puppetMaker)
        .Profile([NSURLProfile new])
        .Apply();
    
    //WHEN
    dixie
        .Revert();
    
    //THEN
    XCTAssert(puppetMaker.isDismissCalled == YES, @"DismissPuppet protocol function should be called");
}

-(void) testSingleProfileAdded {
 
    //GIVEN
    DixieProfileEntry* singleProfile = [NSURLProfile new];
    
    //WHEN
    dixie
        .Profile(singleProfile)
        .Apply();
    
    //THEN
    XCTAssert( [NSURL URLWithString:@"http://www.something.net"] == nil, @"NSURL should be nil");
}

-(void) testPuppetCanBeCalledMultipleTimes {
    
    //GIVEN
    DixieProfileEntry* singleProfile = [NSURLProfile new];
    
    //WHEN
    dixie
    .Profile(singleProfile)
    .Apply();
    
    //THEN
    XCTAssert( [NSURL URLWithString:@"http://www.something.net"] == nil && [NSURL URLWithString:@"http://www.something.net"] == nil, @"NSURL should be nil");
}

-(void) testSingleProfileReverted
{
    //GIVEN
    DixieProfileEntry* entry1 = [DixieProfileEntry entry:[NSURL class] selector:@selector(URLWithString:) chaosProvider:[DixieNilChaosProvider new]];
    DixieProfileEntry* entry2 = [DixieProfileEntry entry:[NSURL class] selector:@selector(baseURL) chaosProvider:[DixieNilChaosProvider new]];
    
    dixie
    .Profiles(@[entry1 , entry2])
    .Apply();
    
    //WHEN
    dixie.RevertIt(entry1);

    //THEN
    NSURL* url = [NSURL URLWithString:@"http://something.net"];
    XCTAssert(url != nil && url.baseURL == nil, @"First entry should be reverted and second not");
}

-(void) testMultipleProfileReverted
{
    //GIVEN
    DixieProfileEntry* entry1 = [DixieProfileEntry entry:[NSURL class] selector:@selector(URLWithString:) chaosProvider:[DixieNilChaosProvider new]];
    DixieProfileEntry* entry2 = [DixieProfileEntry entry:[NSURL class] selector:@selector(baseURL) chaosProvider:[DixieNilChaosProvider new]];
    
    dixie
    .Profiles(@[entry1 , entry2])
    .Apply();
    
    //WHEN
    dixie.Revert();
    
    //THEN
    NSURL* url = [NSURL URLWithString:@"http://something.net"];
    XCTAssert(url != nil && url.baseURL == nil, @"First entry should be reverted and second not");
}

@end
