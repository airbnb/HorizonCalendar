// Created by Bryan Keller on 5/25/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

extension Dictionary {

  // If a value exists for the specified key, it will be returned without invoking
  // `missingValueProvider`. If a value does not exist for the specified key, then it will be
  // created and stored in the dictionary by invoking `missingValueProvider`.
  //
  // Useful when a dictionary is used as a cache.
  mutating func value(for key: Key, missingValueProvider: () -> Value) -> Value {
    if let value = self[key] {
      return value
    } else {
      let value = missingValueProvider()
      self[key] = value
      return value
    }
  }

}
