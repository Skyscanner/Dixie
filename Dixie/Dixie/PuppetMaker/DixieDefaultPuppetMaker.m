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

#import "DixieDefaultPuppetMaker.h"
#import <objc/runtime.h>

@interface DixieDefaultPuppetMaker(/*Private*/)

@property (nonatomic, strong) NSMutableDictionary* victims;

@end

@implementation DixieDefaultPuppetMaker

-(instancetype) init
{
    if (self = [super init])
    {
        self.victims = [@{} mutableCopy];
    }
    
    return self;
}

-(void) createPuppet:(DixieProfileEntry*)entry seed:(NSInteger)seed
{
    //If already a puppet, dismiss it
    if (self.victims[entry.entryID])
    {
        [self dismissPuppet:entry];
    }
    
    DixieMethodInfo* methodInfo = entry.methodInfo;
    
    //Get the victim class (class or meta class)
    Class victim = [DixieRunTimeHelper classForMethodInfo:methodInfo];

    //Create the context for the behaviour replacement
    DixieChaosContext* context = [[DixieChaosContext alloc] init:seed methodInfo:methodInfo];
    [entry.chaosProvider setContext:context];
    context.originalIMP = method_getImplementation([DixieRunTimeHelper methodForMethodInfo:methodInfo]);
    
    //Retrieve the new behaviour from the provider
    IMP chaos = [entry.chaosProvider chaos];
    
    //Add the original implementation to the class with a new selector, dixie_[originalSelectorName]
    class_addMethod(victim,
                    NSSelectorFromString([DixieMethodPrefix stringByAppendingString:NSStringFromSelector(methodInfo.selector)]),
                    context.originalIMP,
                    methodInfo.methodTypeEncoding);
    
    //Replace the original behaviour with the new one
    class_replaceMethod(victim, methodInfo.selector, chaos, methodInfo.methodTypeEncoding);

    //Store original implementation
    self.victims[entry.entryID] = [NSValue valueWithPointer:context.originalIMP];
}

-(void) dismissPuppet:(DixieProfileEntry*)entry
{
    DixieMethodInfo* methodInfo = entry.methodInfo;
    NSValue* value = self.victims[entry.entryID];
    
    if (!value)
        return;
    
    //Retrieve original implementation
    IMP originalIMP = [value pointerValue];

    Class victim = [DixieRunTimeHelper classForMethodInfo:methodInfo];
    
    //Put back original implementation
    class_replaceMethod(victim, methodInfo.selector, originalIMP, methodInfo.methodTypeEncoding);
    
    //No need to store it
    [self.victims removeObjectForKey:entry.entryID];
}

@end
