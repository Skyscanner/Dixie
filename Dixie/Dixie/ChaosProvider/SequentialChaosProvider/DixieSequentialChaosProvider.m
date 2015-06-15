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

#import "DixieSequentialChaosProvider.h"
#import "DixieNonChaosProvider.h"

@interface DixieSequentialChaosProvider (/*Private*/)

@property (nonatomic) NSInteger callCount;
@property (nonatomic, strong) NSArray* sequence;

@end

@implementation DixieSequentialChaosProvider

-(id) init
{
	if (self = [super init])
	{
		self.callCount = 0;
		self.sequence = @[];
	}

	return self;
}

+(instancetype) sequence:(NSArray*)sequenceOfChaosProviders
{
	DixieSequentialChaosProvider* provider = [DixieSequentialChaosProvider new];

	provider.sequence = sequenceOfChaosProviders;

	return provider;
}

-(void) setContext:(DixieChaosContext *)context
{
    [super setContext:context];
    
    for (DixieBaseChaosProvider* provider in self.sequence) {
        [provider setContext:context];
    }
}

-(void) chaosImplementationFor:(id)victim environment:(DixieCallEnvironment *)environment
{
	DixieBaseChaosProvider* current;

	//If we are not out of bounds, then use chaos provider mathcing the call count
	if (self.callCount < self.sequence.count)
	{
		current = self.sequence[self.callCount];
	}
	//Else use always the last one
	else
	{
		current = [self.sequence lastObject];
	}

	//Only increamenet callcount if its less than NSIntegerMax so prevent overflows
	if (self.callCount < NSIntegerMax)
	{
		self.callCount++;
	}

	//If the current is a BaseChaosProvider, then forward the chaos to it
	if ([current isKindOfClass:[DixieBaseChaosProvider class]])
	{
        [self forwardChaosOf:victim environment:environment to:current];
	}
	//If it is of different class, do nothing
	else
	{
        [self forwardChaosOf:victim environment:environment to:[DixieNonChaosProvider new]];
	}
}

@end
