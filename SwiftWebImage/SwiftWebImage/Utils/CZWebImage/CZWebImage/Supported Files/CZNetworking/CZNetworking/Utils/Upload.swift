//
//  Upload.swift
//  CZNetworking
//
//  Created by Cheng Zhang on 1/24/19.
//  Copyright © 2019 Cheng Zhang. All rights reserved.
//

import CZUtils
import MobileCoreServices

public class Upload {
    static let kFilePath = "file"
    
    // MARK: - Upload File
    
    public static func buildRequest(_ url: URL,
                                    params: HTTPRequestWorker.Params = [:],
                                    filePath: String) throws -> URLRequest {
        return try buildRequest(url, params: params, filePaths: [filePath])
    }
    
    // MARK: - Upload Data
    
    public static func buildRequest(_ url: URL,
                                    params: HTTPRequestWorker.Params? = [:],
                                    fileName: String,
                                    data: Data) throws -> URLRequest {
        let boundary = generateBoundaryString()
        var request = buildBaseRequest(url, boundary: boundary)
        let file = FileInfo(name: fileName, data: data)
        request.httpBody = try buildBody(
            with: params,
            files: [file],
            boundary: boundary)
        return request
    }
}

private extension Upload {
    struct FileInfo {
        let name: String
        let data: Data
    }
    
    static func buildBaseRequest(_ url: URL, boundary: String) -> URLRequest {

//#if false
//        case let .POST(contentType, data):
//        // Set postData as input data if non-nil
//        let postData = data ?? paramsString?.data(using: .utf8)
//        let contentTypeValue: String = {
//            switch contentType {
//            case .formUrlencoded:
//                return "application/x-www-form-urlencoded"
//            case .textPlain:
//                return "text/plain"
//            }
//        }()
//        request.addValue(contentTypeValue, forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        let contentLength = postData?.count ?? 0
//        request.addValue("\(contentLength)", forHTTPHeaderField: "Content-Length")
//        request.httpBody = postData
//        dataTask = urlSession?.uploadTask(withStreamedRequest: request as URLRequest)
//#endif

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    static func buildRequest(_ url: URL,
                             params: HTTPRequestWorker.Params = [:],
                             filePaths: [String]) throws -> URLRequest {
        let boundary = generateBoundaryString()
        var request = buildBaseRequest(url, boundary: boundary)
        
        let files: [FileInfo] = try filePaths.map { filePath in
            let url = URL(fileURLWithPath: filePath)
            let name = url.lastPathComponent
            let data = try Data(contentsOf: url)
            return FileInfo(name: name, data: data)
        }
        
        request.httpBody = try buildBody(
            with: params,
            files: files,
            boundary: boundary)
        return request
    }
    
    static func buildBody(with params: HTTPRequestWorker.Params?,
                          filePathKey: String = kFilePath,
                          files: [FileInfo],
                          boundary: String) throws -> Data {
        // Build multipart/form-data
        var body = Data()
        if let params = params {
            for (key, value) in params {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }
        
        for file in files {
            let mimetype = mimeType(for: file.name)
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(file.name)\"\r\n")
            body.append("Content-Type: \(mimetype)\r\n\r\n")
            body.append(file.data)
            body.append("\r\n")
        }
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    static func generateBoundaryString() -> String {
        return "Boundary-\(UUID.generate())"
    }
    
    static func mimeType(for path: String) -> String {
        let url = URL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
}
