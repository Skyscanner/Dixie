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

#import "DixieRandomChaosProvider.h"

@interface DixieRandomChaosProvider (/*Private*/)

@property (nonatomic, strong) DixieRandomParamProvider* paramProvider;

@end

@implementation DixieRandomChaosProvider

+(instancetype) randomProvider:(DixieRandomParamProvider*)paramProvider
{
	DixieRandomChaosProvider* provider = [DixieRandomChaosProvider new];

	provider.paramProvider = paramProvider;

	return provider;
}

-(void) setContext:(DixieChaosContext *)context
{
    [super setContext:context];
    
    [self.paramProvider setSeed:context.seed];
}

-(void) chaosImplementationFor:(id)victim environment:(DixieCallEnvironment *)environment
{
    environment.returnValue = (__bridge void *)([self.paramProvider parameter]);
}
@end
