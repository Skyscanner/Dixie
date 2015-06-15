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
#import <objc/runtime.h>

#import "DixieCallEnvironment.h"
#import "DixieChaosContext.h"
#import "DixieMethodInfo.h"

#define DixieMethodPrefix @"dixie_"

/**
 *  Block type to describe a method's concrete implementation
 *
 *  @param victim      The receiver of the ObjC message
 *  @param environment The environment of the call
 */
typedef void(^DixieImplementationBlock)(id victim, DixieCallEnvironment* environment);

/**
 *  Helper to generate behaviour implementation, transparently call implementations and provide Runtime informations
 */
@interface DixieRunTimeHelper : NSObject

/**
 *  Generates an implementation pointer that confirms to the chaosContext and block
 *
 *  @param chaosContext The context of the implementation
 *  @param block        Block for the body of the implementation pointer
 *
 *  @return the implementation pointer
 */
+(IMP) implementationWithChaosContext:(DixieChaosContext*)chaosContext environment:(DixieImplementationBlock)block;

/**
 *  Calls the implementation pointer
 *
 *  @param implementation The IMP pointer to call
 *  @param puppet         The receiver of the ObjC message
 *  @param chaosContext   The context of the behaviour
 *  @param environment    The environment of the method's implementation call
 */
+(void) callImplementation:(IMP)implementation on:(id)puppet chaosContext:(DixieChaosContext*)chaosContext environment:(DixieCallEnvironment*)environment;

/**
 *  Collects the runtime public methodnames for a given class
 *
 *  @param targetClass The class
 *
 *  @return Array of public selector strings
 */
+(NSArray*) selectorsForClass:(Class)targetClass;

/**
 *  Returns the Method pointer for a given MethodInfo object
 *
 *  @param methodInfo Describes the target class and it's method
 *
 *  @return The Method pointer
 */
+(Method) methodForMethodInfo:(DixieMethodInfo*)methodInfo;

/**
 *  Returns the string representation of the method encoding describes by the MethodInfo object
 *
 *  @param methodInfo Describes the target class and it's method
 *
 *  @return the string representation of the method encoding
 */
+(const char*) methodTypeEncodingForMethodInfo:(DixieMethodInfo*)methodInfo;

/**
 *  Returns the class for the method described in the MethodInfo.
 *
 *  @param methodInfo Describes the target class and it's method
 *
 *  @return A Class object for instance methods and meta class object for class methods
 */
+(Class) classForMethodInfo:(DixieMethodInfo*)methodInfo;

@end
