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

#import "Dixie.h"
#import "DixieDefaultPuppetMaker.h"
#import "DixieLogger.h"

@interface Dixie(/*Private*/)

@property (atomic) NSLock* lock;
@property (nonatomic, strong) NSMutableArray* profiles;
@property (nonatomic, strong) id<DixiePuppetMaking> puppetMaker;

@end

@implementation Dixie

-(id) init
{
    if (self = [super init])
    {
        self.lock = [NSLock new];
        self.profiles = [@[] mutableCopy];
        self.puppetMaker = [DixieDefaultPuppetMaker new];
    }
    
    return self;
}

-(instancetype) puppetMaker:(id<DixiePuppetMaking>)puppetMaker
{
    [self.lock lock];
    
    self.puppetMaker = puppetMaker;
    
    [self.lock unlock];
    
    return self;
}

-(instancetype) profile:(DixieProfileEntry*)profile
{
    NSAssert(profile != nil, @"DixieProfileEntry should not be nil");
    return [self profiles:@[ profile ]];
}

-(instancetype) profiles:(NSArray*)arrayOfEntries
{
    [self.lock lock];
    
    [self.profiles addObjectsFromArray:arrayOfEntries];
    
    [self.lock unlock];
    
    return self;
}

-(void) apply
{
    [self apply:0];
}

-(void) apply:(NSInteger)seed
{
    [self.lock lock];
    
    for (DixieProfileEntry* entry in self.profiles) {
    
        [self.puppetMaker createPuppet:entry seed:seed];
    }
    
    [self.lock unlock];
}

-(void) revert
{
    for (DixieProfileEntry* entry in self.profiles.copy) {
        
        [self revert:entry];
    }
}

-(void) revert:(DixieProfileEntry*)entry
{
    [self.lock lock];
    
    [self.puppetMaker dismissPuppet:entry];
    [self.profiles removeObject:entry];
    
    [self.lock unlock];
}

@end
