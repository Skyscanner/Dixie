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

#import "DixieProfileEntry.h"
#import "DixieRunTimeHelper.h"

@interface DixieProfileEntry(/*Private*/)

@property (nonatomic, strong) NSString* entryID;
@property (nonatomic, strong) DixieMethodInfo* methodInfo;

@end

@implementation DixieProfileEntry

-(instancetype) init
{
    if (self  = [super init])
    {
        self.entryID = [[NSUUID UUID] UUIDString];
    }
    
    return self;
}

+(instancetype) entry:(Class)victim selector:(SEL)selector chaosProvider:(DixieBaseChaosProvider*)chaosProvider
{
    DixieProfileEntry* entry = [DixieProfileEntry new];
    
    entry.methodInfo = [DixieMethodInfo infoWithClass:victim selector:selector];
    entry.chaosProvider = chaosProvider;
    entry.entryID = [NSString stringWithFormat:@"%@%@", NSStringFromClass(victim), NSStringFromSelector(selector)];
    
    return entry;
}

+(NSArray*) entries:(Class)victim excludeSelectorsOfClass:(Class)excludeClass chaosProvider:(DixieBaseChaosProvider *)chaosProvider
{
    NSArray* selectorsToExclude = [DixieRunTimeHelper selectorsForClass:excludeClass];
    
    return [self entries:victim excludes:selectorsToExclude chaosProvider:chaosProvider];
}

+(NSArray*) entries:(Class)victim excludes:(NSArray*)excludedSelectorNames chaosProvider:(DixieBaseChaosProvider*)chaosProvider
{
    NSArray* selectorNames = [DixieRunTimeHelper selectorsForClass:victim];
    
    NSMutableArray* profileEntries = [@[] mutableCopy];
    
    for (NSString* selectorName in selectorNames) {
        
        if (![excludedSelectorNames containsObject:selectorName])
        {
            DixieProfileEntry* entry = [DixieProfileEntry entry:victim selector:NSSelectorFromString(selectorName) chaosProvider:chaosProvider];
            
            if (entry)
            {
                [profileEntries addObject:entry];
            }
        }
    }
    
    return profileEntries;
}

@end
