<a name="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/github_username/mac_voice_whispers">
    <img src="mac_voice_whispers/Documentation/Logo.webp" alt="Logo" width="120" height="120">
  </a>

<h3 align="center">Mac Voice Whispers</h3>

  <p align="center">
    A simple macOS app leveraging OpenAI's Whisper model to convert voice to text.
    <br />
  </p>
</div>
 
<!-- ABOUT THE PROJECT -->
## About The Project

Here's a simple macOS app that uses the tiny model of OpenAI's Whisper to convert spoken words into text directly within the application. This project is designed to be lightweight, efficient, and suitable for everyday tasks requiring voice transcription.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

- ![Swift][Swift-badge]
- ![SwiftUI][SwiftUI-badge]

[Swift-badge]: https://img.shields.io/badge/Swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white
[SwiftUI-badge]: https://img.shields.io/badge/SwiftUI-0D1117?style=for-the-badge&logo=swift&logoColor=white

<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

- Xcode: Ensure you have Xcode installed to run and modify the project. Xcode can be installed from the Mac App Store.

### Installation

1. **Clone the repo**
   ```sh
   git clone https://github.com/github_username/mac_voice_whispers.git
   ```

2. **Download the model binary**
   [ggml-tiny.en-q5_1.bin](https://huggingface.co/ggerganov/whisper.cpp/blob/main/ggml-tiny.en-q5_1.bin) and drag it into the `mac_voice_whispers/Resources/models/` directory.

3. **Dependencies**
   Ensure you have [HotKey(main)](https://github.com/soffes/HotKey) and [whisper(master)](https://github.com/ggerganov/whisper.cpp) dependencies added.
   Note: The whisper.cpp dependency has been pinned to a specific commit to prevent potential issues caused by future updates.
    
