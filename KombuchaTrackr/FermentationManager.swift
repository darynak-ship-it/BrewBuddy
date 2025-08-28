//
//  FermentationManager.swift
//  KombuchaTrackr
//
//  Created by Daryna Kalnichenko on 8/4/25.
//

import Foundation
import UserNotifications
import SwiftUI

class FermentationManager: ObservableObject {
    @Published var activeFermentations: [Fermentation] = []
    @Published var fermentationHistory: [Fermentation] = []
    @Published var completedUnratedFermentation: Fermentation?
    
    private var timers: [String: Timer] = [:]
    private var isUpdatingDuration = false
    private let userDefaults = UserDefaults.standard
    private let activeFermentationsKey = "activeFermentations"
    private let historyKey = "fermentationHistory"
    private let nextBatchNumberKey = "nextBatchNumber"
    
    init() {
        loadActiveFermentations()
        loadHistory()
        startAllTimers()
    }
    
    // MARK: - Public Methods
    
    var hasActiveFermentations: Bool {
        !activeFermentations.isEmpty
    }
    
    var totalActiveBatches: Int {
        activeFermentations.count
    }
    
    var hasCompletedUnratedFermentation: Bool {
        completedUnratedFermentation != nil
    }
    
    func startFermentation(days: Int) {
        let endDate = Date().addingTimeInterval(TimeInterval(days * 24 * 60 * 60))
        let batchNumber = getNextBatchNumber()
        let batchName = "Batch #\(batchNumber)"
        
        let newFermentation = Fermentation(
            id: UUID().uuidString,
            name: batchName,
            startDate: Date(),
            endDate: endDate,
            durationDays: days
        )
        
        activeFermentations.append(newFermentation)
        scheduleNotification(for: newFermentation)
        saveActiveFermentations()
        startTimer(for: newFermentation)
    }
    
    func startFermentationWithDetails(days: Int, scobyName: String?, teaType: TeaType?, sugar: String?, starterLiquidAmount: String?, activeNotes: String?) {
        let endDate = Date().addingTimeInterval(TimeInterval(days * 24 * 60 * 60))
        let batchNumber = getNextBatchNumber()
        let batchName = "Batch #\(batchNumber)"
        
        let newFermentation = Fermentation(
            id: UUID().uuidString,
            name: batchName,
            startDate: Date(),
            endDate: endDate,
            durationDays: days,
            rating: nil,
            notes: nil,
            scobyName: scobyName,
            teaType: teaType,
            sugar: sugar,
            starterLiquidAmount: starterLiquidAmount,
            activeNotes: activeNotes
        )
        
        activeFermentations.append(newFermentation)
        scheduleNotification(for: newFermentation)
        saveActiveFermentations()
        startTimer(for: newFermentation)
    }
    
    func updateFermentationDetails(id: String, scobyName: String?, teaType: TeaType?, sugar: String?, starterLiquidAmount: String?, activeNotes: String?) {
        guard let index = activeFermentations.firstIndex(where: { $0.id == id }) else { return }
        let currentFermentation = activeFermentations[index]
        
        let updatedFermentation = Fermentation(
            id: currentFermentation.id,
            name: currentFermentation.name,
            startDate: currentFermentation.startDate,
            endDate: currentFermentation.endDate,
            durationDays: currentFermentation.durationDays,
            rating: currentFermentation.rating,
            notes: currentFermentation.notes,
            scobyName: scobyName,
            teaType: teaType,
            sugar: sugar,
            starterLiquidAmount: starterLiquidAmount,
            activeNotes: activeNotes
        )
        
        activeFermentations[index] = updatedFermentation
        saveActiveFermentations()
    }
    
    func stopFermentation(id: String) {
        guard let index = activeFermentations.firstIndex(where: { $0.id == id }) else { return }
        let completedFermentation = activeFermentations[index]
        
        // Set as completed unrated fermentation instead of immediately adding to history
        completedUnratedFermentation = completedFermentation
        
        // Remove from active fermentations
        activeFermentations.remove(at: index)
        
        // Stop timer and cancel notification
        stopTimer(for: completedFermentation)
        cancelNotification(for: completedFermentation)
        
        saveActiveFermentations()
    }
    
    func updateFermentationDuration(id: String, days: Int) {
        guard let index = activeFermentations.firstIndex(where: { $0.id == id }) else { return }
        let currentFermentation = activeFermentations[index]
        
        // Set flag to prevent timer updates during transition
        isUpdatingDuration = true
        
        // Stop the current timer to prevent flickering
        stopTimer(for: currentFermentation)
        
        // Calculate new end date
        let newEndDate = currentFermentation.startDate.addingTimeInterval(TimeInterval(days * 24 * 60 * 60))
        
        // Update fermentation object
        let updatedFermentation = Fermentation(
            id: currentFermentation.id,
            name: currentFermentation.name,
            startDate: currentFermentation.startDate,
            endDate: newEndDate,
            durationDays: days,
            rating: currentFermentation.rating,
            notes: currentFermentation.notes,
            scobyName: currentFermentation.scobyName,
            teaType: currentFermentation.teaType,
            sugar: currentFermentation.sugar,
            starterLiquidAmount: currentFermentation.starterLiquidAmount,
            activeNotes: currentFermentation.activeNotes
        )
        
        // Notify observers that the object will change
        objectWillChange.send()
        
        activeFermentations[index] = updatedFermentation
        
        // Update notification and save
        scheduleNotification(for: updatedFermentation)
        saveActiveFermentations()
        
        // Restart the timer with the new duration
        startTimer(for: updatedFermentation)
        
        // Clear the flag after a brief delay to ensure smooth transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.isUpdatingDuration = false
        }
    }
    
    // MARK: - Robust Editing Methods
    
    func setDuration(for id: String, toDays newDays: Int) {
        let clamped = max(1, newDays)
        
        if let index = activeFermentations.firstIndex(where: { $0.id == id }) {
            var updatedFermentation = activeFermentations[index]
            
            // Recompute end date from the original start date
            if let newEnd = Calendar.current.date(byAdding: .day, value: clamped, to: updatedFermentation.startDate) {
                updatedFermentation = Fermentation(
                    id: updatedFermentation.id,
                    name: updatedFermentation.name,
                    startDate: updatedFermentation.startDate,
                    endDate: newEnd,
                    durationDays: clamped,
                    rating: updatedFermentation.rating,
                    notes: updatedFermentation.notes,
                    scobyName: updatedFermentation.scobyName,
                    teaType: updatedFermentation.teaType,
                    sugar: updatedFermentation.sugar,
                    starterLiquidAmount: updatedFermentation.starterLiquidAmount,
                    activeNotes: updatedFermentation.activeNotes
                )
                
                // Update the fermentation in the array
                activeFermentations[index] = updatedFermentation
                
                // Restart the timer for this fermentation
                restartTimer(for: updatedFermentation)
                
                // Save changes
                saveActiveFermentations()
                
                // Notify SwiftUI of the change
                objectWillChange.send()
            }
        }
    }
    
    private func restartTimer(for fermentation: Fermentation) {
        // Cancel existing timer if it exists
        if let existingTimer = timers[fermentation.id] {
            existingTimer.invalidate()
        }
        
        // Start new timer
        startTimer(for: fermentation)
    }
    
    func finishFermentationEarly(id: String) {
        guard let index = activeFermentations.firstIndex(where: { $0.id == id }) else { return }
        let currentFermentation = activeFermentations[index]
        
        // Set end date to now to mark as complete
        let completedFermentation = Fermentation(
            id: currentFermentation.id,
            name: currentFermentation.name,
            startDate: currentFermentation.startDate,
            endDate: Date(),
            durationDays: currentFermentation.durationDays,
            rating: currentFermentation.rating,
            notes: currentFermentation.notes,
            scobyName: currentFermentation.scobyName,
            teaType: currentFermentation.teaType,
            sugar: currentFermentation.sugar,
            starterLiquidAmount: currentFermentation.starterLiquidAmount,
            activeNotes: currentFermentation.activeNotes
        )
        
        // Notify observers that the object will change
        objectWillChange.send()
        
        // Set as completed unrated fermentation instead of immediately adding to history
        completedUnratedFermentation = completedFermentation
        
        // Remove from active fermentations
        activeFermentations.remove(at: index)
        
        // Stop timer and cancel notification
        stopTimer(for: currentFermentation)
        cancelNotification(for: currentFermentation)
        
        saveActiveFermentations()
    }
    
    func updateRating(id: String, rating: Int) {
        guard let index = activeFermentations.firstIndex(where: { $0.id == id }) else { return }
        activeFermentations[index].rating = rating
        saveActiveFermentations()
    }
    
    func updateNotes(id: String, notes: String) {
        guard let index = activeFermentations.firstIndex(where: { $0.id == id }) else { return }
        activeFermentations[index].notes = notes
        saveActiveFermentations()
    }
    
    func completeRatingAndNotes() {
        if let completedFermentation = completedUnratedFermentation {
            addToHistory(completedFermentation)
            completedUnratedFermentation = nil
        }
    }
    
    func deleteFromHistory(_ fermentation: Fermentation) {
        if let index = fermentationHistory.firstIndex(where: { $0.id == fermentation.id }) {
            fermentationHistory.remove(at: index)
            saveHistory()
        }
    }
    
    func updateHistoryFermentation(_ fermentation: Fermentation) {
        if let index = fermentationHistory.firstIndex(where: { $0.id == fermentation.id }) {
            fermentationHistory[index] = fermentation
            saveHistory()
        }
    }
    
    func getFermentation(id: String) -> Fermentation? {
        return activeFermentations.first { $0.id == id }
    }
    
    // MARK: - Private Methods
    
    private func getNextBatchNumber() -> Int {
        let nextNumber = userDefaults.integer(forKey: nextBatchNumberKey)
        let newNumber = nextNumber == 0 ? 1 : nextNumber + 1
        userDefaults.set(newNumber, forKey: nextBatchNumberKey)
        return newNumber
    }
    
    private func startTimer(for fermentation: Fermentation) {
        stopTimer(for: fermentation)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimeRemaining(for: fermentation)
        }
        
        timers[fermentation.id] = timer
        RunLoop.main.add(timer, forMode: .common)
    }
    
    private func stopTimer(for fermentation: Fermentation) {
        timers[fermentation.id]?.invalidate()
        timers.removeValue(forKey: fermentation.id)
    }
    
    private func startAllTimers() {
        for fermentation in activeFermentations {
            startTimer(for: fermentation)
        }
    }
    
    private func updateTimeRemaining(for fermentation: Fermentation) {
        guard !isUpdatingDuration else { return }
        
        // Get the current fermentation data to ensure we're working with the latest
        guard let currentFermentation = activeFermentations.first(where: { $0.id == fermentation.id }) else { return }
        
        let remaining = currentFermentation.endDate.timeIntervalSinceNow
        
        if remaining <= 0 {
            // Fermentation is complete
            DispatchQueue.main.async { [weak self] in
                self?.finishFermentationEarly(id: fermentation.id)
            }
        }
    }
    
    private func scheduleNotification(for fermentation: Fermentation) {
        cancelNotification(for: fermentation)
        
        let content = UNMutableNotificationContent()
        content.title = "\(fermentation.name) Ready! 🍵"
        content.body = "Your kombucha fermentation is complete! Time to enjoy your delicious brew."
        content.sound = .default
        
        let timeInterval = fermentation.endDate.timeIntervalSinceNow
        
        // For very long durations, schedule notification for maximum allowed time
        let maxNotificationInterval: TimeInterval = 365 * 24 * 60 * 60 // 1 year in seconds
        let notificationInterval = min(timeInterval, maxNotificationInterval)
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: notificationInterval,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "kombuchaFermentation_\(fermentation.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling error: \(error)")
            }
        }
    }
    
    private func cancelNotification(for fermentation: Fermentation) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["kombuchaFermentation_\(fermentation.id)"]
        )
    }
    
    private func saveActiveFermentations() {
        if let encoded = try? JSONEncoder().encode(activeFermentations) {
            userDefaults.set(encoded, forKey: activeFermentationsKey)
        }
    }
    
    private func loadActiveFermentations() {
        if let data = userDefaults.data(forKey: activeFermentationsKey),
           let loadedFermentations = try? JSONDecoder().decode([Fermentation].self, from: data) {
            
            // Filter out completed fermentations
            let now = Date()
            activeFermentations = loadedFermentations.filter { $0.endDate > now }
            
            // Add completed ones to history
            let completed = loadedFermentations.filter { $0.endDate <= now }
            for fermentation in completed {
                addToHistory(fermentation)
            }
        }
    }
    
    private func loadHistory() {
        if let data = userDefaults.data(forKey: historyKey),
           let loadedHistory = try? JSONDecoder().decode([Fermentation].self, from: data) {
            fermentationHistory = loadedHistory.sorted { $0.endDate > $1.endDate }
        }
    }
    
    private func addToHistory(_ fermentation: Fermentation) {
        fermentationHistory.insert(fermentation, at: 0)
        // Keep only last 50 entries
        if fermentationHistory.count > 50 {
            fermentationHistory = Array(fermentationHistory.prefix(50))
        }
        saveHistory()
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(fermentationHistory) {
            userDefaults.set(encoded, forKey: historyKey)
        }
    }
    
    deinit {
        for timer in timers.values {
            timer.invalidate()
        }
    }
}

struct Fermentation: Codable, Identifiable {
    let id: String
    let name: String
    let startDate: Date
    let endDate: Date
    let durationDays: Int
    var rating: Int?
    var notes: String?
    
    // New fields for fermentation details
    var scobyName: String?
    var teaType: TeaType?
    var sugar: String?
    var starterLiquidAmount: String?
    var activeNotes: String?
    
    var progress: Double {
        let totalDuration = endDate.timeIntervalSince(startDate)
        let elapsed = Date().timeIntervalSince(startDate)
        return min(max(elapsed / totalDuration, 0), 1)
    }
    
    var isComplete: Bool {
        return Date() >= endDate
    }
    
    var timeRemaining: TimeInterval {
        return max(0, endDate.timeIntervalSinceNow)
    }
    
    // MARK: - Legacy Support
    
    init(startDate: Date, endDate: Date, durationDays: Int, rating: Int? = nil, notes: String? = nil) {
        self.id = UUID().uuidString
        self.name = "Kombucha Batch"
        self.startDate = startDate
        self.endDate = endDate
        self.durationDays = durationDays
        self.rating = rating
        self.notes = notes
        self.scobyName = nil
        self.teaType = nil
        self.sugar = nil
        self.starterLiquidAmount = nil
        self.activeNotes = nil
    }
    
    init(id: String, name: String, startDate: Date, endDate: Date, durationDays: Int, rating: Int? = nil, notes: String? = nil, scobyName: String? = nil, teaType: TeaType? = nil, sugar: String? = nil, starterLiquidAmount: String? = nil, activeNotes: String? = nil) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.durationDays = durationDays
        self.rating = rating
        self.notes = notes
        self.scobyName = scobyName
        self.teaType = teaType
        self.sugar = sugar
        self.starterLiquidAmount = starterLiquidAmount
        self.activeNotes = activeNotes
    }
}

// MARK: - Tea Type Enum
enum TeaType: String, CaseIterable, Codable {
    case black = "Black"
    case green = "Green"
    case herbal = "Herbal"
    case oolong = "Oolong"
    case other = "Other"
    
    var displayName: String {
        return self.rawValue
    }
} 