// Created by Bryan Keller on 9/11/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

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

import UIKit

extension NSDirectionalEdgeInsets: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(top)
    hasher.combine(leading)
    hasher.combine(bottom)
    hasher.combine(trailing)
  }

}
