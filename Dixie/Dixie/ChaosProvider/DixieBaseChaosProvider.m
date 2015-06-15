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

#import "DixieBaseChaosProvider.h"
#import "DixieLogger.h"

@implementation DixieBaseChaosProvider

-(IMP) chaos
{
    return [DixieRunTimeHelper implementationWithChaosContext:self.context
                                                  environment:^(id victim, DixieCallEnvironment *environment) {
        
        [self chaosImplementationFor:victim environment:environment];
        
        [[DixieLogger defaultLogger] log:@"Puppet %@: %@ used %@ to return %@",
         NSStringFromClass([victim class]),
         NSStringFromSelector(self.context.methodInfo.selector),
         [self class],
         environment.returnValue];
        
    }];
}

-(void) forwardChaosOf:(id)victim environment:(DixieCallEnvironment*)environment to:(DixieBaseChaosProvider*)chaosProvider
{
	[chaosProvider setContext:self.context];
	IMP chaosIMP = [chaosProvider chaos];

    SEL selector;
    
    if (chaosIMP == self.context.originalIMP)
    {
        selector = NSSelectorFromString([DixieMethodPrefix stringByAppendingString:NSStringFromSelector(self.context.methodInfo.selector)]);
    }
    else
    {
        selector = self.context.methodInfo.selector;
    }
    
    [DixieRunTimeHelper callImplementation:chaosIMP on:victim chaosContext:self.context environment:environment];
}

-(void) chaosImplementationFor:(id)victim environment:(DixieCallEnvironment *)environment
{
	@throw [NSException exceptionWithName:@"Method not overriden"
                                   reason:@"DixieBaseChaosProvider subclasses should override [BaseChaosProvider chaosImpl:]"
                                 userInfo:nil];
}

@end
