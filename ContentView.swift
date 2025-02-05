import SwiftUI
import UserNotifications
import WidgetKit

struct ContentView: View {
    var body: some View {
        TabView {
            TodoListView()
                .tabItem {
                    Label("Задачи", systemImage: "checklist")
                }
            ActivityCalendarView()
                .tabItem {
                    Label("Активность", systemImage: "calendar")
                }
            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gear")
                }
        }
    }
}

struct TodoListView: View {
    @State private var tasks: [(String, Date?, Bool)] = []
    @State private var newTask: String = ""
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Новая задача", text: $newTask)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Добавить") {
                        addTask()
                    }
                }
                .padding()
                List {
                    ForEach(tasks.indices, id: \ .self) { index in
                        HStack {
                            Button(action: { toggleTaskCompletion(index) }) {
                                Image(systemName: tasks[index].2 ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(tasks[index].2 ? .green : .gray)
                            }
                            Text(tasks[index].0)
                            Spacer()
                            if let date = tasks[index].1 {
                                Text("📅 " + formattedDate(date))
                                    .foregroundColor(.gray)
                            }
                            Button(action: { removeTask(index) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                Button("Выбрать дату уведомления") {
                    showDatePicker.toggle()
                }
                .padding()
                if showDatePicker {
                    DatePicker("Дата и время", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                }
            }
            .navigationTitle("Список дел")
        }
    }
    
    func addTask() {
        if !newTask.isEmpty {
            tasks.append((newTask, selectedDate, false))
            scheduleNotification(task: newTask, date: selectedDate)
            newTask = ""
        }
    }
    
    func removeTask(_ index: Int) {
        tasks.remove(at: index)
    }
    
    func toggleTaskCompletion(_ index: Int) {
        tasks[index].2.toggle()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func scheduleNotification(task: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Напоминание"
        content.body = task
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ActivityCalendarView: View {
    var body: some View {
        VStack {
            Text("Календарь активности")
            ActivityGridView()
        }
    }
}

struct ActivityGridView: View {
    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<42, id: \ .self) { index in
                Rectangle()
                    .fill(Color.random())
                    .frame(width: 20, height: 20)
                    .cornerRadius(4)
            }
        }
        .padding()
    }
}

extension Color {
    static func random() -> Color {
        return Color(hue: Double.random(in: 0...1), saturation: 0.5, brightness: 0.8)
    }
}

struct SettingsView: View {
    @State private var backgroundColor = Color.white
    @State private var textColor = Color.black
    @State private var buttonColor = Color.blue
    
    var body: some View {
        Form {
            ColorPicker("Фон", selection: $backgroundColor)
            ColorPicker("Текст", selection: $textColor)
            ColorPicker("Кнопки", selection: $buttonColor)
        }
        .navigationTitle("Настройки")
    }
}

@main
struct TodoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
