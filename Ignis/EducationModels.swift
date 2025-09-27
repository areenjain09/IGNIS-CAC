import SwiftUI
import Foundation

// MARK: - Core Education Data Models
// Following Apple's Swift API Design Guidelines

/// Represents a complete learning module with lessons, quizzes, and progress tracking
struct LearningModule: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let category: ModuleCategory
    let difficulty: DifficultyLevel
    let estimatedDuration: TimeInterval
    let iconName: String
    let colorScheme: ModuleColorScheme
    let prerequisites: [UUID] // Other module IDs required before this one
    
    var lessons: [Lesson]
    var quiz: Quiz?
    var flashcards: [Flashcard]?
    var resources: [Resource]
    
    // Progress tracking
    var isUnlocked: Bool
    var completedLessons: Set<UUID>
    var quizAttempts: [QuizAttempt]
    var lastAccessedDate: Date?
    var bookmarkedLessons: Set<UUID>
    
    // Computed properties
    var progress: Double {
        guard !lessons.isEmpty else { return 0.0 }
        return Double(completedLessons.count) / Double(lessons.count)
    }
    
    var isCompleted: Bool {
        let lessonsCompleted = completedLessons.count == lessons.count
        let quizPassed = quiz?.bestScore ?? 0 >= 0.7 // 70% passing grade
        return lessonsCompleted && quizPassed
    }
    
    var badge: String? {
        if isCompleted {
            switch difficulty {
            case .beginner: return "🔥 Fire Safety Rookie"
            case .intermediate: return "🏆 Safety Expert"
            case .advanced: return "🎖️ Fire Safety Master"
            }
        }
        return nil
    }
    
    var formattedDuration: String {
        let minutes = Int(estimatedDuration / 60)
        return "\(minutes) min"
    }
}

/// Individual lesson within a module
struct Lesson: Identifiable, Codable, Equatable {
    let id: UUID
    let moduleId: UUID
    let title: String
    let content: LessonContent
    let estimatedDuration: TimeInterval
    
    // Progress tracking
    var isCompleted: Bool
    var timeSpent: TimeInterval = 0
    var lastAccessedDate: Date?
    var userNotes: String
    
    var formattedReadingTime: String {
        let minutes = Int(estimatedDuration / 60)
        return "\(minutes) min read"
    }
}

/// Rich content for lessons supporting multiple media types
struct LessonContent: Codable, Equatable {
    let sections: [ContentSection]
}

struct ContentSection: Identifiable, Codable, Equatable {
    let id: UUID
    let type: ContentType
    let title: String?
    let content: String
    let mediaURL: URL?
}

/// Interactive quiz system
struct Quiz: Identifiable, Codable, Equatable {
    let id: UUID
    let moduleId: UUID
    let title: String
    let description: String
    let questions: [QuizQuestion]
    let timeLimit: TimeInterval?
    let passingScore: Double // 0.0 to 1.0
    let maxAttempts: Int
    
    // Best score from all attempts
    var bestScore: Double {
        // This would be calculated from quiz attempts
        return 0.0
    }
}

struct QuizQuestion: Identifiable, Codable, Equatable {
    let id: UUID
    let question: String
    let type: QuestionType
    let options: [String] // For multiple choice
    let correctAnswers: [Int] // Indices of correct answers
    let explanation: String
    let points: Int
    let mediaURL: URL? // Optional image/video
}

struct QuizAttempt: Identifiable, Codable, Equatable {
    let id: UUID
    let quizId: UUID
    let startDate: Date
    let endDate: Date?
    let answers: [UUID: [Int]] // QuestionId: Selected answer indices
    let score: Double
    let isCompleted: Bool
}

/// Flashcard system for spaced repetition learning
struct Flashcard: Identifiable, Codable, Equatable {
    let id: UUID
    let moduleId: UUID
    let front: String
    let back: String
    let difficulty: DifficultyLevel
    let tags: [String]
    
    // Spaced repetition data
    var easeFactor: Double = 2.5
    var interval: Int = 1
    var repetitions: Int = 0
    var nextReviewDate: Date = Date()
    var isLearned: Bool = false
}

/// Learning resources and references
struct Resource: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let type: ResourceType
    let url: String?
}

/// User progress and achievements
struct UserProgress: Codable, Equatable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalXP: Int = 0
    var currentLevel: Int = 1
    var completedModules: Set<UUID> = []
    var unlockedModules: Set<UUID> = []
    var achievements: [Achievement] = []
    var studyTimeToday: TimeInterval = 0
    var totalStudyTime: TimeInterval = 0
    var lastStudyDate: Date?
    var preferredStudyTime: StudyTimePreference = .flexible
    var dailyGoalMinutes: Int = 15
    
    // Computed properties
    var xpForNextLevel: Int {
        return currentLevel * 100 // Simple progression
    }
    
    var levelProgress: Double {
        let currentLevelXP = (currentLevel - 1) * 100
        let nextLevelXP = currentLevel * 100
        let progressInLevel = totalXP - currentLevelXP
        return Double(progressInLevel) / Double(nextLevelXP - currentLevelXP)
    }
}

struct Achievement: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    let unlockedDate: Date
    let category: AchievementCategory
}

// MARK: - Enums

enum ModuleCategory: String, CaseIterable, Codable {
    case basics = "Wildfire Basics"
    case prevention = "Prevention"
    case emergency = "Emergency Response"
    case advanced = "Advanced Topics"
    case recovery = "Recovery"
    case community = "Community Safety"
    
    var iconName: String {
        switch self {
        case .basics: return "flame.fill"
        case .prevention: return "shield.fill"
        case .emergency: return "exclamationmark.triangle.fill"
        case .advanced: return "brain.head.profile"
        case .recovery: return "heart.fill"
        case .community: return "person.3.fill"
        }
    }
}

enum DifficultyLevel: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var color: Color {
        switch self {
        case .beginner: return .appSuccess
        case .intermediate: return .appWarning
        case .advanced: return .appError
        }
    }
}

enum ModuleColorScheme: String, Codable {
    case primary, secondary, accent, success, warning, error
    
    var colors: (primary: Color, secondary: Color) {
        switch self {
        case .primary: return (.appPrimary, .appSecondary)
        case .secondary: return (.appSecondary, .appAccent)
        case .accent: return (.appAccent, .appPrimary)
        case .success: return (.appSuccess, Color.appSuccess.opacity(0.7))
        case .warning: return (.appWarning, Color.appWarning.opacity(0.7))
        case .error: return (.appError, Color.appError.opacity(0.7))
        }
    }
}

enum ContentType: String, Codable {
    case text, image, video, audio, interactive, checklist, infographic
}

enum QuestionType: String, Codable {
    case multipleChoice = "multiple_choice"
    case multipleSelect = "multiple_select"
    case trueFalse = "true_false"
    case shortAnswer = "short_answer"
}

enum ResourceType: String, Codable {
    case article, video, podcast, tool, checklist, infographic, externalLink, pdf
    
    var iconName: String {
        switch self {
        case .article: return "doc.text.fill"
        case .video: return "play.rectangle.fill"
        case .podcast: return "waveform"
        case .tool: return "wrench.fill"
        case .checklist: return "checklist"
        case .infographic: return "photo.fill"
        case .externalLink: return "link"
        case .pdf: return "doc.fill"
        }
    }
}

enum AchievementCategory: String, Codable {
    case streak, completion, mastery, social, special
}

enum StudyTimePreference: String, CaseIterable, Codable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case flexible = "Flexible"
}

enum InteractiveElement: Codable, Equatable {
    case checklistItem(String, Bool)
    case quiz(UUID)
    case flashcard(UUID)
    case simulation(String)
    case calculator(String)
}

// MARK: - Extensions

extension LearningModule {
    /// Creates a sample module for preview/testing
    static func sample(id: UUID = UUID()) -> LearningModule {
        LearningModule(
            id: id,
            title: "Wildfire Basics",
            description: "Understanding fire behavior, causes, and basic safety principles",
            category: .basics,
            difficulty: .beginner,
            estimatedDuration: 900, // 15 minutes
            iconName: "flame.fill",
            colorScheme: .primary,
            prerequisites: [],
            lessons: [Lesson.sample()],
            quiz: Quiz.sample(),
            flashcards: nil,
            resources: [Resource.sample()],
            isUnlocked: true,
            completedLessons: [],
            quizAttempts: [],
            lastAccessedDate: nil,
            bookmarkedLessons: []
        )
    }
}

extension Lesson {
    static func sample(id: UUID = UUID()) -> Lesson {
        Lesson(
            id: id,
            moduleId: UUID(),
            title: "What Causes Wildfires?",
            content: LessonContent(sections: [
                ContentSection(
                    id: UUID(),
                    type: .text,
                    title: "Natural Causes",
                    content: "Lightning strikes are responsible for about 10% of all wildfires...",
                    mediaURL: nil
                )
            ]),
            estimatedDuration: 300,
            isCompleted: false,
            lastAccessedDate: nil,
            userNotes: ""
        )
    }
}

extension Quiz {
    static func sample() -> Quiz {
        Quiz(
            id: UUID(),
            moduleId: UUID(),
            title: "Wildfire Basics Quiz",
            description: "Test your knowledge of wildfire fundamentals",
            questions: [QuizQuestion.sample()],
            timeLimit: 600, // 10 minutes
            passingScore: 0.7,
            maxAttempts: 3
        )
    }
}

extension QuizQuestion {
    static func sample() -> QuizQuestion {
        QuizQuestion(
            id: UUID(),
            question: "What percentage of wildfires are caused by human activities?",
            type: .multipleChoice,
            options: ["50%", "75%", "90%", "95%"],
            correctAnswers: [2], // 90%
            explanation: "According to the National Park Service, human activities cause about 90% of wildfires.",
            points: 10,
            mediaURL: nil
        )
    }
}

extension Resource {
    static func sample() -> Resource {
        Resource(
            id: UUID(),
            title: "Wildfire Safety Checklist",
            description: "Essential steps to protect your home and family",
            type: .checklist,
            url: nil
        )
    }
}
