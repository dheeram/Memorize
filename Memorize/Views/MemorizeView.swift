//
//  ContentView.swift
//  Memorize
//
//  Created by Ulrich Braß on 19.05.20.
//  Copyright © 2020 Ulrich Braß. All rights reserved.
//

import SwiftUI
//
// The VIEW file for the complete game: Reflects the model stateless, declared, reactive
// - Render the UI
// - Perform animations
// - Pass user interactions to VIEW MODEL
// - automatically observes publications
// - pulls data and rebuilds

// You create custom views by declaring types that conform to the View protocol.
// The View protocol provides a large set of modifiers, defined as protocol methods with default implementations,
// that you use to position and configure views in the layout of your app
struct MemorizeView: View, Identifiable {
    var id : UUID
    
    // A property wrapper type for an observable object supplied by a parent or ancestor view.
    // The property wrapper subscribes to it's observable object and invalidates the view whenever the observable object changes.
    @EnvironmentObject var viewModel : MemorizeViewModel
    //@ObservedObject var viewModel : MemorizeViewModel
    
    // Theme will be chosen from parent dialog
    var theme : Theme.ThemeItem
    //
    // Navigation Bar items:
    //
    // Take control over back button
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    private var backButton : some View { Button(action: {
            self.viewModel.storeScore(theme : self.theme)
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "hand.point.left.fill") // set image here
                    .aspectRatio(contentMode: .fit)
                Text("Zurück")
            }
        }
    }
    //
    // Add a button to the navigation bar that starts a new game
    private var newGameButton: some View {
        Button(action: {
            self.viewModel.storeScore(theme : self.theme)
            // explicit animation for card redistribution effect
            withAnimation(.easeInOut(duration: 1.5)){
                self.viewModel.newGame(theme : self.theme)
            }
            }
        ) { // label:
            HStack{
            Text("Neu")
            Image(systemName: "hand.point.right.fill")
                .aspectRatio(contentMode: .fit)
            } // HStack
        } // Button
    }
    // Buttons
    //
    //Implement the required body computed property to provide the content for your custom view.
    // Assemble the view’s body by combining one or more of the primitive views provided by SwiftUI, plus other custom views
    // that you define, into a hierarchy of views.
    var body: some View {
        VStack {
            // GridView A view that arranges its children items in a grid
            GridView(viewModel.cards){ card in     // The 'in' keyword indicates that the definition of the closure’s parameters and return type
                                                            // has finished, and the body of the closure is about to begin
                    CardView(card : card)
                        .onTapGesture { // will call closure after recognizing a tap gesture.
                            // Explicit animations are almost always wrapped around calls to ViewModel Intent functions
                            withAnimation(.linear(duration : 0.75)){
                                self.viewModel.chooseCard(card: card) // express intent
                            }
                        }
            .padding(5)
            } // viewForItems closure
            HStack {
                Text ("Punkte: " + String(viewModel.gameScore))
                Spacer()
                Text ("Aufgedeckt: " + String(viewModel.flipCount))
            }
        } //VStack
        // VStack modifiers
            //The effects of a modifier typically propagate to any child views that don’t explicitly override the modifier.
            // Here the HStack instance on its own acts only to horizontally stack other views, and has no text to display.
            // Therefore, the font(_:) modifier that we apply to the stack has no effect on the stack itself. Yet the font modifier
            // does apply to any of the stack’s child views, some of which might display text.
            // On the other hand, you can locally override the stack’s modifier by adding another one to a specific child view
            .padding()
            .navigationBarTitle(Text(self.theme.themeName), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton, trailing: newGameButton )
            .foregroundColor(Color(self.theme.themeColor))
            // needs to be done here, because access to environment in initializer does not work
            .onAppear(){self.viewModel.newGame(theme: self.theme)}
        // VStack View modifiers
    } // body
    
    init(theme : Theme.ThemeItem){
        self.theme = theme
        self.id = UUID()
    }
    
} // View

struct MemorizeView_Previews: PreviewProvider {
    static var previews: some View {
        MemorizeView(theme : Theme().themeList[0]).environmentObject(MemorizeViewModel())
    }
}
