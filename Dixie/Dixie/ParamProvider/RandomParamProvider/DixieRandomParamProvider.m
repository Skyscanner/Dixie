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

/*
 A C-program for MT19937-64 (2004/9/29 version).
 Coded by Takuji Nishimura and Makoto Matsumoto.
 
 This is a 64-bit version of Mersenne Twister pseudorandom number
 generator.
 
 Before using, initialize the state by using init_genrand64(seed)
 or init_by_array64(init_key, key_length).
 
 Copyright (C) 2004, Makoto Matsumoto and Takuji Nishimura,
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 
 1. Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 3. The names of its contributors may not be used to endorse or promote
 products derived from this software without specific prior written
 permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 References:
 T. Nishimura, ``Tables of 64-bit Mersenne Twisters''
 ACM Transactions on Modeling and
 Computer Simulation 10. (2000) 348--357.
 M. Matsumoto and T. Nishimura,
 ``Mersenne Twister: a 623-dimensionally equidistributed
 uniform pseudorandom number generator''
 ACM Transactions on Modeling and
 Computer Simulation 8. (Jan. 1998) 3--30.
 
 Any feedback is very welcome.
 http://www.math.hiroshima-u.ac.jp/~m-mat/MT/emt.html
 email: m-mat @ math.sci.hiroshima-u.ac.jp (remove spaces)
 */

#import "DixieRandomParamProvider.h"

#define NN 312
#define MM 156
#define MATRIX_A 0xB5026F5AA96619E9ULL
#define UM 0xFFFFFFFF80000000ULL /* Most significant 33 bits */
#define LM 0x7FFFFFFFULL /* Least significant 31 bits */

@interface DixieRandomParamProvider()
{
    /* The array for the state vector */
    unsigned long long _mt[NN];
    int _mti;
    unsigned int _upperBound;
}
@end

@implementation DixieRandomParamProvider

+(instancetype) providerWithUpperBound:(unsigned int)upperBound
{
    DixieRandomParamProvider* paramProvider = [DixieRandomParamProvider new];

    paramProvider->_upperBound = upperBound;
    
    return paramProvider;
}

-(instancetype) init
{
    self = [super init];
    
    if(self)
    {
        /* mti==NN+1 means mt[NN] is not initialized */
        _mti = NN+1;
        _upperBound = 100;
        
        [self setSeed:[[NSDate date] timeIntervalSince1970]];
    }
    
    return self;
}

-(void) setSeed:(unsigned long long)seed
{
    _mt[0] = seed;
    for (_mti=1; _mti<NN; _mti++)
        _mt[_mti] =  (6364136223846793005ULL * (_mt[_mti-1] ^ (_mt[_mti-1] >> 62)) + _mti);
}

-(id) parameter
{
    return @((unsigned int)([self generateRealNumber] * _upperBound));
}

/* generates a random number on [0,1]-real-interval */
-(double) generateRealNumber
{
    return ([self generateRandomUnsignedLongLong] >> 11) * (1.0/9007199254740991.0);
}

-(unsigned long long) generateRandomUnsignedLongLong
{
    int i;
    unsigned long long x;
    static unsigned long long mag01[2]={0ULL, MATRIX_A};
    
    if (_mti >= NN) { /* generate NN words at one time */
        
        /* if init_genrand64() has not been called, */
        /* a default initial seed is used     */
        if (_mti == NN+1)
            [self setSeed:5489ULL];
        
        for (i=0;i<NN-MM;i++) {
            x = (_mt[i]&UM)|(_mt[i+1]&LM);
            _mt[i] = _mt[i+MM] ^ (x>>1) ^ mag01[(int)(x&1ULL)];
        }
        for (;i<NN-1;i++) {
            x = (_mt[i]&UM)|(_mt[i+1]&LM);
            _mt[i] = _mt[i+(MM-NN)] ^ (x>>1) ^ mag01[(int)(x&1ULL)];
        }
        x = (_mt[NN-1]&UM)|(_mt[0]&LM);
        _mt[NN-1] = _mt[MM-1] ^ (x>>1) ^ mag01[(int)(x&1ULL)];
        
        _mti = 0;
    }
    
    x = _mt[_mti++];
    
    x ^= (x >> 29) & 0x5555555555555555ULL;
    x ^= (x << 17) & 0x71D67FFFEDA60000ULL;
    x ^= (x << 37) & 0xFFF7EEE000000000ULL;
    x ^= (x >> 43);
    
    return x;
}

@end
