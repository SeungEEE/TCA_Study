/*
 See LICENSE folder for this sample’s licensing information.
 */

import SwiftUI

struct NewScrumSheet: View {

    var body: some View {
        NavigationStack {
            DetailEditView(scrum: nil)
        }
    }
}

#Preview {
    NewScrumSheet()
}
