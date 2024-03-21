// ContentView.swift
import SwiftUI

struct ContentView: View {
    //key for storing todo items in userdefault
    let todosKey = "todos"
    
    //user inputs
    @State private var newTodoTitle = ""
    @State private var newTodoDescription = ""
    
    //array to hold the todo items
    @State private var todos: [TodoItem] = []
    
    var body: some View {
        NavigationView {
            VStack {
                List(todos) { todo in
                    VStack(alignment: .leading) {
                        Text(todo.title)
                            .font(.headline)
                        Text(todo.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .navigationTitle("Todo List")
                
                Button(action: addTodo) {
                    Text("Add Todo")
                }
                .padding()
                
                //field for user inputs
                TextField("Title", text: $newTodoTitle)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Description", text: $newTodoDescription)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .onAppear {
            //gets the todos from userdefault when the view pops up
            fetchTodos()
        }
    }
    
    //adds the todo item to userdefault storage
    private func addTodo() {
        guard !newTodoTitle.isEmpty && !newTodoDescription.isEmpty else {
            return
        }
        
        let todo = TodoItem(title: newTodoTitle, description: newTodoDescription)
        
        //adds todo to the array
        todos.append(todo)
        
        //adds todo to the userdefault storage
        saveTodos()
        
        //removes the user input in the view
        newTodoTitle = ""
        newTodoDescription = ""
    }
    
    //function to save the todos to the storage
    private func saveTodos() {
        do {
            let data = try JSONEncoder().encode(todos)
            UserDefaults.standard.set(data, forKey: todosKey)
        } catch {
            print("Error encoding todos: \(error.localizedDescription)")
        }
    }
    
    //gets todos from the storage
    private func fetchTodos() {
        if let data = UserDefaults.standard.data(forKey: todosKey) {
            do {
                todos = try JSONDecoder().decode([TodoItem].self, from: data)
            } catch {
                print("Error decoding todos: \(error.localizedDescription)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
