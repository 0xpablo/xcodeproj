import Foundation
import Unbox

// This is the element for the framewrok link build phase.
public struct PBXFrameworksBuildPhase {
    
    // MARK: - Properties
    
    /// Element reference.
    public let reference: UUID
    
    /// Framework build phase files.
    public let files: Set<UUID>
    
    /// Build phase build action mask.
    public let buildActionMask: Int
    
    /// Build phase run only for deployment post processing.
    public let runOnlyForDeploymentPostprocessing: UInt
    
    // MARK: - Init
    
    /// Initializes the frameworks build phase with its attributes.
    ///
    /// - Parameters:
    ///   - reference: element reference.
    ///   - files: frameworks build phase files.
    ///   - runOnlyForDeploymentPostprocessing: run only for deployment pos processing value.
    public init(reference: UUID,
                files: Set<UUID>,
                runOnlyForDeploymentPostprocessing: UInt,
                buildActionMask: Int = 2147483647) {
        self.reference = reference
        self.files = files
        self.runOnlyForDeploymentPostprocessing = runOnlyForDeploymentPostprocessing
        self.buildActionMask = buildActionMask
    }
    
}

// MARK: - PBXFrameworksBuildPhase Extension (Extras)

extension PBXFrameworksBuildPhase {
    
    /// Returns a new frameworks build phase with a new file added.
    ///
    /// - Parameter file: file to be added.
    /// - Returns: new build phase with the file added.
    public func adding(file: UUID) -> PBXFrameworksBuildPhase {
        var files = self.files
        files.insert(file)
        return PBXFrameworksBuildPhase(reference: reference,
                                       files: files,
                                       runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing)
    }
    
    /// Returns a new frameworks build phase with the file removed.
    ///
    /// - Parameter file: file to be removed.
    /// - Returns: new frameworks build phase with the file removed.
    public func removing(file: UUID) -> PBXFrameworksBuildPhase {
        var files = self.files
        files.remove(file)
        return PBXFrameworksBuildPhase(reference: reference,
                                       files: files,
                                       runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing)
    }
    
}

// MARK: - PBXFrameworksBuildPhase Extension (ProjectElement)

extension PBXFrameworksBuildPhase: ProjectElement {
    
    public static var isa: String = "PBXFrameworksBuildPhase"

    public static func == (lhs: PBXFrameworksBuildPhase,
                           rhs: PBXFrameworksBuildPhase) -> Bool {
        return lhs.reference == rhs.reference &&
            lhs.files == rhs.files &&
            lhs.runOnlyForDeploymentPostprocessing == rhs.runOnlyForDeploymentPostprocessing
    }
    
    public var hashValue: Int { return self.reference.hashValue }
    
    public init(reference: UUID, dictionary: [String : Any]) throws {
        self.reference = reference
        let unboxer = Unboxer(dictionary: dictionary)
        self.files = try unboxer.unbox(key: "files")
        self.runOnlyForDeploymentPostprocessing = try unboxer.unbox(key: "runOnlyForDeploymentPostprocessing")
        self.buildActionMask = try unboxer.unbox(key: "buildActionMask")
    }
}

// MARK: - PBXFrameworksBuildPhase Extension (PlistSerializable)

extension PBXFrameworksBuildPhase: PlistSerializable {
    
    func plistKeyAndValue(proj: PBXProj) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = [:]
        dictionary["isa"] = .string(CommentedString(PBXFrameworksBuildPhase.isa))
        dictionary["buildActionMask"] = .string(CommentedString("\(buildActionMask)"))
        dictionary["files"] = .array(files.map({ (fileReference) -> PlistValue in
            let comment = proj.buildFileName(reference: reference).flatMap({"\($0) in Frameworks"})
            return .string(CommentedString(fileReference, comment: comment))
        }))
        dictionary["runOnlyForDeploymentPostprocessing"] = .string(CommentedString("\(runOnlyForDeploymentPostprocessing)"))
        return (key: CommentedString(self.reference,
                                                 comment: "Frameworks"),
                value: .dictionary(dictionary))
    }
    
}
