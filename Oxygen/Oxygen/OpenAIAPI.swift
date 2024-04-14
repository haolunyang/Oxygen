//
//  OpenAIAPI.swift
//  Oxygen
//
//  Created by George Kim on 2/3/24.
//

import SwiftUI
import Combine

struct ChatGPTRequest: Codable {
    let model: String
    let messages: [Message]
    let temperature: Double
    let max_tokens: Int
}

struct Message: Codable {
    let role: String
    let content: String
}

struct ChatGPTResponse: Codable {
    let id: String?
    let object: String?
    let created: Int?
    let model: String?
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message?
}

public class NetworkManager {
    func sendRequest(prompt: String, model: String = "gpt-3.5-turbo", completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Replace your API key here:
        request.addValue("Bearer sk-REPLACEYOURAPIKEYHERE", forHTTPHeaderField: "Authorization")
        
        let requestBody = ChatGPTRequest(model: model, messages: [Message(role: "user", content: prompt)], temperature: 0.7, max_tokens: 150)
        
        do {
            let requestData = try JSONEncoder().encode(requestBody)
            request.httpBody = requestData
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(error!))
                }
                return
            }
            
            do {
                let jsonResponse = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
                if let firstResponseMessage = jsonResponse.choices.first?.message?.content {
                    DispatchQueue.main.async {
                        completion(.success(firstResponseMessage))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No response message found"])))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        .resume()
    }
}
