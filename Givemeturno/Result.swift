//
//  Result.swift
//  Givemeturno
//
//  Created by Joaquin Barcena on 8/21/19.
//  Copyright © 2019 Joaquin Barcena. All rights reserved.
//

import Foundation

enum Result<A> {
    case fail(String)
    case ok(A)
}
