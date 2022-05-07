//
//  TikTok.swift
//  
//
//  Created by Noah Pistilli on 2022-05-05.
//

#if os(Linux)
import FoundationNetworking
#endif

import Foundation
import Swiftcord

class TikTok: ListenerAdapter {
    /// The base URL for Tik Tok's TTS API
    let BaseTikTokURL = "https://api16-normal-useast5.us.tiktokv.com/media/api/text/speech/invoke"
    
    struct TikTokTTS: Decodable {
        
        /// The struct that contains the TTS data
        private let data: ActualTTS
        
        /// TikTok nests our TTS data inside a dictionary
        private struct ActualTTS: Decodable {
            let v_str: String
        }
        
        /// Returns the TTS data in raw bytes
        func getTTSData() -> Data {
            return Data(base64Encoded: self.data.v_str)!
        }
    }

    override func onSlashCommandEvent(event: SlashCommandEvent) async {
        // Now parse arguments and request from TikTok
        let speaker = event.getOptionAsString(optionName: "voice")!
        
        let builder = ModalBuilder(modal: Modal(customId: speaker, title: "TikTok TTS"), textInput: TextInput(customID: speaker, style: .paragraph, label: "Text to convert"))

        try! await event.replyModal(modal: builder)
    }
    
    override func onTextInputEvent(event: TextInputEvent) async {
        do {
            let text = event.value
            
            // Swift doesn't like some text that is passed to an URL. Until I solve this,
            // just check if Swift will allow it.
            if !self.CheckIfValidURL(text: self.SanitizeText(text)) {
                try! await event.reply(message: "Invalid Text was passed!")
                return
            }
            
            let tiktok = try await self.RequestFromTikTok(text: text, voice: event.modalID)
            
            let attachment = AttachmentBuilder(filename: "voice.mp3", data: tiktok.getTTSData())
            
            try! await event.reply(message: "Here is your voice!", attachments: attachment)
        } catch {
            try! await event.reply(message: "An error has occured\n\n. Error: \(error.localizedDescription)")
        }
    }
    
    func RequestFromTikTok(text: String, voice: String) async throws -> TikTokTTS {
        var request = await URLRequest(url: CreateTikTokURL(text: SanitizeText(text), voice: voice))
        request.httpMethod = "POST"
        
        let response = try await AsyncHTTPRequest(request)
        
        return try JSONDecoder().decode(TikTokTTS.self, from: response!)
    }
    
    func CreateTikTokURL(text: String, voice: String) async -> URL {
        return URL(string: "\(BaseTikTokURL)/?text_speaker=\(voice)&req_text=\(text)&speaker_map_type=0")!
    }
    
    func CheckIfValidURL(text: String) -> Bool {
        if URL(string: text) != nil {
            return true
        } else {
            return false
        }
    }
    
    /// Cleans the text into a format Tik Tok can use
    func SanitizeText(_ text: String) -> String {
        // Replace all symbols with their proper name
        var sanitized = text.replacingOccurrences(of: "+", with: "plus")
        sanitized = sanitized.replacingOccurrences(of: "&", with: "and")
        sanitized = sanitized.replacingOccurrences(of: "=", with: "equals")
        sanitized = sanitized.replacingOccurrences(of: "-", with: "minus")
        
        // The plus symbol is used for spaces
        sanitized = sanitized.replacingOccurrences(of: " ", with: "+")
        
        return sanitized
    }
}
