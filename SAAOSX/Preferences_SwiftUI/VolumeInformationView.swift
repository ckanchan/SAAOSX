//
//  VolumeInformationView.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 15/01/2023.
//  Copyright © 2023 Chaitanya Kanchan. All rights reserved.
//

import SwiftUI

struct VolumeInformationView: View {
    var volume: Volume

    var body: some View {
        HStack {

                Text(volume.title)
          
            Spacer()
            
            Image(nsImage: volume.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 120, alignment: .trailing)
        }
    }
}

struct VolumeInformationView_Previews: PreviewProvider {
    static var previews: some View {
        VolumeInformationView(volume: Volume.saa01)
    }
}
