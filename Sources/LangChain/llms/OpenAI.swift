//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/10.
//

import Foundation
import NIOPosix
import AsyncHTTPClient
import OpenAIKit

public class OpenAI: LLM {
    
    let temperature: Double
    let model: ModelID
    let apiKey: String?
    
    public init(temperature: Double = 0.0, model: ModelID = Model.GPT3.gpt3_5Turbo16K, callbacks: [BaseCallbackHandler] = [], cache: BaseCache? = nil, apiKey: String? = nil) {
        self.temperature = temperature
        self.model = model
        self.apiKey = apiKey
        super.init(callbacks: callbacks, cache: cache)
    }
    
    public override func _send(text: String, stops: [String] = []) async throws -> LLMResult {
        let env = Env.loadEnv()
        
        if let apiKey = self.apiKey ?? env["OPENAI_API_KEY"] {
            let baseUrl = env["OPENAI_API_BASE"] ?? "api.openai.com"
            let eventLoopGroup = ThreadManager.thread

            let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
            defer {
                // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
                try? httpClient.syncShutdown()
            }
            let configuration = Configuration(apiKey: apiKey, api: API(scheme: .https, host: baseUrl))

            let openAIClient = OpenAIKit.Client(httpClient: httpClient, configuration: configuration)
            
            do{
                let completion = try await openAIClient.chats.create(model: model, messages: [.user(content: text)], temperature: temperature, stops: stops)
                return LLMResult(llm_output: completion.choices.first!.message.content)
            }
            catch {
                print("An error occurred: \(error)")
                return LLMResult(llm_output: "Error");
           }
        } else {
            print("Please set openai api key.")
            return LLMResult(llm_output: "Please set openai api key.")
        }
        
    }
    
    
}
