//
//  MainView.swift
//  SwiftUICoreDataSpendingTracker
//
//  Created by Michael Doroff on 10/8/22.
//

import SwiftUI

struct MainView: View {
    
    @State private var shouldPresentAddCardForm = false
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: true)],
        animation: .default)
    private var cards: FetchedResults<Card>
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                if (!cards.isEmpty) {
                    TabView {
                        ForEach(cards) { card in
                            CreditCardView(card: card)
                            .padding(.bottom, 40)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 280)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                } else {

                    emptyPromptMessage
                }
                Spacer()
                    .fullScreenCover(isPresented: $shouldPresentAddCardForm) {
                        AddCardForm()
                    }
            }
            .navigationTitle("Credit Cards")
            .navigationBarItems(leading: HStack {
                addItemButton
                deleteItemsButton
            }, trailing: addCardButton)
        }
    }
    
    
    var emptyPromptMessage: some View {
        VStack {
            Text( "You currently have no cards in the system.")
                .padding(.horizontal, 40)
                .padding(.vertical )
                .multilineTextAlignment(.center )
            Button {
                shouldPresentAddCardForm.toggle()
            } label: {
                Text("+ Add Your First Card")
                    .foregroundColor(Color(.systemBackground))
            }
            .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14 ))
            .background(Color(.label))

        }.font(.system(size: 22, weight: .semibold ))
    }
    
    var deleteItemsButton: some View {
        Button {
            cards.forEach { card in
                viewContext.delete(card)
            }
            do {
                try viewContext.save()
            } catch {
                // handle the error
            }
            
        } label: {
            Text("Delete All")
        }
    }
    
    var addItemButton: some View {
        Button(action: {
            withAnimation {
                let viewContext = PersistenceController.shared.container.viewContext
                let card = Card(context: viewContext)
                card.timestamp = Date()
                
                do {
                    try viewContext.save()
                } catch {
                    print("There was an error")
                }
            }
            
        }, label: {
            Text("Add Item")
        })
    }
    
    struct CreditCardView: View {
        
        let card: Card
        @State private var shouldShowActionSheet = false
        
        private func handleDelete() {
            
            let viewContext = PersistenceController.shared.container.viewContext
            
            viewContext.delete(card)
            
            do {
                try viewContext.save()
            } catch {
                // handle the error
            }
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(card.name ?? "")
                        .font(.system(size: 24, weight: .semibold))
                    Spacer()
                    Button {
                        shouldShowActionSheet.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20, weight: .bold ))
                    }
                    .actionSheet(isPresented: $shouldShowActionSheet) {
                        .init(title: Text(card.name ?? "" ), message: Text("Options"), buttons: [
                            .destructive(Text("Delete Card"), action: handleDelete),
                            .cancel()
                             
                        ])
                    }
                }
                HStack {
                    Image("visa")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 44)
                    Spacer()
                    Text("Balance: $5,000")
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Text(card.number ?? "")
                Text("Credit Limit: $\(card.limit)")
                
                HStack { Spacer() }
            }
            .foregroundColor(.white)
            .padding()
            .background(
                VStack {
                    if let colorData = card.color, let uiColor = UIColor.color(data: colorData), let actualColor = Color(uiColor: uiColor) {
                        LinearGradient(colors: [
                            actualColor
                        ], startPoint: .center, endPoint: .bottom)
                    } else {
                        Color.cyan
                    }
                }
            )
            .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 1))
            .cornerRadius(8)
            .shadow(radius: 5)
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
    var addCardButton: some View {
        Button(action: {
            shouldPresentAddCardForm.toggle()
        }, label: {
            Text("+ Card")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .background(Color.black)
                .cornerRadius(5)
        })
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.shared.container.viewContext
        MainView()
            .environment(\.managedObjectContext, viewContext)
    }
}
