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

@import Foundation;

/**
 *  Describes a class and one of its method
 */
@interface DixieMethodInfo : NSObject

/**
 *  Owner of the method.
 */
@property (readonly) Class targetClass;

/**
 *  Selector of the method.
 */
@property (readonly) SEL selector;

/**
 *  The string representation of the method encoding
 */
@property (readonly) const char* methodTypeEncoding;

/**
 *  Indicates whether the method is a class method.
 */
@property (readonly) BOOL isClassMethod;

/**
 *  Signature of the method.
 */
@property (readonly) NSMethodSignature* signature;

/**
 *  Creates a new MethodInfo instance.
 *
 *  @param targetClass The owner of the method.
 *  @param selector    The selector of the method.
 *
 *  @return A MethodInfo instance.
 */
+(instancetype) infoWithClass:(Class)targetClass selector:(SEL)selector;

@end
