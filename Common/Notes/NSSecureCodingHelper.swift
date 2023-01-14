//
//  NSSecureCodingHelper.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 20/04/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation

extension NSSecureCoding {
    func securelyEncoded() -> Data {
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        self.encode(with: coder)
        coder.finishEncoding()
        return coder.encodedData
    }
}
